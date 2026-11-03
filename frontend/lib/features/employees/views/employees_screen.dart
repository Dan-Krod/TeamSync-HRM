// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/employee_cubit.dart';
import '../cubit/employee_state.dart';
import '../models/employee.dart';
import '../../../core/api/api_client.dart';

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

class _EmployeesView extends StatefulWidget {
  const _EmployeesView();

  @override
  State<_EmployeesView> createState() => _EmployeesViewState();
}

class _EmployeesViewState extends State<_EmployeesView> {
  String _searchQuery = '';

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Future<void> _downloadContract(int empId) async {
    _showSnackBar('Генерація контракту...', Colors.blue);
    try {
      final response = await ApiClient.getFile(
        '/documents/generate/$empId?type=contract',
      );

      if (response.statusCode == 200) {
        final blob = html.Blob([response.bodyBytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', 'contract_$empId.pdf')
          ..click();
        html.Url.revokeObjectUrl(url);
        _showSnackBar('Контракт завантажено', Colors.green);
      } else {
        _showSnackBar(
          'Помилка ${response.statusCode}: перезайдіть у систему',
          Colors.red,
        );
      }
    } catch (e) {
      _showSnackBar('Помилка: $e', Colors.red);
    }
  }

  void _showEmployeeDialog({Employee? employee}) {
    final isEditing = employee != null;
    final firstNameController = TextEditingController(
      text: employee?.firstName ?? '',
    );
    final lastNameController = TextEditingController(
      text: employee?.lastName ?? '',
    );
    final emailController = TextEditingController(text: employee?.email ?? '');
    final positionController = TextEditingController(
      text: employee?.position ?? '',
    );
    final salaryController = TextEditingController(
      text: employee?.salary.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          isEditing ? 'Редагувати співробітника' : 'Новий співробітник',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: 'Ім\'я'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'Прізвище'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: positionController,
                  decoration: const InputDecoration(labelText: 'Посада'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: salaryController,
                  decoration: const InputDecoration(
                    labelText: 'Зарплата (грн)',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
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
      body: BlocBuilder<EmployeeCubit, EmployeeState>(
        builder: (context, state) {
          if (state is EmployeeLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }
          if (state is EmployeeError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (state is EmployeeLoaded) {
            final filteredEmployees = state.employees.where((emp) {
              final fullName = '${emp.firstName} ${emp.lastName}'.toLowerCase();
              return fullName.contains(_searchQuery.toLowerCase());
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Штат співробітників',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showEmployeeDialog(),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text(
                        'Додати',
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

                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        // Пошук
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: TextField(
                            onChanged: (value) =>
                                setState(() => _searchQuery = value),
                            decoration: InputDecoration(
                              hintText: 'Пошук співробітника...',
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
                                dataRowMaxHeight:
                                    72, 
                                dataRowMinHeight: 72,
                                headingTextStyle: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                                columns: const [
                                  DataColumn(label: Text('Співробітник')),
                                  DataColumn(label: Text('Посада')),
                                  DataColumn(label: Text('Дії')),
                                ],
                                rows: filteredEmployees.map((emp) {
                                  final initials =
                                      '${emp.firstName[0]}${emp.lastName[0]}';
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor:
                                                  Colors.grey.shade100,
                                              foregroundColor: Colors.black87,
                                              radius: 20,
                                              child: Text(
                                                initials,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '${emp.firstName} ${emp.lastName}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  emp.email,
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          emp.position,
                                          style: const TextStyle(
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        PopupMenuButton<String>(
                                          icon: const Icon(
                                            Icons.more_vert_rounded,
                                            color: Colors.grey,
                                          ),
                                          color: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          onSelected: (value) {
                                            if (value == 'contract')
                                              _downloadContract(emp.id);
                                            if (value == 'edit')
                                              _showEmployeeDialog(
                                                employee: emp,
                                              );
                                            if (value == 'delete')
                                              context
                                                  .read<EmployeeCubit>()
                                                  .deleteEmployee(emp.id);
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 'contract',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .picture_as_pdf_outlined,
                                                    size: 20,
                                                  ),
                                                  SizedBox(width: 12),
                                                  Text('Контракт'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.edit_outlined,
                                                    size: 20,
                                                  ),
                                                  SizedBox(width: 12),
                                                  Text('Редагувати'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.delete_outline,
                                                    color: Colors.red,
                                                    size: 20,
                                                  ),
                                                  SizedBox(width: 12),
                                                  Text(
                                                    'Звільнити',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
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
