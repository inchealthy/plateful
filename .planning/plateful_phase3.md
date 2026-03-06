# Plateful — Phase 3: RestaurantMenuScreen + Cart Flow
> Read `plateful_prd_final.md` first. Phases 1 + 2 must be complete.

---

## What's Already Done (Phases 1–2)
- Full project structure, theme, routing
- All entities: `Restaurant`, `MenuItem`, `CartItem`, `Order`, `FeedbackModel`
- JSON files loaded: `restaurants.json`, `menu_items.json`
- HomeScreen fully working (list + map views)
- Navigation from Home → RestaurantMenuScreen stub working

---

## Goal
Full browse-to-cart UX: collapsed restaurant header, sticky category tabs, menu item list, item detail bottom sheet, cart with Hive persistence, CartFAB.

---

## What to Build

### 1. RestaurantMenuState + RestaurantMenuController

**`restaurant_menu_state.dart`:**
```dart
class RestaurantMenuState {
  final Restaurant? restaurant;
  final List<MenuItem> allItems;
  final List<MenuItem> filteredItems;
  final String selectedCategory;  // 'All' | 'Breakfast' | 'Lunch' | 'Dinner' | 'Snacks' | 'Beverages'
  final bool isLoading;
  const RestaurantMenuState({
    this.restaurant,
    this.allItems = const [],
    this.filteredItems = const [],
    this.selectedCategory = 'All',
    this.isLoading = true,
  });
  RestaurantMenuState copyWith({...});

  // derive available categories from allItems
  List<String> get availableCategories {
    final cats = allItems.map((e) => e.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }
}
```

**`restaurant_menu_controller.dart`:**
```dart
class RestaurantMenuController extends FamilyNotifier<RestaurantMenuState, String> {
  RestaurantMenuState build(String restaurantId) {
    Future.microtask(() => loadData(restaurantId));
    return const RestaurantMenuState();
  }

  Future<void> loadData(String restaurantId) async {
    // load restaurants.json, find matching restaurant
    // load menu_items.json, filter by restaurantId
    // update state
  }

  void onCategoryChanged(String category) {
    final filtered = category == 'All'
        ? state.allItems
        : state.allItems.where((i) => i.category == category).toList();
    state = state.copyWith(selectedCategory: category, filteredItems: filtered);
  }
}

final restaurantMenuProvider = NotifierProvider.family<RestaurantMenuController, RestaurantMenuState, String>(
  RestaurantMenuController.new,
);
```

### 2. RestaurantMenuScreen Layout

`ConsumerStatefulWidget`. Receives `restaurantId` from `GoRouterState.pathParameters['restaurantId']`.

**Overall structure:**
```dart
Scaffold(
  body: Stack(
    children: [
      CustomScrollView(
        slivers: [
          _RestaurantSliverHeader(),      // collapsing gradient header
          _CategoryTabsHeader(),          // sticky tabs
          _MenuItemsList(),               // items list
          SliverToBoxAdapter(child: SizedBox(height: 100.h)), // space for CartFAB
        ],
      ),
      if (cartItems.isNotEmpty) CartFAB(),  // positioned bottom
    ],
  ),
)
```

**`restaurant_sliver_header.dart`:**
```dart
SliverAppBar(
  expandedHeight: 200.h,
  pinned: true,
  backgroundColor: AppColors.primary,
  leading: CircleBackButton(),   // white circle, primary arrow
  flexibleSpace: FlexibleSpaceBar(
    background: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd]),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(restaurant.emoji, style: TextStyle(fontSize: 48.sp)),
          Text(restaurant.name, style: white bold heading2),
          SizedBox(height: 8.h),
          Row(  // stats row
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatChip('⭐ ${restaurant.rating}'),
              _StatChip('🕐 ${restaurant.hours}'),
              _StatChip('📍 ${restaurant.distanceMiles} mi'),
              _StatusBadge(restaurant.status),
            ],
          ),
        ],
      ),
    ),
    title: Text(restaurant.name),   // shown when collapsed
    titlePadding: EdgeInsets.only(left: 56.w, bottom: 16.h),
  ),
)
```

**`menu_category_tabs.dart`** (SliverPersistentHeader):
- Shows only categories that have items for this restaurant
- `TabBar`-style horizontal scroll
- Active tab: `AppColors.primary` underline + text
- Inactive: `AppColors.textSecondary`
- On tap: `controller.onCategoryChanged(category)`

**`menu_section.dart`** (SliverList):
- Groups items by category if `selectedCategory == 'All'`
- For each group: section header (emoji + category name + item count)
- For each item: `MenuItemCard`

**`menu_item_card.dart`:**
```
Container (white/fafafa bg, radius 12, margin bottom 12)
Row:
├── Left: 90×90 Container
│     background color varies by category:
│       Breakfast=#FFF3E0, Lunch=#E8F5E9, Dinner=#E3F2FD,
│       Snacks=#FFF8E1, Beverages=#F3E5F5
│     centered: emoji text 36px
│
└── Right: Expanded Column
      ├── Row: item name (bold, 15px) + dietary badge icons (🌱🌾🌶)
      ├── description (grey, 13px, maxLines:2, overflow:ellipsis)
      ├── SizedBox(height: 6)
      └── Row:
          ├── Left: '${calories.toInt()} cal · ${protein.toInt()}g protein' (grey, 12px)
          └── Right: Row:
                ├── '$price' (primary, bold, 15px)
                └── SizedBox(width: 8)
                └── _AddButton(onTap: _handleAddTap)

_AddButton: 32×32 Container, primary bg, radius 8, '+' white text
```

Tap anywhere (not `_AddButton`) → `ItemDetailSheet`
Tap `_AddButton` → `_handleAddTap()`:
  1. Check if cart has items from different restaurant → show conflict dialog if yes
  2. Otherwise: `cartNotifier.addItem(CartItem(item: menuItem, quantity: 1))`
  3. Show `SnackBar('${item.name} added to cart 🛒')`

### 3. ItemDetailSheet

Called via:
```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => ItemDetailSheet(item: item),
);
```

**`item_detail_sheet.dart`:**
```
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
  ),
  padding: EdgeInsets.all(20.w),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // drag handle
      Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(
        color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
      SizedBox(height: 16.h),

      // emoji image
      Container(width: 120.w, height: 120.w, decoration: BoxDecoration(
        color: _categoryColor(item.category), borderRadius: BorderRadius.circular(16.r)),
        child: Center(child: Text(item.emoji, style: TextStyle(fontSize: 56.sp)))),
      SizedBox(height: 12.h),

      // name + description
      Text(item.name, style: AppTextStyles.heading2),
      SizedBox(height: 4.h),
      Text(item.description, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        textAlign: TextAlign.center),
      SizedBox(height: 16.h),

      Divider(color: AppColors.border),
      SizedBox(height: 12.h),

      // nutrition row: 4 boxes
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NutritionBox(value: '${item.calories.toInt()}', label: 'Calories'),
          _NutritionBox(value: '${item.carbs.toInt()}g', label: 'Carbs'),
          _NutritionBox(value: '${item.protein.toInt()}g', label: 'Protein'),
          _NutritionBox(value: '${item.fat.toInt()}g', label: 'Fat'),
        ],
      ),
      SizedBox(height: 12.h),

      Divider(color: AppColors.border),
      SizedBox(height: 12.h),

      // allergens chips
      if (item.allergens.isNotEmpty) ...[
        Align(alignment: Alignment.centerLeft,
          child: Text('Allergens', style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold))),
        SizedBox(height: 8.h),
        Wrap(spacing: 6, children: item.allergens.map((a) =>
          Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warning)),
            child: Text(a, style: TextStyle(fontSize: 12, color: AppColors.warning)))).toList()),
        SizedBox(height: 12.h),
      ],

      // dietary tags
      if (item.dietaryTags.isNotEmpty)
        Wrap(spacing: 6, children: item.dietaryTags.map((t) => _DietaryBadge(t)).toList()),
      SizedBox(height: 16.h),

      Divider(color: AppColors.border),
      SizedBox(height: 12.h),

      // qty + price row + add button
      Row(
        children: [
          _QtyButton('-', onTap: () => qty > 1 ? setState(() => qty--) : null),
          SizedBox(width: 16),
          Text('$qty', style: AppTextStyles.heading3),
          SizedBox(width: 16),
          _QtyButton('+', onTap: () => setState(() => qty++)),
          Spacer(),
          Text('\$${(item.price * qty).toStringAsFixed(2)}',
            style: AppTextStyles.heading2.copyWith(color: AppColors.primary)),
        ],
      ),
      SizedBox(height: 12.h),
      AppButton(
        label: 'Add to Cart',
        onPressed: () {
          _handleAddToCart(context, item, qty);
          Navigator.pop(context);
        },
      ),
      SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
    ],
  ),
)
```

**Cart conflict AlertDialog:**
```dart
AlertDialog(
  title: Text('Replace Cart?'),
  content: Text('Your cart has items from ${cartState.restaurantName}. '
    'Clear cart and add from ${restaurant.name}?'),
  actions: [
    TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
    TextButton(
      onPressed: () {
        cartNotifier.clearAndAdd(CartItem(item: item, quantity: qty));
        Navigator.pop(context); // close dialog
        Navigator.pop(context); // close sheet
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cart updated 🛒')));
      },
      child: Text('Clear & Add', style: TextStyle(color: AppColors.error)),
    ),
  ],
)
```

### 4. CartState + CartNotifier

**`cart_state.dart`:**
```dart
class CartState {
  final List<CartItem> items;
  final String? restaurantId;
  final String? restaurantName;
  const CartState({this.items = const [], this.restaurantId, this.restaurantName});
  CartState copyWith({...});

  double get subtotal => items.fold(0, (sum, i) => sum + i.item.price * i.quantity);
  double get tax => subtotal * 0.08;
  double get total => subtotal + tax;
  int get totalItems => items.fold(0, (sum, i) => sum + i.quantity);
}
```

**`cart_controller.dart`:**
```dart
class CartNotifier extends Notifier<CartState> {
  late Box _box;

  CartState build() {
    _box = Hive.box('cart');
    final saved = _box.get('current_cart');
    if (saved != null) return _deserialize(saved);
    return const CartState();
  }

  void addItem(CartItem newItem) {
    final existing = state.items.indexWhere((i) => i.item.id == newItem.item.id);
    List<CartItem> updated;
    if (existing >= 0) {
      updated = [...state.items];
      updated[existing] = CartItem(
        item: updated[existing].item,
        quantity: updated[existing].quantity + newItem.quantity,
      );
    } else {
      updated = [...state.items, newItem];
    }
    _updateState(state.copyWith(
      items: updated,
      restaurantId: newItem.item.restaurantId,
      // restaurantName passed separately — controller receives it
    ));
  }

  void clearAndAdd(CartItem newItem, String restaurantName) {
    _updateState(CartState(
      items: [newItem],
      restaurantId: newItem.item.restaurantId,
      restaurantName: restaurantName,
    ));
  }

  void removeItem(String menuItemId) {
    _updateState(state.copyWith(
      items: state.items.where((i) => i.item.id != menuItemId).toList(),
    ));
  }

  void updateQuantity(String menuItemId, int qty) {
    if (qty <= 0) { removeItem(menuItemId); return; }
    final updated = state.items.map((i) =>
      i.item.id == menuItemId ? CartItem(item: i.item, quantity: qty) : i
    ).toList();
    _updateState(state.copyWith(items: updated));
  }

  void clearCart() => _updateState(const CartState());

  void _updateState(CartState newState) {
    state = newState;
    _box.put('current_cart', _serialize(newState));
  }

  // serialize/deserialize: convert CartState to/from JSON string using jsonEncode/jsonDecode
  // CartItem.toJson() / CartItem.fromJson() using MenuItem.toJson() / MenuItem.fromJson()
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(CartNotifier.new);
```

### 5. CartScreen

**`cart_screen.dart`** — `ConsumerWidget`:
```dart
final cartState = ref.watch(cartProvider);

Scaffold(
  appBar: AppBar(title: Text('My Cart')),
  body: cartState.items.isEmpty
    ? _EmptyCartWidget()
    : Column(children: [
        Expanded(child: ListView.builder(
          itemCount: cartState.items.length,
          itemBuilder: (_, i) => CartItemTile(
            cartItem: cartState.items[i],
            onQtyChanged: (qty) => ref.read(cartProvider.notifier).updateQuantity(item.id, qty),
            onRemove: () => ref.read(cartProvider.notifier).removeItem(item.id),
          ),
        )),
        CartSummaryCard(cartState: cartState),  // sticky bottom
      ]),
)
```

**`cart_item_tile.dart`:**
```
Padding(all: 16)
Row:
├── 60×60 emoji container (category bg color)
├── SizedBox(width: 12)
├── Expanded Column:
│   ├── item name (bold, 15px)
│   └── restaurant name (grey, 12px)
├── Column:
│   ├── Row: [−][qty][+] stepper (32×32 buttons, border style)
│   └── '$price × qty' (grey, 12px, right-aligned)
└── IconButton(Icons.delete_outline, color: error, onPressed: onRemove)
```

**`cart_summary_card.dart`:**
```
Container(white, shadow top, padding 20)
Column:
├── Row: 'Subtotal'  '$subtotal'
├── Row: 'Tax (8%)'  '$tax'
├── Divider
├── Row: 'Total' (bold)  '$total' (bold, primary)
└── SizedBox(height: 12)
└── AppButton(label: 'Proceed to Checkout', onPressed: () => context.push('/checkout'))
```

**`_EmptyCartWidget`:**
```
Center Column:
├── Text '🛒' (64px)
├── 'Your cart is empty' (heading3)
├── 'Add some delicious food!' (grey, body)
└── AppButton(label: 'Browse Restaurants', onPressed: () => context.go('/shell/home'))
```

### 6. CartFAB — `lib/src/common/components/cart_fab.dart`

```dart
class CartFAB extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    if (cart.items.isEmpty) return const SizedBox.shrink();
    return Positioned(
      bottom: 16.h, left: 16.w, right: 16.w,
      child: GestureDetector(
        onTap: () => context.push('/cart'),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4),
              blurRadius: 12, offset: Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r)),
                child: Text('🛒', style: TextStyle(fontSize: 18.sp)),
              ),
              SizedBox(width: 10.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r)),
                child: Text('${cart.totalItems}',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12.sp)),
              ),
              SizedBox(width: 8.w),
              Text('View Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              Spacer(),
              Text('\$${cart.total.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Acceptance Criteria
- [ ] RestaurantMenuScreen loads correct restaurant + its menu items from JSON
- [ ] SliverAppBar collapses correctly — emoji/stats visible when expanded, restaurant name when collapsed
- [ ] Category tabs filter items correctly, show only relevant categories per restaurant
- [ ] Tapping menu item opens ItemDetailSheet with correct data
- [ ] Nutrition boxes show correct values
- [ ] Allergen + dietary chips render correctly
- [ ] Qty stepper in sheet works, price updates
- [ ] "Add to Cart" adds item, closes sheet, shows snackbar
- [ ] "+" button on card adds item directly with snackbar
- [ ] CartFAB appears after first item added, shows correct count + total
- [ ] Cart conflict dialog appears when adding from different restaurant
- [ ] "Clear & Add" replaces cart correctly
- [ ] CartScreen shows all items with correct qty, subtotal, tax, total
- [ ] Qty stepper in cart updates price
- [ ] Delete removes item from cart
- [ ] Cart persists after hot restart (Hive working)
- [ ] Empty cart shows empty state with "Browse Restaurants" button
