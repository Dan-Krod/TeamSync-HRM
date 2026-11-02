import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/candidate_cubit.dart';
import '../cubit/candidate_state.dart';

class RecruitingScreen extends StatelessWidget {
  const RecruitingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CandidateCubit()..fetchCandidates(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocBuilder<CandidateCubit, CandidateState>(
          builder: (context, state) {
            if (state is CandidateLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CandidateError) {
              return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
            } else if (state is CandidateLoaded) {
              return _buildTable(state.candidates);
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildTable(List candidates) {
    return Card(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Управління кандидатами', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          DataTable(
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('ПІБ')),
              DataColumn(label: Text('Статус')),
              DataColumn(label: Text('Резюме')),
            ],
            rows: candidates.map((c) => DataRow(
              cells: [
                DataCell(Text(c.id.toString())),
                DataCell(Text(c.fullName)),
                DataCell(_buildStatusChip(c.status)),
                DataCell(Text(c.resumeUrl, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline))),
              ],
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'hired': color = Colors.green; break;
      case 'rejected': color = Colors.red; break;
      case 'interviewed': color = Colors.orange; break;
      default: color = Colors.grey;
    }
    return Chip(
      label: Text(status, style: TextStyle(color: color.withOpacity(0.9), fontSize: 12)),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide.none,
    );
  }
}