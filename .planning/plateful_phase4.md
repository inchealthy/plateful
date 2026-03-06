# Plateful — Phase 4: Checkout + Orders + Dummy Seed
> Read `plateful_prd_final.md` first. Phases 1–3 must be complete.

---

## What's Already Done (Phases 1–3)
- Full project structure, theme, routing, entities, JSON data
- HomeScreen (list + map), RestaurantMenuScreen, ItemDetailSheet
- CartNotifier + CartState fully working with Hive persistence
- CartScreen with qty stepper, summary, "Proceed to Checkout" CTA

---

## Goal
Complete the dummy order loop. CheckoutScreen places orders. OrdersScreen shows history. Seeded dummy orders visible on fresh install. OrderDetailSheet with "Leave Feedback" CTA.

---

## What to Build

### 1. DummyData Seeder — `lib/src/utils/dummy_data.dart`

```dart
class DummyData {
  static Future<void> seedIfNeeded(Box ordersBox, Box metaBox) async {
    if (metaBox.get('is_seeded') == true) return;

    final seededOrders = [
      Order(
        id: 'seed_001',
        restaurantId: 'r1',
        restaurantName: 'Main Campus Cafeteria',
        items: [
          CartItem(item: _mockItem('m1', 'Canyon Classic Burger', '🍔', 8.50), quantity: 1),
          CartItem(item: _mockItem('m2', 'Mediterranean Bowl', '🥙', 9.25), quantity: 2),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        status: 'completed',
        isRated: false,
        total: 27.00,
      ),
      Order(
        id: 'seed_002',
        restaurantId: 'r3',
        restaurantName: 'Riverside Coffee & Bakery',
        items: [
          CartItem(item: _mockItem('m11', 'Caramel Latte', '☕', 4.50), quantity: 2),
          CartItem(item: _mockItem('m13', 'Blueberry Muffin', '🫐', 3.50), quantity: 1),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        status: 'completed',
        isRated: false,
        total: 13.41,
      ),
      Order(
        id: 'seed_003',
        restaurantId: 'r4',
        restaurantName: 'Student Union Grill',
        items: [
          CartItem(item: _mockItem('m16', 'Smash Burger', '🍔', 9.50), quantity: 1),
          CartItem(item: _mockItem('m17', 'Loaded Fries', '🍟', 5.00), quantity: 1),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        status: 'completed',
        isRated: false,
        total: 15.66,
      ),
    ];

    final jsonList = seededOrders.map((o) => o.toJson()).toList();
    await ordersBox.put('orders_list', jsonEncode(jsonList));
    await metaBox.put('is_seeded', true);
  }

  // minimal MenuItem stub for seeding (no nutrition needed)
  static MenuItem _mockItem(String id, String name, String emoji, double price) => MenuItem(
    id: id, restaurantId: '', name: name, description: '',
    emoji: emoji, category: '', price: price,
    calories: 0, carbs: 0, protein: 0, fat: 0,
    allergens: [], dietaryTags: [],
  );
}
```

Call in `main.dart`:
```dart
final ordersBox = await Hive.openBox('orders');
final metaBox = await Hive.openBox('meta');
await DummyData.seedIfNeeded(ordersBox, metaBox);
```

### 2. Order Entity — update if needed

Ensure `Order` has `toJson()` and `fromJson()` that handles `List<CartItem>` serialization:
```dart
class Order {
  final String id, restaurantId, restaurantName, status;
  final List<CartItem> items;
  final DateTime createdAt;
  final bool isRated;
  final double total;

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'],
    restaurantId: json['restaurantId'],
    restaurantName: json['restaurantName'],
    status: json['status'],
    items: (json['items'] as List).map((i) => CartItem.fromJson(i)).toList(),
    createdAt: DateTime.parse(json['createdAt']),
    isRated: json['isRated'] ?? false,
    total: (json['total'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'restaurantId': restaurantId, 'restaurantName': restaurantName,
    'status': status,
    'items': items.map((i) => i.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'isRated': isRated, 'total': total,
  };

  Order copyWith({bool? isRated, String? status}) => Order(
    id: id, restaurantId: restaurantId, restaurantName: restaurantName,
    status: status ?? this.status, items: items,
    createdAt: createdAt, isRated: isRated ?? this.isRated, total: total,
  );
}
```

### 3. OrdersState + OrdersNotifier

**`orders_state.dart`:**
```dart
class OrdersState {
  final List<Order> orders;   // sorted newest first
  final bool isLoading;
  const OrdersState({this.orders = const [], this.isLoading = false});
  OrdersState copyWith({...});
}
```

**`orders_controller.dart`:**
```dart
class OrdersNotifier extends Notifier<OrdersState> {
  late Box _box;

  OrdersState build() {
    _box = Hive.box('orders');
    _loadOrders();
    return const OrdersState(isLoading: true);
  }

  void _loadOrders() {
    final saved = _box.get('orders_list');
    if (saved == null) { state = const OrdersState(); return; }
    final list = (jsonDecode(saved) as List)
        .map((e) => Order.fromJson(e)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = OrdersState(orders: list);
  }

  void addOrder(Order order) {
    final updated = [order, ...state.orders];
    state = state.copyWith(orders: updated);
    _persist(updated);
  }

  void markAsRated(String orderId) {
    final updated = state.orders.map((o) =>
      o.id == orderId ? o.copyWith(isRated: true) : o
    ).toList();
    state = state.copyWith(orders: updated);
    _persist(updated);
  }

  void _persist(List<Order> orders) {
    _box.put('orders_list', jsonEncode(orders.map((o) => o.toJson()).toList()));
  }
}

final ordersProvider = NotifierProvider<OrdersNotifier, OrdersState>(OrdersNotifier.new);
```

### 4. CheckoutState + CheckoutController

**`checkout_state.dart`:**
```dart
class CheckoutState {
  final bool isNow;
  final DateTime? scheduledTime;
  final bool isLoading;
  final bool orderPlaced;
  const CheckoutState({
    this.isNow = true,
    this.scheduledTime,
    this.isLoading = false,
    this.orderPlaced = false,
  });
  CheckoutState copyWith({...});
}
```

**`checkout_controller.dart`:**
```dart
class CheckoutController extends Notifier<CheckoutState> {
  CheckoutState build() => const CheckoutState();

  void togglePickupMode(bool isNow) => state = state.copyWith(isNow: isNow);
  void setScheduledTime(DateTime time) => state = state.copyWith(scheduledTime: time);

  Future<void> placeOrder() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 800)); // simulate network

    final cart = ref.read(cartProvider);
    final order = Order(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      restaurantId: cart.restaurantId ?? '',
      restaurantName: cart.restaurantName ?? '',
      items: cart.items,
      createdAt: DateTime.now(),
      status: 'preparing',
      isRated: false,
      total: cart.total,
    );

    ref.read(ordersProvider.notifier).addOrder(order);
    ref.read(cartProvider.notifier).clearCart();
    state = state.copyWith(isLoading: false, orderPlaced: true);
  }
}

final checkoutProvider = NotifierProvider<CheckoutController, CheckoutState>(CheckoutController.new);
```

### 5. CheckoutScreen UI

`ConsumerStatefulWidget`. Watches `cartProvider` for summary. Watches `checkoutProvider` for state.

**Listen for `orderPlaced` → show `OrderSuccessDialog`:**
```dart
ref.listen(checkoutProvider, (prev, next) {
  if (!prev!.orderPlaced && next.orderPlaced) {
    showDialog(context: context, barrierDismissible: false,
      builder: (_) => const OrderSuccessDialog());
  }
});
```

**Layout:**
```
Scaffold(
  appBar: AppBar(title: Text('Checkout')),
  body: SingleChildScrollView(
    padding: EdgeInsets.all(16.w),
    child: Column(children: [

      // 1. Order Summary card
      _SectionCard(
        title: 'Order Summary',
        child: Column(
          children: cart.items.map((cartItem) => Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: Row(children: [
              Text(cartItem.item.emoji),
              SizedBox(width: 8.w),
              Expanded(child: Text(cartItem.item.name)),
              Text('×${cartItem.quantity}', style: grey),
              SizedBox(width: 8.w),
              Text('\$${(cartItem.item.price * cartItem.quantity).toStringAsFixed(2)}'),
            ]),
          )).toList(),
        ),
      ),

      SizedBox(height: 12.h),

      // 2. Pickup Location card (read-only)
      _SectionCard(
        title: 'Pickup Location',
        child: Row(children: [
          Text('📍', style: TextStyle(fontSize: 20.sp)),
          SizedBox(width: 8.w),
          Text(cart.restaurantName ?? '', style: AppTextStyles.body),
        ]),
      ),

      SizedBox(height: 12.h),

      // 3. Pickup Time card
      _SectionCard(
        title: 'Pickup Time',
        child: Column(children: [
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: true, label: Text('Now'), icon: Icon(Icons.flash_on)),
              ButtonSegment(value: false, label: Text('Schedule'), icon: Icon(Icons.schedule)),
            ],
            selected: {checkoutState.isNow},
            onSelectionChanged: (val) => controller.togglePickupMode(val.first),
          ),
          if (!checkoutState.isNow) ...[
            SizedBox(height: 12.h),
            // dummy time display — "Pick a time" button shows a time picker (result shown as text only)
            OutlinedButton.icon(
              icon: Icon(Icons.access_time),
              label: Text(checkoutState.scheduledTime != null
                ? DateFormat('h:mm a').format(checkoutState.scheduledTime!)
                : 'Pick a time'),
              onPressed: () async {
                final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                if (time != null) {
                  final now = DateTime.now();
                  controller.setScheduledTime(DateTime(now.year, now.month, now.day, time.hour, time.minute));
                }
              },
            ),
          ],
        ]),
      ),

      SizedBox(height: 12.h),

      // 4. Price Summary card
      _SectionCard(
        title: 'Price Summary',
        child: Column(children: [
          _PriceRow('Subtotal', '\$${cart.subtotal.toStringAsFixed(2)}'),
          _PriceRow('Tax (8%)', '\$${cart.tax.toStringAsFixed(2)}'),
          Divider(color: AppColors.border),
          _PriceRow('Total', '\$${cart.total.toStringAsFixed(2)}', bold: true),
        ]),
      ),

      SizedBox(height: 24.h),
    ]),
  ),
  bottomNavigationBar: SafeArea(
    child: Padding(
      padding: EdgeInsets.all(16.w),
      child: AppButton(
        label: checkoutState.isLoading ? 'Placing Order...' : 'Place Order',
        isLoading: checkoutState.isLoading,
        onPressed: checkoutState.isLoading ? null : () => controller.placeOrder(),
      ),
    ),
  ),
)
```

**`order_success_dialog.dart`:**
```dart
AlertDialog(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
  content: Column(mainAxisSize: MainAxisSize.min, children: [
    Text('✅', style: TextStyle(fontSize: 64.sp)),
    SizedBox(height: 12.h),
    Text('Order Placed!', style: AppTextStyles.heading2),
    SizedBox(height: 8.h),
    Text('Your order is being prepared.\nEst. ready: 15–20 minutes',
      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
      textAlign: TextAlign.center),
    SizedBox(height: 20.h),
    AppButton(
      label: 'Track Order',
      onPressed: () {
        Navigator.of(context).pop(); // close dialog
        context.go('/shell/orders'); // switch to orders tab (pops full stack)
      },
    ),
  ]),
)
```

### 6. OrdersScreen UI

`ConsumerWidget`. Watches `ordersProvider`.

```
Scaffold(
  appBar: AppBar(title: Text('My Orders')),
  body: ordersState.orders.isEmpty
    ? _EmptyOrdersWidget()
    : ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: ordersState.orders.length,
        itemBuilder: (_, i) => OrderCard(
          order: ordersState.orders[i],
          onTap: () => _showOrderDetail(context, ordersState.orders[i]),
        ),
      ),
)
```

**`order_card.dart`:**
```
Card(radius 12, white, margin bottom 12)
Padding(all: 16)
Column:
├── Row:
│   ├── Text(restaurant.emoji, 24px)
│   ├── SizedBox(width: 10)
│   ├── Expanded Column:
│   │   ├── restaurant name (bold, 15px)
│   │   └── formatted date (grey, 12px) e.g. 'Jan 31 · 12:45 PM'
│   └── _StatusBadge(order.status)
├── SizedBox(height: 8)
├── Text(itemsSummary, grey, 13px)  // 'Canyon Burger, Med Bowl +1 more'
├── SizedBox(height: 8)
└── Row:
    ├── Text('${order.items.length} items', grey, 12px)
    └── Spacer()
    └── Text('\$${order.total.toStringAsFixed(2)}', bold, primary, 15px)
```

`itemsSummary`: first 2 item names joined by ', ' + ' +N more' if >2.

**Status badge colors:**
- `preparing` → orange bg `#FFF3E0`, text `#FF9800`
- `ready` → green bg `#E8F5E9`, text `#4CAF50`
- `completed` → grey bg `#F5F5F5`, text `#666666`

**`order_detail_sheet.dart`** (bottom sheet):
```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => OrderDetailSheet(order: order),
);
```

```
Container(white, radius top 20)
Padding(all: 20)
Column:
├── drag handle
├── Row: emoji (32px) + Column(restaurantName bold, 'Order #${order.id.substring(order.id.length-6)} · ${formattedDate}' grey)
├── SizedBox(height: 16)
├── Divider
├── // items list
    for each cartItem: Row(emoji, name, '×qty', Spacer(), '$price')
├── Divider
├── _PriceRow('Subtotal', ...)
├── _PriceRow('Tax (8%)', ...)
├── _PriceRow('Total', ..., bold: true)
├── SizedBox(height: 12)
├── Row: Text('Status:') + Spacer() + _StatusBadge(order.status)
├── if (order.status == 'completed' && !order.isRated) ...[
│   SizedBox(height: 16)
│   AppButton(
│     label: '⭐ Leave Feedback',
│     onPressed: () {
│       Navigator.pop(context);
│       context.push('/feedback/${order.id}');
│     },
│   ),
│ ]
└── SizedBox(height: MediaQuery.of(context).viewInsets.bottom)
```

---

## Acceptance Criteria
- [ ] Fresh install seeds 3 completed orders in Orders tab
- [ ] Seeder runs only once — second launch does NOT re-seed
- [ ] CheckoutScreen shows correct order summary from CartState
- [ ] "Now" / "Schedule" toggle works, time picker shows on Schedule
- [ ] "Place Order" shows loading state for ~800ms
- [ ] After place order: OrderSuccessDialog appears
- [ ] "Track Order" navigates to Orders tab and clears navigation stack
- [ ] New order appears at TOP of Orders list
- [ ] Cart is empty after order placed
- [ ] OrderCard shows correct restaurant, date, items summary, status badge
- [ ] Tapping OrderCard shows OrderDetailSheet with all item details
- [ ] "Leave Feedback" CTA shows on completed + unrated orders only
- [ ] "Leave Feedback" navigates to FeedbackScreen (still stub) with correct orderId
