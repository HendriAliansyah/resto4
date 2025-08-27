// lib/views/staff/staff_management_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:resto2/models/join_request_model.dart';
import 'package:resto2/models/role_permission_model.dart';
import 'package:resto2/providers/auth_providers.dart';
import 'package:resto2/providers/staff_filter_provider.dart';
import 'package:resto2/providers/staff_provider.dart';
import 'package:resto2/utils/constants.dart';
import 'package:resto2/utils/snackbar.dart';
import 'package:resto2/views/widgets/app_drawer.dart';
import 'package:resto2/views/widgets/filter_expansion_tile.dart';
import 'package:resto2/views/widgets/loading_indicator.dart';
import 'package:resto2/views/widgets/sort_order_toggle.dart';

class StaffManagementPage extends HookConsumerWidget {
  const StaffManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(UIStrings.staffManagement),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.people_outline),
                text: UIStrings.currentStaff,
              ),
              Tab(
                icon: Icon(Icons.person_add_alt_1_outlined),
                text: UIStrings.joinRequests,
              ),
            ],
          ),
        ),
        drawer: const AppDrawer(),
        body: const TabBarView(
          children: [CurrentStaffView(), JoinRequestsView()],
        ),
      ),
    );
  }
}

class CurrentStaffView extends HookConsumerWidget {
  const CurrentStaffView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffListAsync = ref.watch(staffListStreamProvider);
    final filterState = ref.watch(staffFilterProvider);
    final sortedStaffList = ref.watch(sortedStaffProvider);
    final searchFocusNode = useFocusNode();

    return staffListAsync.when(
      data: (_) {
        return Column(
          children: [
            FilterExpansionTile(
              children: [
                TextFormField(
                  focusNode: searchFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Search by Name or Email',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    ref
                        .read(staffFilterProvider.notifier)
                        .setSearchQuery(value);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField2<UserRole?>(
                  value: filterState.role,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Role',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.zero,
                  ),
                  buttonStyleData: const ButtonStyleData(
                    height: 50,
                    padding: EdgeInsets.only(right: 10),
                  ),
                  onMenuStateChange: (isOpen) {
                    if (isOpen) {
                      searchFocusNode.unfocus();
                    }
                  },
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Roles'),
                    ),
                    ...UserRole.values.map(
                      (role) =>
                          DropdownMenuItem(value: role, child: Text(role.name)),
                    ),
                  ],
                  onChanged: (role) {
                    ref.read(staffFilterProvider.notifier).setRoleFilter(role);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField2<StaffSortOption>(
                        value: filterState.sortOption,
                        decoration: const InputDecoration(
                          labelText: 'Sort by',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.zero,
                        ),
                        buttonStyleData: const ButtonStyleData(
                          height: 50,
                          padding: EdgeInsets.only(right: 10),
                        ),
                        onMenuStateChange: (isOpen) {
                          if (isOpen) {
                            searchFocusNode.unfocus();
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: StaffSortOption.byRole,
                            child: Text('Role'),
                          ),
                          DropdownMenuItem(
                            value: StaffSortOption.byName,
                            child: Text('Name'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            ref
                                .read(staffFilterProvider.notifier)
                                .setSortOption(value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    SortOrderToggle(
                      currentOrder: filterState.sortOrder,
                      onOrderChanged: (order) {
                        ref
                            .read(staffFilterProvider.notifier)
                            .setSortOrder(order);
                      },
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child:
                  sortedStaffList.isEmpty
                      ? const Center(child: Text('No staff members found.'))
                      : ListView.builder(
                        itemCount: sortedStaffList.length,
                        itemBuilder: (context, index) {
                          final staff = sortedStaffList[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: ListTile(
                              title: Text(staff.displayName),
                              subtitle: Text(
                                '${staff.role.name} - ${staff.email}',
                              ),
                              trailing: Icon(
                                staff.isDisabled
                                    ? Icons.lock_person_outlined
                                    : Icons.chevron_right,
                                color:
                                    staff.isDisabled ? Colors.redAccent : null,
                              ),
                              onTap: () {
                                context.push(AppRoutes.editStaff, extra: staff);
                              },
                            ),
                          );
                        },
                      ),
            ),
          ],
        );
      },
      loading: () => const LoadingIndicator(),
      error: (e, st) => Center(child: Text('Error: ${e.toString()}')),
    );
  }
}

class JoinRequestsView extends ConsumerWidget {
  const JoinRequestsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final joinRequestsAsync = ref.watch(joinRequestsStreamProvider);
    final staffController = ref.read(staffControllerProvider);
    final restaurantId =
        ref.watch(currentUserProvider).asData?.value?.restaurantId;

    void onAccept(JoinRequestModel request) async {
      if (restaurantId == null) return;
      final selectedRole = await showDialog<UserRole>(
        context: context,
        builder: (context) {
          UserRole role = UserRole.cashier; // Default role
          return AlertDialog(
            title: const Text(UIStrings.assignRole),
            content: DropdownButtonFormField<UserRole>(
              initialValue: role,
              items:
                  UserRole.values
                      .where((r) => r != UserRole.owner) // Cannot assign owner
                      .map(
                        (r) => DropdownMenuItem(value: r, child: Text(r.name)),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) role = value;
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(UIStrings.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(role),
                child: const Text(UIStrings.assign),
              ),
            ],
          );
        },
      );

      if (selectedRole != null && context.mounted) {
        try {
          await staffController.approveJoinRequest(
            restaurantId: restaurantId,
            userId: request.userId,
            role: selectedRole,
          );
          if (context.mounted) {
            showSnackBar(
              context,
              '${request.userDisplayName} has been added to your staff.',
            );
          }
        } catch (e) {
          if (context.mounted) {
            showSnackBar(context, 'Error: ${e.toString()}', isError: true);
          }
        }
      }
    }

    void onReject(JoinRequestModel request) async {
      if (restaurantId == null) return;
      try {
        await staffController.rejectJoinRequest(
          restaurantId: restaurantId,
          userId: request.userId,
        );
        if (context.mounted) {
          showSnackBar(
            context,
            'Request from ${request.userDisplayName} has been rejected.',
          );
        }
      } catch (e) {
        if (context.mounted) {
          showSnackBar(context, 'Error: ${e.toString()}', isError: true);
        }
      }
    }

    return joinRequestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_add_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    UIStrings.noPendingRequests,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    UIStrings.noPendingRequestsMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }
        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(request.userDisplayName),
                subtitle: Text(request.userEmail),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      tooltip: 'Reject',
                      onPressed: () => onReject(request),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      tooltip: 'Accept',
                      onPressed: () => onAccept(request),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const LoadingIndicator(),
      error:
          (e, st) =>
              Center(child: Text('Error loading requests: ${e.toString()}')),
    );
  }
}
