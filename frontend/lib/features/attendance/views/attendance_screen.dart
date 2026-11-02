import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/attendance_cubit.dart';

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

class _AttendanceView extends StatelessWidget {
  const _AttendanceView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<AttendanceCubit, AttendanceState>(
        builder: (context, state) {
          if (state is AttendanceLoading) return const Center(child: CircularProgressIndicator());
          if (state is AttendanceError) return Center(child: Text(state.message));
          if (state is AttendanceLoaded) {
            return Card(
              margin: const EdgeInsets.all(16),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('Облік робочого часу', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  DataTable(
                    columns: const [
                      DataColumn(label: Text('Дата')),
                      DataColumn(label: Text('Співробітник')),
                      DataColumn(label: Text('Початок (Clock-In)')),
                      DataColumn(label: Text('Кінець (Clock-Out)')),
                    ],
                    rows: state.records.map((rec) {
                      return DataRow(
                        cells: [
                          DataCell(Text(rec.date)),
                          DataCell(Text(rec.employeeName)),
                          DataCell(Text(rec.clockIn, style: const TextStyle(color: Colors.green))),
                          DataCell(Text(rec.clockOut, style: const TextStyle(color: Colors.red))),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}