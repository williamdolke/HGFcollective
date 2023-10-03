# Notifications

## Notifications are sent to clients in the following scenarios:

- Chat messages/images are sent.
- The user has not opened the app for two weeks.

Scenarios planned for the future:

- Recently viewed artworks. This would be scheduled locally by the client.
- New additions (artists and artworks). This type of notification would be sent remotely.

## Implementation

### When chat messages/images are sent
Permission to send notifications is requested when the app is first launched.

A javascript cloud function is deployed via Firebase Cloud Messaging (FCM). This script listens for new chat messages from all users in the Firestore Database. It then determines where to send notification(s) based on who sent the message and what the notification should display based on whether the message contains text or an image.

The script is capable of handling the case where there are multiple administrator accounts with FCM tokens, which means that all administrators will receive notifications for a single chat message sent by a user/customer.

When chat message notifications are tapped by the user, the chat tab will open.

### When the user has not opened the app for two weeks
Local notifications are scheduled when the app becomes active for two weeks in the future and any outstanding notifications with the same identifier are cancelled. If the app becomes active in the following two weeks the scheduled notification is cancelled and a new one is scheduled, otherwise the notification will be triggered after two weeks of inactivity and prompt the user to open the app.

## Limitations

When the chat message sent is an image, the notification displayed doesn't display the image that was sent currently. This requires future work to implement.

## Useful documentation

https://firebase.google.com/docs/cloud-messaging/http-server-ref
