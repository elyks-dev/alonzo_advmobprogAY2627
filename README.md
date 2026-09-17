# Kyle Alonzo

# INF 231

# CTADMOBL Advance Mobile Programming

A Flutter project that focuses on advance topics, Covering the Mobile to Web Transactions.

# Lab Activity 1: Discussion
In this activity, the counter uses setState() in a StatefulWidget to manage local or temporary state and rebuild only the widget when its state changes. While the dark mode uses Provider in a StatelessWidget to update the application's theme globally. Provider is more suitable for larger applications because it keeps the code organized and makes state easier to manage.

# Lab Activity 2: Discussion
This activity showed how the app is organized into layers. The environment file gives the app its base URL, the service layer calls the API, the model layer turns JSON into objects, and the screen layer displays the data. This makes the code easier to understand and easier to test. It also keeps the UI simple by separating it from the network and data logic.

# Lab Activity 3: Discussion
This activity added the cart feature using the same pattern as the product feature. The cart model stores product data and totals, the cart service handles API requests, and the cart screen shows the user’s items. The app can load one user’s cart and also let the user tap a product to open the detail page. This keeps the cart logic organized and makes it easier to update quantities and totals.

# Lab Activity 4: Discussion
This activity adds authentication to the shopping app using DummyJSON, Provider, and SharedPreferences. UserService handles login, session storage, and logout, while AuthProvider manages the app’s authentication state through ChangeNotifier. The app uses an authentication gate in main.dart to display the Splash, Sign In, or Home screen based on the user’s login status. After a successful login, the authenticated user’s ID is used to load the correct cart and profile information, and signing out clears the saved session and returns the user to the login screen.

# Lab Activity 5: Discussion
The app uses UserService as the central authentication layer: Firebase handles sign-in, account creation, username updates, password changes, deletion, logout, password resets, session state, and profile retrieval, while DummyJSON remains a fallback for existing sample accounts. During signup, the user enters personal details, email, username, and a validated password; Firebase creates and manages the account. During login, Firebase is attempted first, then DummyJSON if Firebase fails. Firebase improves the app by providing secure authentication, persistent sessions, reauthentication for sensitive actions, password recovery, and managed account security, while the service keeps these operations organized in one reusable class.