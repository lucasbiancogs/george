import 'package:flutter/material.dart';
import 'package:george/items/item.dart';

class Inventory extends ValueNotifier<List<Item>> {
  Inventory(super._value, {required this.capacity});

  final int capacity;

  void add(Item item) {
    value.add(item);
    notifyListeners();
  }

  void remove(Item item) {
    value.remove(item);
    notifyListeners();
  }

  int get itemsAmount => value.length;

  List<Item> get items => [...value];
}
