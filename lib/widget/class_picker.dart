import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/utils/env.dart';

typedef OnClassSelected = void Function(String classId, String className);

Future<void> showClassPicker({
  required BuildContext context,
  required String selectedClass,
  required String lecturerId,
  required OnClassSelected onSelected,
}) async {
  List<Map<String, dynamic>> classes = [];
  bool isError = false;

  try {
    final response = await http.get(
      Uri.parse('${Env.classApi}/classes?lecturer_id=$lecturerId'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        classes = List<Map<String, dynamic>>.from(data['data']);
      } else {
        isError = true;
      }
    } else {
      isError = true;
    }
  } catch (_) {
    isError = true;
  }

  if (classes.isEmpty || isError) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const Center(child: Text("Failed to load classes")),
    );
    return;
  }

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _ClassPickerSheet(
      classes: classes,
      selectedClass: selectedClass,
      onSelected: onSelected,
    ),
  );
}

class _ClassPickerSheet extends StatefulWidget {
  final List<Map<String, dynamic>> classes;
  final String selectedClass;
  final OnClassSelected onSelected;

  const _ClassPickerSheet({
    required this.classes,
    required this.selectedClass,
    required this.onSelected,
  });

  @override
  State<_ClassPickerSheet> createState() => _ClassPickerSheetState();
}

class _ClassPickerSheetState extends State<_ClassPickerSheet> {
  late List<Map<String, dynamic>> filteredClasses;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    filteredClasses = widget.classes;
  }

  void updateSearch(String query) {
    setState(() {
      searchQuery = query;
      filteredClasses = widget.classes.where((cls) {
        final name = '${cls['class_code']} ${cls['session']}/${cls['year']}';
        return name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
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
          TextField(
            decoration: InputDecoration(
              hintText: 'Search class...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            ),
            onChanged: updateSearch,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 300,
            child: filteredClasses.isEmpty
                ? const Center(child: Text('No classes found'))
                : ListView.builder(
                    itemCount: filteredClasses.length,
                    itemBuilder: (context, index) {
                      final cls = filteredClasses[index];
                      final fullName = '${cls['class_code']} ${cls['session']}/${cls['year']}';
                      return ListTile(
                        title: Text(
                          fullName,
                          style: TextStyle(
                            color: fullName == widget.selectedClass ? Colors.blue : Colors.black,
                            fontWeight: fullName == widget.selectedClass ? FontWeight.bold : null,
                          ),
                        ),
                        onTap: () {
                          widget.onSelected(cls['class_id'].toString(), fullName);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
