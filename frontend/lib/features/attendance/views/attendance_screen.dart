import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/attendance_cubit.dart';
import '../models/attendance_record.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AttendanceCubit()..loadAttendance(),
      child: const _AttendanceView(),
    );
  }
}

class _AttendanceView extends StatefulWidget {
  const _AttendanceView();

  @override
  State<_AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<_AttendanceView> {
  String _searchQuery = '';
  int _selectedTab = 0; // 0 = Відмітки присутності, 1 = Графік роботи

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  void _showEditScheduleDialog(BuildContext ctx, WorkSchedule schedule) {
    final daysCtrl = TextEditingController(text: schedule.workDays);
    final startCtrl = TextEditingController(text: schedule.startTime);
    final endCtrl = TextEditingController(text: schedule.endTime);
    String selectedShift = schedule.shiftType;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Графік: ${schedule.employeeName}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: daysCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Робочі дні (напр. Пн-Пт, 2/2)',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: startCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Початок (09:00)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: endCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Кінець (18:00)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value:
                      ['Офіс', 'Дистанційно', 'Гібрид'].contains(selectedShift)
                      ? selectedShift
                      : 'Офіс',
                  decoration: const InputDecoration(labelText: 'Формат роботи'),
                  items: const [
                    DropdownMenuItem(value: 'Офіс', child: Text('Офіс')),
                    DropdownMenuItem(
                      value: 'Дистанційно',
                      child: Text('Дистанційно'),
                    ),
                    DropdownMenuItem(value: 'Гібрид', child: Text('Гібрид')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedShift = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Скасувати',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                ctx
                    .read<AttendanceCubit>()
                    .updateSchedule(schedule.employeeId, {
                      'work_days': daysCtrl.text,
                      'start_time': startCtrl.text,
                      'end_time': endCtrl.text,
                      'shift_type': selectedShift,
                    });
                Navigator.pop(context);
              },
              child: const Text('Зберегти'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeBadge(String time, bool isClockIn) {
    final isMissing = time == '--:--';
    final bgColor = isMissing
        ? Colors.grey.shade100
        : (isClockIn ? Colors.green.shade50 : Colors.red.shade50);
    final textColor = isMissing
        ? Colors.grey.shade500
        : (isClockIn ? Colors.green.shade700 : Colors.red.shade700);
    final iconData = isClockIn ? Icons.login_rounded : Icons.logout_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isMissing) ...[
            Icon(iconData, size: 14, color: textColor),
            const SizedBox(width: 6),
          ],
          Text(
            time,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              fontFamily: 'Courier',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<AttendanceCubit, AttendanceState>(
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }
          if (state is AttendanceError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (state is AttendanceLoaded) {
            final filteredRecords = state.records.where((rec) {
              return '${rec.employeeName} ${rec.date}'.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );
            }).toList();

            final filteredSchedules = state.schedules.where((sch) {
              return '${sch.employeeName} ${sch.workDays} ${sch.shiftType}'
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Облік робочого часу',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),

                // Перемикач вкладок
                Row(
                  children: [
                    ChoiceChip(
                      label: Text(
                        'Відмітки присутності (${state.records.length})',
                      ),
                      selected: _selectedTab == 0,
                      selectedColor: Colors.black,
                      labelStyle: TextStyle(
                        color: _selectedTab == 0
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) => setState(() {
                        _selectedTab = 0;
                        _searchQuery = '';
                      }),
                    ),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: Text('Графік роботи (${state.schedules.length})'),
                      selected: _selectedTab == 1,
                      selectedColor: Colors.black,
                      labelStyle: TextStyle(
                        color: _selectedTab == 1
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) => setState(() {
                        _selectedTab = 1;
                        _searchQuery = '';
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: TextField(
                            onChanged: (value) =>
                                setState(() => _searchQuery = value),
                            decoration: InputDecoration(
                              hintText: _selectedTab == 0
                                  ? 'Пошук за працівником або датою...'
                                  : 'Пошук за працівником або форматом...',
                              prefixIcon: const Icon(
                                Icons.search_outlined,
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: SingleChildScrollView(
                            child: SizedBox(
                              width: double.infinity,
                              child: _selectedTab == 0
                                  ? _buildAttendanceTable(filteredRecords)
                                  : _buildScheduleTable(
                                      context,
                                      filteredSchedules,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildAttendanceTable(List<AttendanceRecord> records) {
    return DataTable(
      dataRowMaxHeight: 64,
      dataRowMinHeight: 64,
      headingTextStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
      columns: const [
        DataColumn(label: Text('Дата')),
        DataColumn(label: Text('Співробітник')),
        DataColumn(label: Text('Початок (Clock-In)')),
        DataColumn(label: Text('Кінець (Clock-Out)')),
      ],
      rows: records.map((rec) {
        return DataRow(
          cells: [
            DataCell(
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    rec.date,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            DataCell(
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade100,
                    foregroundColor: Colors.black87,
                    radius: 16,
                    child: Text(
                      _getInitials(rec.employeeName),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    rec.employeeName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            DataCell(_buildTimeBadge(rec.clockIn, true)),
            DataCell(_buildTimeBadge(rec.clockOut, false)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildScheduleTable(
    BuildContext context,
    List<WorkSchedule> schedules,
  ) {
    return DataTable(
      dataRowMaxHeight: 64,
      dataRowMinHeight: 64,
      headingTextStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
      columns: const [
        DataColumn(label: Text('Співробітник')),
        DataColumn(label: Text('Робочі дні')),
        DataColumn(label: Text('Години зміни')),
        DataColumn(label: Text('Формат')),
        DataColumn(label: Text('Дії')),
      ],
      rows: schedules.map((sch) {
        return DataRow(
          cells: [
            DataCell(
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade100,
                    foregroundColor: Colors.black87,
                    radius: 16,
                    child: Text(
                      _getInitials(sch.employeeName),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    sch.employeeName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            DataCell(
              Text(
                sch.workDays,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            DataCell(
              Text(
                '${sch.startTime} – ${sch.endTime}',
                style: const TextStyle(fontFamily: 'Courier'),
              ),
            ),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  sch.shiftType,
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            DataCell(
              IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: Colors.black54,
                ),
                tooltip: 'Редагувати графік',
                onPressed: () => _showEditScheduleDialog(context, sch),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
