import 'package:equatable/equatable.dart';
import '../models/leave_request.dart';

abstract class LeaveState extends Equatable {
  @override
  List<Object> get props => [];
}

class LeaveInitial extends LeaveState {}

class LeaveLoading extends LeaveState {}

class LeaveLoaded extends LeaveState {
  final List<LeaveRequest> requests;
  LeaveLoaded(this.requests);
  @override
  List<Object> get props => [requests];
}

class LeaveError extends LeaveState {
  final String message;
  LeaveError(this.message);
  @override
  List<Object> get props => [message];
}
