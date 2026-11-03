import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/attendance_cubit.dart';
//import '../cubit/attendance_state.dart';

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

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
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
              final searchTarget = '${rec.employeeName} ${rec.date}'
                  .toLowerCase();
              return searchTarget.contains(_searchQuery.toLowerCase());
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
                const SizedBox(height: 24),

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
                        // Пошук
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: TextField(
                            onChanged: (value) =>
                                setState(() => _searchQuery = value),
                            decoration: InputDecoration(
                              hintText: 'Пошук за працівником або датою...',
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
                              child: DataTable(
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
                                rows: filteredRecords.map((rec) {
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
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor:
                                                  Colors.grey.shade100,
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
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DataCell(
                                        _buildTimeBadge(rec.clockIn, true),
                                      ),
                                      DataCell(
                                        _buildTimeBadge(rec.clockOut, false),
                                      ),
                                    ],
                                  );
                                }).toList(),
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
}
