// lib/views/order_type/order_type_management_page.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resto2/models/order_type_model.dart';
import 'package:resto2/providers/order_type_provider.dart';
import 'package:resto2/views/order_type/widgets/order_type_dialog.dart';
import 'package:resto2/views/widgets/app_drawer.dart';

class OrderTypeManagementPage extends ConsumerWidget {
  const OrderTypeManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderTypesAsync = ref.watch(orderTypesStreamProvider);
    final controller = ref.read(orderTypeControllerProvider.notifier);

    void showOrderTypeDialog({OrderType? orderType}) {
      showDialog(
        context: context,
        builder: (_) => OrderTypeDialog(orderType: orderType),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Order Type Master')),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: orderTypesAsync.when(
          data:
              (types) => ListView.builder(
                itemCount: types.length,
                itemBuilder: (_, index) {
                  final type = types[index];
                  return ListTile(
                    title: Text(type.name),
                    subtitle: Text(
                      'Accessible by: ${type.accessibility.name.replaceFirst(type.accessibility.name[0], type.accessibility.name[0].toUpperCase())}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => showOrderTypeDialog(orderType: type),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          onPressed: () => controller.deleteOrderType(type.id),
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
        onPressed: showOrderTypeDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
