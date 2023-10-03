# Chat Messaging System

## Implementation
Messages are stored in the Firestore database, excluding any images that have been sent which are stored in Firebase Storeage.

## Message content

Sending a message consists of atleast two seperate updates. An update to the document 

User document:

- id: The customer's anonymous authentication UID.
- fcmToken of the customer: For sending notifications to them.
- isCustomer: Whether the person who sent the last message was the customer or the admin.
- latestTimestamp: The timestamp of the latest message.
- messagePreview: The latest message or preview of it if it is over a certain length
- read: Whether the message has been read. For the case when admins receive messages this means that one admin has read the message.
- sender: The UID of the person who sent the message.
- preferredName: The admins can set a name for each customer to make it easier to identify. different users. The preferredName replaces the anonymous UID in any UI, making it easier for admins to remember who conversations are with and making the UI more clean.

Message document:

- id: Unique identifier of the message.
- content: The content of the message, either the message text or a url of an image in Firebase Storage.
- type: Whether text was sent or an image.
- timestamp: Timestamp that the message was sent.
- read: Whether the message has been read.
- isCustomer: Whether the person who sent the message was the customer or the admin.

Image update:
If the user sends an image and a message at the same time this will consist of an two message updates, a user document update and storing the image in Firebase Storage. The image is uploaded to Storage and the URL of the file location is stored in the content field of the message document.


## Security


## Limitations
Only one image can be sent at one time with the current implementation. The content field has a limited length for text messages although it is not expected that users will hit it.
