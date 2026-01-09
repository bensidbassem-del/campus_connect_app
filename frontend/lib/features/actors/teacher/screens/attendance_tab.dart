import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'teacher_provider.dart';

class AttendanceTab extends ConsumerStatefulWidget {
  const AttendanceTab({super.key});

  @override
  ConsumerState<AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends ConsumerState<AttendanceTab> {
  String? _selectedCourseId = '1';
  DateTime _selectedWeek = DateTime.now();
  final List<String> _statusOptions = [
    'Present',
    'Absent',
    'Late',
    'Excused',
    'Not Marked',
  ];

  @override
  void initState() {
    super.initState();
    // Fetch attendance for current week
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedCourseId != null) {
        ref
            .read(attendanceProvider.notifier)
            .fetchAttendance(_selectedCourseId!, _selectedWeek);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final attendanceAsync = ref.watch(attendanceProvider);
    final coursesAsync = ref.watch(teacherCoursesProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Week Selector Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.cyan[800]),
                      onPressed: () {
                        setState(() {
                          _selectedWeek = _selectedWeek.subtract(
                            const Duration(days: 7),
                          );
                          _refreshAttendance();
                        });
                      },
                    ),
                    Column(
                      children: [
                        const Text(
                          'Week of',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          DateFormat('MMM dd, yyyy').format(_selectedWeek),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.cyan[800],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.cyan[800],
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedWeek = _selectedWeek.add(
                            const Duration(days: 7),
                          );
                          _refreshAttendance();
                        });
                      },
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
                child: coursesAsync.when(
                  data: (courses) {
                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Course',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
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
                          _refreshAttendance();
                        });
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Text('Error: $error'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Attendance Table
            attendanceAsync.when(
              data: (attendanceData) {
                final courseRecords = attendanceData[_selectedCourseId] ?? [];

                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Attendance Sheet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.cyan[800],
                              ),
                            ),
                            coursesAsync.when(
                              data: (courses) {
                                final course = courses.firstWhere(
                                  (c) => c.id == _selectedCourseId,
                                  orElse: () => courses.first,
                                );
                                return Chip(
                                  label: Text(
                                    '${course.code} - ${course.groupId}',
                                  ),
                                  backgroundColor: Colors.cyan[50],
                                  labelStyle: TextStyle(
                                    color: Colors.cyan[800],
                                  ),
                                );
                              },
                              loading: () => const CircularProgressIndicator(),
                              error: (error, stackTrace) => const SizedBox(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
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
                              for (int day = 0; day < 5; day++)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Text(
                                      _getDayName(day),
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
                        // Attendance Rows
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: courseRecords.length,
                          itemBuilder: (context, studentIndex) {
                            final record = courseRecords[studentIndex];
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
                                      child: Text(record.studentName),
                                    ),
                                  ),
                                  for (int day = 0; day < 5; day++)
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: DropdownButtonFormField<String>(
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: 4,
                                                ),
                                          ),
                                          value: _getAttendanceStatus(
                                            record,
                                            day,
                                          ),
                                          items: _statusOptions.map((status) {
                                            Color statusColor = _getStatusColor(
                                              status,
                                            );
                                            return DropdownMenuItem(
                                              value: status,
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: BoxDecoration(
                                                      color: statusColor,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(status),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            final date = _selectedWeek.add(
                                              Duration(days: day),
                                            );
                                            ref
                                                .read(
                                                  attendanceProvider.notifier,
                                                )
                                                .markAttendance(
                                                  _selectedCourseId!,
                                                  record.studentId,
                                                  date,
                                                  value!.toLowerCase(),
                                                );
                                          },
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        // Summary Row
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
                                'Weekly Summary:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.cyan[800],
                                ),
                              ),
                              Row(
                                children: [
                                  _AttendanceLegend(
                                    color: Colors.green,
                                    label: 'Present',
                                  ),
                                  const SizedBox(width: 16),
                                  _AttendanceLegend(
                                    color: Colors.red,
                                    label: 'Absent',
                                  ),
                                  const SizedBox(width: 16),
                                  _AttendanceLegend(
                                    color: Colors.orange,
                                    label: 'Late',
                                  ),
                                  const SizedBox(width: 16),
                                  _AttendanceLegend(
                                    color: Colors.blue,
                                    label: 'Excused',
                                  ),
                                  const SizedBox(width: 16),
                                  _AttendanceLegend(
                                    color: Colors.grey,
                                    label: 'Not Marked',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.save),
                              label: const Text('Save Changes'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.cyan,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Attendance saved'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.file_download),
                              label: const Text('Export'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                // TODO: Export attendance sheet
                              },
                            ),
                          ],
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
                      onPressed: _refreshAttendance,
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

  String _getDayName(int day) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    return days[day];
  }

  String _getAttendanceStatus(AttendanceRecord record, int day) {
    final date = _selectedWeek.add(Duration(days: day));
    final status = record.attendance[date];
    switch (status) {
      case 'present':
        return 'Present';
      case 'absent':
        return 'Absent';
      case 'late':
        return 'Late';
      case 'excused':
        return 'Excused';
      default:
        return 'Not Marked';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Present':
        return Colors.green;
      case 'Absent':
        return Colors.red;
      case 'Late':
        return Colors.orange;
      case 'Excused':
        return Colors.blue;
      case 'Not Marked':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  void _refreshAttendance() {
    if (_selectedCourseId != null) {
      ref
          .read(attendanceProvider.notifier)
          .fetchAttendance(_selectedCourseId!, _selectedWeek);
    }
  }
}

class _AttendanceLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _AttendanceLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
