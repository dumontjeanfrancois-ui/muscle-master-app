"""
Firebase Firestore Structure for Subscription Management

Collection: users/{userId}/subscription/current
Document fields:
- status: string ('free', 'premium', 'trial')
- expiryDate: timestamp (nullable for lifetime)
- platform: string ('android', 'ios', 'stripe', 'web')
- subscriptionId: string (purchase ID from store)
- productId: string (product identifier)
- startDate: timestamp
- updatedAt: timestamp (server timestamp)

Example Document:
{
  "userId": "user123",
  "status": "premium",
  "expiryDate": Timestamp(2025-01-22 00:00:00),
  "platform": "android",
  "subscriptionId": "GPA.1234-5678-9012-34567",
  "productId": "muscle_master_premium_monthly",
  "startDate": Timestamp(2024-12-22 21:00:00),
  "updatedAt": Timestamp(2024-12-22 21:00:00)
}

Security Rules (to add in Firebase Console):

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read their own subscription
    match /users/{userId}/subscription/{document} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if false; // Only Cloud Functions can write
    }
    
    // Public read for other collections (existing rules)
    match /{document=**} {
      allow read, write: if true; // Keep existing permissive rules for development
    }
  }
}

Cloud Function (to implement later):
- verifyAndroidPurchase(purchaseToken, productId)
- verifyIOSPurchase(receiptData, productId)
- handleSubscriptionRenewal(userId, subscriptionData)
- handleSubscriptionCancellation(userId)
"""

# This file documents the Firebase structure
# Actual implementation is in subscription_service.dart
