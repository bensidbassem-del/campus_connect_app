import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'teacher_provider.dart';

class TeacherCoursesTab extends ConsumerStatefulWidget {
  const TeacherCoursesTab({super.key});

  @override
  ConsumerState<TeacherCoursesTab> createState() => _TeacherCoursesTabState();
}

class _TeacherCoursesTabState extends ConsumerState<TeacherCoursesTab> {
  String? _selectedCourseId;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Fetch teacher's courses
    WidgetsBinding.instance.addPostFrameCallback((_) {
      const teacherId = 'teacher123';
      ref.read(teacherCoursesProvider.notifier).fetchTeacherCourses(teacherId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(teacherCoursesProvider);
    final filesAsync = ref.watch(teacherFilesProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Course Selection Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Courses',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyan[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    coursesAsync.when(
                      data: (courses) {
                        if (courses.isEmpty) {
                          return const Text('No courses assigned');
                        }
                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Select Course',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.cyan[400]!),
                            ),
                            prefixIcon: Icon(
                              Icons.school,
                              color: Colors.cyan[800],
                            ),
                          ),
                          value: _selectedCourseId,
                          items: courses.map((course) {
                            return DropdownMenuItem(
                              value: course.id,
                              child: Text('${course.name} (${course.code})'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCourseId = value;
                              if (value != null) {
                                ref
                                    .read(teacherFilesProvider.notifier)
                                    .fetchCourseFiles(value);
                              }
                            });
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stackTrace) => Text('Error: $error'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_selectedCourseId != null) ...[
              // File Management Section
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Course Materials',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.cyan[800],
                            ),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.upload),
                            label: const Text('Upload File'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyan,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => _uploadFile(_selectedCourseId!),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // File Type Filters
                      Wrap(
                        spacing: 8,
                        children:
                            [
                              'All',
                              'Lecture Notes',
                              'Assignments',
                              'Resources',
                            ].map((type) {
                              return FilterChip(
                                label: Text(type),
                                selected: true,
                                onSelected: (_) {},
                                backgroundColor: Colors.cyan[50],
                                selectedColor: Colors.cyan[100],
                                labelStyle: TextStyle(
                                  color: Colors.cyan[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 16),
                      // Files List
                      filesAsync.when(
                        data: (files) {
                          if (files.isEmpty) {
                            return const Center(
                              child: Text('No files uploaded yet'),
                            );
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: files.length,
                            itemBuilder: (context, index) {
                              final file = files[index];
                              return ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.cyan[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.insert_drive_file,
                                    color: Colors.cyan[800],
                                  ),
                                ),
                                title: Text(file.name),
                                subtitle: Text(
                                  'Uploaded: ${_formatDate(file.uploadedAt)}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.download,
                                        color: Colors.cyan,
                                      ),
                                      onPressed: () {},
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stackTrace) => Text('Error: $error'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Students List Section
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Students in this Course',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyan[800],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Students List
                      coursesAsync.when(
                        data: (courses) {
                          final course = courses.firstWhere(
                            (c) => c.id == _selectedCourseId,
                            orElse: () => courses.first,
                          );
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: course.students.length,
                            itemBuilder: (context, index) {
                              final student = course.students[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.cyan[100],
                                  child: Text(
                                    student.name.isNotEmpty
                                        ? student.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(student.name),
                                subtitle: Text('ID: ${student.studentId}'),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.email,
                                    color: Colors.cyan,
                                  ),
                                  onPressed: () {},
                                ),
                              );
                            },
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stackTrace) => Text('Error: $error'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _uploadFile(String courseId) async {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo, color: Colors.cyan[800]),
              title: const Text('Upload from Gallery'),
              onTap: () async {
                Navigator.pop(sheetContext);
                final pickedFile = await _picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (pickedFile != null) {
                  try {
                    await ref
                        .read(teacherFilesProvider.notifier)
                        .uploadFile(
                          courseId,
                          File(pickedFile.path),
                          'Image_${DateTime.now().millisecondsSinceEpoch}',
                          'resource',
                        );
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('File uploaded successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.file_upload, color: Colors.cyan[800]),
              title: const Text('Upload Document'),
              onTap: () async {
                Navigator.pop(sheetContext);
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.any,
                  allowMultiple: false,
                );
                if (result != null && result.files.isNotEmpty) {
                  final file = result.files.first;
                  try {
                    await ref
                        .read(teacherFilesProvider.notifier)
                        .uploadFile(
                          courseId,
                          File(file.path!),
                          file.name,
                          'document',
                        );
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('File uploaded successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
