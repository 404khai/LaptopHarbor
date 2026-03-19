# LaptopHarbor

LaptopHarbor is a Flutter + Firebase e-commerce mobile app for browsing, reviewing, and purchasing laptops and related accessories. It includes authentication, product listings and search, wishlists, reviews, cart and checkout with Paystack, saved shipping addresses, order history and tracking, support messaging, and scheduled order status updates via email + in-app + FCM push notifications.

## Contents

- Overview
- Features
- Tech Stack
- Project Structure
- Data Model (Firestore)
- Environment Variables
- Firebase Setup
- Android Setup (SHA keys, notifications)
- Running the App
- Cloud Functions (Support email + daily order status updates)
- Payment (Paystack)
- Media Upload (Cloudinary)
- Troubleshooting

## Overview

The app is designed around a standard commerce flow:

1. User signs up / signs in
2. User browses products (with categories and search)
3. User adds items to cart, manages quantities
4. User selects a shipping address (saved addresses per user)
5. User reviews order and pays with Paystack
6. App creates an immutable “order snapshot” (items, totals, shipping) and clears the cart
7. User sees order confirmation and can view order details and tracking
8. A scheduled backend job updates order status daily and notifies the user (email + in-app + push)

## Features

### Authentication

- Email/password sign up and sign in
- Forgot password flow includes a phone OTP UI flow using Firebase Phone Auth (SMS)
  - Note: Phone Auth SMS sending may require enabling billing (Blaze) depending on region/quota
- Profile screen with user info and navigation to orders, addresses, wishlist, reviews, support

### Products

- Product browsing by category (e.g., Laptop, Mouse, Keyboard, Charger, Laptop Bag)
- Product detail view with images, specifications, and pricing
- Search screen with filtering and price range selection

### Wishlist

- Add/remove products to wishlist (per user)
- Category chip filters with counts (e.g., Laptop (5))
- Inline search within wishlist (no separate search page)

### Reviews

- Users can submit rating + text review per product
- Reviews are stored per product and also mirrored per user so they’re visible under the user in Firestore:
  - `products/{productId}/reviews/{userId}`
  - `users/{userId}/reviews/{productId}`
- “My Reviews” screen lists a user’s reviews with product image/name, stars, and review text
  - Includes a backfill step to mirror legacy product reviews into `users/{uid}/reviews`

### Cart

- Cart stored per user in Firestore: `users/{uid}/cart`
- Quantity update and remove item support
- Order summary shows consistent totals:
  - Shipping: ₦5000
  - Tax: ₦2000

### Shipping Addresses

- Firestore-backed saved addresses per user: `users/{uid}/addresses`
- Create/edit/delete addresses, set default
- Shipping screen shows default or selected address and passes selected address into checkout

### Checkout + Paystack Payment

- Order review screen reads cart items and shipping address
- Paystack payment via `flutter_paystack_plus`
- On payment success:
  - Creates an order document in `users/{uid}/orders` (snapshot of cart + totals + shipping)
  - Clears the cart
  - Navigates to Order Confirmation for the created order

### Orders + Tracking

- My Orders screen reads orders from Firestore and provides chip filters with counts:
  - All / Active / Completed / Cancelled
- Order Details screen loads order snapshot (items, totals, shipping address)
- Package Tracking screen reads the same order and displays:
  - Delivery address from the order’s selected shipping address
  - ETA derived from the order placement time (+2 hours window) and the 3rd day date
- Order statuses are derived daily based on `createdAt`:
  - processing → shipped → in_transit → delivered

### Notifications (In-app + Push)

- In-app notifications stored under: `users/{uid}/notifications`
- Notifications screen lists notifications and marks them read on tap
- FCM push notifications are sent for daily order status updates
- Settings toggles stored on the user document:
  - `appNotificationsEnabled`
  - `emailNotificationsEnabled`
  - Email toggle affects order-status emails only (not payment-success messaging)

### Support

- Support screen submits a ticket to Firestore: `users/{uid}/supportTickets`
- Also sends an email through Firebase Cloud Functions + SMTP (Blaze-ready)

## Tech Stack

- Flutter (Dart)
- Firebase
  - Authentication (email/password + phone OTP)
  - Firestore (users, wishlist, cart, orders, addresses, notifications, reviews)
  - Cloud Functions (Support SMTP, scheduled order updates, FCM push)
- Paystack (payments)
- Cloudinary (profile photo upload)
- FCM (push notifications)

## Project Structure

Common folders:

- `lib/screens/` UI screens (home, product details, wishlist, cart, shipping, order review, orders, tracking, profile, settings, support, notifications)
- `lib/providers/` app state (AuthProvider, CartProvider, WishlistProvider, ProductProvider)
- `lib/services/` external integrations (Cloudinary upload, support service)
- `functions/` Firebase Cloud Functions (Node.js) for SMTP + scheduled status updates

## Data Model (Firestore)

The app organizes data primarily under `users/{uid}` and `products/{productId}`.

### User Profile

- `users/{uid}`
  - `firstName`, `lastName`, `displayName`, `email`
  - `photoUrl`
  - `phone`, `phoneIso`, `phoneNational`
  - `appNotificationsEnabled` (bool)
  - `emailNotificationsEnabled` (bool)

### Wishlist

- `users/{uid}/wishlist/{wishlistItemId}`
  - `productId`
  - `title`, `image`, `price`
  - `category` (backfilled if missing)

### Cart

- `users/{uid}/cart/{productId}`
  - `name`, `image`, `price`
  - `quantity`

### Addresses

- `users/{uid}/addresses/{addressId}`
  - `label`, `country`, `state`, `city`, `zipCode`, `street` (if present)
  - `isDefault` (bool)

### Orders

- `users/{uid}/orders/{orderId}`
  - `orderNumber`
  - `paystackReference`
  - `currency`
  - `items`: array of snapshots:
    - `productId`, `name`, `image`, `quantity`, `unitPrice`, `lineTotal`
  - `shippingAddressId`
  - `shippingAddress` (snapshot of address doc)
  - Totals:
    - `subtotal`
    - `shippingCost` (₦5000)
    - `tax` (₦2000)
    - `total`
  - Status:
    - `status` (processing/shipped/in_transit/delivered)
    - `lastStatusNotified`, `lastStatusNotifiedAt`
  - Delivery estimate:
    - `estimatedDeliveryStart`
    - `estimatedDeliveryEnd`
  - `createdAt`, `updatedAt`

### Reviews

- `products/{productId}/reviews/{userId}` (per-product listing)
- `users/{uid}/reviews/{productId}` (user’s review history)

### Notifications

- `users/{uid}/notifications/{notificationId}`
  - `type` (e.g., `order_status`)
  - `orderId`, `status`
  - `title`, `body`
  - `read` (bool)
  - `createdAt`

### FCM Tokens

- `users/{uid}/fcmTokens/{token}`
  - `token`
  - `platform` (e.g., android)
  - `createdAt`, `updatedAt`

## Environment Variables

This project uses `.env` in the Flutter app (loaded by `flutter_dotenv`).

Copy `.env.example` to `.env` and fill values.

Keys used:

- `PAYSTACK_PUBLIC_KEY`
- `PAYSTACK_SECRET_KEY`
- `PAYSTACK_CALLBACK_URL`
- `CLOUDINARY_CLOUD_NAME`
- `CLOUDINARY_UPLOAD_PRESET`
- `CLOUDINARY_FOLDER`
- `SUPPORT_TO_EMAIL`
- `SUPPORT_FUNCTION_URL` (HTTPS URL of deployed `sendSupportEmail` function)

## Firebase Setup

1. Create a Firebase project
2. Add Android app in Firebase Console (use the same `applicationId` as Android)
3. Download `google-services.json` and place it in:
   - `android/app/google-services.json`
4. Enable providers:
   - Authentication → Email/Password
   - Authentication → Phone (for OTP)
5. Firestore:
   - Create database in production or test mode
   - Configure security rules appropriate for per-user data

## Android Setup (SHA keys + notifications)

### Debug SHA-1 / SHA-256

Run from the Android folder:

```powershell
cd android
.\gradlew signingReport
```

Copy the SHA-1 and SHA-256 into Firebase Console → Project Settings → Your Android App.

### Notifications permission (Android 13+)

Android 13+ requires `POST_NOTIFICATIONS` permission. This project includes it in `AndroidManifest.xml`, and the app requests permission when enabling App Notifications in Settings.

## Running the App

```powershell
flutter pub get
flutter run
```

## Cloud Functions (Support SMTP + daily order updates)

The `functions/` directory contains Firebase Functions v2:

- `sendSupportEmail` (HTTP) — sends support email via SMTP
- `dailyOrderStatusUpdate` (Scheduler) — updates order status daily and notifies users by:
  - Email (if `emailNotificationsEnabled == true`)
  - In-app notifications + FCM push (if `appNotificationsEnabled == true`)

### Required Function Secrets (Blaze)

Set these secrets in Firebase Functions:

- `SUPPORT_SMTP_USER` (e.g., Gmail address)
- `SUPPORT_SMTP_APP_PASSWORD` (Gmail app password)
- `SUPPORT_TO_EMAIL` (support inbox recipient)
- `SUPPORT_FROM_NAME` (display name used as sender)

After deployment, set `SUPPORT_FUNCTION_URL` in the app `.env` to the deployed URL for `sendSupportEmail`.

## Payment (Paystack)

Paystack checkout is initiated from the Order Review screen.

Required `.env` keys:

- `PAYSTACK_PUBLIC_KEY`
- `PAYSTACK_SECRET_KEY`
- `PAYSTACK_CALLBACK_URL`

## Media Upload (Cloudinary)

Profile pictures use Cloudinary unsigned uploads.

Required `.env` keys:

- `CLOUDINARY_CLOUD_NAME`
- `CLOUDINARY_UPLOAD_PRESET`
- `CLOUDINARY_FOLDER`

## Troubleshooting

### Phone OTP fails with BILLING_NOT_ENABLED

Firebase Phone Auth SMS may require enabling billing. For testing without billing:

- Firebase Console → Authentication → Phone → add Test phone numbers + test code.

### FCM push not received

- Ensure App Notifications is enabled in Settings (stores `appNotificationsEnabled`)
- Ensure the app has notification permission (Android 13+)
- Ensure tokens exist under `users/{uid}/fcmTokens`
- Ensure your scheduler function is deployed and running
