import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resto2/controllers/staff_controller.dart';
import 'package:resto2/models/join_request_model.dart';
import 'package:resto2/models/staff_model.dart';
import 'package:resto2/providers/staff_filter_provider.dart';
import 'package:resto2/services/staff_service.dart';
import 'auth_providers.dart';

// Provider for the new StaffService
final staffServiceProvider = Provider((ref) => StaffService());

final staffListStreamProvider = StreamProvider.autoDispose<List<Staff>>((ref) {
  final restaurantId =
      ref.watch(currentUserProvider).asData?.value?.restaurantId;
  if (restaurantId == null) {
    return Stream.value([]);
  }
  return FirebaseFirestore.instance
      .collection('users')
      .where('restaurantId', isEqualTo: restaurantId)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          // Ensure role is not null, defaulting if necessary
          if (data['role'] == null) {
            data['role'] = 'cashier';
          }
          return Staff.fromJson(data);
        }).toList();
      });
});

// Stream provider to get all pending join requests for the current restaurant
final joinRequestsStreamProvider =
    StreamProvider.autoDispose<List<JoinRequestModel>>((ref) {
      final user = ref.watch(currentUserProvider).asData?.value;

      if (user?.restaurantId != null) {
        return ref
            .watch(staffServiceProvider)
            .getPendingJoinRequests(user!.restaurantId!);
      }

      return Stream.value(<JoinRequestModel>[]);
    });

final staffControllerProvider = Provider.autoDispose<StaffController>((ref) {
  return StaffController(ref);
});

final sortedStaffProvider = Provider.autoDispose<List<Staff>>((ref) {
  final staffList = ref.watch(staffListStreamProvider).asData?.value ?? [];
  final filterState = ref.watch(staffFilterProvider);

  final filteredList =
      staffList.where((staff) {
        final query = filterState.searchQuery.trim().toLowerCase();

        // Search match (name or email)
        final searchMatch =
            query.isEmpty ||
            staff.displayName.toLowerCase().contains(query) ||
            staff.email.toLowerCase().contains(query);

        // Role match
        final roleMatch =
            filterState.role == null || staff.role == filterState.role;

        return searchMatch && roleMatch;
      }).toList();

  final sortedList = List.of(filteredList);
  sortedList.sort((a, b) {
    int comparison;
    switch (filterState.sortOption) {
      case StaffSortOption.byName:
        comparison = a.displayName.compareTo(b.displayName);
        break;
      case StaffSortOption.byRole:
        comparison = a.role.name.compareTo(b.role.name);
        break;
    }
    return filterState.sortOrder == SortOrder.asc ? comparison : -comparison;
  });

  return sortedList;
});
