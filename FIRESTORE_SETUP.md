# Firestore Setup for Bhajanavali

## Collection Structure

Create a collection named `songs` in your Firestore database with the following document structure:

```json
{
  "title": "Song Title",
  "god": "Krishna",
  "raaga": ["Yaman", "Bhairavi"],
  "lyrics": "Song lyrics here...",
  "audioUrl": "https://example.com/audio.mp3",
  "imageUrl": "https://example.com/image.jpg",
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

## Required Fields

- **title** (string, required): The title of the song
- **god** (string, optional): The deity the song is dedicated to (e.g., "Krishna", "Rama", "Shiva", "Devi")
- **raaga** (array of strings, optional): The musical ragas of the song (e.g., ["Yaman", "Bhairavi"], ["Kalyan", "Todi"])
- **lyrics** (string, optional): The lyrics of the song (supports Kannada, Hindi, and English)
- **audioUrl** (string, optional): URL to the audio file
- **imageUrl** (string, optional): URL to the song's image/thumbnail
- **createdAt** (timestamp, optional): When the song was added to the collection

## Example Documents

### Document 1 (English)
```json
{
  "title": "Hare Krishna Hare Rama",
  "god": "Krishna",
  "raaga": ["Yaman", "Bhairavi"],
  "lyrics": "Hare Krishna Hare Krishna, Krishna Krishna Hare Hare\nHare Rama Hare Rama, Rama Rama Hare Hare",
  "audioUrl": "https://storage.googleapis.com/bhajanavali-audio/hare-krishna.mp3",
  "imageUrl": "https://storage.googleapis.com/bhajanavali-images/krishna.jpg",
  "createdAt": "2024-01-15T10:30:00.000Z"
}
```

### Document 2 (Hindi)
```json
{
  "title": "Jai Shri Ram",
  "god": "Rama",
  "raaga": ["Bhairavi", "Kalyan"],
  "lyrics": "जय श्री राम, जय श्री राम\nराम राम जय जय राम",
  "audioUrl": "https://storage.googleapis.com/bhajanavali-audio/jai-shri-ram.mp3",
  "imageUrl": "https://storage.googleapis.com/bhajanavali-images/rama.jpg",
  "createdAt": "2024-01-16T14:20:00.000Z"
}
```

### Document 3 (Kannada)
```json
{
  "title": "ಕೃಷ್ಣ ನಮನ",
  "god": "Krishna",
  "raaga": ["Yaman"],
  "lyrics": "ಕೃಷ್ಣ ಕೃಷ್ಣ ಮುಕುಂದ ಮುರಾರಿ\nಗೋವಿಂದ ಗೋಪಾಲ ಕೃಷ್ಣ",
  "audioUrl": "https://storage.googleapis.com/bhajanavali-audio/krishna-naman.mp3",
  "imageUrl": "https://storage.googleapis.com/bhajanavali-images/krishna-kannada.jpg",
  "createdAt": "2024-01-17T12:00:00.000Z"
}
```

## Firestore Rules

Make sure your Firestore security rules allow read and write access to the songs collection:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /songs/{document} {
      allow read: if true;  // Allow anyone to read songs
      allow create, update: if true;  // Allow anyone to create and update songs
      allow delete: if false; // Prevent deletion for safety
    }
  }
}
```

**Note**: For production apps, you should implement proper authentication and authorization. These rules allow anyone to add/edit songs, which is fine for development but should be restricted in production.

## Testing the Connection

1. Make sure your Firebase project is properly configured
2. Add some test documents to the `songs` collection
3. Run the app and navigate to the song listing page
4. You should see the songs displayed in a list
5. Try filtering by god and raga using the dropdown menus

## Troubleshooting

- If you don't see any songs, check that:
  - Your Firebase configuration is correct
  - The `songs` collection exists
  - Documents have the correct field names
  - Firestore rules allow read access
- If you see errors, check the console for specific error messages
