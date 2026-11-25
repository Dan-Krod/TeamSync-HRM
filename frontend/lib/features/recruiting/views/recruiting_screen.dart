import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/candidate_cubit.dart';
import '../cubit/candidate_state.dart';
import '../models/candidate.dart';

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
  int _selectedTab = 0;
  String _candidateStatusFilter = 'all';
  String _vacancyStatusFilter = 'all';

  void _showAddCandidateDialog(BuildContext ctx, List<Vacancy> vacancies) {
    final fullNameCtrl = TextEditingController();
    final resumeUrlCtrl = TextEditingController();
    final openVacancies = vacancies.where((v) => v.status == 'open').toList();
    int? selectedVacancyId =
        openVacancies.isNotEmpty ? openVacancies.first.id : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
                const SizedBox(height: 16),
                if (openVacancies.isNotEmpty)
                  DropdownButtonFormField<int?>(
                    value: selectedVacancyId,
                    decoration: const InputDecoration(labelText: 'Вакансія'),
                    items: openVacancies
                        .map(
                          (v) => DropdownMenuItem<int?>(
                            value: v.id,
                            child: Text(v.title),
                          ),
                        )
                        .toList(),
                    onChanged: (val) =>
                        setDialogState(() => selectedVacancyId = val),
                  )
                else
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Немає відкритих вакансій',
                      style: TextStyle(color: Colors.redAccent, fontSize: 13),
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
              onPressed: openVacancies.isEmpty
                  ? null
                  : () {
                      ctx.read<RecruitingCubit>().addCandidate({
                        'full_name': fullNameCtrl.text,
                        'resume_url': resumeUrlCtrl.text,
                        'status': 'new',
                        'vacancy_id': selectedVacancyId,
                      });
                      Navigator.pop(context);
                    },
              child: const Text('Додати'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddVacancyDialog(BuildContext ctx) {
    final titleCtrl = TextEditingController();
    final salaryCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Нова вакансія',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Назва посади'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: salaryCtrl,
                decoration: const InputDecoration(
                  labelText: 'Зарплатна вилка (напр. 2000 - 3000 \$)',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Короткий опис'),
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
              ctx.read<RecruitingCubit>().addVacancy({
                'title': titleCtrl.text,
                'salary_range': salaryCtrl.text,
                'description': descCtrl.text,
                'status': 'open',
              });
              Navigator.pop(context);
            },
            child: const Text('Створити'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'hired':
      case 'open':
        return Colors.green.shade700;
      case 'rejected':
      case 'closed':
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

  String _getVacancyTitle(int? vacancyId, List<Vacancy> vacancies) {
    if (vacancyId == null) return '—';
    final match = vacancies.where((v) => v.id == vacancyId);
    return match.isNotEmpty ? match.first.title : '—';
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
              final matchesSearch = cand.fullName
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());
              final matchesStatus = _candidateStatusFilter == 'all' ||
                  cand.status == _candidateStatusFilter;
              return matchesSearch && matchesStatus;
            }).toList();

            final filteredVacancies = state.vacancies.where((vac) {
              final matchesSearch = vac.title
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());
              final matchesStatus = _vacancyStatusFilter == 'all' ||
                  vac.status == _vacancyStatusFilter;
              return matchesSearch && matchesStatus;
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Шапка екрану
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Рекрутинг та вакансії',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _selectedTab == 0
                          ? _showAddCandidateDialog(context, state.vacancies)
                          : _showAddVacancyDialog(context),
                      icon: Icon(
                        _selectedTab == 0
                            ? Icons.person_add_outlined
                            : Icons.work_outline,
                        size: 20,
                      ),
                      label: Text(
                        _selectedTab == 0
                            ? 'Додати кандидата'
                            : 'Додати вакансію',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Перемикач вкладок
                Row(
                  children: [
                    ChoiceChip(
                      label: Text('Кандидати (${state.candidates.length})'),
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
                      label: Text('Вакансії (${state.vacancies.length})'),
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
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  onChanged: (value) =>
                                      setState(() => _searchQuery = value),
                                  decoration: InputDecoration(
                                    hintText: _selectedTab == 0
                                        ? 'Пошук кандидата...'
                                        : 'Пошук вакансії...',
                                    prefixIcon: const Icon(
                                      Icons.search_outlined,
                                      color: Colors.grey,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: _selectedTab == 0
                                      ? DropdownButton<String>(
                                          value: _candidateStatusFilter,
                                          items: const [
                                            DropdownMenuItem(value: 'all', child: Text('Усі статуси')),
                                            DropdownMenuItem(value: 'new', child: Text('Новий')),
                                            DropdownMenuItem(value: 'pending', child: Text('Очікує')),
                                            DropdownMenuItem(value: 'interviewed', child: Text('Інтерв\'ю')),
                                            DropdownMenuItem(value: 'offer', child: Text('Офер')),
                                            DropdownMenuItem(value: 'hired', child: Text('Найнято')),
                                            DropdownMenuItem(value: 'rejected', child: Text('Відмовлено')),
                                          ],
                                          onChanged: (val) {
                                            if (val != null) {
                                              setState(() => _candidateStatusFilter = val);
                                            }
                                          },
                                        )
                                      : DropdownButton<String>(
                                          value: _vacancyStatusFilter,
                                          items: const [
                                            DropdownMenuItem(value: 'all', child: Text('Усі статуси')),
                                            DropdownMenuItem(value: 'open', child: Text('Відкриті')),
                                            DropdownMenuItem(value: 'closed', child: Text('Закриті')),
                                          ],
                                          onChanged: (val) {
                                            if (val != null) {
                                              setState(() => _vacancyStatusFilter = val);
                                            }
                                          },
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: SingleChildScrollView(
                            child: SizedBox(
                              width: double.infinity,
                              child: _selectedTab == 0
                                  ? _buildCandidatesTable(
                                      context,
                                      filteredCandidates,
                                      state.vacancies,
                                    )
                                  : _buildVacanciesTable(
                                      context,
                                      filteredVacancies,
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

  Widget _buildCandidatesTable(
    BuildContext context,
    List<Candidate> candidates,
    List<Vacancy> vacancies,
  ) {
    return DataTable(
      dataRowMaxHeight: 64,
      dataRowMinHeight: 64,
      headingTextStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
      columns: const [
        DataColumn(label: Text('ПІБ кандидата')),
        DataColumn(label: Text('Вакансія')),
        DataColumn(label: Text('Резюме')),
        DataColumn(label: Text('Етап (Статус)')),
      ],
      rows: candidates.map((cand) {
        return DataRow(
          cells: [
            DataCell(
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade100,
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
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            DataCell(Text(_getVacancyTitle(cand.vacancyId, vacancies))),
            DataCell(
              Row(
                children: [
                  const Icon(Icons.link, size: 18, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    cand.resumeUrl.length > 25
                        ? '${cand.resumeUrl.substring(0, 25)}...'
                        : cand.resumeUrl,
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            DataCell(
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: _getStatusColor(cand.status).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getStatusColor(cand.status).withOpacity(0.2),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: cand.status,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: _getStatusColor(cand.status),
                      size: 18,
                    ),
                    style: TextStyle(
                      color: _getStatusColor(cand.status),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'new', child: Text('Новий')),
                      DropdownMenuItem(value: 'pending', child: Text('Очікує')),
                      DropdownMenuItem(
                        value: 'interviewed',
                        child: Text('Інтерв\'ю'),
                      ),
                      DropdownMenuItem(value: 'offer', child: Text('Офер')),
                      DropdownMenuItem(value: 'hired', child: Text('Найнято')),
                      DropdownMenuItem(
                        value: 'rejected',
                        child: Text('Відмовлено'),
                      ),
                    ],
                    onChanged: (newValue) {
                      if (newValue != null && newValue != cand.status) {
                        context.read<RecruitingCubit>().updateStatus(
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
    );
  }

  Widget _buildVacanciesTable(BuildContext context, List<Vacancy> vacancies) {
    return DataTable(
      dataRowMaxHeight: 64,
      dataRowMinHeight: 64,
      headingTextStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
      columns: const [
        DataColumn(label: Text('Посада')),
        DataColumn(label: Text('Зарплатна вилка')),
        DataColumn(label: Text('Статус')),
      ],
      rows: vacancies.map((vac) {
        return DataRow(
          cells: [
            DataCell(
              Text(
                vac.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            DataCell(Text(vac.salaryRange)),
            DataCell(
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: _getStatusColor(vac.status).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getStatusColor(vac.status).withOpacity(0.2),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: vac.status,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: _getStatusColor(vac.status),
                      size: 18,
                    ),
                    style: TextStyle(
                      color: _getStatusColor(vac.status),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'open', child: Text('Відкрита')),
                      DropdownMenuItem(value: 'closed', child: Text('Закрита')),
                    ],
                    onChanged: (newValue) {
                      if (newValue != null && newValue != vac.status) {
                        context.read<RecruitingCubit>().updateVacancyStatus(
                          vac.id,
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
    );
  }
}
