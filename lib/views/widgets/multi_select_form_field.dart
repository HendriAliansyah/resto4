// lib/views/widgets/multi_select_form_field.dart
import 'package:flutter/material.dart';

class MultiSelectBottomSheetField<T> extends FormField<List<T>> {
  MultiSelectBottomSheetField({
    super.key,
    required List<T> items,
    required Widget Function(T) chipLabelBuilder,
    required Widget Function(T)? tileLabelBuilder,
    required String dialogTitle,
    required String searchHint,
    super.onSaved,
    super.validator,
    super.initialValue,
  }) : super(
         builder: (FormFieldState<List<T>> state) {
           final selectedItems = state.value ?? [];

           void showBottomSheet(BuildContext context) {
             showModalBottomSheet(
               context: context,
               isScrollControlled: true,
               useSafeArea: true,
               shape: const RoundedRectangleBorder(
                 borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
               ),
               builder: (context) {
                 return DraggableScrollableSheet(
                   expand: false,
                   initialChildSize: 0.8,
                   maxChildSize: 0.9,
                   builder: (context, scrollController) {
                     return _MultiSelectBottomSheet(
                       scrollController: scrollController,
                       items: items,
                       initialValue: selectedItems,
                       dialogTitle: dialogTitle,
                       searchHint: searchHint,
                       tileLabelBuilder: tileLabelBuilder,
                       onConfirm: (values) {
                         state.didChange(values);
                       },
                     );
                   },
                 );
               },
             );
           }

           return InkWell(
             onTap: () => showBottomSheet(state.context),
             child: InputDecorator(
               decoration: InputDecoration(
                 labelText: dialogTitle,
                 errorText: state.errorText,
                 border: const OutlineInputBorder(),
                 contentPadding: const EdgeInsets.symmetric(
                   horizontal: 12,
                   vertical: 8,
                 ),
               ),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: <Widget>[
                   Expanded(
                     child:
                         selectedItems.isEmpty
                             ? Text(
                               'Select items',
                               style: Theme.of(
                                 state.context,
                               ).textTheme.titleMedium?.copyWith(
                                 color: Theme.of(state.context).hintColor,
                                 fontWeight: FontWeight.w400,
                               ),
                             )
                             : Text(
                               '${selectedItems.length} items selected',
                               style:
                                   Theme.of(
                                     state.context,
                                   ).textTheme.titleMedium,
                             ),
                   ),
                   const Icon(Icons.arrow_drop_down),
                 ],
               ),
             ),
           );
         },
       );
}

class _MultiSelectBottomSheet<T> extends StatefulWidget {
  final List<T> items;
  final List<T> initialValue;
  final String dialogTitle;
  final String searchHint;
  final Widget Function(T)? tileLabelBuilder;
  final Function(List<T>) onConfirm;
  final ScrollController scrollController;

  const _MultiSelectBottomSheet({
    required this.items,
    required this.initialValue,
    required this.dialogTitle,
    required this.searchHint,
    required this.tileLabelBuilder,
    required this.onConfirm,
    required this.scrollController,
  });

  @override
  State<_MultiSelectBottomSheet<T>> createState() =>
      _MultiSelectBottomSheetState<T>();
}

class _MultiSelectBottomSheetState<T>
    extends State<_MultiSelectBottomSheet<T>> {
  final _selectedValues = <T>[];
  List<T> _filteredItems = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedValues.addAll(widget.initialValue);
    _filteredItems = widget.items;
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      _filteredItems = widget.items;
    } else {
      _filteredItems =
          widget.items.where((item) {
            String itemText = '';
            if (widget.tileLabelBuilder != null) {
              final tileWidget = widget.tileLabelBuilder!(item);
              if (tileWidget is Text) {
                itemText = tileWidget.data ?? '';
              }
            }
            if (itemText.isEmpty) {
              itemText = item.toString();
            }
            return itemText.toLowerCase().contains(query.toLowerCase());
          }).toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get the current theme

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag handle and header
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor, // Use theme color
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.dialogTitle,
                    style: theme.textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            // THE FIX IS HERE: Using theme colors for perfect contrast
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: widget.searchHint,
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              prefixIcon: Icon(
                Icons.search,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor:
                  theme
                      .colorScheme
                      .surfaceContainerHighest, // Theme-aware background
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1),
        // List of items
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
            itemCount: _filteredItems.length,
            itemBuilder: (context, index) {
              final item = _filteredItems[index];
              return CheckboxListTile(
                value: _selectedValues.contains(item),
                title:
                    widget.tileLabelBuilder?.call(item) ??
                    Text(item.toString()),
                onChanged: (bool? isSelected) {
                  setState(() {
                    if (isSelected == true) {
                      _selectedValues.add(item);
                    } else {
                      _selectedValues.remove(item);
                    }
                  });
                },
              );
            },
          ),
        ),
        // Sticky footer with Confirm button
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: theme.canvasColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: () {
              widget.onConfirm(_selectedValues);
              Navigator.pop(context);
            },
            child: const Text('Confirm'),
          ),
        ),
      ],
    );
  }
}
