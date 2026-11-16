import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/api_client.dart';
import '../models/employee.dart';
import 'employee_state.dart';

class EmployeeCubit extends Cubit<EmployeeState> {
  EmployeeCubit() : super(EmployeeInitial());

  Future<void> loadEmployees() async {
    emit(EmployeeLoading());
    try {
      final response = await ApiClient.get('/employees/');
      final List<Employee> employees = (response as List)
          .map((e) => Employee.fromJson(e))
          .toList();
      emit(EmployeeLoaded(employees));
    } catch (e) {
      emit(EmployeeError('Помилка завантаження: ${e.toString()}'));
    }
  }

  Future<void> addEmployee(Map<String, dynamic> employeeData) async {
    try {
      await ApiClient.post('/employees/', employeeData);
      loadEmployees(); // Оновлюємо таблицю
    } catch (e) {
      emit(EmployeeError('Помилка створення: ${e.toString()}'));
    }
  }

  Future<void> updateEmployee(int id, Map<String, dynamic> employeeData) async {
    try {
      await ApiClient.put('/employees/$id', employeeData);
      loadEmployees();
    } catch (e) {
      emit(EmployeeError('Помилка оновлення: ${e.toString()}'));
    }
  }

  Future<void> deleteEmployee(int id) async {
    try {
      await ApiClient.delete('/employees/$id');
      loadEmployees();
    } catch (e) {
      emit(EmployeeError('Помилка звільнення: ${e.toString()}'));
    }
  }
}
