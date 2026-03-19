require('dotenv').config();
const { onRequest } = require('firebase-functions/v2/https');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const { defineSecret } = require('firebase-functions/params');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

admin.initializeApp();

const SUPPORT_SMTP_USER = defineSecret('SUPPORT_SMTP_USER');
const SUPPORT_SMTP_APP_PASSWORD = defineSecret('SUPPORT_SMTP_APP_PASSWORD');
const SUPPORT_TO_EMAIL = defineSecret('SUPPORT_TO_EMAIL');
const SUPPORT_FROM_NAME = defineSecret('SUPPORT_FROM_NAME');

exports.sendSupportEmail = onRequest(
  {
    secrets: [
      SUPPORT_SMTP_USER,
      SUPPORT_SMTP_APP_PASSWORD,
      SUPPORT_TO_EMAIL,
      SUPPORT_FROM_NAME,
    ],
  },
  async (req, res) => {
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'method_not_allowed' });
    return;
  }

  const smtpUser =
    (SUPPORT_SMTP_USER.value && SUPPORT_SMTP_USER.value()) ||
    process.env.SUPPORT_SMTP_USER;
  const smtpPass =
    (SUPPORT_SMTP_APP_PASSWORD.value && SUPPORT_SMTP_APP_PASSWORD.value()) ||
    process.env.SUPPORT_SMTP_APP_PASSWORD;
  const toEmail =
    (SUPPORT_TO_EMAIL.value && SUPPORT_TO_EMAIL.value()) ||
    process.env.SUPPORT_TO_EMAIL;
  const fromName =
    (SUPPORT_FROM_NAME.value && SUPPORT_FROM_NAME.value()) ||
    process.env.SUPPORT_FROM_NAME ||
    'LaptopHarbor Support';

  if (!smtpUser || !smtpPass || !toEmail) {
    res.status(500).json({ error: 'missing_smtp_config' });
    return;
  }

  const transporter = nodemailer.createTransport({
    host: 'smtp.gmail.com',
    port: 465,
    secure: true,
    auth: { user: smtpUser, pass: smtpPass },
  });

  const authHeader = req.headers.authorization || '';
  const token = authHeader.startsWith('Bearer ')
    ? authHeader.substring('Bearer '.length)
    : '';
  if (!token) {
    res.status(401).json({ error: 'unauthorized' });
    return;
  }

  let decoded;
  try {
    decoded = await admin.auth().verifyIdToken(token);
  } catch (e) {
    res.status(401).json({ error: 'unauthorized' });
    return;
  }

  const title = (req.body?.title || '').toString().trim();
  const subject = (req.body?.subject || '').toString().trim();
  const message = (req.body?.message || '').toString().trim();
  if (!subject || !message) {
    res.status(400).json({ error: 'missing_fields' });
    return;
  }

  const uid = decoded.uid;
  let fullName = (decoded.name || '').toString().trim();
  let email = (decoded.email || '').toString().trim();

  try {
    const userDoc = await admin.firestore().collection('users').doc(uid).get();
    const data = userDoc.exists ? userDoc.data() : null;
    if (data) {
      const first = (data.firstName || data.firstname || '').toString().trim();
      const last = (data.lastName || data.lastname || '').toString().trim();
      const combined = `${first} ${last}`.trim();
      if (combined) fullName = combined;
      const userEmail = (data.email || '').toString().trim();
      if (userEmail) email = userEmail;
    }
  } catch (_) {}

  if (!fullName) fullName = 'Anonymous';

  const mailSubject = `[${title || 'Support'}] ${subject}`;
  const text = `Name: ${fullName}\nEmail: ${email || 'N/A'}\nSubject: ${subject}\n\nMessage:\n${message}\n\nUID: ${uid}`;
  const html = `<p><b>Name:</b> ${escapeHtml(fullName)}</p><p><b>Email:</b> ${escapeHtml(email || 'N/A')}</p><p><b>Subject:</b> ${escapeHtml(subject)}</p><p><b>Message:</b><br/>${escapeHtml(message).replace(/\n/g, '<br/>')}</p><p><b>UID:</b> ${escapeHtml(uid)}</p>`;

  try {
    await transporter.sendMail({
      from: `${fromName} <${smtpUser}>`,
      to: toEmail,
      subject: mailSubject,
      text,
      html,
      replyTo: email || undefined,
    });
    res.status(200).json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: 'send_failed' });
  }
  },
);

function escapeHtml(input) {
  return String(input)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

function normalizeStatus(value) {
  return String(value || '')
    .trim()
    .toLowerCase()
    .replaceAll(' ', '_')
    .replaceAll('-', '_');
}

function lagosDayStamp(date) {
  const shifted = new Date(date.getTime() + 60 * 60 * 1000);
  return Date.UTC(
    shifted.getUTCFullYear(),
    shifted.getUTCMonth(),
    shifted.getUTCDate(),
  );
}

function derivedOrderStatus(createdAt) {
  const now = new Date();
  const diffDays = Math.floor(
    (lagosDayStamp(now) - lagosDayStamp(createdAt)) / (24 * 60 * 60 * 1000),
  );
  if (diffDays <= 0) return 'processing';
  if (diffDays === 1) return 'shipped';
  if (diffDays === 2) return 'in_transit';
  return 'delivered';
}

function money(amount) {
  const n = Number(amount || 0);
  return `₦${n.toFixed(2)}`;
}

function statusLabel(status) {
  const s = normalizeStatus(status);
  if (s === 'processing') return 'PROCESSING';
  if (s === 'shipped') return 'SHIPPED';
  if (s === 'in_transit') return 'IN TRANSIT';
  if (s === 'delivered') return 'DELIVERED';
  return String(status || '').toUpperCase();
}

async function resolveUserEmail(uid, orderData) {
  const direct = String(orderData.userEmail || '').trim();
  if (direct) return direct;
  try {
    const userRecord = await admin.auth().getUser(uid);
    const email = String(userRecord.email || '').trim();
    if (email) return email;
  } catch (_) {}
  try {
    const userDoc = await admin.firestore().collection('users').doc(uid).get();
    const data = userDoc.exists ? userDoc.data() : null;
    const email = String((data && data.email) || '').trim();
    if (email) return email;
  } catch (_) {}
  return '';
}

function buildOrderEmail({ orderId, status, order }) {
  const orderNumber = String(order.orderNumber || '').trim();
  const items = Array.isArray(order.items) ? order.items : [];
  const currency = String(order.currency || 'NGN').trim();

  const itemLines = items
    .filter((i) => i && typeof i === 'object')
    .map((i) => {
      const name = String(i.name || 'Item');
      const quantity = Number(i.quantity || 1);
      const unitPrice = Number(i.unitPrice || 0);
      const lineTotal = Number(i.lineTotal || unitPrice * quantity);
      return `${name} — ${quantity} x ${money(unitPrice)} = ${money(lineTotal)}`;
    })
    .join('\n');

  const subtotal = Number(order.subtotal || 0);
  const shippingCost = Number(order.shippingCost || 0);
  const tax = Number(order.tax || 0);
  const total = Number(order.total || subtotal + shippingCost + tax);

  const subject = `Order Update: ${orderId} (${statusLabel(status)})`;
  const text = [
    `Order ID: ${orderId}`,
    orderNumber ? `Order Number: ${orderNumber}` : null,
    currency ? `Currency: ${currency}` : null,
    '',
    `Status: ${statusLabel(status)}`,
    '',
    'Items:',
    itemLines || 'No items.',
    '',
    `Subtotal: ${money(subtotal)}`,
    `Shipping: ${money(shippingCost)}`,
    `Tax: ${money(tax)}`,
    `Total: ${money(total)}`,
  ]
    .filter(Boolean)
    .join('\n');

  const rowsHtml = items
    .filter((i) => i && typeof i === 'object')
    .map((i) => {
      const name = escapeHtml(String(i.name || 'Item'));
      const quantity = Number(i.quantity || 1);
      const unitPrice = Number(i.unitPrice || 0);
      const lineTotal = Number(i.lineTotal || unitPrice * quantity);
      return `<tr><td style="padding:6px 0;">${name}</td><td style="padding:6px 0; text-align:right;">${quantity}</td><td style="padding:6px 0; text-align:right;">${escapeHtml(
        money(unitPrice),
      )}</td><td style="padding:6px 0; text-align:right;">${escapeHtml(
        money(lineTotal),
      )}</td></tr>`;
    })
    .join('');

  const html = `
    <p><b>Order Update</b></p>
    <p><b>Order ID:</b> ${escapeHtml(orderId)}</p>
    ${
      orderNumber
        ? `<p><b>Order Number:</b> ${escapeHtml(orderNumber)}</p>`
        : ''
    }
    <p><b>Status:</b> ${escapeHtml(statusLabel(status))}</p>
    <h3 style="margin:16px 0 8px;">Items</h3>
    <table style="width:100%; border-collapse:collapse;">
      <thead>
        <tr>
          <th style="text-align:left; padding:6px 0;">Product</th>
          <th style="text-align:right; padding:6px 0;">Qty</th>
          <th style="text-align:right; padding:6px 0;">Unit Price</th>
          <th style="text-align:right; padding:6px 0;">Line Total</th>
        </tr>
      </thead>
      <tbody>
        ${rowsHtml || `<tr><td colspan="4">No items.</td></tr>`}
      </tbody>
    </table>
    <h3 style="margin:16px 0 8px;">Summary</h3>
    <p>Subtotal: <b>${escapeHtml(money(subtotal))}</b></p>
    <p>Shipping: <b>${escapeHtml(money(shippingCost))}</b></p>
    <p>Tax: <b>${escapeHtml(money(tax))}</b></p>
    <p>Total: <b>${escapeHtml(money(total))}</b></p>
  `;

  return { subject, text, html };
}

exports.dailyOrderStatusUpdate = onSchedule(
  {
    schedule: 'every day 08:00',
    timeZone: 'Africa/Lagos',
    secrets: [
      SUPPORT_SMTP_USER,
      SUPPORT_SMTP_APP_PASSWORD,
      SUPPORT_FROM_NAME,
    ],
  },
  async () => {
    const smtpUser =
      (SUPPORT_SMTP_USER.value && SUPPORT_SMTP_USER.value()) ||
      process.env.SUPPORT_SMTP_USER;
    const smtpPass =
      (SUPPORT_SMTP_APP_PASSWORD.value && SUPPORT_SMTP_APP_PASSWORD.value()) ||
      process.env.SUPPORT_SMTP_APP_PASSWORD;
    const fromName =
      (SUPPORT_FROM_NAME.value && SUPPORT_FROM_NAME.value()) ||
      process.env.SUPPORT_FROM_NAME ||
      'LaptopHarbor';
    const hasSmtp = Boolean(smtpUser && smtpPass);

    const transporter = nodemailer.createTransport({
      host: 'smtp.gmail.com',
      port: 465,
      secure: true,
      auth: { user: smtpUser, pass: smtpPass },
    });

    const since = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() - 10 * 24 * 60 * 60 * 1000),
    );

    const snapshot = await admin
      .firestore()
      .collectionGroup('orders')
      .where('createdAt', '>=', since)
      .get();

    const prefsCache = new Map();

    for (const doc of snapshot.docs) {
      const order = doc.data() || {};
      const createdAtTs = order.createdAt;
      const createdAt =
        createdAtTs && typeof createdAtTs.toDate === 'function'
          ? createdAtTs.toDate()
          : null;
      if (!createdAt) continue;

      const uid = doc.ref.parent.parent ? doc.ref.parent.parent.id : '';
      if (!uid) continue;

      const current = normalizeStatus(order.status);
      const derived = derivedOrderStatus(createdAt);
      const shouldUpdate = current !== derived;

      if (shouldUpdate) {
        await doc.ref.set(
          {
            status: derived,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true },
        );
      }

      const lastNotified = normalizeStatus(order.lastStatusNotified);
      if (lastNotified === derived) continue;

      let prefs = prefsCache.get(uid);
      if (!prefs) {
        try {
          const userDoc = await admin.firestore().collection('users').doc(uid).get();
          const data = userDoc.exists ? userDoc.data() : null;
          prefs = {
            app: data ? data.appNotificationsEnabled !== false : true,
            email: data ? data.emailNotificationsEnabled !== false : true,
          };
        } catch (_) {
          prefs = { app: true, email: true };
        }
        prefsCache.set(uid, prefs);
      }

      const shouldEmail = prefs.email === true;
      const shouldApp = prefs.app === true;

      if (shouldEmail && hasSmtp) {
        const email = await resolveUserEmail(uid, order);
        if (email) {
          const { subject, text, html } = buildOrderEmail({
            orderId: doc.id,
            status: derived,
            order,
          });
          try {
            await transporter.sendMail({
              from: `${fromName} <${smtpUser}>`,
              to: email,
              subject,
              text,
              html,
            });
          } catch (_) {}
        }
      }

      if (shouldApp) {
        const title = 'Order update';
        const body = `Your order ${doc.id} is now ${statusLabel(derived)}.`;

        await admin
          .firestore()
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .add({
            type: 'order_status',
            orderId: doc.id,
            status: derived,
            title,
            body,
            read: false,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });

        try {
          const tokensSnap = await admin
            .firestore()
            .collection('users')
            .doc(uid)
            .collection('fcmTokens')
            .get();
          const tokens = tokensSnap.docs
            .map((d) => d.id)
            .filter((t) => t && typeof t === 'string');

          if (tokens.length > 0) {
            const resp = await admin.messaging().sendMulticast({
              tokens,
              notification: { title, body },
              data: {
                type: 'order_status',
                orderId: doc.id,
                status: derived,
              },
            });

            const toDelete = [];
            resp.responses.forEach((r, i) => {
              if (r.success) return;
              const code =
                r.error && r.error.code ? String(r.error.code) : '';
              if (
                code === 'messaging/registration-token-not-registered' ||
                code === 'messaging/invalid-registration-token'
              ) {
                toDelete.push(tokens[i]);
              }
            });
            for (const token of toDelete) {
              await admin
                .firestore()
                .collection('users')
                .doc(uid)
                .collection('fcmTokens')
                .doc(token)
                .delete();
            }
          }
        } catch (_) {}
      }

      await doc.ref.set(
        {
          lastStatusNotified: derived,
          lastStatusNotifiedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    }
  },
);
