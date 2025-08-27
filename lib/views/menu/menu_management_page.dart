// lib/views/menu/menu_management_page.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:resto2/models/menu_model.dart';
import 'package:resto2/providers/course_provider.dart';
import 'package:resto2/providers/menu_filter_provider.dart';
import 'package:resto2/providers/menu_provider.dart';
import 'package:resto2/providers/order_type_provider.dart';
import 'package:resto2/views/menu/widgets/menu_bottom_sheet.dart';
import 'package:resto2/views/widgets/app_drawer.dart';
import 'package:resto2/views/widgets/filter_expansion_tile.dart';
import 'package:resto2/views/widgets/sort_order_toggle.dart';

class MenuManagementPage extends ConsumerWidget {
  const MenuManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menusAsync = ref.watch(menusStreamProvider);
    final coursesAsync = ref.watch(coursesStreamProvider);
    final orderTypesAsync = ref.watch(orderTypesStreamProvider);
    final sortedMenus = ref.watch(sortedMenusProvider);
    final filterState = ref.watch(menuFilterProvider);

    void showMenuSheet({MenuModel? menu}) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true, // This is the fix
        builder: (_) => MenuBottomSheet(menu: menu),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Menu Master')),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            // Dismiss the keyboard when the user taps on an empty space
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              coursesAsync.when(
                data:
                    (courses) => FilterExpansionTile(
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Search by Name',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged:
                              (value) => ref
                                  .read(menuFilterProvider.notifier)
                                  .setSearchQuery(value),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField2<String>(
                          value: filterState.courseId,
                          decoration: const InputDecoration(
                            labelText: 'Filter by Course',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.zero,
                          ),
                          buttonStyleData: const ButtonStyleData(
                            height: 50,
                            padding: EdgeInsets.only(right: 10),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('All Courses'),
                            ),
                            ...courses.map(
                              (course) => DropdownMenuItem(
                                value: course.id,
                                child: Text(course.name),
                              ),
                            ),
                          ],
                          onChanged:
                              (courseId) => ref
                                  .read(menuFilterProvider.notifier)
                                  .setCourseFilter(courseId),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: DropdownButtonFormField2<MenuSortOption>(
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
                                items: const [
                                  DropdownMenuItem(
                                    value: MenuSortOption.byName,
                                    child: Text('Name'),
                                  ),
                                  DropdownMenuItem(
                                    value: MenuSortOption.byPrice,
                                    child: Text('Price'),
                                  ),
                                ],
                                onChanged: (option) {
                                  if (option != null) {
                                    ref
                                        .read(menuFilterProvider.notifier)
                                        .setSortOption(option);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            SortOrderToggle(
                              currentOrder: filterState.sortOrder,
                              onOrderChanged:
                                  (order) => ref
                                      .read(menuFilterProvider.notifier)
                                      .setSortOrder(order),
                            ),
                          ],
                        ),
                      ],
                    ),
                loading: () => const SizedBox.shrink(),
                error: (e, st) => const SizedBox.shrink(),
              ),
              Expanded(
                child: menusAsync.when(
                  data: (_) {
                    if (coursesAsync.isLoading || orderTypesAsync.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final courseMap = {
                      for (var c in coursesAsync.asData!.value) c.id: c.name,
                    };
                    final orderTypeMap = {
                      for (var ot in orderTypesAsync.asData!.value)
                        ot.id: ot.name,
                    };

                    if (sortedMenus.isEmpty) {
                      return const Center(child: Text('No menu items found.'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: sortedMenus.length,
                      itemBuilder: (_, index) {
                        final menu = sortedMenus[index];
                        final courseName = courseMap[menu.courseId] ?? 'N/A';
                        final orderTypeName =
                            orderTypeMap[menu.orderTypeId] ?? 'N/A';
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          margin: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 8,
                          ),
                          child: ListTile(
                            onTap: () => showMenuSheet(menu: menu),
                            leading: SizedBox(
                              width: 56,
                              height: 56,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child:
                                    menu.imageUrl != null
                                        ? Image.network(
                                          menu.imageUrl!,
                                          fit: BoxFit.cover,
                                        )
                                        : Container(
                                          color: Colors.grey.shade300,
                                          child: const Icon(
                                            Icons.image_not_supported,
                                          ),
                                        ),
                              ),
                            ),
                            title: Text(
                              menu.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '$courseName • $orderTypeName',
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              '\$${menu.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text(e.toString())),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showMenuSheet(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
