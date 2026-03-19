require('dotenv').config();
const functions = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

admin.initializeApp();

const smtpUser = process.env.SUPPORT_SMTP_USER;
const smtpPass = process.env.SUPPORT_SMTP_APP_PASSWORD;
const toEmail = process.env.SUPPORT_TO_EMAIL;
const fromName = process.env.SUPPORT_FROM_NAME || 'LaptopHarbor Support';

const transporter =
  smtpUser && smtpPass
    ? nodemailer.createTransport({
        host: 'smtp.gmail.com',
        port: 465,
        secure: true,
        auth: { user: smtpUser, pass: smtpPass },
      })
    : null;

exports.sendSupportEmail = functions.onRequest(async (req, res) => {
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'method_not_allowed' });
    return;
  }

  if (!transporter || !toEmail || !smtpUser) {
    res.status(500).json({ error: 'missing_smtp_config' });
    return;
  }

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
});

function escapeHtml(input) {
  return String(input)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

