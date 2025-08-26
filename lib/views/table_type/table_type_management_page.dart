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

    // THE FIX: The listener has been removed from this page.

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
          data:
              (types) => ListView.builder(
                itemCount: types.length,
                itemBuilder: (_, index) {
                  final type = types[index];
                  return ListTile(
                    title: Text(type.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => showTableTypeDialog(tableType: type),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          onPressed: () => controller.deleteTableType(type.id),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text(e.toString())),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showTableTypeDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
