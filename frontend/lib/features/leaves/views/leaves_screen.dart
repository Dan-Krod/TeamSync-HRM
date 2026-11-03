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

class _LeavesView extends StatefulWidget {
  const _LeavesView();

  @override
  State<_LeavesView> createState() => _LeavesViewState();
}

class _LeavesViewState extends State<_LeavesView> {
  String _searchQuery = '';

  // Хелпер для назв відпусток
  String _getLeaveTypeName(String type) {
    switch (type.toLowerCase()) {
      case 'annual':
        return 'Щорічна';
      case 'sick':
        return 'Лікарняний';
      case 'unpaid':
        return 'За свій рахунок';
      default:
        return type.toUpperCase();
    }
  }

  // Хелпер для стилізації бейджів статусу
  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'approved':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        label = 'Погоджено';
        break;
      case 'rejected':
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        label = 'Відхилено';
        break;
      case 'pending':
      default:
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade800;
        label = 'Очікує';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<LeaveCubit, LeaveState>(
        builder: (context, state) {
          if (state is LeaveLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }
          if (state is LeaveError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (state is LeaveLoaded) {
            final filteredRequests = state.requests.where((req) {
              final searchTarget = '${req.employeeId} ${req.type}'
                  .toLowerCase();
              return searchTarget.contains(_searchQuery.toLowerCase());
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Управління відпустками',
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
                              hintText: 'Пошук за ID працівника або типом...',
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
                                  DataColumn(label: Text('Заявка')),
                                  DataColumn(label: Text('ID Працівника')),
                                  DataColumn(label: Text('Тип')),
                                  DataColumn(label: Text('Період')),
                                  DataColumn(label: Text('Статус')),
                                  DataColumn(label: Text('Дії')),
                                ],
                                rows: filteredRequests.map((req) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          '#${req.id}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.person_outline,
                                              size: 18,
                                              color: Colors.black54,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              req.employeeId.toString(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          _getLeaveTypeName(req.type),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          '${req.startDate} — ${req.endDate}',
                                          style: const TextStyle(
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      DataCell(_buildStatusBadge(req.status)),
                                      DataCell(
                                        req.status == 'pending'
                                            ? Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  InkWell(
                                                    onTap: () => context
                                                        .read<LeaveCubit>()
                                                        .approveLeave(req.id),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            8,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .green
                                                            .shade50,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: const Icon(
                                                        Icons.check,
                                                        color: Colors.green,
                                                        size: 20,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  InkWell(
                                                    onTap: () => context
                                                        .read<LeaveCubit>()
                                                        .rejectLeave(req.id),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            8,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.red.shade50,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: const Icon(
                                                        Icons.close,
                                                        color: Colors.red,
                                                        size: 20,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : const Text(
                                                '-',
                                                style: TextStyle(
                                                  color: Colors.grey,
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
