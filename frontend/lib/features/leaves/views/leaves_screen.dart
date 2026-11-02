import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/leave_cubit.dart';
import '../cubit/leave_state.dart';

class LeavesScreen extends StatelessWidget {
  const LeavesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LeaveCubit()..loadLeaves(),
      child: const _LeavesView(),
    );
  }
}

class _LeavesView extends StatelessWidget {
  const _LeavesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<LeaveCubit, LeaveState>(
        builder: (context, state) {
          if (state is LeaveLoading) return const Center(child: CircularProgressIndicator());
          if (state is LeaveError) return Center(child: Text(state.message));
          if (state is LeaveLoaded) {
            return Card(
              margin: const EdgeInsets.all(16),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('Заявки на відпустку', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  DataTable(
                    columns: const [
                      DataColumn(label: Text('ID Заявки')),
                      DataColumn(label: Text('ID Працівника')),
                      DataColumn(label: Text('Тип')),
                      DataColumn(label: Text('Дати')),
                      DataColumn(label: Text('Статус')),
                      DataColumn(label: Text('Дії')),
                    ],
                    rows: state.requests.map((req) {
                      return DataRow(cells: [
                        DataCell(Text(req.id.toString())),
                        DataCell(Text(req.employeeId.toString())),
                        DataCell(Text(req.type)),
                        DataCell(Text('${req.startDate} - ${req.endDate}')),
                        DataCell(Text(req.status.toUpperCase(), 
                          style: TextStyle(color: req.status == 'approved' ? Colors.green : req.status == 'rejected' ? Colors.red : Colors.orange))),
                        DataCell(req.status == 'pending' 
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () => context.read<LeaveCubit>().approveLeave(req.id)),
                                IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => context.read<LeaveCubit>().rejectLeave(req.id)),
                              ],
                            )
                          : const Text('-')
                        ),
                      ]);
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