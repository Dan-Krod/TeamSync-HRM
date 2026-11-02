import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/candidate_cubit.dart';
import '../cubit/candidate_state.dart';

class RecruitingScreen extends StatelessWidget {
  const RecruitingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecruitingCubit()..loadCandidates(),
      child: const _RecruitingView(),
    );
  }
}

class _RecruitingView extends StatefulWidget {
  const _RecruitingView();

  @override
  State<_RecruitingView> createState() => _RecruitingViewState();
}

class _RecruitingViewState extends State<_RecruitingView> {
  void _showAddCandidateDialog(BuildContext ctx) {
    final fullNameCtrl = TextEditingController();
    final resumeUrlCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Новий кандидат'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: fullNameCtrl, decoration: const InputDecoration(labelText: 'ПІБ')),
              TextField(controller: resumeUrlCtrl, decoration: const InputDecoration(labelText: 'Посилання на резюме')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Скасувати')),
          ElevatedButton(
            onPressed: () {
              ctx.read<RecruitingCubit>().addCandidate({
                'full_name': fullNameCtrl.text,
                'resume_url': resumeUrlCtrl.text,
                'status': 'new',
              });
              Navigator.pop(context);
            },
            child: const Text('Додати'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCandidateDialog(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Додати кандидата'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<RecruitingCubit, RecruitingState>(
        builder: (context, state) {
          if (state is RecruitingLoading)
            return const Center(child: CircularProgressIndicator());
          if (state is RecruitingError)
            return Center(child: Text(state.message));
          if (state is RecruitingLoaded) {
            return Card(
              margin: const EdgeInsets.all(16),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Воронка рекрутингу',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  DataTable(
                    columns: const [
                      DataColumn(label: Text('ПІБ')),
                      DataColumn(label: Text('Резюме')),
                      DataColumn(label: Text('Етап (Статус)')),
                    ],
                    rows: state.candidates.map((cand) {
                      return DataRow(
                        cells: [
                          DataCell(Text(cand.fullName)),
                          DataCell(Text(cand.resumeUrl, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline))),
                          DataCell(
                            DropdownButton<String>(
                              value: cand.status,
                              underline: const SizedBox(),
                              items: const [
                                DropdownMenuItem(value: 'new', child: Text('Новий')),
                                DropdownMenuItem(value: 'pending', child: Text('Очікує')),
                                DropdownMenuItem(value: 'interviewed', child: Text('Інтерв\'ю')),
                                DropdownMenuItem(value: 'offer', child: Text('Офер')),
                                DropdownMenuItem(value: 'hired', child: Text('Найнято', style: TextStyle(color: Colors.green))),
                                DropdownMenuItem(value: 'rejected', child: Text('Відмовлено', style: TextStyle(color: Colors.red))),
                              ],
                              onChanged: (newValue) {
                                if (newValue != null && newValue != cand.status) {
                                  context.read<RecruitingCubit>().updateStatus(cand.id, newValue);
                                }
                              },
                            ),
                          ),
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
