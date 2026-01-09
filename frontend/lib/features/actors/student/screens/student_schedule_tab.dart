import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'student_providers.dart';

class StudentScheduleTab extends ConsumerStatefulWidget {
  const StudentScheduleTab({super.key});

  @override
  ConsumerState<StudentScheduleTab> createState() => _StudentScheduleTabState();
}

class _StudentScheduleTabState extends ConsumerState<StudentScheduleTab> {
  bool _showTodayOnly = true;

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(studentScheduleProvider);
    final attendanceAsync = ref.watch(studentAttendanceProvider);

    return scheduleAsync.when(
      data: (schedule) {
        final List<ScheduleEvent> displayedSchedule = _showTodayOnly
            ? schedule.where((event) {
          final today = DateTime.now();
          final dayName = DateFormat('EEEE').format(today);
          return event.day == dayName;
        }).toList()
            : schedule;

        final todayEvents = schedule.where((event) {
          final today = DateTime.now();
          final dayName = DateFormat('EEEE').format(today);
          return event.day == dayName;
        }).toList();

        final now = DateTime.now();
        final currentEvent = todayEvents.firstWhere(
              (event) => now.isAfter(event.startTime) && now.isBefore(event.endTime),
          orElse: () => todayEvents.isNotEmpty && now.isBefore(todayEvents.first.startTime)
              ? todayEvents.first
              : ScheduleEvent(
            id: '',
            courseName: '',
            courseCode: '',
            teacher: '',
            room: '',
            startTime: now,
            endTime: now,
            day: '',
            type: '',
          ),
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Class Card
              if (_showTodayOnly && currentEvent.courseName.isNotEmpty)
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.cyan[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.cyan[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getEventIcon(currentEvent.type),
                            color: Colors.cyan[800],
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Class',
                                style: TextStyle(
                                  color: Colors.cyan[800],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                currentEvent.courseName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${DateFormat('HH:mm').format(currentEvent.startTime)} - ${DateFormat('HH:mm').format(currentEvent.endTime)}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              Text(
                                'Room: ${currentEvent.room} | ${currentEvent.teacher}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Schedule Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _showTodayOnly ? "Today's Schedule" : 'Weekly Schedule',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyan[800],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        _showTodayOnly ? 'Today' : 'Week',
                        style: TextStyle(color: Colors.cyan[800]),
                      ),
                      Switch(
                        value: _showTodayOnly,
                        activeColor: Colors.cyan,
                        onChanged: (value) {
                          setState(() {
                            _showTodayOnly = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Schedule List
              if (displayedSchedule.isEmpty)
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.event_busy, size: 50, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No classes scheduled',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ...displayedSchedule.map((event) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _getEventColor(event.type),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getEventIcon(event.type),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        event.courseName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${event.courseCode} - ${event.teacher}'),
                          Text('Room: ${event.room}'),
                          Text(
                            '${DateFormat('HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.cyan[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              event.day.substring(0, 3),
                              style: TextStyle(
                                color: Colors.cyan[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event.type.toUpperCase(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 20),

              // Attendance Summary
              attendanceAsync.when(
                data: (attendance) {
                  final totalPercentage = attendance.isNotEmpty
                      ? attendance.map((a) => a.percentage).reduce((a, b) => a + b) /
                      attendance.length
                      : 0.0;

                  return Card(
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
                            'Attendance Overview',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.cyan[800],
                            ),
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: totalPercentage / 100,
                            backgroundColor: Colors.grey[200],
                            color: _getAttendanceColor(totalPercentage),
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Overall Attendance:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.cyan[800],
                                ),
                              ),
                              Text(
                                '${totalPercentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _getAttendanceColor(totalPercentage),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...attendance.take(3).map((record) => ListTile(
                            leading: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _getAttendanceColor(record.percentage),
                                shape: BoxShape.circle,
                              ),
                            ),
                            title: Text(record.courseName),
                            subtitle: Text(
                                '${record.present}/${record.total} classes'),
                            trailing: Text(
                              '${record.percentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getAttendanceColor(record.percentage),
                              ),
                            ),
                          )),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const Center(
                    child: CircularProgressIndicator()),
                error: (error, stackTrace) => const SizedBox(),
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
              onPressed: () => ref.invalidate(studentScheduleProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getEventColor(String type) {
    switch (type) {
      case 'lecture':
        return Colors.cyan;
      case 'lab':
        return Colors.teal;
      case 'tutorial':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getEventIcon(String type) {
    switch (type) {
      case 'lecture':
        return Icons.school;
      case 'lab':
        return Icons.computer;
      case 'tutorial':
        return Icons.group;
      default:
        return Icons.event;
    }
  }

  Color _getAttendanceColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 75) return Colors.orange;
    return Colors.red;
  }
}