part of 'admin_queues_bloc.dart';

sealed class AdminQueuesState extends Equatable {
  const AdminQueuesState();

  @override
  List<Object?> get props => [];
}

final class AdminQueuesLoading extends AdminQueuesState {
  const AdminQueuesLoading();
}

final class AdminQueuesLoaded extends AdminQueuesState {
  const AdminQueuesLoaded(this.queues);

  final AdminQueues queues;

  @override
  List<Object?> get props => [queues];
}

final class AdminQueuesFailure extends AdminQueuesState {
  const AdminQueuesFailure(this.message, {this.reference});

  final String message;
  final String? reference;

  @override
  List<Object?> get props => [message, reference];
}
