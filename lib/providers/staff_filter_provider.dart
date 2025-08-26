import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resto2/models/role_permission_model.dart'; // Import this

// Enum for what to sort by
enum StaffSortOption { byName, byRole }

// Enum for the sort order
enum SortOrder { asc, desc }

// State class to hold all settings
class StaffFilterState {
  final StaffSortOption sortOption;
  final SortOrder sortOrder;
  final String searchQuery;
  final UserRole? role; // New property for the role filter

  StaffFilterState({
    this.sortOption = StaffSortOption.byRole,
    this.sortOrder = SortOrder.asc,
    this.searchQuery = '',
    this.role, // Default to null (all roles)
  });

  // This is kept for internal consistency but the notifier will use a more explicit pattern.
  StaffFilterState copyWith({
    StaffSortOption? sortOption,
    SortOrder? sortOrder,
    String? searchQuery,
    UserRole? role,
  }) {
    return StaffFilterState(
      sortOption: sortOption ?? this.sortOption,
      sortOrder: sortOrder ?? this.sortOrder,
      searchQuery: searchQuery ?? this.searchQuery,
      role: role, // Allow role to be explicitly set to null
    );
  }
}

// StateNotifier to manage the filter state
class StaffFilterNotifier extends StateNotifier<StaffFilterState> {
  StaffFilterNotifier() : super(StaffFilterState());

  void setSortOption(StaffSortOption option) {
    state = state.copyWith(sortOption: option);
  }

  void setSortOrder(SortOrder order) {
    state = state.copyWith(sortOrder: order);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  // THE FIX IS HERE: This method now correctly handles being set to null.
  void setRoleFilter(UserRole? role) {
    // We create a new state object to ensure the change is always applied.
    state = StaffFilterState(
      role: role, // Explicitly set the new value (which can be null)
      searchQuery: state.searchQuery,
      sortOption: state.sortOption,
      sortOrder: state.sortOrder,
    );
  }
}

// The final provider the UI will use
final staffFilterProvider =
    StateNotifierProvider.autoDispose<StaffFilterNotifier, StaffFilterState>((
      ref,
    ) {
      return StaffFilterNotifier();
    });
