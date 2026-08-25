import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/auth/presentation/pages/password_reset_page.dart';
import '../../features/booking/presentation/pages/booking_args.dart';
import '../../features/booking/presentation/pages/booking_page.dart';
import '../../features/farm_details/presentation/pages/farm_details_page.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/my_bookings/presentation/pages/my_bookings_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/reviews/presentation/pages/submit_review_args.dart';
import '../../features/reviews/presentation/pages/submit_review_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const AuthPage(),
    ),
    GoRoute(
      path: '/password-reset',
      name: 'password-reset',
      builder: (context, state) => const PasswordResetPage(),
    ),
    GoRoute(
      path: '/farm-details',
      name: 'farm-details',
      builder: (context, state) => const FarmDetailsPage(),
    ),
    GoRoute(
      path: '/booking',
      name: 'booking',
      builder: (context, state) => BookingPage(args: state.extra as BookingArgs),
    ),
    GoRoute(
      path: '/my-bookings',
      name: 'my-bookings',
      builder: (context, state) => const MyBookingsPage(),
    ),
    GoRoute(
      path: '/submit-review',
      name: 'submit-review',
      builder: (context, state) => SubmitReviewPage(args: state.extra as SubmitReviewArgs),
    ),
    GoRoute(
      path: '/favorites',
      name: 'favorites',
      builder: (context, state) => const FavoritesPage(),
    ),
  ],
);
