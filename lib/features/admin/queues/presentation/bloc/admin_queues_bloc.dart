import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/core.dart';
import '../../domain/entities/admin_queues.dart';
import '../../domain/usecase/get_admin_queues.dart';

part 'admin_queues_event.dart';
part 'admin_queues_state.dart';

class AdminQueuesBloc extends Bloc<AdminQueuesEvent, AdminQueuesState> {
  AdminQueuesBloc(this._getQueues) : super(const AdminQueuesLoading()) {
    on<AdminQueuesRequested>(_onRequested);
  }

  final GetAdminQueues _getQueues;

  Future<void> _onRequested(
    AdminQueuesRequested event,
    Emitter<AdminQueuesState> emit,
  ) async {
    if (state is! AdminQueuesLoaded) emit(const AdminQueuesLoading());
    try {
      emit(AdminQueuesLoaded(await _getQueues(const NoParams())));
    } catch (e) {
      emit(AdminQueuesFailure(errorMessage(e), reference: errorReference(e)));
    }
  }
}
