import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_providers.dart';
import '../services/admin_service.dart';
import 'admin_style.dart';

class ScheduleTab extends ConsumerStatefulWidget {
  const ScheduleTab({super.key});

  @override
  ConsumerState<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends ConsumerState<ScheduleTab> {
  String? _selectedGroupId;

  // Form State
  String _selectedDay = 'MONDAY';
  CourseAssignment? _selectedAssignment;
  String _selectedType = 'LECTURE';
  final _roomController = TextEditingController();
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 9, minute: 30);
  bool _isAdding = false;

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(adminGroupsProvider);
    final scheduleAsync = ref.watch(adminScheduleProvider);
    final assignmentsAsync = ref.watch(adminAssignmentsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text('Schedule Manager', style: AdminStyle.header),
            const SizedBox(height: 24),

            // 1. Group Filter
            groupsAsync.when(
              data: (groups) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AdminStyle.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedGroupId,
                      hint: Text(
                        'Select Group to Filter',
                        style: AdminStyle.body,
                      ),
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: AdminStyle.primary,
                      ),
                      style: AdminStyle.body.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGroupId = newValue;
                          if (_selectedAssignment != null &&
                              newValue != null &&
                              _selectedAssignment!.groupId != newValue) {
                            _selectedAssignment = null;
                          }
                        });
                        ref
                            .read(adminScheduleProvider.notifier)
                            .refresh(groupId: _selectedGroupId);
                      },
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text(
                            'All Groups',
                            style: AdminStyle.body.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...groups.map((g) {
                          return DropdownMenuItem<String>(
                            value: g.id,
                            child: Text(g.name, style: AdminStyle.body),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Error loading groups'),
            ),
            const SizedBox(height: 24),

            // 2. Add Session Form
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AdminStyle.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AdminStyle.textPrimary.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add New Session', style: AdminStyle.subHeader),
                  const SizedBox(height: 24),

                  // Row 1: Day & Type
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedDay,
                          decoration: AdminStyle.inputDec(
                            'Day',
                            icon: Icons.calendar_today_rounded,
                          ),
                          isExpanded: true,
                          items:
                              [
                                    'MONDAY',
                                    'TUESDAY',
                                    'WEDNESDAY',
                                    'THURSDAY',
                                    'FRIDAY',
                                    'SATURDAY',
                                  ]
                                  .map(
                                    (d) => DropdownMenuItem(
                                      value: d,
                                      child: Text(
                                        d,
                                        style: AdminStyle.body.copyWith(
                                          fontSize: 13,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) => setState(() => _selectedDay = v!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedType,
                          decoration: AdminStyle.inputDec(
                            'Type',
                            icon: Icons.category_rounded,
                          ),
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(
                              value: 'LECTURE',
                              child: Text(
                                'Lecture',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'LAB',
                              child: Text(
                                'Lab',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'TUTORIAL',
                              child: Text(
                                'Tutorial',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                          onChanged: (v) => setState(() => _selectedType = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Row 2: Course
                  assignmentsAsync.when(
                    data: (assignments) {
                      final filtered = _selectedGroupId == null
                          ? assignments
                          : assignments
                                .where((a) => a.groupId == _selectedGroupId)
                                .toList();

                      return DropdownButtonFormField<CourseAssignment>(
                        value: _selectedAssignment,
                        decoration: AdminStyle.inputDec(
                          'Course',
                          icon: Icons.book_rounded,
                        ),
                        isExpanded: true,
                        hint: Text('Select Course', style: AdminStyle.body),
                        items: filtered
                            .map(
                              (a) => DropdownMenuItem(
                                value: a,
                                child: Text(
                                  '${a.courseCode} - ${a.teacherName}',
                                  style: AdminStyle.body.copyWith(fontSize: 13),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedAssignment = v),
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Error: $e'),
                  ),
                  const SizedBox(height: 16),

                  // Row 3: Room & Times
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _roomController,
                          decoration: AdminStyle.inputDec(
                            'Room',
                            icon: Icons.room_rounded,
                          ),
                          style: AdminStyle.body,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: _timePicker(
                          'Start',
                          _startTime,
                          (t) => setState(() => _startTime = t),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: _timePicker(
                          'End',
                          _endTime,
                          (t) => setState(() => _endTime = t),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Add Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminStyle.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _isAdding ? null : _addSession,
                      child: _isAdding
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Add Session',
                              style: AdminStyle.button.copyWith(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 3. Session List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Scheduled Sessions',
                  style: AdminStyle.header.copyWith(fontSize: 20),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  style: IconButton.styleFrom(
                    foregroundColor: AdminStyle.primary,
                  ),
                  onPressed: () => ref.refresh(adminScheduleProvider),
                ),
              ],
            ),
            const SizedBox(height: 16),

            scheduleAsync.when(
              data: (sessions) {
                if (sessions.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'No sessions scheduled yet.',
                        style: AdminStyle.body,
                      ),
                    ),
                  );
                }

                final sorted = List<ScheduleSession>.from(sessions);
                final dayOrder = {
                  'MONDAY': 1,
                  'TUESDAY': 2,
                  'WEDNESDAY': 3,
                  'THURSDAY': 4,
                  'FRIDAY': 5,
                  'SATURDAY': 6,
                };
                sorted.sort((a, b) {
                  final dayComp = (dayOrder[a.day] ?? 7).compareTo(
                    dayOrder[b.day] ?? 7,
                  );
                  if (dayComp != 0) return dayComp;
                  return a.startTime.compareTo(b.startTime);
                });

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sorted.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final s = sorted[i];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AdminStyle.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _getColor(s.sessionType),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      s.courseCode ?? 'Unknown',
                                      style: AdminStyle.subHeader.copyWith(
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getColor(
                                          s.sessionType,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        s.sessionType,
                                        style: TextStyle(
                                          color: _getColor(s.sessionType),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${s.day} • ${s.startTime} - ${s.endTime}',
                                  style: AdminStyle.body.copyWith(fontSize: 13),
                                ),
                                Text(
                                  'Room: ${s.room} • ${s.groupName ?? 'No Group'}',
                                  style: AdminStyle.body.copyWith(
                                    fontSize: 12,
                                    color: AdminStyle.textSecondary.withOpacity(
                                      0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AdminStyle.error,
                            ),
                            onPressed: () => _deleteSession(s.id),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error loading schedule: $e'),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Future<void> _addSession() async {
    if (_selectedAssignment == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a course')));
      return;
    }
    if (_roomController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a room')));
      return;
    }

    setState(() => _isAdding = true);

    try {
      final s = ScheduleSession(
        assignmentId: _selectedAssignment!.id,
        day: _selectedDay,
        startTime:
            '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
        endTime:
            '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
        room: _roomController.text,
        sessionType: _selectedType,
      );

      await ref.read(adminScheduleProvider.notifier).addSession(s);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session Added Successfully'),
            backgroundColor: AdminStyle.secondary,
          ),
        );
        _roomController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AdminStyle.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  Future<void> _deleteSession(int? id) async {
    if (id == null) return;
    try {
      await ref.read(adminServiceProvider).deleteScheduleSession(id);
      ref.invalidate(adminScheduleProvider);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Deleted')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Widget _timePicker(
    String label,
    TimeOfDay time,
    Function(TimeOfDay) onChanged,
  ) {
    return InkWell(
      onTap: () async {
        final t = await showTimePicker(context: context, initialTime: time);
        if (t != null) onChanged(t);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AdminStyle.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AdminStyle.body.copyWith(fontSize: 11)),
            Text(
              time.format(context),
              style: AdminStyle.subHeader.copyWith(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor(String? type) {
    if (type == 'LAB') return const Color(0xFF10B981);
    if (type == 'TUTORIAL') return const Color(0xFFF59E0B);
    return AdminStyle.primary;
  }
}
