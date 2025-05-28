import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/utils/env.dart'; // for Env.baseUrl

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
    final response = await http.get(Uri.parse('${Env.classApi}/classes?lecturer_id=$lecturerId'),);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
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

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(16),
        child: isError
            ? const Center(child: Text("Failed to load classes"))
            : Column(
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
                    height: 300,
                    child: ListView.builder(
                      itemCount: classes.length,
                      itemBuilder: (context, index) {
                        final cls = classes[index];
                        final fullName = '${cls['class_code']} ${cls['session']}/${cls['year']}';
                        return ListTile(
                          title: Text(
                            fullName,
                            style: TextStyle(
                              color: fullName == selectedClass ? Colors.blue : Colors.black,
                              fontWeight: fullName == selectedClass ? FontWeight.bold : null,
                            ),
                          ),
                          onTap: () {
                            onSelected(cls['class_id'], fullName);
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
