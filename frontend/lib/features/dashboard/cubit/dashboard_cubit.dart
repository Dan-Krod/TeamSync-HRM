import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/api_client.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(DashboardInitial());

  Future<void> loadDashboard() async {
    emit(DashboardLoading());
    try {
      final results = await Future.wait([
        ApiClient.get('/employees/'),
        ApiClient.get('/candidates/'),
      ]);

      final employeesCount = (results[0] as List).length;
      final candidatesCount = (results[1] as List).length;

      emit(
        DashboardLoaded(
          totalEmployees: employeesCount,
          totalCandidates: candidatesCount,
        ),
      );
    } catch (e) {
      emit(DashboardError('Помилка: ${e.toString()}'));
    }
  }
}
