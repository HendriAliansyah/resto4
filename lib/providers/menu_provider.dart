import 'dart:io';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resto2/models/menu_model.dart';
import 'package:resto2/providers/auth_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resto2/providers/menu_filter_provider.dart';
import 'package:resto2/providers/staff_filter_provider.dart';
import 'package:resto2/providers/storage_provider.dart';

// Service
class MenuService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionPath = 'menus';

  Stream<List<MenuModel>> getMenusStream(String restaurantId) {
    return _db
        .collection(_collectionPath)
        .where('restaurantId', isEqualTo: restaurantId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => MenuModel.fromFirestore(doc)).toList(),
        );
  }

  Future<DocumentReference> addMenu(Map<String, dynamic> data) async {
    return await _db.collection(_collectionPath).add(data);
  }

  Future<void> updateMenu(String id, Map<String, dynamic> data) async {
    await _db.collection(_collectionPath).doc(id).update(data);
  }

  Future<void> deleteMenu(String id) async {
    await _db.collection(_collectionPath).doc(id).delete();
  }
}

// State
enum MenuActionStatus { initial, loading, success, error }

class MenuState {
  final MenuActionStatus status;
  final String? errorMessage;
  MenuState({this.status = MenuActionStatus.initial, this.errorMessage});
}

// Providers
final menuServiceProvider = Provider((ref) => MenuService());

final menusStreamProvider = StreamProvider.autoDispose<List<MenuModel>>((ref) {
  final restaurantId =
      ref.watch(currentUserProvider).asData?.value?.restaurantId;
  if (restaurantId != null) {
    return ref.watch(menuServiceProvider).getMenusStream(restaurantId);
  }
  return Stream.value([]);
});

final menuControllerProvider =
    StateNotifierProvider.autoDispose<MenuController, MenuState>((ref) {
      return MenuController(ref);
    });

class MenuController extends StateNotifier<MenuState> {
  final Ref _ref;
  MenuController(this._ref) : super(MenuState());

  bool _isNameUnique(String name, String? idToExclude) {
    final items = _ref.read(menusStreamProvider).asData?.value ?? [];
    return items
        .where(
          (item) =>
              item.id != idToExclude &&
              item.name.trim().toLowerCase() == name.trim().toLowerCase(),
        )
        .isEmpty;
  }

  Future<void> addMenu({
    required String name,
    required String description,
    required double price,
    required String courseId,
    required String orderTypeId,
    required List<String> menuItems,
    required List<String> inventoryItems,
    File? imageFile,
  }) async {
    state = MenuState(status: MenuActionStatus.loading);
    if (!_isNameUnique(name, null)) {
      state = MenuState(
        status: MenuActionStatus.error,
        errorMessage: 'A menu item with this name already exists.',
      );
      return;
    }
    final restaurantId =
        _ref.read(currentUserProvider).asData?.value?.restaurantId;
    if (restaurantId == null) {
      state = MenuState(
        status: MenuActionStatus.error,
        errorMessage: 'User not in a restaurant.',
      );
      return;
    }
    try {
      final newItem = MenuModel(
        id: '',
        name: name,
        description: description,
        price: price,
        restaurantId: restaurantId,
        courseId: courseId,
        orderTypeId: orderTypeId,
        menuItems: menuItems,
        inventoryItems: inventoryItems,
      );

      final docRef = await _ref
          .read(menuServiceProvider)
          .addMenu(newItem.toJson());

      if (imageFile != null) {
        final imageUrl = await _ref
            .read(storageServiceProvider)
            .uploadImage('menus/${docRef.id}/image.jpg', imageFile);
        await _ref.read(menuServiceProvider).updateMenu(docRef.id, {
          'imageUrl': imageUrl,
        });
      }
      state = MenuState(status: MenuActionStatus.success);
    } catch (e) {
      state = MenuState(
        status: MenuActionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateMenu({
    required String id,
    required String name,
    required String description,
    required double price,
    required String courseId,
    required String orderTypeId,
    required List<String> menuItems,
    required List<String> inventoryItems,
    File? imageFile,
    String? existingImageUrl,
  }) async {
    state = MenuState(status: MenuActionStatus.loading);
    if (!_isNameUnique(name, id)) {
      state = MenuState(
        status: MenuActionStatus.error,
        errorMessage: 'Another menu item with this name already exists.',
      );
      return;
    }
    try {
      String? finalImageUrl = existingImageUrl;
      if (imageFile != null) {
        finalImageUrl = await _ref
            .read(storageServiceProvider)
            .uploadImage('menus/$id/image.jpg', imageFile);
      }
      final updatedData = {
        'name': name,
        'description': description,
        'price': price,
        'courseId': courseId,
        'orderTypeId': orderTypeId,
        'imageUrl': finalImageUrl,
        'menuItems': menuItems,
        'inventoryItems': inventoryItems,
      };

      await _ref.read(menuServiceProvider).updateMenu(id, updatedData);
      state = MenuState(status: MenuActionStatus.success);
    } catch (e) {
      state = MenuState(
        status: MenuActionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> deleteMenu(String id) async {
    try {
      await _ref.read(menuServiceProvider).deleteMenu(id);
      await _ref
          .read(storageServiceProvider)
          .deleteImage('menus/$id/image.jpg');
    } catch (e) {
      // Errors can be handled more granularly if needed
    }
  }
}

final sortedMenusProvider = Provider.autoDispose<List<MenuModel>>((ref) {
  final menuList = ref.watch(menusStreamProvider).asData?.value ?? [];
  final filter = ref.watch(menuFilterProvider);

  // Apply search and course filters
  final filteredList =
      menuList.where((menu) {
        final searchMatch =
            filter.searchQuery.isEmpty ||
            menu.name.toLowerCase().contains(filter.searchQuery.toLowerCase());
        final courseMatch =
            filter.courseId == null || menu.courseId == filter.courseId;
        return searchMatch && courseMatch;
      }).toList();

  // Apply sorting
  filteredList.sort((a, b) {
    int comparison;
    switch (filter.sortOption) {
      case MenuSortOption.byName:
        comparison = a.name.compareTo(b.name);
        break;
      case MenuSortOption.byPrice:
        comparison = a.price.compareTo(b.price);
        break;
    }
    return filter.sortOrder == SortOrder.asc ? comparison : -comparison;
  });

  return filteredList;
});
