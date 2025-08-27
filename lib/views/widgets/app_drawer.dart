// lib/views/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resto2/models/role_permission_model.dart';
import 'package:resto2/providers/auth_providers.dart';
import 'package:resto2/utils/constants.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).asData?.value;
    final authController = ref.read(authControllerProvider.notifier);

    if (currentUser == null) {
      return const Drawer(); // Return an empty drawer if user is not loaded
    }

    final userRole = currentUser.role;

    // Permission checks using the logic from YOUR file
    final bool canAccessMasterRestaurant =
        userRole != null
            ? rolePermissions[userRole]?.contains(
                  PagePermission.accessMasterRestaurant,
                ) ??
                false
            : false;

    final bool canAccessStaffManagement =
        userRole != null
            ? rolePermissions[userRole]?.contains(
                  PagePermission.accessStaffManagement,
                ) ??
                false
            : false;

    final bool canAccessCourseMaster =
        userRole != null
            ? rolePermissions[userRole]?.contains(
                  PagePermission.accessCourseMaster,
                ) ??
                false
            : false;

    final bool canAccessTableTypeMaster =
        userRole != null
            ? rolePermissions[userRole]?.contains(
                  PagePermission.accessTableTypeMaster,
                ) ??
                false
            : false;

    final bool canAccessTableMaster =
        userRole != null
            ? rolePermissions[userRole]?.contains(
                  PagePermission.accessTableMaster,
                ) ??
                false
            : false;

    final bool canAccessOrderTypeMaster =
        userRole != null
            ? rolePermissions[userRole]?.contains(
                  PagePermission.accessOrderTypeMaster,
                ) ??
                false
            : false;

    final bool canAccessMenuMaster =
        userRole != null
            ? rolePermissions[userRole]?.contains(
                  PagePermission.accessMenuMaster,
                ) ??
                false
            : false;

    final bool canAccessInventoryMaster =
        userRole != null
            ? rolePermissions[userRole]?.contains(
                  PagePermission.accessInventoryMaster,
                ) ??
                false
            : false;

    final bool canAccessPurchasePage =
        userRole != null
            ? rolePermissions[userRole]?.contains(
                  PagePermission.accessPurchasePage,
                ) ??
                false
            : false;
    final bool canAccessPurchaseHistory =
        userRole != null
            ? rolePermissions[userRole]?.contains(
                  PagePermission.accessPurchaseHistory,
                ) ??
                false
            : false;
    final bool canAccessStockEdit =
        userRole != null
            ? rolePermissions[userRole]?.contains(
                  PagePermission.accessStockEdit,
                ) ??
                false
            : false;

    final bool canAccessStockMovementHistory =
        userRole != null
            ? rolePermissions[userRole]?.contains(
                  PagePermission.accessStockMovementHistory,
                ) ??
                false
            : false;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
              currentUser.displayName ?? 'No Name',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(currentUser.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: Text(
                currentUser.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(fontSize: 40.0),
              ),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.home);
            },
          ),
          if (canAccessMasterRestaurant)
            ListTile(
              leading: const Icon(Icons.storefront_outlined),
              title: const Text('Manage Restaurant'),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.manageRestaurant);
              },
            ),
          if (canAccessStaffManagement)
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Manage Staff'),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.manageStaff);
              },
            ),
          if (canAccessCourseMaster)
            ListTile(
              leading: const Icon(Icons.book_outlined),
              title: const Text('Course Master'),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.manageCourses);
              },
            ),
          if (canAccessTableTypeMaster)
            ListTile(
              leading: const Icon(Icons.category_outlined),
              title: const Text('Table Type Master'),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.manageTableTypes);
              },
            ),
          if (canAccessTableMaster)
            ListTile(
              leading: const Icon(Icons.table_restaurant_outlined),
              title: const Text('Table Master'),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.manageTables);
              },
            ),
          if (canAccessOrderTypeMaster)
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Order Type Master'),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.manageOrderTypes);
              },
            ),
          if (canAccessMenuMaster)
            ListTile(
              leading: const Icon(Icons.restaurant_menu_outlined),
              title: const Text('Menu Master'),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.manageMenu);
              },
            ),
          if (canAccessInventoryMaster)
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('Inventory & Stock'), // Updated Title
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.manageInventory);
              },
            ),
          if (canAccessPurchasePage)
            ListTile(
              leading: const Icon(
                Icons.inventory_outlined,
              ), // A more fitting icon
              title: const Text('Receiving Inventory'), // Updated Text
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.receivingInventory); // Updated route
              },
            ),
          if (canAccessPurchaseHistory) // Add this block
            ListTile(
              leading: const Icon(Icons.history_outlined),
              title: const Text('Purchase History'),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.purchaseHistory);
              },
            ),
          if (canAccessStockEdit)
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('Edit Stock'),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.editStock);
              },
            ),
          if (canAccessStockMovementHistory)
            ListTile(
              leading: const Icon(Icons.sync_alt),
              title: const Text('Stock Movement History'),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.stockMovementHistory);
              },
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.settings);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log Out'),
            onTap: () {
              Navigator.pop(context);
              authController.signOut();
            },
          ),
        ],
      ),
    );
  }
}
