enum AppRoute {
  splash,
  login,
  home,
  orders,
  feedback,
  profile,
  restaurantMenu,
  cart,
  checkout,
  feedbackForm,
}

extension AppRouteExt on AppRoute {
  String get path => switch (this) {
        AppRoute.splash => '/splash',
        AppRoute.login => '/login',
        AppRoute.home => '/shell/home',
        AppRoute.orders => '/shell/orders',
        AppRoute.feedback => '/shell/feedback',
        AppRoute.profile => '/shell/profile',
        AppRoute.restaurantMenu => '/restaurant/:restaurantId',
        AppRoute.cart => '/cart',
        AppRoute.checkout => '/checkout',
        AppRoute.feedbackForm => '/feedback/:orderId',
      };
}
