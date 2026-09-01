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