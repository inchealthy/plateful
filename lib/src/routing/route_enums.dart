enum AppRoute {
  splash,
  login,
  home,
  orders,
  feedback,
  plato,
  profile,
  restaurantMenu,
  cart,
  checkout,
  feedbackForm,
  restaurantFeedbackForm,
}

extension AppRouteExt on AppRoute {
  String get path => switch (this) {
        AppRoute.splash => '/splash',
        AppRoute.login => '/login',
        AppRoute.home => '/shell/home',
        AppRoute.orders => '/shell/orders',
        AppRoute.feedback => '/shell/feedback',
        AppRoute.plato => '/shell/plato',
        AppRoute.profile => '/shell/profile',
        AppRoute.restaurantMenu => '/restaurant/:restaurantId',
        AppRoute.cart => '/cart',
        AppRoute.checkout => '/checkout',
        AppRoute.feedbackForm => '/feedback/:orderId',
        AppRoute.restaurantFeedbackForm => '/feedback/restaurant/:restaurantId',
      };
}
