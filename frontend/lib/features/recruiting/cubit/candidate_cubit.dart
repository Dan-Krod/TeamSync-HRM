import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/api_client.dart';
import '../models/candidate.dart';
import 'candidate_state.dart';

class RecruitingCubit extends Cubit<RecruitingState> {
  RecruitingCubit() : super(RecruitingInitial());

  Future<void> loadCandidates() async {
    emit(RecruitingLoading());
    try {
      final candResponse = await ApiClient.get('/candidates/');
      final vacResponse = await ApiClient.get('/candidates/vacancies');

      final List<Candidate> candidates = (candResponse as List)
          .map((e) => Candidate.fromJson(e))
          .toList();
      final List<Vacancy> vacancies = (vacResponse as List)
          .map((e) => Vacancy.fromJson(e))
          .toList();

      emit(RecruitingLoaded(candidates, vacancies));
    } catch (e) {
      emit(RecruitingError('Помилка завантаження: $e'));
    }
  }

  Future<void> addCandidate(Map<String, dynamic> data) async {
    try {
      await ApiClient.post('/candidates/', data);
      loadCandidates();
    } catch (e) {
      emit(RecruitingError('Помилка створення кандидата: $e'));
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

  Future<void> addVacancy(Map<String, dynamic> data) async {
    try {
      await ApiClient.post('/candidates/vacancies', data);
      loadCandidates();
    } catch (e) {
      emit(RecruitingError('Помилка створення вакансії: $e'));
    }
  }

  Future<void> updateVacancyStatus(int id, String newStatus) async {
    try {
      await ApiClient.put('/candidates/vacancies/$id', {'status': newStatus});
      loadCandidates();
    } catch (e) {
      emit(RecruitingError('Помилка оновлення вакансії: $e'));
    }
  }
}