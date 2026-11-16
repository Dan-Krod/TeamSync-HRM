import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/api_client.dart';
import '../models/candidate.dart';
import 'candidate_state.dart';

class RecruitingCubit extends Cubit<RecruitingState> {
  RecruitingCubit() : super(RecruitingInitial());

  Future<void> loadCandidates() async {
    emit(RecruitingLoading());
    try {
      final response = await ApiClient.get('/candidates/');
      final List<Candidate> candidates = (response as List)
          .map((e) => Candidate.fromJson(e))
          .toList();
      emit(RecruitingLoaded(candidates));
    } catch (e) {
      emit(RecruitingError('Помилка завантаження: $e'));
    }
  }

  Future<void> addCandidate(Map<String, dynamic> data) async {
    try {
      await ApiClient.post('/candidates/', data);
      loadCandidates();
    } catch (e) {
      emit(RecruitingError('Помилка створення: $e'));
    }
  }

  Future<void> updateStatus(int id, String newStatus) async {
    try {
      await ApiClient.put('/candidates/$id', {'status': newStatus});
      loadCandidates();
    } catch (e) {
      emit(RecruitingError('Помилка оновлення статусу: $e'));
    }
  }
}
