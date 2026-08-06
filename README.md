# Kyle Alonzo

# INF 231

# CTADMOBL Advance Mobile Programming

A Flutter project that focuses on advance topics, Covering the Mobile to Web Transactions.

# Lab Activity 1: Discussion
In this activity, the counter uses setState() in a StatefulWidget to manage local or temporary state and rebuild only the widget when its state changes. While the dark mode uses Provider in a StatelessWidget to update the application's theme globally. Provider is more suitable for larger applications because it keeps the code organized and makes state easier to manage.

# Lab Activity 2: Discussion
The app implements a clear three-layer flow: the environment loader provides the runtime HOST (via .env and flutter_dotenv), the service builds requests against that host and performs HTTP I/O, the model parses JSON into typed objects, and the screen calls the service and maps those model objects into widgets. Concretely: ProductScreen requests data from ProductService (which uses the host getter in lib/constants.dart), ProductService performs the GET to $_baseHost/products, decodes the JSON and returns a List<Product> (constructed by Product.fromJson() in lib/models/product_model.dart), and ProductScreen renders loading / error / content states from that list.

The design pattern here emphasizes separation of concerns, lightweight dependency injection, and configuration-as-code: services accept a baseHost override (for tests), configuration lives in .env, and models handle parsing so the UI works with typed data. This yields testability (mock or inject hosts), resiliency (service timeouts + local fallback), and maintainability (UI logic remains presentation-only). Global app state (theme via ThemeModel/Provider) is kept distinct from ephemeral widget state (the counter), showing proper scoping of responsibilities. Overall, the pattern makes it easy to swap endpoints, add mocks for CI, and keep each layer small and verifiable.