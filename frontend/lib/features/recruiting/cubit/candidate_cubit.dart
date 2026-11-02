import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/api_client.dart';
import '../models/candidate.dart';
import 'candidate_state.dart';

class CandidateCubit extends Cubit<CandidateState> {
  CandidateCubit() : super(CandidateInitial());

  Future<void> fetchCandidates() async {
    emit(CandidateLoading());
    try {
      final response = await ApiClient.get('/candidates/');
      final List<Candidate> candidates = (response as List)
          .map((json) => Candidate.fromJson(json))
          .toList();
      emit(CandidateLoaded(candidates));
    } catch (e) {
      emit(CandidateError('Не вдалося завантажити кандидатів: ${e.toString()}'));
    }
  }
}