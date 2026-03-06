# Plateful — Phase 5: Feedback + Profile + Auth Scaffold + Polish
> Read `plateful_prd_final.md` first. Phases 1–4 must be complete.

---

## What's Already Done (Phases 1–4)
- Full project, theme, routing, entities, JSON data
- HomeScreen (list + map), RestaurantMenuScreen, ItemDetailSheet, CartFAB
- CartNotifier + CartScreen + CheckoutScreen
- OrdersNotifier + OrdersScreen + OrderDetailSheet with "Leave Feedback" CTA
- Dummy seeded orders visible on fresh install
- `/feedback/:orderId` route exists but shows stub screen

---

## Goal
All remaining screens complete. Full end-to-end demo flow working. App is demo-ready.

---

## What to Build

### 1. FeedbackState + FeedbackController

**`feedback_state.dart`:**
```dart
enum FeedbackDimension { overall, foodQuality, portionSize, serviceSpeed }

class FeedbackState {
  final Order? order;
  final int overallRating;
  final int foodQualityRating;
  final int portionSizeRating;
  final int serviceSpeedRating;
  final String comment;
  final bool isSubmitting;
  final bool submitted;

  const FeedbackState({
    this.order,
    this.overallRating = 0,
    this.foodQualityRating = 0,
    this.portionSizeRating = 0,
    this.serviceSpeedRating = 0,
    this.comment = '',
    this.isSubmitting = false,
    this.submitted = false,
  });

  bool get canSubmit =>
    overallRating > 0 && foodQualityRating > 0 &&
    portionSizeRating > 0 && serviceSpeedRating > 0;

  FeedbackState copyWith({...});
}
```

**`feedback_controller.dart`:**
```dart
class FeedbackController extends FamilyNotifier<FeedbackState, String> {
  FeedbackState build(String orderId) {
    Future.microtask(() => _loadOrder(orderId));
    return const FeedbackState();
  }

  void _loadOrder(String orderId) {
    final orders = ref.read(ordersProvider).orders;
    final order = orders.firstWhere((o) => o.id == orderId, orElse: () => throw Exception('Order not found'));
    state = state.copyWith(order: order);
  }

  void setRating(FeedbackDimension dim, int value) {
    state = switch (dim) {
      FeedbackDimension.overall      => state.copyWith(overallRating: value),
      FeedbackDimension.foodQuality  => state.copyWith(foodQualityRating: value),
      FeedbackDimension.portionSize  => state.copyWith(portionSizeRating: value),
      FeedbackDimension.serviceSpeed => state.copyWith(serviceSpeedRating: value),
    };
  }

  void setComment(String text) => state = state.copyWith(comment: text);

  Future<void> submit() async {
    if (!state.canSubmit) return;
    state = state.copyWith(isSubmitting: true);

    final feedback = FeedbackModel(
      id: 'fb_${DateTime.now().millisecondsSinceEpoch}',
      orderId: state.order!.id,
      overallRating: state.overallRating,
      foodQualityRating: state.foodQualityRating,
      portionSizeRating: state.portionSizeRating,
      serviceSpeedRating: state.serviceSpeedRating,
      comment: state.comment.isEmpty ? null : state.comment,
      submittedAt: DateTime.now(),
    );

    // persist to Hive
    final box = Hive.box('feedbacks');
    final existing = box.get('feedbacks_list');
    final list = existing != null
      ? (jsonDecode(existing) as List).map((e) => FeedbackModel.fromJson(e)).toList()
      : <FeedbackModel>[];
    list.add(feedback);
    await box.put('feedbacks_list', jsonEncode(list.map((f) => f.toJson()).toList()));

    // mark order as rated
    ref.read(ordersProvider.notifier).markAsRated(state.order!.id);

    state = state.copyWith(isSubmitting: false, submitted: true);
  }
}

final feedbackProvider = NotifierProvider.family<FeedbackController, FeedbackState, String>(
  FeedbackController.new,
);
```

### 2. FeedbackScreen UI — `lib/src/features/feedback/feedback_screen.dart`

`ConsumerStatefulWidget`. Receives `orderId` from route params.

**Listen for `submitted` → show success modal:**
```dart
ref.listen(feedbackProvider(orderId), (prev, next) {
  if (!prev!.submitted && next.submitted) {
    _showSuccessModal(context);
  }
});
```

**Layout:**
```
Scaffold(
  appBar: AppBar(title: Text('Leave Feedback'), centerTitle: true),
  body: SingleChildScrollView(
    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
    child: Column(children: [

      // Order info card
      Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(color: Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(state.order?.restaurantName ?? '', style: AppTextStyles.heading3),
          SizedBox(height: 4.h),
          Text('Order #${shortId} · ${formattedDate}', style: grey caption),
          SizedBox(height: 4.h),
          Text(itemsSummary, style: grey caption),
        ]),
      ),
      SizedBox(height: 24.h),

      // 4 rating dimensions
      DimensionRatingRow(
        label: 'Overall Experience',
        rating: state.overallRating,
        onRatingChanged: (v) => controller.setRating(FeedbackDimension.overall, v),
      ),
      SizedBox(height: 20.h),
      DimensionRatingRow(
        label: 'Food Quality',
        rating: state.foodQualityRating,
        onRatingChanged: (v) => controller.setRating(FeedbackDimension.foodQuality, v),
      ),
      SizedBox(height: 20.h),
      DimensionRatingRow(
        label: 'Portion Size',
        rating: state.portionSizeRating,
        onRatingChanged: (v) => controller.setRating(FeedbackDimension.portionSize, v),
      ),
      SizedBox(height: 20.h),
      DimensionRatingRow(
        label: 'Service Speed',
        rating: state.serviceSpeedRating,
        onRatingChanged: (v) => controller.setRating(FeedbackDimension.serviceSpeed, v),
      ),
      SizedBox(height: 24.h),

      // text field
      Align(alignment: Alignment.centerLeft,
        child: Text('Tell us more (optional)', style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w600))),
      SizedBox(height: 8.h),
      TextField(
        maxLines: 4,
        maxLength: 500,
        onChanged: controller.setComment,
        decoration: InputDecoration(
          hintText: 'What did you like or dislike? Any suggestions?',
          hintStyle: TextStyle(color: AppColors.textHint),
        ),
      ),
    ]),
  ),
  bottomNavigationBar: SafeArea(
    child: Padding(
      padding: EdgeInsets.all(16.w),
      child: AppButton(
        label: state.isSubmitting ? 'Submitting...' : 'Submit Feedback',
        isLoading: state.isSubmitting,
        onPressed: state.canSubmit && !state.isSubmitting ? () => controller.submit() : null,
      ),
    ),
  ),
)
```

**`dimension_rating_row.dart`:**
```dart
class DimensionRatingRow extends StatelessWidget {
  final String label;
  final int rating;       // 0 = unset, 1–5 = selected
  final ValueChanged<int> onRatingChanged;

  static const Map<int, String> _ratingText = {
    1: 'Poor 😞', 2: 'Fair 😐', 3: 'Good 🙂', 4: 'Great 😊', 5: 'Excellent! 🤩',
  };

  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
      SizedBox(height: 10.h),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          final starValue = index + 1;
          final isActive = starValue <= rating;
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onRatingChanged(starValue);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                '⭐',
                style: TextStyle(
                  fontSize: 40.sp,
                  color: isActive ? null : Colors.grey,
                ),
              ).animate(target: isActive ? 1 : 0)
                .scale(begin: Offset(0.8, 0.8), end: Offset(1.0, 1.0)),
            ),
          );
        }),
      ),
      SizedBox(height: 6.h),
      Center(child: Text(
        rating > 0 ? _ratingText[rating]! : '',
        style: AppTextStyles.body.copyWith(color: AppColors.primary, fontWeight: FontWeight.w500),
      )),
    ],
  );
}
```

> Note: Uses `flutter_animate` package for star pop animation. Add to pubspec if not already there.

**Success Modal** (called by `_showSuccessModal`):
```dart
showDialog(
  context: context,
  barrierDismissible: false,
  builder: (_) => AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
    content: Column(mainAxisSize: MainAxisSize.min, children: [
      Text('✅', style: TextStyle(fontSize: 64.sp)),
      SizedBox(height: 12.h),
      Text('Thank You!', style: AppTextStyles.heading2),
      SizedBox(height: 8.h),
      Text('Your feedback helps us serve you better.',
        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        textAlign: TextAlign.center),
      SizedBox(height: 20.h),
      AppButton(label: 'Done', onPressed: () {
        Navigator.of(context).pop(); // close dialog
        Navigator.of(context).pop(); // pop feedback screen back to caller
      }),
    ]),
  ),
);
```

### 3. FeedbackTabScreen UI

`ConsumerWidget`. Derives from `ordersProvider`.

```dart
final unratedOrders = ref.watch(ordersProvider.select(
  (s) => s.orders.where((o) => o.status == 'completed' && !o.isRated).toList()
));
```

**Layout:**
```
Scaffold(
  appBar: AppBar(title: Text('Feedback')),
  body: unratedOrders.isEmpty
    ? _AllCaughtUpWidget()
    : ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: unratedOrders.length,
        itemBuilder: (_, i) => UnratedOrderCard(
          order: unratedOrders[i],
          onTap: () => context.push('/feedback/${unratedOrders[i].id}'),
        ),
      ),
)
```

**`_AllCaughtUpWidget`:**
```
Center Column:
├── Text('🎉', 64px)
├── 'All caught up!' (heading3)
└── 'No pending reviews' (grey, body)
```

**`unrated_order_card.dart`:**
```
Card(radius 12, white, margin bottom 12)
Padding(all: 16)
Row:
├── Column(expanded):
│   ├── restaurant name (bold, 15px)
│   ├── formatted date (grey, 12px)
│   └── items summary (grey, 13px)
└── Row:
    ├── Text('Rate Now', primary, 13px, bold)
    └── Icon(Icons.arrow_forward_ios, primary, size 14)
```

### 4. ProfileState + ProfileController

**`profile_state.dart`:**
```dart
class ProfileState {
  final Set<String> selectedDietaryPrefs;
  final String allergiesText;
  const ProfileState({this.selectedDietaryPrefs = const {}, this.allergiesText = ''});
  ProfileState copyWith({...});
}
```

**`profile_controller.dart`:**
```dart
class ProfileController extends Notifier<ProfileState> {
  late Box _box;

  ProfileState build() {
    _box = Hive.box('profile');
    final saved = _box.get('profile_data');
    if (saved != null) {
      final json = jsonDecode(saved);
      return ProfileState(
        selectedDietaryPrefs: Set<String>.from(json['prefs'] ?? []),
        allergiesText: json['allergies'] ?? '',
      );
    }
    return const ProfileState();
  }

  void togglePref(String pref) {
    final updated = Set<String>.from(state.selectedDietaryPrefs);
    updated.contains(pref) ? updated.remove(pref) : updated.add(pref);
    state = state.copyWith(selectedDietaryPrefs: updated);
    _persist();
  }

  void updateAllergies(String text) {
    state = state.copyWith(allergiesText: text);
    _persist();
  }

  void _persist() {
    _box.put('profile_data', jsonEncode({
      'prefs': state.selectedDietaryPrefs.toList(),
      'allergies': state.allergiesText,
    }));
  }
}

final profileProvider = NotifierProvider<ProfileController, ProfileState>(ProfileController.new);
```

### 5. ProfileScreen UI

```
Scaffold(
  appBar: AppBar(title: Text('Profile')),
  body: SingleChildScrollView(
    padding: EdgeInsets.all(20.w),
    child: Column(children: [

      // Avatar
      CircleAvatar(radius: 40.r, backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Text('G', style: TextStyle(fontSize: 32.sp, color: AppColors.primary, fontWeight: FontWeight.bold))),
      SizedBox(height: 12.h),
      Text('Guest User', style: AppTextStyles.heading3),
      Text('Sign in to personalize your experience', style: grey caption),
      SizedBox(height: 24.h),

      // Dietary Preferences
      _SectionHeader('Dietary Preferences'),
      SizedBox(height: 10.h),
      Wrap(
        spacing: 8.w, runSpacing: 8.h,
        children: ['Vegan 🌱', 'Vegetarian', 'Gluten-Free', 'Halal', 'No Spicy', 'Dairy-Free']
          .map((pref) => AppChip(
            label: pref,
            isSelected: state.selectedDietaryPrefs.contains(pref),
            onTap: () { HapticFeedback.lightImpact(); controller.togglePref(pref); },
          )).toList(),
      ),
      SizedBox(height: 20.h),

      // Allergies
      _SectionHeader('Allergies'),
      SizedBox(height: 10.h),
      TextField(
        maxLines: 2,
        controller: TextEditingController(text: state.allergiesText),
        onChanged: controller.updateAllergies,
        decoration: InputDecoration(hintText: 'e.g. peanuts, shellfish, tree nuts'),
      ),
      SizedBox(height: 24.h),

      Divider(color: AppColors.border),

      // Order History tile
      ListTile(
        leading: Icon(Icons.receipt_long_outlined, color: AppColors.primary),
        title: Text('Order History'),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => context.go('/shell/orders'),
      ),

      Divider(color: AppColors.border),

      // Sign Out tile
      ListTile(
        leading: Icon(Icons.logout, color: AppColors.error),
        title: Text('Sign Out', style: TextStyle(color: AppColors.error)),
        onTap: () => showDialog(context: context, builder: (_) => AlertDialog(
          title: Text('Coming Soon'),
          content: Text('Sign out will be available once authentication is set up.'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
        )),
      ),
    ]),
  ),
)
```

### 6. LoginScreen UI

`ConsumerStatefulWidget`.

```
Scaffold(
  body: SafeArea(
    child: SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(children: [
        SizedBox(height: 40.h),

        // Logo
        Text('🍽️', style: TextStyle(fontSize: 72.sp)),
        SizedBox(height: 8.h),
        Text('Plateful', style: AppTextStyles.heading1.copyWith(color: AppColors.primary)),
        Text('Campus Dining Made Easy', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
        SizedBox(height: 48.h),

        // Email field
        TextField(
          onChanged: controller.updateEmail,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        SizedBox(height: 12.h),

        // Password field
        TextField(
          onChanged: controller.updatePassword,
          obscureText: !state.passwordVisible,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(state.passwordVisible ? Icons.visibility_off : Icons.visibility),
              onPressed: controller.togglePasswordVisibility,
            ),
          ),
        ),
        SizedBox(height: 24.h),

        // Sign In button
        AppButton(label: 'Sign In', onPressed: () => controller.signIn()),
        SizedBox(height: 12.h),

        // Continue as Guest
        TextButton(
          onPressed: () => context.go('/shell/home'),
          child: Text('Continue as Guest', style: TextStyle(color: AppColors.textSecondary)),
        ),
        SizedBox(height: 24.h),

        // Divider
        Row(children: [Expanded(child: Divider()), Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text('or', style: grey caption),
        ), Expanded(child: Divider())]),
        SizedBox(height: 16.h),

        // Google Sign-In (disabled)
        Tooltip(
          message: 'Coming soon',
          child: OutlinedButton.icon(
            icon: Text('G', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            label: Text('Sign in with Google', style: TextStyle(color: Colors.grey)),
            onPressed: null,   // disabled
            style: OutlinedButton.styleFrom(
              minimumSize: Size(double.infinity, 52.h),
              side: BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ]),
    ),
  ),
)
```

### 7. Polish Pass

**Empty states** — ensure all these have proper illustrated empty states (large emoji + title + subtitle):
- CartScreen (empty): '🛒' · 'Your cart is empty' · 'Add some delicious food!'
- OrdersScreen (empty): '📋' · 'No orders yet' · 'Start by browsing restaurants'
- FeedbackTabScreen (all rated): '🎉' · 'All caught up!' · 'No pending reviews'
- HomeScreen (no results): '🔍' · 'No restaurants found' · 'Try a different search'

**Loading states:**
- HomeScreen: `CircularProgressIndicator` centered while `isLoading`
- RestaurantMenuScreen: same while loading items

**Snackbars** (use `ScaffoldMessenger.of(context).showSnackBar`):
- Add to cart: `'${item.name} added to cart 🛒'`
- Order placed: shown via success dialog (no snackbar needed)
- Feedback submitted: shown via success modal (no snackbar needed)

**Haptic feedback** (`HapticFeedback.lightImpact()`):
- Star rating tap
- Dietary chip toggle
- Add to cart (the `+` button)
- Place Order button tap

**Page transitions** — in `routes.dart`, wrap push routes with custom transition:
```dart
GoRoute(
  path: '/restaurant/:restaurantId',
  pageBuilder: (context, state) => CustomTransitionPage(
    child: RestaurantMenuScreen(restaurantId: state.pathParameters['restaurantId']!),
    transitionsBuilder: (_, anim, __, child) => SlideTransition(
      position: Tween<Offset>(begin: Offset(0, 1), end: Offset.zero).animate(anim),
      child: child,
    ),
  ),
),
// same slide-up for /cart, /checkout, /feedback/:orderId
```

**Status bar:**
- On gradient screens (SplashScreen header, HomeScreen header, RestaurantMenuScreen expanded header):
  ```dart
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  ```

**Hive box opening** — ensure all 5 boxes opened in `main.dart` before `runApp`:
```dart
await Hive.openBox('cart');
await Hive.openBox('orders');
await Hive.openBox('feedbacks');
await Hive.openBox('profile');
await Hive.openBox('meta');
```

### 8. Firebase Init Hardening
```dart
// main.dart
try {
  await Firebase.initializeApp();
} catch (e) {
  debugPrint('Firebase init skipped: $e');
  // App continues normally — Firebase not required for POC
}
```

---

## Full End-to-End Demo Flow (Acceptance Criteria)

Run through this entire flow to verify the app is demo-ready:

- [ ] App boots → SplashScreen 1.5s → HomeScreen
- [ ] Search "burger" → filters to restaurants with burger items
- [ ] Tap filter chip "Vegan" → only vegan restaurants shown
- [ ] Switch to Map tab → user location dot + 6 nearby pins visible
- [ ] Tap a pin → bottom sheet with restaurant info + "View Menu"
- [ ] Tap "View Menu" → RestaurantMenuScreen opens (slide up)
- [ ] SliverAppBar collapses on scroll
- [ ] Tap category tab → filters items correctly
- [ ] Tap menu item → ItemDetailSheet opens with nutrition + allergens
- [ ] Qty stepper works, price updates
- [ ] "Add to Cart" → sheet closes → snackbar → CartFAB appears
- [ ] CartFAB shows correct count + total
- [ ] Add item from different restaurant → conflict dialog → "Clear & Add" works
- [ ] Tap CartFAB → CartScreen with items
- [ ] Update qty in cart → total updates
- [ ] Delete item → item removed
- [ ] "Proceed to Checkout" → CheckoutScreen
- [ ] Toggle "Schedule" → time picker shows
- [ ] "Place Order" → loading → OrderSuccessDialog
- [ ] "Track Order" → Orders tab (stack cleared)
- [ ] New order at top of list with "Preparing" badge
- [ ] 3 seeded orders below with "Completed" badge
- [ ] Tap a completed order → OrderDetailSheet
- [ ] "Leave Feedback" → FeedbackScreen
- [ ] Rate all 4 dimensions → Submit button enables
- [ ] Star pop animation works on tap
- [ ] Submit → success modal → pop back
- [ ] Order disappears from FeedbackTab (now rated)
- [ ] Feedback tab empty state shows after all rated
- [ ] Profile: toggle dietary chip → persists after hot restart
- [ ] Profile: "Order History" → navigates to Orders tab
- [ ] Login stub: "Continue as Guest" → HomeScreen
