import 'package:flutter/material.dart';
import 'package:george/items/inventory.dart';

class InventoryComponent extends StatefulWidget {
  const InventoryComponent({required this.inventory});

  final Inventory inventory;

  @override
  State<InventoryComponent> createState() => _InventoryComponentState();
}

class _InventoryComponentState extends State<InventoryComponent> {
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    final openCloseButton = GestureDetector(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.backpack),
              Icon(
                isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              ),
            ],
          ),
        ),
        onTap: () {
          setState(() {
            isOpen = !isOpen;
          });
        });

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          color: Colors.grey.shade700,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: !isOpen
              ? openCloseButton
              : ConstrainedBox(
                  constraints: BoxConstraints.tight(Size(140, 180)),
                  child: ValueListenableBuilder(
                    valueListenable: widget.inventory,
                    builder: (context, items, _) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${items.length} Items'),
                              openCloseButton,
                            ],
                          ),
                          Flexible(
                            child: GridView.builder(
                              itemCount: widget.inventory.capacity,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 4,
                                childAspectRatio: 1,
                                mainAxisExtent: 32,
                                mainAxisSpacing: 4,
                              ),
                              itemBuilder: (context, index) {
                                final item =
                                    items.length > index ? items[index] : null;
                                return Container(
                                  color: Colors.grey.shade600,
                                  child: Center(
                                    child: item != null
                                        ? Image.asset(
                                            'assets/images/${item.sprite}')
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
