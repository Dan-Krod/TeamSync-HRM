import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/api_client.dart';
import '../models/report_models.dart';
import 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  ReportCubit() : super(ReportInitial());

  Future<void> fetchReports() async {
    emit(ReportLoading());
    try {
      // Виконуємо два запити паралельно для швидкості
      final results = await Future.wait([
        ApiClient.get('/reports/departments'),
        ApiClient.get('/reports/leaves-analytics'),
      ]);

      final deptData = results[0]['department_reports'] as List;
      final leavesData = results[1]['leaves_analytics'] as Map<String, dynamic>;

      final departments = deptData.map((json) => DepartmentReport.fromJson(json)).toList();

      emit(ReportLoaded(departments: departments, leavesAnalytics: leavesData));
    } catch (e) {
      emit(ReportError('Помилка завантаження звітів: ${e.toString()}'));
    }
  }
}