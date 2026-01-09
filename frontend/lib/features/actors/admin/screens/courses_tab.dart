import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

// Modèles
class Course {
  final String id;
  final String name;
  final String code;

  Course({required this.id, required this.name, required this.code});
}

class FileItem {
  final String id;
  final String name;
  final String category;
  final String url;

  FileItem({
    required this.id,
    required this.name,
    required this.category,
    required this.url,
  });
}

final coursesProvider = AsyncNotifierProvider<CoursesNotifier, List<Course>>(
  () {
    return CoursesNotifier();
  },
);

class CoursesNotifier extends AsyncNotifier<List<Course>> {
  @override
  Future<List<Course>> build() async {
    // État initial - vous pouvez charger les données ici ou via fetchCourses()
    return [];
  }

  Future<void> fetchCourses() async {
    state = const AsyncLoading<List<Course>>();
    try {
      // TODO: Backend - GET /api/admin/courses
      await Future.delayed(const Duration(seconds: 1)); // Simulation
      final courses = [
        Course(id: '1', name: 'Mathématiques', code: 'MATH101'),
        Course(id: '2', name: 'Physique', code: 'PHYS101'),
      ];
      state = AsyncData<List<Course>>(courses);
    } catch (e, stackTrace) {
      state = AsyncError<List<Course>>(e, stackTrace);
    }
  }

  Future<void> addCourse(String name, String code) async {
    try {
      final newCourse = Course(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        code: code,
      );

      // Mettre à jour l'état
      state.whenData((courses) {
        state = AsyncData<List<Course>>([...courses, newCourse]);
      });
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<void> assignCourseToTeacher(String courseId, String teacherId) async {
    // TODO: Backend - POST /api/admin/courses/assign-teacher
    await Future.delayed(const Duration(seconds: 1));
  }
}

// ✅ CORRECTION : Pour les fichiers aussi
final filesProvider = AsyncNotifierProvider<FilesNotifier, List<FileItem>>(() {
  return FilesNotifier();
});

class FilesNotifier extends AsyncNotifier<List<FileItem>> {
  @override
  Future<List<FileItem>> build() async {
    return [];
  }

  Future<void> uploadFile(PlatformFile file, String category) async {
    try {
      // TODO: Backend - POST /api/admin/files/upload
      await Future.delayed(const Duration(seconds: 2));

      final newFile = FileItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: file.name,
        category: category,
        url: 'url_from_backend',
      );

      // Mettre à jour l'état
      state.whenData((files) {
        state = AsyncData<List<FileItem>>([...files, newFile]);
      });
    } catch (e, stackTrace) {
      state = AsyncError<List<FileItem>>(e, stackTrace);
    }
  }

  Future<void> fetchFiles() async {
    state = const AsyncLoading<List<FileItem>>();
    try {
      // TODO: Backend - GET /api/admin/files
      await Future.delayed(const Duration(seconds: 1));
      state = const AsyncData<List<FileItem>>([]);
    } catch (e, stackTrace) {
      state = AsyncError<List<FileItem>>(e, stackTrace);
    }
  }
}

class CoursesTab extends ConsumerStatefulWidget {
  const CoursesTab({super.key});

  @override
  ConsumerState<CoursesTab> createState() => _CoursesTabState();
}

class _CoursesTabState extends ConsumerState<CoursesTab> {
  final List<String> categories = ['Schedules', 'Timetables', 'Notices'];
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _courseCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Récupérer les cours au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(coursesProvider.notifier).fetchCourses();
    });
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _courseCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesProvider);
    final filesAsync = ref.watch(filesProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Téléchargement de fichiers
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
                    'Upload Files',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyan[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: categories.map((category) {
                      return ElevatedButton.icon(
                        icon: Icon(_getCategoryIcon(category)),
                        label: Text(category),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan[50],
                          foregroundColor: Colors.cyan[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => _uploadFile(category),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  // Affichage des fichiers
                  filesAsync.when(
                    data: (files) {
                      if (files.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('No files uploaded yet'),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recent Files:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...files
                              .take(3)
                              .map(
                                (file) => ListTile(
                                  leading: Icon(
                                    _getCategoryIcon(file.category),
                                  ),
                                  title: Text(file.name),
                                  subtitle: Text(file.category),
                                ),
                              ),
                        ],
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

          // Section Gestion des cours
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
                        'Course Management',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyan[800],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.cyan,
                        ),
                        onPressed: _addNewCourse,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Liste des cours
                  coursesAsync.when(
                    data: (courses) {
                      if (courses.isEmpty) {
                        return const Center(
                          child: Text('No courses available'),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: courses.length,
                        itemBuilder: (context, index) {
                          final course = courses[index];
                          return ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.cyan[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.school,
                                color: Colors.cyan[800],
                              ),
                            ),
                            title: Text(course.name),
                            subtitle: Text('Code: ${course.code}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.cyan),
                              onPressed: () => _editCourse(course),
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
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Schedules':
        return Icons.calendar_today;
      case 'Timetables':
        return Icons.schedule;
      case 'Notices':
        return Icons.announcement;
      default:
        return Icons.insert_drive_file;
    }
  }

  Future<void> _uploadFile(String category) async {
    try {
      // Utiliser file_picker au lieu de image_picker pour tous les fichiers
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;

        // Afficher un indicateur de chargement
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(width: 10),
                Text('Uploading $category...'),
              ],
            ),
            backgroundColor: Colors.cyan[600],
          ),
        );

        // Télécharger le fichier
        await ref.read(filesProvider.notifier).uploadFile(file, category);

        // Cacher le snackbar
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$category uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _addNewCourse() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Course'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _courseNameController,
              decoration: const InputDecoration(
                labelText: 'Course Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _courseCodeController,
              decoration: const InputDecoration(
                labelText: 'Course Code',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _courseNameController.clear();
              _courseCodeController.clear();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
            onPressed: () async {
              if (_courseNameController.text.isEmpty ||
                  _courseCodeController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all fields'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                await ref
                    .read(coursesProvider.notifier)
                    .addCourse(
                      _courseNameController.text,
                      _courseCodeController.text,
                    );

                Navigator.pop(context);
                _courseNameController.clear();
                _courseCodeController.clear();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Course added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editCourse(Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Course'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Name: ${course.name}'),
              Text('Code: ${course.code}'),
              const SizedBox(height: 20),
              const Text('Assign teachers and student groups here...'),
              // TODO: Ajouter des sélecteurs pour les enseignants et groupes
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implémenter la sauvegarde des modifications
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
