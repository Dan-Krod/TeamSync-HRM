import 'package:equatable/equatable.dart';
import '../models/report_models.dart';

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object> get props => [];
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportLoaded extends ReportState {
  final List<DepartmentReport> departments;
  final Map<String, dynamic> leavesAnalytics;

  const ReportLoaded({
    required this.departments,
    required this.leavesAnalytics,
  });

  @override
  List<Object> get props => [departments, leavesAnalytics];
}

class ReportError extends ReportState {
  final String message;
  const ReportError(this.message);

  @override
  List<Object> get props => [message];
}
