import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/api_client.dart';
import '../models/attendance_record.dart';

abstract class AttendanceState {}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final List<AttendanceRecord> records;
  final List<WorkSchedule> schedules;
  AttendanceLoaded(this.records, this.schedules);
}

class AttendanceError extends AttendanceState {
  final String message;
  AttendanceError(this.message);
}

class AttendanceCubit extends Cubit<AttendanceState> {
  AttendanceCubit() : super(AttendanceInitial());

  Future<void> loadAttendance() async {
    emit(AttendanceLoading());
    try {
      final recordsRes = await ApiClient.get('/time/');
      final schedulesRes = await ApiClient.get('/time/schedules');

      final List<AttendanceRecord> records = (recordsRes as List)
          .map((e) => AttendanceRecord.fromJson(e))
          .toList();
      final List<WorkSchedule> schedules = (schedulesRes as List)
          .map((e) => WorkSchedule.fromJson(e))
          .toList();

      emit(AttendanceLoaded(records, schedules));
    } catch (e) {
      emit(AttendanceError('Помилка завантаження: $e'));
    }
  }

  Future<void> updateSchedule(int employeeId, Map<String, dynamic> data) async {
    try {
      await ApiClient.put('/time/schedules/$employeeId', data);
      loadAttendance();
    } catch (e) {
      emit(AttendanceError('Помилка оновлення графіка: $e'));
    }
  }
}
