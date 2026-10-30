part of 'admin_queues_bloc.dart';

sealed class AdminQueuesEvent extends Equatable {
  const AdminQueuesEvent();

  @override
  List<Object?> get props => [];
}

final class AdminQueuesRequested extends AdminQueuesEvent {
  const AdminQueuesRequested();
}
