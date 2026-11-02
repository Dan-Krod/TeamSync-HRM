// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../cubit/employee_cubit.dart';
import '../cubit/employee_state.dart';
import '../models/employee.dart';
import '../../../core/api/api_client.dart';

// 1. Віджет-обгортка, який ініціалізує Cubit та завантажує дані
class EmployeesScreen extends StatelessWidget {
  const EmployeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EmployeeCubit()..loadEmployees(),
      child: const _EmployeesView(),
    );
  }
}

// 2. Внутрішній віджет, який будує інтерфейс
class _EmployeesView extends StatefulWidget {
  const _EmployeesView();

  @override
  State<_EmployeesView> createState() => _EmployeesViewState();
}

class _EmployeesViewState extends State<_EmployeesView> {
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Future<void> _downloadContract(int empId) async {
    _showSnackBar('Генерація контракту...', Colors.blue);
    try {
      final response = await ApiClient.getFile('/documents/generate/$empId?type=contract');

      if (response.statusCode == 200) {
        final blob = html.Blob([response.bodyBytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', 'contract_$empId.pdf')
          ..click();
        html.Url.revokeObjectUrl(url);
        _showSnackBar('Контракт завантажено', Colors.green);
      } else {
        print('Помилка сервера: ${response.statusCode} - ${response.body}');
        _showSnackBar('Помилка ${response.statusCode}: перезайдіть у систему', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Помилка: $e', Colors.red);
    }
  }

  void _showEmployeeDialog({Employee? employee}) {
    final isEditing = employee != null;
    final firstNameController = TextEditingController(text: employee?.firstName ?? '');
    final lastNameController = TextEditingController(text: employee?.lastName ?? '');
    final emailController = TextEditingController(text: employee?.email ?? '');
    final positionController = TextEditingController(text: employee?.position ?? '');
    final salaryController = TextEditingController(text: employee?.salary.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Редагувати співробітника' : 'Новий співробітник'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: firstNameController, decoration: const InputDecoration(labelText: 'Ім\'я')),
                TextField(controller: lastNameController, decoration: const InputDecoration(labelText: 'Прізвище')),
                TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
                TextField(controller: positionController, decoration: const InputDecoration(labelText: 'Посада')),
                TextField(controller: salaryController, decoration: const InputDecoration(labelText: 'Зарплата (грн)'), keyboardType: TextInputType.number),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Скасувати')),
          ElevatedButton(
            onPressed: () {
              final data = {
                'first_name': firstNameController.text,
                'last_name': lastNameController.text,
                'email': emailController.text,
                'position': positionController.text,
                'salary': double.tryParse(salaryController.text) ?? 0.0,
                'department_id': 1,
              };
              if (isEditing) {
                context.read<EmployeeCubit>().updateEmployee(employee.id, data);
              } else {
                context.read<EmployeeCubit>().addEmployee(data);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Зберегти'),
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
        onPressed: () => _showEmployeeDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Додати'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<EmployeeCubit, EmployeeState>(
        builder: (context, state) {
          if (state is EmployeeLoading) return const Center(child: CircularProgressIndicator());
          if (state is EmployeeError) return Center(child: Text(state.message));
          if (state is EmployeeLoaded) {
            return Card(
              margin: const EdgeInsets.all(16),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('Штат співробітників', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  DataTable(
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('ПІБ')),
                      DataColumn(label: Text('Посада')),
                      DataColumn(label: Text('Дії')),
                    ],
                    rows: state.employees.map((emp) {
                      return DataRow(cells: [
                        DataCell(Text(emp.id.toString())),
                        DataCell(Text('${emp.firstName} ${emp.lastName}')),
                        DataCell(Text(emp.position)),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.picture_as_pdf, color: Colors.blue),
                              tooltip: 'Завантажити контракт',
                              onPressed: () => _downloadContract(emp.id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              tooltip: 'Редагувати',
                              onPressed: () => _showEmployeeDialog(employee: emp),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Звільнити',
                              onPressed: () => context.read<EmployeeCubit>().deleteEmployee(emp.id),
                            ),
                          ],
                        )),
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