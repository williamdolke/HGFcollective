# Portfolio Management

## Implementation

Artists and artworks can be created, edited and deleted by administrators via a toolbar icon that is only presented to admin users.

## Security

The option to manage the portfolio administrators is only presented users that are 'signed in as admin'. This is really just a check for a UserDefaults value so is far from enough to be considered secure. 

The true means of securing this system is through the user of Firebase Authentication. The administrators sign in using email and password and rules are setup in the Firebase Database that control read and write access to the database. Write permissions are limited to the 'artists' collection of the database such that only these administrators can add, edit or delete these documents. Suppose that another user worked out how to present the portfolio management menu, they would not be able to make changes to the database without exploiting a security flaw in the database rules.

## Limitations

Currently is not possible to change the names of artworks or artists. It is also not possible to edit the photos of artworks. These require future work to implement.
