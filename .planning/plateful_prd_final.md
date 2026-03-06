# Plateful — PRD v2 Final
### POC · 3-Day Sprint · Flutter 3.28.8 · Riverpod · Clean Arch (Lite)

---

## 1. App Context

Plateful is a **closed campus/hospital food ordering app**. All dining locations are within the same building complex (0.1–0.7 miles radius). Users walk to pick up — no delivery. Users are students, staff, patients, visitors.

**Platform scope (POC): iOS + Android only.** Web/Desktop are out-of-scope for all phases unless explicitly changed.

---

## 2. Tech Stack

| Concern | Package |
|---|---|
| State management | `flutter_riverpod` |
| Navigation | `go_router` |
| Local storage | `hive_flutter` |
| Map | `flutter_map` + `latlong2` |
| Location | `geolocator` + `permission_handler` |
| Image | `cached_network_image` |
| Responsive | `flutter_screenutil` (base: 390×844, iPhone 14) |
| Firebase | `firebase_core`, `firebase_auth` (wired later) |

---

## 3. Design System

| Token | Value |
|---|---|
| Primary | `#667eea` |
| Primary Dark | `#5568d3` |
| Primary Gradient | `135deg → #667eea to #764ba2` |
| Background | `#f5f5f5` |
| Surface | `#ffffff` |
| Text Primary | `#222222` |
| Text Secondary | `#666666` |
| Text Hint | `#999999` |
| Border | `#e0e0e0` |
| Success | `#4CAF50` |
| Error | `#F44336` |
| Warning | `#FF9800` |
| Card radius | `12px` |
| Chip radius | `20px` |
| Button radius | `12px` |
| Card shadow | `0 2px 10px rgba(0,0,0,0.05)` |

**AppTheme lives in:** `lib/src/app/themes/app_theme.dart`
Exports: `AppColors`, `AppTextStyles`, `AppSizes`, `AppTheme.light()`

---

## 4. Project Structure

```
lib/
├── main.dart
└── src/
    ├── app/
    │   └── themes/
    │       ├── app_colors.dart
    │       ├── app_text_styles.dart
    │       ├── app_sizes.dart
    │       └── app_theme.dart
    ├── common/
    │   ├── components/
    │   │   ├── app_bottom_nav_bar.dart
    │   │   ├── app_button.dart
    │   │   ├── app_chip.dart
    │   │   ├── app_search_bar.dart
    │   │   ├── restaurant_card.dart
    │   │   ├── menu_item_card.dart
    │   │   ├── star_rating_row.dart
    │   │   └── cart_fab.dart
    │   └── domain/
    │       └── entities/
    │           ├── restaurant.dart
    │           ├── menu_item.dart
    │           ├── cart_item.dart
    │           ├── order.dart
    │           └── feedback_model.dart
    ├── features/
    │   ├── auth/login/
    │   ├── home/
    │   ├── restaurant_menu/
    │   ├── cart/
    │   ├── checkout/
    │   ├── orders/
    │   ├── feedback/
    │   └── profile/
    ├── routing/
    │   ├── routes.dart
    │   ├── route_enums.dart
    │   └── shell_scaffold.dart
    └── utils/
        ├── extensions/
        │   ├── context_ext.dart
        │   └── string_ext.dart
        └── dummy_data.dart
```

Each feature follows:
```
<feature>/
├── <feature>_controller.dart   # Riverpod Notifier
├── <feature>_state.dart        # plain Dart state class
├── <feature>_screen.dart       # ConsumerWidget root
└── widgets/                    # feature-scoped sub-widgets
```

---

## 5. Route Map

```
/splash
/login

/shell                          (StatefulShellRoute — BottomNav wrapper)
  /shell/home
  /shell/orders
  /shell/feedback
  /shell/profile

/restaurant/:restaurantId       (push)
/cart                           (push)
/checkout                       (push)
/feedback/:orderId              (push)
```

### Navigation Flow

```
SplashScreen (1.5s delay)
  └──► ShellScaffold
         ├── [Tab 0] HomeScreen
         │     ├── List view → tap RestaurantCard
         │     │     └── push /restaurant/:id → RestaurantMenuScreen
         │     │           ├── tap item → ItemDetailSheet (bottom sheet)
         │     │           │     └── Add to Cart → CartNotifier.addItem()
         │     │           └── tap CartFAB → push /cart → CartScreen
         │     │                 └── Proceed → push /checkout → CheckoutScreen
         │     │                       └── Place Order → OrderSuccessDialog
         │     │                             └── Done → go /shell/orders
         │     └── Map view → tap pin → MapPinBottomSheet (bottom sheet)
         │           └── View Menu → push /restaurant/:id
         │
         ├── [Tab 1] OrdersScreen
         │     └── tap OrderCard → OrderDetailSheet (bottom sheet)
         │           └── Leave Feedback → push /feedback/:orderId
         │
         ├── [Tab 2] FeedbackTabScreen
         │     └── tap UnratedOrderCard → push /feedback/:orderId
         │           └── Submit → pop back
         │
         └── [Tab 3] ProfileScreen
```

### Data Passed Between Screens

| From | To | How |
|---|---|---|
| Home / MapPin | RestaurantMenuScreen | `restaurantId` route param |
| RestaurantMenuScreen | ItemDetailSheet | `MenuItem` object in-memory |
| Any screen | CartScreen | `cartProvider` global |
| CartScreen | CheckoutScreen | `cartProvider` global |
| CheckoutScreen | OrdersScreen | `ordersProvider` global, tab switch |
| Orders / FeedbackTab | FeedbackScreen | `orderId` route param |

---

## 6. Screen Specifications

---

### 6.1 SplashScreen `/splash`
- Gradient bg + centered app name + logo emoji 🍽️
- 1.5s delay → always `context.go('/shell/home')` for POC
- No controller needed — `StatefulWidget` + `initState` timer

---

### 6.2 LoginScreen `/login`
**State:**
```dart
class LoginState {
  final String email;
  final String password;
  final bool isLoading;
  final String? errorMessage;
  final bool passwordVisible;
}
```
**Controller methods:** `updateEmail`, `updatePassword`, `togglePasswordVisibility`, `signIn` (stub), `continueAsGuest → context.go('/shell/home')`

**UI:** gradient header · email field · password field (toggle visibility) · Sign In button · "Continue as Guest" text button · Google Sign-In outlined button (`onPressed: null`, disabled)

---

### 6.3 ShellScaffold
- `StatefulShellRoute` in go_router
- `AppBottomNavBar` 4 tabs: Home · Orders · Feedback · Profile
- Tab switching uses `context.go()` — NOT push (preserves scroll/state per tab)

---

### 6.4 HomeScreen `/shell/home`
**State:**
```dart
class HomeState {
  final List<Restaurant> allRestaurants;
  final List<Restaurant> filteredList;
  final String searchQuery;
  final String selectedFilter;   // 'All' | 'Breakfast' | 'Lunch' | ...
  final int selectedTabIndex;    // 0=List, 1=Map
  final bool isLoading;
}
```
**Controller methods:** `loadRestaurants()`, `onSearchChanged(String)`, `onFilterSelected(String)`, `onTabChanged(int)`

**Layout:**
```
┌─────────────────────────────────────┐
│ HEADER (gradient)                   │
│ "Good morning 👋"                   │
│ [Search: "What are you craving?"]   │
│ [List] [Map] toggle                 │
├─────────────────────────────────────┤
│ Filter chips (scrollable):          │
│ All · Breakfast · Lunch · Dinner    │
│ · Snacks · Beverages · Vegan        │
│ · Halal · Gluten-Free               │
├─────────────────────────────────────┤
│ TabBarView:                         │
│   [0] RestaurantListView            │
│   [1] RestaurantMapView             │
└─────────────────────────────────────┘
```

**RestaurantCard fields:** emoji placeholder · name · cuisine type · Open/Closed/Busy badge · distance · rating · hours
→ tap: `context.push('/restaurant/${restaurant.id}')`

**RestaurantMapView:**
- `flutter_map` OSM tiles
- On init: `geolocator.getCurrentPosition()`
- **Permission granted:** center on user location, show blue dot
- **Permission denied:** center on centroid of all restaurant coords (`avgLat`, `avgLng`), show banner "Enable location for better experience"
- Restaurant pins: offset from user coords at runtime → `userLat + offsets[i]`, `userLng + offsets[i]`
  - offsets (lat): `[0.002, -0.003, 0.005, -0.004, 0.007, -0.001]`
  - offsets (lng): `[-0.003, 0.004, -0.002, 0.006, -0.005, 0.003]`
- Tap pin → `MapPinBottomSheet`: name · status · distance · rating · hours · "View Menu" button
- "My Location" FAB bottom-right → re-center map

---

### 6.5 RestaurantMenuScreen `/restaurant/:restaurantId`
**Merged restaurant detail + menu in one screen.**

**State:**
```dart
class RestaurantMenuState {
  final Restaurant? restaurant;
  final List<MenuItem> allItems;
  final List<MenuItem> filteredItems;
  final String selectedCategory;   // 'All' | 'Breakfast' | ...
  final bool isLoading;
}
```
**Controller:** family provider `restaurantMenuProvider(restaurantId)` · `loadData()` · `onCategoryChanged(String)`

**Layout:**
```
CustomScrollView
├── SliverAppBar (expandedHeight: 200, pinned)
│   ├── expanded: gradient bg · big emoji · restaurant name
│   │   stats row: ⭐rating · 🕐hours · 📍distance · status badge
│   └── collapsed: AppBar with restaurant name + back button
├── SliverPersistentHeader (pinned)
│   └── category tab bar (scrollable): All · Breakfast · Lunch · ...
└── SliverList
    └── MenuItemCard per item:
        ├── left: 90×90 emoji container (colored bg per category)
        ├── middle: name · description (2 lines max) · dietary badges
        ├── bottom-left: Xcal · Xg protein
        ├── bottom-right: $price · [+] button
        └── tap item (not [+]) → ItemDetailSheet
            tap [+] → CartNotifier.addItem(), show snackbar
```

**ItemDetailSheet** (`showModalBottomSheet isScrollControlled: true`):
```
drag handle
emoji 120×120 centered
name (bold 20px) · description
────────────────
Nutrition: calories · carbs · protein · fat (4 boxes)
────────────────
Allergens: [chip][chip]
Dietary:   🌱 Vegan  🌾 GF  🌶 Spicy
────────────────
[−] qty [+]          $price
[Add to Cart] primary button
```
Add to Cart → if different restaurant in cart → show conflict `AlertDialog` → "Clear & Add" calls `CartNotifier.clearAndAdd()`

**CartFAB** (bottom of screen, `Positioned`):
- visible when `cartState.items.isNotEmpty`
- shows: 🛒 · item count badge · total price
- tap → `context.push('/cart')`

---

### 6.6 CartScreen `/cart`
**State:**
```dart
class CartState {
  final List<CartItem> items;
  final String? restaurantId;
  final String? restaurantName;
  // computed: subtotal, tax (8%), total
}
```
**CartNotifier (global):** `addItem`, `clearAndAdd`, `removeItem`, `updateQuantity`, `clearCart`
Hive persistence: serialize on every mutation, rehydrate on init from box `'cart'`

**Layout:**
- Empty: large emoji + "Your cart is empty" + "Browse Restaurants" button → `context.go('/shell/home')`
- Filled: `CartItemTile` list (emoji · name · restaurant name · qty stepper · price · delete) + `CartSummaryCard` (subtotal · tax · total · "Proceed to Checkout")

---

### 6.7 CheckoutScreen `/checkout`
**State:**
```dart
class CheckoutState {
  final bool isNow;
  final DateTime? scheduledTime;
  final bool isLoading;
  final bool orderPlaced;
}
```
**`placeOrder()`:** creates `Order` → `OrdersNotifier.addOrder()` → `CartNotifier.clearCart()` → sets `orderPlaced = true`

**Layout:** order summary (read-only) · pickup location (restaurant name, read-only) · pickup time toggle (Now / Schedule) · price summary · "Place Order" button

**OrderSuccessDialog:**
```
✅ (64px)
Order Placed!
Est. ready: 15–20 minutes
[Track Order] → context.go('/shell/orders')
```

---

### 6.8 OrdersScreen `/shell/orders`
**State:**
```dart
class OrdersState {
  final List<Order> orders;   // newest first
  final bool isLoading;
}
```
**OrdersNotifier (global):** `loadOrders()` (Hive + seeded), `addOrder()`, `markAsRated(String orderId)`

**Layout:** `OrderCard` list (restaurant · date · items summary · total · status badge)
Tap → `OrderDetailSheet` (bottom sheet):
```
restaurant name · Order #XXXX · date
────────────────
item list with qty + price
────────────────
subtotal · tax · total
status badge
[Leave Feedback] — only if completed && !isRated
```
"Leave Feedback" → `context.push('/feedback/${order.id}')`

---

### 6.9 FeedbackTabScreen `/shell/feedback`
- Derives from `ordersProvider` — filters `completed && !isRated`
- Empty state: "All caught up! No pending reviews 🎉"
- `UnratedOrderCard`: restaurant · date · items summary · "Rate Now →"
- Tap → `context.push('/feedback/${order.id}')`

---

### 6.10 FeedbackScreen `/feedback/:orderId`
**State:**
```dart
class FeedbackState {
  final Order? order;
  final int overallRating;
  final int foodQualityRating;
  final int portionSizeRating;
  final int serviceSpeedRating;
  final String comment;
  final bool isSubmitting;
  final bool submitted;
  // computed: bool canSubmit = all 4 ratings > 0
}
```
**Controller:** family `feedbackProvider(orderId)` · `loadOrder()` · `setRating(dim, value)` · `setComment()` · `submit()` → saves to Hive `'feedbacks'` → `OrdersNotifier.markAsRated()`

**Layout:**
```
OrderInfoCard (restaurant · order# · date · items)
────────────────
Overall Experience      ★★★★★
Food Quality            ★★★★★
Portion Size            ★★★★★
Service Speed           ★★★★★
────────────────
[Tell us more... textarea 500 chars]
────────────────
(sticky) [Submit Feedback] — disabled until all 4 rated
```
Star UX: inactive = greyscale 30% opacity · selected = full color + scale pop · rating text below: "Poor 😞 / Fair 😐 / Good 🙂 / Great 😊 / Excellent! 🤩"

Submit → SuccessModal → pop back

---

### 6.11 ProfileScreen `/shell/profile`
**State:**
```dart
class ProfileState {
  final Set<String> selectedDietaryPrefs;
  final String allergiesText;
}
```
Persisted to Hive box `'profile'`

**Layout:** avatar (initials placeholder) · "Guest User" · dietary preference chips (Vegan · Vegetarian · Gluten-Free · Halal · No Spicy · Dairy-Free) · allergies text field · Order History tile → `/shell/orders` · Sign Out tile (stub dialog)

---

## 7. Data Models

```dart
class Restaurant {
  final String id, name, cuisine, emoji, hours, status;
  final double rating, lat, lng, distanceMiles;
  final List<String> tags;
}

class MenuItem {
  final String id, restaurantId, name, description, emoji, category;
  final double price, calories, carbs, protein, fat;
  final List<String> allergens, dietaryTags;
}

class CartItem {
  final MenuItem item;
  final int quantity;
}

class Order {
  final String id, restaurantId, restaurantName, status;
  final List<CartItem> items;
  final DateTime createdAt;
  final bool isRated;
  final double total;
}

class FeedbackModel {
  final String id, orderId;
  final int overallRating, foodQualityRating, portionSizeRating, serviceSpeedRating;
  final String? comment;
  final DateTime submittedAt;
}
```

---

## 8. JSON Data

### `assets/jsons/restaurants.json` — 6 restaurants, each specialized:

| id | Name | Specializes in |
|---|---|---|
| r1 | Main Campus Cafeteria | Breakfast · Lunch · Dinner · Vegan · Halal |
| r2 | Health Sciences Food Court | Lunch · Dinner · Healthy |
| r3 | Riverside Coffee & Bakery | Beverages · Snacks · Breakfast |
| r4 | Student Union Grill | Lunch · Dinner · Snacks |
| r5 | Garden Terrace Bistro | Breakfast · Lunch · Vegan · Gluten-Free |
| r6 | Express Convenience Store | Snacks · Beverages |

lat/lng in JSON = `0.0` placeholder. Replaced at runtime with `userCoords + offsets[i]`.

### `assets/jsons/menu_items.json` — ~25 items:
- r1: 8 items (Breakfast + Lunch + Dinner mix)
- r2: 5 items (Lunch + Dinner, healthy focus)
- r3: 5 items (coffee, pastries, sandwiches)
- r4: 4 items (burgers, fries, pizza)
- r5: 4 items (salads, bowls, smoothies)
- r6: 3 items (grab & go snacks, drinks)

---

## 9. Hive Boxes

| Box | Key | Stores |
|---|---|---|
| `'cart'` | `'current_cart'` | `CartState` as JSON string |
| `'orders'` | `'orders_list'` | `List<Order>` as JSON string |
| `'feedbacks'` | `'feedbacks_list'` | `List<FeedbackModel>` as JSON string |
| `'profile'` | `'profile_data'` | `ProfileState` as JSON string |
| `'meta'` | `'is_seeded'` | `bool` |

---

## 10. Riverpod Providers

```dart
final cartProvider = NotifierProvider<CartNotifier, CartState>(CartNotifier.new);
final ordersProvider = NotifierProvider<OrdersNotifier, OrdersState>(OrdersNotifier.new);
final homeProvider = NotifierProvider<HomeController, HomeState>(HomeController.new);
final profileProvider = NotifierProvider<ProfileController, ProfileState>(ProfileController.new);
final loginProvider = NotifierProvider<LoginController, LoginState>(LoginController.new);
final checkoutProvider = NotifierProvider<CheckoutController, CheckoutState>(CheckoutController.new);

// family providers
final restaurantMenuProvider = NotifierProvider.family<RestaurantMenuController, RestaurantMenuState, String>(
  (ref, restaurantId) => RestaurantMenuController(restaurantId),
);
final feedbackProvider = NotifierProvider.family<FeedbackController, FeedbackState, String>(
  (ref, orderId) => FeedbackController(orderId),
);
```

---

## 11. Dummy Seed

`DummyData.seedIfNeeded()` called in `main.dart` after Hive init:
- Checks `meta['is_seeded']` — skips if true
- Seeds 3 completed orders (`isRated: false`) using realistic items from menu_items.json
- Sets `meta['is_seeded'] = true`
