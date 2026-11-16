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
  String _searchQuery = '';

  void _showAddCandidateDialog(BuildContext ctx) {
    final fullNameCtrl = TextEditingController();
    final resumeUrlCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Новий кандидат',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fullNameCtrl,
                decoration: const InputDecoration(labelText: 'ПІБ'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: resumeUrlCtrl,
                decoration: const InputDecoration(
                  labelText: 'Посилання на резюме (URL)',
                ),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'hired':
        return Colors.green.shade700;
      case 'rejected':
        return Colors.red.shade700;
      case 'offer':
        return Colors.orange.shade700;
      case 'interviewed':
        return Colors.purple.shade700;
      case 'pending':
        return Colors.blue.shade700;
      default:
        return Colors.black87;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<RecruitingCubit, RecruitingState>(
        builder: (context, state) {
          if (state is RecruitingLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }
          if (state is RecruitingError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (state is RecruitingLoaded) {
            final filteredCandidates = state.candidates.where((cand) {
              return cand.fullName.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Шапка екрану
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Воронка рекрутингу',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAddCandidateDialog(context),
                      icon: const Icon(Icons.person_add_outlined, size: 20),
                      label: const Text(
                        'Додати кандидата',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Основна картка з таблицею
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
                              hintText: 'Пошук кандидата...',
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

                        // Таблиця
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
                                  DataColumn(label: Text('ПІБ кандидата')),
                                  DataColumn(label: Text('Резюме')),
                                  DataColumn(label: Text('Етап (Статус)')),
                                ],
                                rows: filteredCandidates.map((cand) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor:
                                                  Colors.grey.shade100,
                                              radius: 16,
                                              child: const Icon(
                                                Icons.person_outline,
                                                size: 18,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              cand.fullName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.link,
                                              size: 18,
                                              color: Colors.blue,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              cand.resumeUrl.length > 25
                                                  ? '${cand.resumeUrl.substring(0, 25)}...'
                                                  : cand.resumeUrl,
                                              style: const TextStyle(
                                                color: Colors.blue,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                          height: 36,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(
                                              cand.status,
                                            ).withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: _getStatusColor(
                                                cand.status,
                                              ).withOpacity(0.2),
                                            ),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: cand.status,
                                              icon: Icon(
                                                Icons.keyboard_arrow_down,
                                                color: _getStatusColor(
                                                  cand.status,
                                                ),
                                                size: 18,
                                              ),
                                              style: TextStyle(
                                                color: _getStatusColor(
                                                  cand.status,
                                                ),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                              items: const [
                                                DropdownMenuItem(
                                                  value: 'new',
                                                  child: Text('Новий'),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'pending',
                                                  child: Text('Очікує'),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'interviewed',
                                                  child: Text('Інтерв\'ю'),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'offer',
                                                  child: Text('Офер'),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'hired',
                                                  child: Text('Найнято'),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'rejected',
                                                  child: Text('Відмовлено'),
                                                ),
                                              ],
                                              onChanged: (newValue) {
                                                if (newValue != null &&
                                                    newValue != cand.status) {
                                                  context
                                                      .read<RecruitingCubit>()
                                                      .updateStatus(
                                                        cand.id,
                                                        newValue,
                                                      );
                                                }
                                              },
                                            ),
                                          ),
                                        ),
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
