import 'package:equatable/equatable.dart';

abstract class DashboardState extends Equatable {
  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {}
class DashboardLoading extends DashboardState {}
class DashboardLoaded extends DashboardState {
  final int totalEmployees;
  final int totalCandidates;

  DashboardLoaded({required this.totalEmployees, required this.totalCandidates});

  @override
  List<Object> get props => [totalEmployees, totalCandidates];
}
class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}