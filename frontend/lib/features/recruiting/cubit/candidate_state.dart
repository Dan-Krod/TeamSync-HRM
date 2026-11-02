import 'package:equatable/equatable.dart';
import '../models/candidate.dart';

abstract class CandidateState extends Equatable {
  const CandidateState();
  
  @override
  List<Object> get props => [];
}

class CandidateInitial extends CandidateState {}

class CandidateLoading extends CandidateState {}

class CandidateLoaded extends CandidateState {
  final List<Candidate> candidates;
  const CandidateLoaded(this.candidates);

  @override
  List<Object> get props => [candidates];
}

class CandidateError extends CandidateState {
  final String message;
  const CandidateError(this.message);

  @override
  List<Object> get props => [message];
}