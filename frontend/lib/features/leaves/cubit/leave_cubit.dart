import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/api_client.dart';
import '../models/leave_request.dart';
import 'leave_state.dart';

class LeaveCubit extends Cubit<LeaveState> {
  LeaveCubit() : super(LeaveInitial());

  Future<void> loadLeaves() async {
    emit(LeaveLoading());
    try {
      final response = await ApiClient.get('/leaves/');
      final List<LeaveRequest> requests = (response as List)
          .map((e) => LeaveRequest.fromJson(e))
          .toList();
      emit(LeaveLoaded(requests));
    } catch (e) {
      emit(LeaveError('Помилка завантаження: $e'));
    }
  }

  Future<void> approveLeave(int id) async {
    try {
      await ApiClient.put('/leaves/$id/approve', {});
      loadLeaves();
    } catch (e) {
      emit(LeaveError('Помилка погодження: $e'));
    }
  }

  Future<void> rejectLeave(int id) async {
    try {
      await ApiClient.put('/leaves/$id/reject', {});
      loadLeaves();
    } catch (e) {
      emit(LeaveError('Помилка відхилення: $e'));
    }
  }
}
