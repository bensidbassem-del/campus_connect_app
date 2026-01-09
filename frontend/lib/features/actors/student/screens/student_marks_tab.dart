import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'student_providers.dart';

class StudentMarksTab extends ConsumerStatefulWidget {
  const StudentMarksTab({super.key});

  @override
  ConsumerState<StudentMarksTab> createState() => _StudentMarksTabState();
}

class _StudentMarksTabState extends ConsumerState<StudentMarksTab> {
  String? _selectedCourseId;

  @override
  Widget build(BuildContext context) {
    final marksAsync = ref.watch(studentMarksProvider);

    return marksAsync.when(
      data: (marks) {
        final selectedCourse = _selectedCourseId != null
            ? marks.firstWhere((m) => m.courseId == _selectedCourseId,
            orElse: () => marks.first)
            : marks.first;

        final overallAverage = marks.isNotEmpty
            ? marks.map((m) => m.totalScore).reduce((a, b) => a + b) / marks.length
            : 0.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overall Performance Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Overall Performance',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.cyan[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Semester 3',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.cyan[50],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'GPA',
                                  style: TextStyle(
                                    color: Colors.cyan[800],
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  _calculateGPA(marks).toStringAsFixed(2),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      LinearProgressIndicator(
                        value: overallAverage / 100,
                        backgroundColor: Colors.grey[200],
                        color: _getGradeColor(overallAverage),
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Average Score:',
                            style: TextStyle(
                              color: Colors.cyan[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${overallAverage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: _getGradeColor(overallAverage),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Course Selection
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
                        'Select Course',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyan[800],
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedCourseId ?? marks.first.courseId,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: marks.map((mark) {
                          return DropdownMenuItem(
                            value: mark.courseId,
                            child: Text('${mark.courseName} (${mark.courseCode})'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCourseId = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Course Details
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedCourse.courseName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _getGradeColor(selectedCourse.totalScore),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              selectedCourse.grade,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        selectedCourse.courseCode,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Score Progress
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Score',
                                  style: TextStyle(
                                    color: Colors.cyan[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${selectedCourse.totalScore.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color: _getGradeColor(selectedCourse.totalScore),
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Class Average',
                                  style: TextStyle(
                                    color: Colors.cyan[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${selectedCourse.classAverage.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rank',
                                  style: TextStyle(
                                    color: Colors.cyan[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '#${selectedCourse.rank}',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Assessments Breakdown
                      Text(
                        'Assessments',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyan[800],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...selectedCourse.assessments.entries.map((entry) {
                        final percentage = (entry.value / 20) * 100;
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(entry.key),
                                Text('${entry.value.toStringAsFixed(1)}/20'),
                              ],
                            ),
                            LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.grey[200],
                              color: _getGradeColor(percentage),
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            const SizedBox(height: 12),
                          ],
                        );
                      }),

                      // Total Score
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.cyan[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Score',
                              style: TextStyle(
                                color: Colors.cyan[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${selectedCourse.totalScore.toStringAsFixed(1)}/100',
                              style: TextStyle(
                                color: _getGradeColor(selectedCourse.totalScore),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // All Courses Summary
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
                        'All Courses',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyan[800],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...marks.map((mark) => ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getGradeColor(mark.totalScore),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              mark.grade,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        title: Text(mark.courseName),
                        subtitle: Text(mark.courseCode),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${mark.totalScore.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getGradeColor(mark.totalScore),
                              ),
                            ),
                            Text(
                              'Rank #${mark.rank}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 50),
            const SizedBox(height: 10),
            Text('Error: $error'),
            ElevatedButton(
              onPressed: () => ref.invalidate(studentMarksProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.lightGreen;
    if (score >= 70) return Colors.orange;
    if (score >= 60) return Colors.amber;
    return Colors.red;
  }

  double _calculateGPA(List<CourseMark> marks) {
    if (marks.isEmpty) return 0.0;

    double totalPoints = 0;
    for (var mark in marks) {
      if (mark.totalScore >= 90) {
        totalPoints += 4.0;
      } else if (mark.totalScore >= 80) {
        totalPoints += 3.0;
      } else if (mark.totalScore >= 70) {
        totalPoints += 2.0;
      } else if (mark.totalScore >= 60) {
        totalPoints += 1.0;
      }
    }

    return totalPoints / marks.length;
  }
}