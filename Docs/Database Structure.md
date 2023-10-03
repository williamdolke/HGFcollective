# Database Structure

## Structure
The Firestore database has 4 collections:

- users: Contains all information about anonymously authenticated users and their chat messages.
- artists: Contains all information about the portfolio of artists and artworks, including URLs of images which may or may not be stored in Firebase Storage.
- enquiries: Contains the email addresses used in for email enquiries and can override the name and image used in the chat tab.
- admin: Contains administrator Firebase Cloud Messaging (FCM) tokens. This is used by the Firebase Cloud Messaging sendNotification function to send notifications to multiple admins.
