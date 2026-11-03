import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/report_cubit.dart';
import '../cubit/report_state.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReportCubit()..fetchReports(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocBuilder<ReportCubit, ReportState>(
          builder: (context, state) {
            if (state is ReportLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.black),
              );
            } else if (state is ReportError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              );
            } else if (state is ReportLoaded) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Звіти та аналітика',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Фінансові показники та статистика персоналу',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 32),

                    const Text(
                      'Фінансовий звіт за відділами',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDepartmentsGrid(state.departments),

                    const SizedBox(height: 40),

                    const Text(
                      'Аналітика відпусток та лікарняних',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLeavesAnalytics(state.leavesAnalytics),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
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
                      color: Colors.black87,
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
                  color: Colors.black,
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
}
