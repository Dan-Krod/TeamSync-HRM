import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/employee_cubit.dart';
import '../cubit/employee_state.dart';

class EmployeesScreen extends StatelessWidget {
  const EmployeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EmployeeCubit()..fetchEmployees(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocBuilder<EmployeeCubit, EmployeeState>(
          builder: (context, state) {
            if (state is EmployeeLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is EmployeeError) {
              return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
            } else if (state is EmployeeLoaded) {
              return _buildTable(state.employees);
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildTable(List employees) {
    return Card(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Список співробітників', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          DataTable(
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('ПІБ')),
              DataColumn(label: Text('Посада')),
              DataColumn(label: Text('Email')),
            ],
            rows: employees.map((emp) => DataRow(
              cells: [
                DataCell(Text(emp.id.toString())),
                DataCell(Text('${emp.firstName} ${emp.lastName}')),
                DataCell(Text(emp.position)),
                DataCell(Text(emp.email)),
              ],
            )).toList(),
          ),
        ],
      ),
    );
  }
}