// lib/utils/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resto2/models/staff_model.dart';
import 'package:resto2/views/auth/splash_screen.dart';
import 'package:resto2/views/course/course_management_page.dart';
import 'package:resto2/views/inventory/edit_stock_page.dart';
import 'package:resto2/views/inventory/inventory_management_page.dart';
import 'package:resto2/views/inventory/stock_movement_history_page.dart';
import 'package:resto2/views/menu/menu_management_page.dart';
import 'package:resto2/views/notifications/notification_page.dart';
import 'package:resto2/views/onboarding/onboarding_screen.dart';
import 'package:resto2/views/order_type/order_type_management_page.dart';
import 'package:resto2/views/purchase/purchase_history_page.dart';
import 'package:resto2/views/purchase/purchase_page.dart'; // Added
import 'package:resto2/views/restaurant/master_restaurant_page.dart';
import 'package:resto2/views/settings/settings_page.dart';
import 'package:resto2/views/staff/edit_staff_page.dart';
import 'package:resto2/views/staff/staff_management_page.dart';
import 'package:resto2/views/table/table_management_page.dart';
import 'package:resto2/views/table_type/table_type_management_page.dart';
import '../providers/auth_providers.dart';
import '../views/auth/forgot_password_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/home/home_screen.dart';
import 'constants.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangeProvider);
  final appUser = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: '/', // Start at the splash screen
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationPage(),
      ),
      GoRoute(
        path: AppRoutes.manageRestaurant,
        builder: (context, state) => const MasterRestaurantPage(),
      ),
      GoRoute(
        path: AppRoutes.manageStaff,
        builder: (context, state) => const StaffManagementPage(),
      ),
      GoRoute(
        path: AppRoutes.editStaff,
        builder: (context, state) {
          final staff = state.extra as Staff; // Uses your 'Staff' class
          return EditStaffPage(staff: staff);
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.manageCourses,
        builder: (context, state) => const CourseManagementPage(),
      ),
      GoRoute(
        path: AppRoutes.manageTableTypes,
        builder: (context, state) => const TableTypeManagementPage(),
      ),
      GoRoute(
        path: AppRoutes.manageTables,
        builder: (context, state) => const TableManagementPage(),
      ),
      GoRoute(
        path: AppRoutes.manageOrderTypes,
        builder: (context, state) => const OrderTypeManagementPage(),
      ),
      GoRoute(
        path: AppRoutes.manageMenu,
        builder: (context, state) => const MenuManagementPage(),
      ),
      GoRoute(
        path: AppRoutes.manageInventory,
        builder: (context, state) => const InventoryManagementPage(),
      ),
      GoRoute(
        path: AppRoutes.receivingInventory,
        builder: (context, state) => const ReceivingInventoryPage(),
      ),
      GoRoute(
        // Add this route
        path: AppRoutes.purchaseHistory,
        builder: (context, state) => const PurchaseHistoryPage(),
      ),
      GoRoute(
        path: AppRoutes.editStock,
        builder: (context, state) => const EditStockPage(),
      ),
      GoRoute(
        path: AppRoutes.stockMovementHistory,
        builder: (context, state) => const StockMovementHistoryPage(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final onSplash = state.matchedLocation == '/';
      final userIsAuthenticating =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.forgotPassword;

      // While providers are loading, stay on the splash screen.
      if (authState.isLoading ||
          (authState.value != null && appUser.isLoading)) {
        return onSplash ? null : '/';
      }

      final loggedIn = authState.hasValue && authState.value != null;

      // If the user is logged in, we need to determine where to go.
      if (loggedIn) {
        final hasRole =
            appUser.value?.role != null && appUser.value?.restaurantId != null;

        if (hasRole) {
          // If user has a role, redirect away from auth/onboarding/splash pages to home.
          if (userIsAuthenticating ||
              state.matchedLocation == AppRoutes.onboarding ||
              onSplash) {
            return AppRoutes.home;
          }
        } else {
          // If user has no role, redirect to onboarding unless they are already there or creating a restaurant.
          if (state.matchedLocation != AppRoutes.onboarding &&
              state.matchedLocation != AppRoutes.manageRestaurant) {
            return AppRoutes.onboarding;
          }
        }
      }
      // If the user is not logged in
      else {
        // Redirect from any protected page to the login screen.
        if (!userIsAuthenticating) {
          return AppRoutes.login;
        }
      }

      // No redirect needed for the current location.
      return null;
    },
  );
});
