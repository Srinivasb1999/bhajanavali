# Firestore Security Rules Setup

## Current Issue
Your app is getting a permission error: `[cloud_firestore/permission-denied] The caller does not have permission to execute the specified operation.`

This means your Firestore security rules are not allowing read access to the `songs` collection.

## How to Fix This

### Step 1: Go to Firebase Console
1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. In the left sidebar, click on **Firestore Database**
4. Click on the **Rules** tab

### Step 2: Update Security Rules
Replace your current rules with these:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read access to songs collection for everyone
    match /songs/{document} {
      allow read: if true;
      allow write: if false; // Only allow writes from authenticated users or admin
    }
    
    // Default rule - deny all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### Step 3: Publish Rules
1. Click the **Publish** button
2. Wait for the rules to be deployed (usually takes a few seconds)

### Step 4: Test the App
1. Restart your Flutter app
2. Navigate to the song listing page
3. You should now see your songs (or an empty state if no songs exist)

## Alternative Rules (More Secure)

If you want more security, you can use these rules instead:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read access to songs collection
    match /songs/{document} {
      allow read: if true;
      allow write: if request.auth != null; // Only authenticated users can write
    }
    
    // Allow read access to other collections if needed
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

## Troubleshooting

### If you still get permission errors:

1. **Check Collection Name**: Make sure your collection is named exactly `songs` (lowercase)
2. **Wait for Rules to Deploy**: Rules can take up to 1 minute to fully deploy
3. **Check Firebase Configuration**: Ensure your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are up to date
4. **Clear App Cache**: Try uninstalling and reinstalling the app

### If you want to test with sample data:

Add this test document to your `songs` collection:

```json
{
  "title": "Test Song",
  "god": "Krishna",
  "raaga": ["Yaman"],
  "lyrics": "This is a test song for Bhajanavali app.",
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

## Security Best Practices

- **For Development**: Use the simple rules above to get started
- **For Production**: Consider implementing user authentication and more restrictive rules
- **Regular Reviews**: Review your security rules periodically
- **Testing**: Always test your rules in the Firebase Console Rules Playground

## Next Steps

Once you've updated the security rules:
1. The app should connect successfully to Firestore
2. You'll see your songs in the listing (or an empty state)
3. The filtering by god and raaga will work
4. You can add more songs through the Firebase Console

Let me know if you need help with any of these steps!
