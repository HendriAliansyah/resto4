// lib/models/role_permission_model.dart
// Defines the different roles a user can have in the application.
enum UserRole { owner, admin, manager, cashier }

// Defines permissions based on page access.
enum PagePermission {
  accessMasterRestaurant,
  accessStaffManagement,
  accessCourseMaster,
  accessTableTypeMaster,
  accessTableMaster,
  accessOrderTypeMaster,
  accessMenuMaster,
  accessInventoryMaster,
  accessPurchasePage,
  accessPurchaseHistory,
  accessStockEdit,
  accessStockMovementHistory,
}

// Maps each user role to a list of pages they are allowed to access.
const Map<UserRole, List<PagePermission>> rolePermissions = {
  UserRole.owner: [
    PagePermission.accessMasterRestaurant,
    PagePermission.accessStaffManagement,
    PagePermission.accessCourseMaster,
    PagePermission.accessTableTypeMaster,
    PagePermission.accessTableMaster,
    PagePermission.accessOrderTypeMaster,
    PagePermission.accessMenuMaster,
    PagePermission.accessInventoryMaster,
    PagePermission.accessPurchasePage,
    PagePermission.accessPurchaseHistory,
    PagePermission.accessStockEdit,
    PagePermission.accessStockMovementHistory,
  ],
  UserRole.admin: [
    PagePermission.accessStaffManagement,
    PagePermission.accessCourseMaster,
    PagePermission.accessTableTypeMaster,
    PagePermission.accessTableMaster,
    PagePermission.accessOrderTypeMaster,
    PagePermission.accessMenuMaster,
    PagePermission.accessInventoryMaster,
    PagePermission.accessPurchasePage,
    PagePermission.accessPurchaseHistory,
    PagePermission.accessStockEdit,
    PagePermission.accessStockMovementHistory,
  ],
  UserRole.manager: [
    PagePermission.accessTableTypeMaster,
    PagePermission.accessTableMaster,
    PagePermission.accessInventoryMaster,
    PagePermission.accessPurchasePage,
    PagePermission.accessPurchaseHistory,
    PagePermission.accessStockEdit,
    PagePermission.accessStockMovementHistory,
  ],
  UserRole.cashier: [
    // Cashier has no page-level permissions
  ],
};
