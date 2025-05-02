# Memory Lane - CS 348 Project

**Memory Lane** is a photo-sharing app that lets users relive and explore their past memories based on location. Users can upload photos, tag landmarks, comment, and discover nearby memories from others.

## Features

- Upload photos with location and timestamp
- View photos grouped by landmarks
- Discover nearby photos using geolocation
- Tag people in photos
- Comment on photos
- Google Cloud Storage integration for hosting images
- User authentication and authorization

## Tech Stack

- **Frontend:** Flutter
- **Backend:** Flask (Python)
- **Database:** MySQL
- **Storage:** Google Cloud Storage
- **Deployment:** Google Cloud App Engine

## API Endpoints being used

- GET /api/photos/user/<user_id> – Get user's photos
- POST /api/photos – Upload photo
- GET /api/photos/nearby – Get nearby photos
- DELETE /api/users/<user_id> – Delete user
- GET /api/comments/<photo_id> – Fetch comments
- GET /api/tags/<photo_id> – Fetch tags

## License

For educational purposes only.