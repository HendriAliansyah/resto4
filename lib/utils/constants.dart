// lib/utils/constants.dart (Corrected)
import 'package:flutter/material.dart';

// Route Constants
class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String onboarding = '/onboarding';
  static const String notifications = '/notifications';
  static const String manageRestaurant = '/manage-restaurant';
  static const String manageStaff = '/manage-staff';
  static const String editStaff = '/edit-staff';
  static const String settings = '/settings';
  static const String manageCourses = '/manage-courses';
  static const String manageTableTypes = '/manage-table-types';
  static const String manageTables = '/manage-tables';
  static const String manageOrderTypes = '/manage-order-types';
  static const String manageMenu = '/manage-menu';
  static const String manageInventory = '/manage-inventory';
  static const String receivingInventory = '/receiving-inventory';
  static const String purchaseHistory = '/purchase-history';
  static const String editStock = '/edit-stock';
  static const String stockMovementHistory = '/stock-movement-history';
}

// UI String Constants
class UIStrings {
  static const String appTitle = 'Restaurant App';

  // Auth Screens
  static const String loginTitle = 'Login';
  static const String registerTitle = 'Register';
  static const String forgotPasswordTitle = 'Forgot Password';
  static const String emailLabel = 'Email';
  static const String passwordLabel = 'Password';
  static const String displayNameLabel = 'Display Name';
  static const String confirmPasswordLabel = 'Confirm Password';
  static const String loginButton = 'Login';
  static const String registerButton = 'Register';
  static const String resetButton = 'Reset Password';
  static const String dontHaveAccount = 'Don\'t have an account? Register';
  static const String alreadyHaveAccount = 'Already have an account? Login';
  static const String forgotPasswordPrompt = 'Forgot Password?';

  // Onboarding Screen
  static const String welcome = 'Welcome!';
  static const String welcomeUser = 'Welcome, {name}! 👋';
  static const String createNewRestaurant = 'Create a New Restaurant';
  static const String or = 'or';
  static const String joinExistingRestaurant =
      'Join an existing restaurant by entering its ID:';
  static const String restaurantId = 'Restaurant ID';
  static const String restaurantIdHint =
      'Enter the ID provided by your manager';
  static const String sendJoinRequest = 'Send Join Request';
  static const String requestSentSuccessfully =
      'Your request has been sent successfully.';
  static const String restaurantNotFound =
      'Restaurant not found. Please check the ID and try again.';
  static const String unexpectedError =
      'An unexpected error occurred. Please try again.';

  // Notifications
  static const String notificationsTitle = 'Notifications';
  static const String noNotifications = 'No Notifications Yet';
  static const String noNotificationsMessage =
      'Important updates and requests from your restaurant will appear here.';
  static const String newJoinRequestTitle = 'New Join Request';
  static const String joinRequestMessage =
      'A user has requested to join your restaurant.';
  static const String requestApproved =
      'Your request to join the restaurant was approved.';
  static const String requestRejected =
      'Your request to join the restaurant was rejected.';
  static const String newNotification = 'You have a new notification.';
  static const String close = 'Close';
  static const String requestApprovedTitle = 'Request Approved!';
  static const String requestRejectedTitle = 'Request Rejected';

  // Restaurant Management
  static const String createRestaurantTitle = 'Create Your Restaurant';
  static const String manageRestaurantTitle = 'Manage Restaurant';
  static const String restaurantName = 'Restaurant Name';
  static const String address = 'Address';
  static const String phoneNumber = 'Phone Number';
  static const String phoneNumberHint = '08123654789';
  static const String saveChanges = 'Save Changes';
  static const String saving = 'Saving...';

  // Package Management
  static const String packageManagement = 'Package Management';

  // Staff Management
  static const String staffManagement = 'Staff Management';
  static const String currentStaff = 'Current Staff';
  static const String joinRequests = 'Join Requests';
  static const String noStaffFound = 'No Staff Found';
  static const String noStaffMessage =
      'When users join your restaurant, they will appear here.';
  static const String noPendingRequests = 'No Pending Requests';
  static const String noPendingRequestsMessage =
      'When a new user requests to join your restaurant, you will see their request here.';
  static const String assignRole = 'Assign a Role';
  static const String cancel = 'Cancel';
  static const String assign = 'Assign';

  // Edit Staff
  static const String editStaffTitle = 'Edit Staff: {name}';
  static const String name = 'Name: {name}';
  static const String email = 'Email: {email}';
  static const String roleUnchanged = 'The owner\'s role cannot be changed.';
  static const String adminRoleUnchanged =
      'Only an owner can change an admin\'s role.';
  static const String unblockUser = 'Unblock User';
  static const String blockUser = 'Block User';
}

// You can also add color and style constants here
class AppColors {
  static const Color primary = Colors.orange;
  static const Color error = Colors.redAccent;
}

class DBConstants {
  static const String usersCollection = 'users';
}
