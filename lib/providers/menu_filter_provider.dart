import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resto2/providers/staff_filter_provider.dart'; // Reuse SortOrder enum

// Enum for sorting criteria
enum MenuSortOption { byName, byPrice }

// State class to hold all filter and sort settings
class MenuFilterState {
  final String searchQuery;
  final String? courseId;
  final MenuSortOption sortOption;
  final SortOrder sortOrder;

  MenuFilterState({
    this.searchQuery = '',
    this.courseId,
    this.sortOption = MenuSortOption.byName,
    this.sortOrder = SortOrder.asc,
  });

  // copyWith is a helper that can still be useful, but our notifier will be more explicit.
  MenuFilterState copyWith({
    String? searchQuery,
    String? courseId,
    MenuSortOption? sortOption,
    SortOrder? sortOrder,
  }) {
    return MenuFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      courseId: courseId ?? this.courseId,
      sortOption: sortOption ?? this.sortOption,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

// StateNotifier to manage the state
class MenuFilterNotifier extends StateNotifier<MenuFilterState> {
  MenuFilterNotifier() : super(MenuFilterState());

  // THE FIX IS HERE: Each method now reconstructs the state, preserving other values.
  void setSearchQuery(String query) {
    state = MenuFilterState(
      searchQuery: query,
      courseId: state.courseId, // Preserve existing course filter
      sortOption: state.sortOption,
      sortOrder: state.sortOrder,
    );
  }

  void setCourseFilter(String? courseId) {
    state = MenuFilterState(
      searchQuery: state.searchQuery,
      courseId: courseId, // Set the new course filter (can be null)
      sortOption: state.sortOption,
      sortOrder: state.sortOrder,
    );
  }

  void setSortOption(MenuSortOption option) {
    state = MenuFilterState(
      searchQuery: state.searchQuery,
      courseId: state.courseId,
      sortOption: option, // Set the new sort option
      sortOrder: state.sortOrder,
    );
  }

  void setSortOrder(SortOrder order) {
    state = MenuFilterState(
      searchQuery: state.searchQuery,
      courseId: state.courseId,
      sortOption: state.sortOption,
      sortOrder: order, // Set the new sort order
    );
  }
}

// The final provider that the UI will interact with
final menuFilterProvider =
    StateNotifierProvider.autoDispose<MenuFilterNotifier, MenuFilterState>((
      ref,
    ) {
      return MenuFilterNotifier();
    });
