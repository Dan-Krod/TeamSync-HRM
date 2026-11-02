import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/api_client.dart';
import '../models/attendance_record.dart';

abstract class AttendanceState {}
class AttendanceInitial extends AttendanceState {}
class AttendanceLoading extends AttendanceState {}
class AttendanceLoaded extends AttendanceState {
  final List<AttendanceRecord> records;
  AttendanceLoaded(this.records);
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
      final response = await ApiClient.get('/time/');
      final List<AttendanceRecord> records = (response as List)
          .map((e) => AttendanceRecord.fromJson(e))
          .toList();
      emit(AttendanceLoaded(records));
    } catch (e) {
      emit(AttendanceError('Помилка завантаження: $e'));
    }
  }
}