import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'teacher_provider.dart';

class MarksTab extends ConsumerStatefulWidget {
  const MarksTab({super.key});

  @override
  ConsumerState<MarksTab> createState() => _MarksTabState();
}

class _MarksTabState extends ConsumerState<MarksTab> {
  final List<String> _assessments = [
    'Quiz 1',
    'Midterm',
    'Assignment 1',
    'Quiz 2',
    'Final',
  ];
  String? _selectedCourseId = '1';

  @override
  void initState() {
    super.initState();
    // Fetch marks for selected course
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedCourseId != null) {
        ref.read(marksProvider.notifier).fetchMarks(_selectedCourseId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final marksAsync = ref.watch(marksProvider);
    final coursesAsync = ref.watch(teacherCoursesProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Course Selection and Actions
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Mark Entry System',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyan[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: coursesAsync.when(
                            data: (courses) {
                              return DropdownButton<String>(
                                hint: const Text('Select Course'),
                                value: _selectedCourseId,
                                isExpanded: true,
                                items: courses.map((course) {
                                  return DropdownMenuItem(
                                    value: course.id,
                                    child: Text(
                                      '${course.name} (${course.code})',
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCourseId = value;
                                    if (value != null) {
                                      ref
                                          .read(marksProvider.notifier)
                                          .fetchMarks(value);
                                    }
                                  });
                                },
                              );
                            },
                            loading: () => const CircularProgressIndicator(),
                            error: (error, stackTrace) => Text('Error: $error'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add Assessment'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyan,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _addAssessment,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Marks Table
            marksAsync.when(
              data: (marksData) {
                final courseMarks = marksData[_selectedCourseId] ?? [];

                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Table Header
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.cyan[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    'Student',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.cyan[800],
                                    ),
                                  ),
                                ),
                              ),
                              for (final assessment in _assessments)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      children: [
                                        Text(
                                          assessment,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.cyan[800],
                                            fontSize: 12,
                                          ),
                                        ),
                                        const Text(
                                          '/20',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    'Total',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.cyan[800],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Marks Rows
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: courseMarks.length,
                          itemBuilder: (context, studentIndex) {
                            final mark = courseMarks[studentIndex];
                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey[200]!),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 16,
                                            backgroundColor: Colors.cyan[100],
                                            child: Text(
                                              'S${studentIndex + 1}',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.cyan[800],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  mark.studentName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  mark.studentId,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  for (final assessment in _assessments)
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: TextFormField(
                                          initialValue:
                                              mark.assessments[assessment]
                                                  ?.toStringAsFixed(1) ??
                                              '0',
                                          textAlign: TextAlign.center,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              borderSide: BorderSide(
                                                color: Colors.cyan[300]!,
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                          ),
                                          onChanged: (value) {
                                            final score =
                                                double.tryParse(value) ?? 0.0;
                                            if (score >= 0 && score <= 20) {
                                              ref
                                                  .read(marksProvider.notifier)
                                                  .updateMark(
                                                    _selectedCourseId!,
                                                    mark.studentId,
                                                    assessment,
                                                    score,
                                                  );
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '${mark.totalScore.toStringAsFixed(1)}/100',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: _getGradeColor(
                                            mark.totalScore,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        // Summary and Actions
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.cyan[50],
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Class Average:',
                                    style: TextStyle(
                                      color: Colors.cyan[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${_calculateAverage(courseMarks)}/100',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.cyan[800],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.calculate),
                                    label: const Text('Calculate Totals'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.cyan,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Totals calculated'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.publish),
                                    label: const Text('Publish Grades'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      // TODO: Publish grades to students
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Column(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 50),
                    const SizedBox(height: 10),
                    Text('Error: $error'),
                    ElevatedButton(
                      onPressed: () {
                        if (_selectedCourseId != null) {
                          ref
                              .read(marksProvider.notifier)
                              .fetchMarks(_selectedCourseId!);
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calculateAverage(List<Mark> marks) {
    if (marks.isEmpty) return '0.0';
    final total = marks.map((m) => m.totalScore).reduce((a, b) => a + b);
    return (total / marks.length).toStringAsFixed(1);
  }

  Color _getGradeColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  void _addAssessment() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController maxMarksController = TextEditingController();
    final TextEditingController weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Assessment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Assessment Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: maxMarksController,
              decoration: const InputDecoration(
                labelText: 'Maximum Marks',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: weightController,
              decoration: const InputDecoration(
                labelText: 'Weight (%)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  maxMarksController.text.isNotEmpty &&
                  weightController.text.isNotEmpty) {
                setState(() {
                  _assessments.add(nameController.text);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Assessment added'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
