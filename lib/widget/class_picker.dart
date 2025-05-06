import 'package:flutter/material.dart';

typedef OnClassSelected = void Function(String selectedClass);

// Define the class list in the class_picker.dart
final List<String> classes = [
  'Choose Class',
  'BITP2226 2/2024',
  'BITP1234 2/2024',
  'BITP2223 2/2024',
  'BITS2345 1/2024',
  'BITP2134 2/2024',
];

Future<void> showClassPicker({
  required BuildContext context,
  required String selectedClass,
  required OnClassSelected onSelected,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Choose Class',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            ...classes.map((cls) {
              return ListTile(
                title: Text(
                  cls,
                  style: TextStyle(
                    color: cls == selectedClass ? Colors.blue : Colors.black,
                    fontWeight: cls == selectedClass ? FontWeight.bold : null,
                  ),
                ),
                onTap: () {
                  onSelected(cls);
                  Navigator.pop(context);
                },
              );
            }).toList()
          ],
        ),
      );
    },
  );
}
