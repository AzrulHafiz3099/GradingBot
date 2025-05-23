import 'package:flutter/material.dart';

typedef OnClassSelected = void Function(String selectedClass);

final List<String> classes = [
  'Choose Class',
  'BITP2226 2/2024',
  'BITP1234 2/2024',
  'BITP2223 2/2024',
  'BITS2345 1/2024',
  'BITP2134 2/2024',
  'BITP9999 2/2024',
  'BITP8888 1/2023',
];

Future<void> showClassPicker({
  required BuildContext context,
  required String selectedClass,
  required OnClassSelected onSelected,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 300, // Match exam picker height
              child: ListView.builder(
                itemCount: classes.length,
                itemBuilder: (context, index) {
                  final cls = classes[index];
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
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
