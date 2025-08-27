// lib/views/table_type/table_type_management_page.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resto2/models/table_type_model.dart';
import 'package:resto2/providers/table_type_provider.dart';
import 'package:resto2/views/table_type/widgets/table_type_dialog.dart';
import 'package:resto2/views/widgets/app_drawer.dart';

class TableTypeManagementPage extends ConsumerWidget {
  const TableTypeManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableTypesAsync = ref.watch(tableTypesStreamProvider);
    final controller = ref.read(tableTypeControllerProvider.notifier);

    void showTableTypeDialog({TableType? tableType}) {
      showDialog(
        context: context,
        builder: (_) => TableTypeDialog(tableType: tableType),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Table Type Master')),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: tableTypesAsync.when(
          data: (types) {
            if (types.isEmpty) {
              return const Center(
                child: Text('No table types found. Add one to get started!'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: types.length,
              itemBuilder: (_, index) {
                final type = types[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: ListTile(
                    title: Text(
                      type.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => showTableTypeDialog(tableType: type),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          onPressed: () => controller.deleteTableType(type.id),
                          icon: Icon(
                            Icons.delete_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text(e.toString())),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTableTypeDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
