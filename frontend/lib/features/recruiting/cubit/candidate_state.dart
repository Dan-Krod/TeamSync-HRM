import 'package:equatable/equatable.dart';
import '../models/candidate.dart';

abstract class RecruitingState extends Equatable {
  @override
  List<Object> get props => [];
}

class RecruitingInitial extends RecruitingState {}

class RecruitingLoading extends RecruitingState {}

class RecruitingLoaded extends RecruitingState {
  final List<Candidate> candidates;
  RecruitingLoaded(this.candidates);
  @override
  List<Object> get props => [candidates];
}

class RecruitingError extends RecruitingState {
  final String message;
  RecruitingError(this.message);
  @override
  List<Object> get props => [message];
}
