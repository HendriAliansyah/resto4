// lib/views/staff/edit_staff_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:resto2/models/role_permission_model.dart';
import 'package:resto2/models/staff_model.dart';
import 'package:resto2/providers/staff_provider.dart';

class EditStaffPage extends HookConsumerWidget {
  final Staff staff;

  const EditStaffPage({super.key, required this.staff});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = useState(staff.role);
    final formKey = useMemoized(() => GlobalKey<FormState>());

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Staff')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Email: ${staff.email}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Name: ${staff.displayName}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField2<UserRole>(
                value: role.value,
                items:
                    UserRole.values
                        .map(
                          (role) => DropdownMenuItem(
                            value: role,
                            child: Text(role.name),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    role.value = value;
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Role',
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(),
                ),
                buttonStyleData: const ButtonStyleData(
                  height: 50,
                  padding: EdgeInsets.only(right: 10),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(staffControllerProvider)
                      .updateStaffRole(userId: staff.uid, newRole: role.value);
                  Navigator.of(context).pop();
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
