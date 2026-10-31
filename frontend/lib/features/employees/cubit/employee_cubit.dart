import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/api_client.dart';
import '../models/employee.dart';
import 'employee_state.dart';

class EmployeeCubit extends Cubit<EmployeeState> {
  EmployeeCubit() : super(EmployeeInitial());

  Future<void> fetchEmployees() async {
    emit(EmployeeLoading());
    try {
      final response = await ApiClient.get('/employees/');
      final List<Employee> employees = (response as List)
          .map((json) => Employee.fromJson(json))
          .toList();
      emit(EmployeeLoaded(employees));
    } catch (e) {
      emit(EmployeeError('Не вдалося завантажити дані: ${e.toString()}'));
    }
  }
}