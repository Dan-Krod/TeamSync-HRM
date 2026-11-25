// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/report_cubit.dart';
import '../cubit/report_state.dart';
import '../../../core/api/api_client.dart';
import '../models/report_models.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReportCubit()..fetchReports(),
      child: const _ReportsView(),
    );
  }
}

class _ReportsView extends StatelessWidget {
  const _ReportsView();

  Future<void> _exportReport(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Генерація звіту...'),
        backgroundColor: Colors.blue,
      ),
    );
    try {
      final response = await ApiClient.getFile('/reports/export');
      if (response.statusCode == 200) {
        final blob = html.Blob([response.bodyBytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', 'HR_Report_EN.pdf')
          ..click();
        html.Url.revokeObjectUrl(url);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Звіт завантажено'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<ReportCubit, ReportState>(
        builder: (context, state) {
          if (state is ReportLoading)
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          if (state is ReportError)
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.redAccent),
              ),
            );

          if (state is ReportLoaded) {
            // Рахуємо Загальний ФОП (Total Payroll)
            final totalPayroll = state.departments.fold(
              0.0,
              (sum, dept) => sum + dept.totalBudget,
            );

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Звіти та аналітика',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Фінансові показники та статистика персоналу',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _exportReport(context),
                        icon: const Icon(Icons.download_rounded, size: 20),
                        label: const Text('Експорт звіту (PDF)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Загальний фонд оплати праці (ФОП)',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₴ ${totalPayroll.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Text(
                    'Фінансовий звіт за відділами',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  _buildDepartmentsGrid(state.departments),
                  const SizedBox(height: 24),
                  _buildDepartmentPayrollChart(state.departments, totalPayroll),

                  const SizedBox(height: 40),
                  const Text(
                    'Аналітика відпусток та лікарняних',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  _buildLeavesAnalytics(state.leavesAnalytics),
                  const SizedBox(height: 32),
                  const Text(
                    'Динаміка відпусток та лікарняних по місяцях',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  _buildMonthlyLeavesChart(state.monthlyLeaves),
                  const SizedBox(height: 32),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildDepartmentsGrid(List departments) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.2,
      ),
      itemCount: departments.length,
      itemBuilder: (context, index) {
        final dept = departments[index];
        return Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.domain_outlined,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dept.department,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    color: Colors.grey.shade500,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Штат: ${dept.totalEmployees}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '₴ ${dept.totalBudget.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLeavesAnalytics(Map<String, dynamic> leaves) {
    String getLabel(String key) {
      switch (key.toLowerCase()) {
        case 'annual':
          return 'Щорічна';
        case 'sick':
          return 'Лікарняний';
        case 'unpaid':
          return 'За свій рахунок';
        case 'business_trip':
          return 'Відрядження';
        case 'vacation':
          return 'Відпустка';
        default:
          return key.toUpperCase();
      }
    }

    IconData getIcon(String key) {
      switch (key.toLowerCase()) {
        case 'annual':
          return Icons.flight_takeoff_outlined;
        case 'sick':
          return Icons.medical_services_outlined;
        case 'unpaid':
          return Icons.money_off_outlined;
        case 'business_trip':
          return Icons.business_center_outlined;
        default:
          return Icons.event_note_outlined;
      }
    }

    return Row(
      children: leaves.entries
          .map(
            (e) => Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 16.0),
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Icon(
                        getIcon(e.key),
                        color: Colors.black87,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      getLabel(e.key),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      e.value.toString(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildMonthlyLeavesChart(List<MonthlyLeaveStat> stats) {
    if (stats.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Text(
          'Немає даних для побудови графіка',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    int maxVal = 1;
    for (final s in stats) {
      if (s.vacation > maxVal) maxVal = s.vacation;
      if (s.sick > maxVal) maxVal = s.sick;
      if (s.businessTrip > maxVal) maxVal = s.businessTrip;
    }

    const double maxBarHeight = 160.0;

    Widget buildBar(int value, Color color) {
      final height = value == 0 ? 4.0 : (value / maxVal) * maxBarHeight;
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (value > 0)
            Text(
              '$value',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54),
            ),
          const SizedBox(height: 4),
          Container(
            width: 14,
            height: height,
            decoration: BoxDecoration(
              color: value == 0 ? Colors.grey.shade200 : color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ),
        ],
      );
    }

    Widget buildLegendItem(String label, Color color) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Легенда
          Wrap(
            spacing: 20,
            children: [
              buildLegendItem('Відпустки', Colors.green.shade600),
              buildLegendItem('Лікарняні', Colors.orange.shade600),
              buildLegendItem('Відрядження', Colors.blue.shade600),
            ],
          ),
          const SizedBox(height: 24),
          // Стовпчики по місяцях
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: stats.map((s) {
                return Padding(
                  padding: const EdgeInsets.only(right: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: maxBarHeight + 24,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            buildBar(s.vacation, Colors.green.shade600),
                            const SizedBox(width: 4),
                            buildBar(s.sick, Colors.orange.shade600),
                            const SizedBox(width: 4),
                            buildBar(s.businessTrip, Colors.blue.shade600),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.month,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentPayrollChart(
    List<DepartmentReport> departments,
    double totalPayroll,
  ) {
    if (departments.isEmpty || totalPayroll <= 0) {
      return const SizedBox();
    }

    // Сортуємо від найбільшого бюджету до найменшого
    final sorted = List<DepartmentReport>.from(departments)
      ..sort((a, b) => b.totalBudget.compareTo(a.totalBudget));

    final maxBudget = sorted.first.totalBudget > 0 ? sorted.first.totalBudget : 1.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Розподіл витрат на зарплати по відділах',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          ...sorted.map((dept) {
            final sharePercent = (dept.totalBudget / totalPayroll) * 100;
            final barFactor = (dept.totalBudget / maxBudget).clamp(0.02, 1.0);

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${dept.department} (${dept.totalEmployees} ос.)',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '₴ ${dept.totalBudget.toStringAsFixed(0)}  (${sharePercent.toStringAsFixed(1)}%)',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: barFactor,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
