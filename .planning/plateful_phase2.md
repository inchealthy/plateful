# Plateful — Phase 2: Data Layer + Home Screen (List + Map)
> Read `plateful_prd_final.md` first. Phase 1 must be complete before starting this.

---

## What's Already Done (Phase 1)
- Flutter project created, all packages installed
- AppTheme, AppColors, AppTextStyles, AppSizes
- go_router with all routes, ShellScaffold, BottomNavBar
- All screens stubbed and navigable
- main.dart with ProviderScope + ScreenUtil + Hive init

---

## Goal
JSON data loaded from assets. Entities defined. Home screen fully functional — search, filter chips, list view with RestaurantCards, map view with user location + restaurant pins.

---

## What to Build

### 1. JSON Files

**`assets/jsons/restaurants.json`:**
```json
[
  {
    "id": "r1",
    "name": "Main Campus Cafeteria",
    "cuisine": "Full Service Dining Hall",
    "emoji": "🍽️",
    "rating": 4.5,
    "hours": "6am – 9pm",
    "status": "open",
    "lat": 0.0,
    "lng": 0.0,
    "distanceMiles": 0.2,
    "tags": ["Breakfast", "Lunch", "Dinner", "Vegan", "Halal"]
  },
  {
    "id": "r2",
    "name": "Health Sciences Food Court",
    "cuisine": "Multiple Vendors",
    "emoji": "🥗",
    "rating": 4.7,
    "hours": "7am – 8pm",
    "status": "busy",
    "lat": 0.0,
    "lng": 0.0,
    "distanceMiles": 0.5,
    "tags": ["Lunch", "Dinner", "Healthy", "Gluten-Free"]
  },
  {
    "id": "r3",
    "name": "Riverside Coffee & Bakery",
    "cuisine": "Café",
    "emoji": "☕",
    "rating": 4.8,
    "hours": "6:30am – 6pm",
    "status": "open",
    "lat": 0.0,
    "lng": 0.0,
    "distanceMiles": 0.3,
    "tags": ["Breakfast", "Snacks", "Beverages"]
  },
  {
    "id": "r4",
    "name": "Student Union Grill",
    "cuisine": "Casual Dining",
    "emoji": "🍔",
    "rating": 4.3,
    "hours": "10am – 10pm",
    "status": "open",
    "lat": 0.0,
    "lng": 0.0,
    "distanceMiles": 0.4,
    "tags": ["Lunch", "Dinner", "Snacks"]
  },
  {
    "id": "r5",
    "name": "Garden Terrace Bistro",
    "cuisine": "Healthy Options",
    "emoji": "🌿",
    "rating": 4.9,
    "hours": "11am – 8pm",
    "status": "closed",
    "lat": 0.0,
    "lng": 0.0,
    "distanceMiles": 0.6,
    "tags": ["Breakfast", "Lunch", "Vegan", "Gluten-Free"]
  },
  {
    "id": "r6",
    "name": "Express Convenience Store",
    "cuisine": "Grab & Go",
    "emoji": "🏪",
    "rating": 4.2,
    "hours": "24/7",
    "status": "open",
    "lat": 0.0,
    "lng": 0.0,
    "distanceMiles": 0.1,
    "tags": ["Snacks", "Beverages"]
  }
]
```

**`assets/jsons/menu_items.json`** — 25 items total:

r1 (Main Campus Cafeteria) — 8 items across Breakfast/Lunch/Dinner:
- Canyon Classic Burger · 🍔 · Lunch · $8.50 · 650cal · 45C · 35P · 28F · allergens:[Gluten,Dairy] · tags:[Popular]
- Mediterranean Bowl · 🥙 · Lunch · $9.25 · 520cal · 62C · 18P · 14F · allergens:[] · tags:[Vegan,Healthy]
- Buttermilk Pancakes · 🥞 · Breakfast · $6.50 · 520cal · 68C · 12P · 18F · allergens:[Gluten,Dairy,Eggs] · tags:[Popular]
- Protein Power Breakfast · 🍳 · Breakfast · $10.25 · 480cal · 32C · 35P · 22F · allergens:[Eggs,Dairy] · tags:[Healthy]
- Penne Alfredo · 🍝 · Dinner · $10.95 · 720cal · 85C · 32P · 24F · allergens:[Gluten,Dairy] · tags:[Popular]
- Grilled Salmon · 🐟 · Dinner · $13.50 · 420cal · 12C · 48P · 18F · allergens:[Fish] · tags:[Healthy,Gluten-Free]
- Garden Salad · 🥗 · Lunch · $7.00 · 180cal · 22C · 6P · 8F · allergens:[] · tags:[Vegan,Gluten-Free,Healthy]
- Chicken Wrap · 🌯 · Lunch · $8.75 · 540cal · 52C · 28P · 20F · allergens:[Gluten,Dairy] · tags:[Popular]

r2 (Health Sciences Food Court) — 5 items, Lunch/Dinner:
- Fish Tacos (3) · 🌮 · Lunch · $11.50 · 580cal · 48C · 28P · 22F · allergens:[Fish,Gluten] · tags:[Spicy,Healthy]
- Quinoa Power Bowl · 🥣 · Lunch · $10.50 · 440cal · 58C · 16P · 12F · allergens:[] · tags:[Vegan,Gluten-Free,Healthy]
- Turkey Avocado Sandwich · 🥪 · Lunch · $9.00 · 490cal · 42C · 28P · 18F · allergens:[Gluten,Dairy] · tags:[Healthy]
- Veggie Stir Fry · 🥦 · Dinner · $9.75 · 380cal · 52C · 12P · 10F · allergens:[Soy] · tags:[Vegan,Halal]
- BBQ Chicken Plate · 🍗 · Dinner · $12.00 · 620cal · 38C · 45P · 20F · allergens:[Gluten,Soy] · tags:[Popular,Halal]

r3 (Riverside Coffee & Bakery) — 5 items, Beverages/Snacks/Breakfast:
- Caramel Latte · ☕ · Beverages · $4.50 · 180cal · 28C · 6P · 6F · allergens:[Dairy] · tags:[]
- Matcha Green Tea · 🍵 · Beverages · $4.00 · 120cal · 18C · 4P · 4F · allergens:[Dairy] · tags:[]
- Blueberry Muffin · 🫐 · Snacks · $3.50 · 320cal · 48C · 5P · 12F · allergens:[Gluten,Dairy,Eggs] · tags:[Popular]
- Avocado Toast · 🥑 · Breakfast · $7.50 · 340cal · 36C · 10P · 18F · allergens:[Gluten] · tags:[Vegan,Healthy]
- Croissant · 🥐 · Breakfast · $3.00 · 280cal · 32C · 6P · 14F · allergens:[Gluten,Dairy,Eggs] · tags:[]

r4 (Student Union Grill) — 4 items, Lunch/Dinner/Snacks:
- Smash Burger · 🍔 · Lunch · $9.50 · 720cal · 52C · 38P · 32F · allergens:[Gluten,Dairy,Eggs] · tags:[Popular]
- Loaded Fries · 🍟 · Snacks · $5.00 · 480cal · 58C · 12P · 22F · allergens:[Gluten,Dairy] · tags:[Popular]
- Margherita Pizza Slice · 🍕 · Dinner · $4.50 · 380cal · 44C · 15P · 14F · allergens:[Gluten,Dairy] · tags:[Popular]
- BBQ Pulled Pork Sandwich · 🥩 · Dinner · $11.00 · 680cal · 62C · 35P · 24F · allergens:[Gluten,Soy] · tags:[Popular]

r5 (Garden Terrace Bistro) — 4 items, Breakfast/Lunch/Vegan:
- Acai Smoothie Bowl · 🫐 · Breakfast · $8.00 · 380cal · 62C · 8P · 10F · allergens:[] · tags:[Vegan,Gluten-Free,Healthy]
- Buddha Bowl · 🥙 · Lunch · $11.00 · 460cal · 58C · 16P · 14F · allergens:[Soy] · tags:[Vegan,Gluten-Free]
- Green Goddess Wrap · 🌯 · Lunch · $9.00 · 420cal · 52C · 14P · 16F · allergens:[Gluten] · tags:[Vegan,Healthy]
- Chia Pudding · 🍮 · Breakfast · $5.50 · 280cal · 38C · 8P · 10F · allergens:[Dairy] · tags:[Gluten-Free,Healthy]

r6 (Express Convenience Store) — 3 items, Snacks/Beverages:
- Protein Bar · 🍫 · Snacks · $3.00 · 220cal · 28C · 15P · 8F · allergens:[Nuts,Dairy] · tags:[Healthy]
- Sparkling Water · 💧 · Beverages · $2.00 · 0cal · 0C · 0P · 0F · allergens:[] · tags:[Vegan,Gluten-Free]
- Trail Mix · 🥜 · Snacks · $4.00 · 340cal · 32C · 10P · 18F · allergens:[Nuts] · tags:[Vegan,Gluten-Free]

### 2. Entities — `lib/src/common/domain/entities/`

Each entity has: named constructor, `fromJson(Map<String, dynamic>)`, `toJson()`.

```dart
// restaurant.dart
class Restaurant {
  final String id, name, cuisine, emoji, hours, status;
  final double rating, lat, lng, distanceMiles;
  final List<String> tags;
  const Restaurant({...});
  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
    id: json['id'], name: json['name'], cuisine: json['cuisine'],
    emoji: json['emoji'], rating: (json['rating'] as num).toDouble(),
    hours: json['hours'], status: json['status'],
    lat: (json['lat'] as num).toDouble(), lng: (json['lng'] as num).toDouble(),
    distanceMiles: (json['distanceMiles'] as num).toDouble(),
    tags: List<String>.from(json['tags']),
  );
  Map<String, dynamic> toJson() => { 'id': id, 'name': name, ... };
}

// menu_item.dart
class MenuItem {
  final String id, restaurantId, name, description, emoji, category;
  final double price, calories, carbs, protein, fat;
  final List<String> allergens, dietaryTags;
  // fromJson + toJson
}
```

### 3. HomeState + HomeController

**`home_state.dart`:**
```dart
class HomeState {
  final List<Restaurant> allRestaurants;
  final List<Restaurant> filteredList;
  final String searchQuery;
  final String selectedFilter;
  final int selectedTabIndex;
  final bool isLoading;
  const HomeState({
    this.allRestaurants = const [],
    this.filteredList = const [],
    this.searchQuery = '',
    this.selectedFilter = 'All',
    this.selectedTabIndex = 0,
    this.isLoading = false,
  });
  HomeState copyWith({...});
}
```

**`home_controller.dart`:**
```dart
class HomeController extends Notifier<HomeState> {
  HomeState build() {
    Future.microtask(() => loadRestaurants());
    return const HomeState(isLoading: true);
  }

  Future<void> loadRestaurants() async {
    final jsonStr = await rootBundle.loadString('assets/jsons/restaurants.json');
    final list = (jsonDecode(jsonStr) as List)
        .map((e) => Restaurant.fromJson(e)).toList();
    state = state.copyWith(allRestaurants: list, filteredList: list, isLoading: false);
  }

  void onSearchChanged(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void onFilterSelected(String filter) {
    final newFilter = state.selectedFilter == filter ? 'All' : filter;
    state = state.copyWith(selectedFilter: newFilter);
    _applyFilters();
  }

  void onTabChanged(int index) => state = state.copyWith(selectedTabIndex: index);

  void _applyFilters() {
    var result = state.allRestaurants;
    if (state.searchQuery.isNotEmpty) {
      final q = state.searchQuery.toLowerCase();
      result = result.where((r) =>
        r.name.toLowerCase().contains(q) ||
        r.cuisine.toLowerCase().contains(q) ||
        r.tags.any((t) => t.toLowerCase().contains(q))
      ).toList();
    }
    if (state.selectedFilter != 'All') {
      result = result.where((r) => r.tags.contains(state.selectedFilter)).toList();
    }
    state = state.copyWith(filteredList: result);
  }
}

final homeProvider = NotifierProvider<HomeController, HomeState>(HomeController.new);
```

### 4. HomeScreen UI — `lib/src/features/home/home_screen.dart`

`ConsumerStatefulWidget` with a `TabController(length: 2)`.

**`home_header.dart` widget:**
- `Container` with `LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd])`
- "Good morning 👋" text (white, heading2)
- `AppSearchBar` (white bg inside gradient header)
- View toggle: `Container` with white 20% opacity bg, 2 toggle buttons side by side
  - Active button: white bg, primary text, soft shadow
  - Inactive: transparent bg, white 70% text

**`filter_chips_bar.dart` widget:**
- `SingleChildScrollView(scrollDirection: Axis.horizontal)`
- Chip labels: `['All', 'Breakfast', 'Lunch', 'Dinner', 'Snacks', 'Beverages', 'Vegan', 'Halal', 'Gluten-Free']`
- Uses `AppChip` component, reads `homeState.selectedFilter`

**`restaurant_list_view.dart` widget:**
- `ListView.builder` of `RestaurantCard`
- Shows `CircularProgressIndicator` while `isLoading`
- Shows "No restaurants found" text if `filteredList.isEmpty && !isLoading`

**`restaurant_card.dart` component:**
```
Container (white, radius 12, shadow, margin bottom 1px, border bottom)
├── Row:
│   ├── Left: 60×60 Container (gradient bg, centered emoji text 28px)
│   └── Right: Column
│         ├── Row: name (bold) + status badge
│         ├── cuisine type (grey, caption)
│         └── Row: 📍distanceMiles mi · ⭐rating · 🕐hours
```
Status badge: Open=green bg, Closed=red bg, Busy=orange bg — white text, radius 12, padding 4×10

**`restaurant_map_view.dart` widget:**
- `StatefulWidget` (needs initState for location)
- `initState`: call `_initLocation()`
- `_initLocation()`:
  1. `await Geolocator.requestPermission()`
  2. If granted: `pos = await Geolocator.getCurrentPosition()` → set `_userLat`, `_userLng`, `_hasLocation = true`
  3. If denied: compute centroid from `filteredList` coords (using offsets) → set `_userLat = avgLat`, `_userLng = avgLng`, `_hasLocation = false`
  4. Compute restaurant positions: `restaurantLat[i] = _userLat + latOffsets[i]`
  5. Call `setState()`

- `latOffsets = [0.002, -0.003, 0.005, -0.004, 0.007, -0.001]`
- `lngOffsets = [-0.003, 0.004, -0.002, 0.006, -0.005, 0.003]`

**FlutterMap config:**
```dart
FlutterMap(
  options: MapOptions(
    initialCenter: LatLng(_userLat, _userLng),
    initialZoom: 15.0,
  ),
  children: [
    TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.plateful',
    ),
    if (_hasLocation) CircleLayer(circles: [
      CircleMarker(point: LatLng(_userLat, _userLng), radius: 10,
        color: Colors.blue.withOpacity(0.3), borderColor: Colors.blue, borderStrokeWidth: 2),
    ]),
    MarkerLayer(markers: [
      for (int i = 0; i < restaurants.length; i++)
        Marker(
          point: LatLng(_userLat + latOffsets[i], _userLng + lngOffsets[i]),
          child: GestureDetector(
            onTap: () => _showPinSheet(context, restaurants[i], i),
            child: _RestaurantPin(emoji: restaurants[i].emoji),
          ),
        ),
    ]),
  ],
)
```

- If `!_hasLocation`: show yellow banner at top "📍 Enable location for better experience"
- "My Location" FAB (bottom right, inside `Stack`): re-centers map via `MapController`
- `_showPinSheet()`: `showModalBottomSheet` with `MapPinBottomSheet`

**`MapPinBottomSheet` widget:**
```
drag handle (centered grey bar)
Row: big emoji (48px) + Column(name bold, cuisine grey)
status badge + distance + rating + hours row
[View Menu] ElevatedButton full width
  → Navigator.pop() then context.push('/restaurant/${restaurant.id}')
```

---

## Acceptance Criteria
- [ ] `restaurants.json` + `menu_items.json` exist in assets and declared in pubspec
- [ ] All 5 entities parse correctly from JSON (test by printing in debug)
- [ ] HomeScreen loads and shows 6 RestaurantCards
- [ ] Search filters cards in real-time
- [ ] Filter chips filter correctly, single-select, re-tap deselects
- [ ] List/Map toggle switches between views
- [ ] Map shows user location dot (or fallback centroid) with 6 restaurant pins nearby
- [ ] Tapping a pin shows MapPinBottomSheet with correct restaurant info
- [ ] "View Menu" in pin sheet navigates to RestaurantMenuScreen (still stub) with correct restaurantId
- [ ] Tapping a RestaurantCard navigates to RestaurantMenuScreen stub with correct restaurantId
