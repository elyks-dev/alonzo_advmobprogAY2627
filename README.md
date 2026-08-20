# Kyle Alonzo

# INF 231

# CTADMOBL Advance Mobile Programming

A Flutter project that focuses on advance topics, Covering the Mobile to Web Transactions.

# Lab Activity 1: Discussion
In this activity, the counter uses setState() in a StatefulWidget to manage local or temporary state and rebuild only the widget when its state changes. While the dark mode uses Provider in a StatelessWidget to update the application's theme globally. Provider is more suitable for larger applications because it keeps the code organized and makes state easier to manage.

# Lab Activity 2: Discussion
The app implements a clear three-layer flow: the environment loader provides the runtime HOST (via .env and flutter_dotenv), the service builds requests against that host and performs HTTP I/O, the model parses JSON into typed objects, and the screen calls the service and maps those model objects into widgets. Concretely: ProductScreen requests data from ProductService (which uses the host getter in lib/constants.dart), ProductService performs the GET to $_baseHost/products, decodes the JSON and returns a List<Product> (constructed by Product.fromJson() in lib/models/product_model.dart), and ProductScreen renders loading / error / content states from that list.

The design pattern here emphasizes separation of concerns, lightweight dependency injection, and configuration-as-code: services accept a baseHost override (for tests), configuration lives in .env, and models handle parsing so the UI works with typed data. This yields testability (mock or inject hosts), resiliency (service timeouts + local fallback), and maintainability (UI logic remains presentation-only). Global app state (theme via ThemeModel/Provider) is kept distinct from ephemeral widget state (the counter), showing proper scoping of responsibilities. Overall, the pattern makes it easy to swap endpoints, add mocks for CI, and keep each layer small and verifiable.

# Lab Activity 3: Discussion

The cart feature continues the model-service-screen design used by the product feature. `Cart` and `CartProduct` in `alonzo_advmobprog/lib/models/cart.dart` convert the DummyJSON response into typed Dart objects, while `Product` in `lib/models/product.dart` represents the full product used by the detail view. `CartService` in `lib/services/cart_service.dart` owns HTTP requests and exposes `getCartsByUserId()` for `GET /carts/user/{userId}` and `addToCart()` for `POST /carts/add`. This keeps JSON decoding and endpoint details out of the widgets.

`CartScreen` requests one user's carts, renders the first returned cart, and handles loading, empty, error, and retry states. Each cart product is clickable. When tapped, the screen requests the complete product by ID and navigates to the same `ProductDetailsScreen` class in `lib/screens/detail_screen.dart` used by the Shop feed. This ensures the cart detail view shows the same product description and behavior, while the back button returns to the Cart tab. The detail screen sends the selected product ID and quantity to the add-to-cart endpoint and reports the result to the user.

The updated navigation adds Cart as a separate destination. The chat action is represented by a `FloatingActionButton` on the shared home shell and is hidden when Cart is active, keeping cart actions and global actions visually separate. Provider continues to manage global theme state, while cart loading and quantity selection remain local to their screens.

To retrieve one user's carts, call `GET https://dummyjson.com/carts/user/6`; the response contains a `carts` array and `CartScreen` renders only the first cart for that user. This is different from `getCartById(cartId)`, which calls `GET https://dummyjson.com/carts/{cartId}` when the cart record itself is known. The user endpoint filters by `userId`, while the ID endpoint identifies the cart resource directly. All carts can be retrieved with `GET /carts`. To add one or more products, call `POST https://dummyjson.com/carts/add` with a body such as `{"userId":1,"products":[{"id":144,"quantity":4},{"id":98,"quantity":1}]}`. The service exposes this exact multi-product payload through `addProductsToCart()`; the existing `addToCart()` method remains as a convenient single-product wrapper. Existing carts can be changed with `PUT` or `PATCH /carts/{cartId}` using `merge` and `products`, and removed with `DELETE /carts/{cartId}`. DummyJSON simulates these writes, so a real application would also persist the result on its own backend.