import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/core.dart';
import '../../domain/entities/audit_entry.dart';
import '../../domain/usecase/get_audit_log.dart';
import '../widgets/admin_time_format.dart';

part 'admin_audit_log_event.dart';
part 'admin_audit_log_state.dart';

class AdminAuditLogBloc extends Bloc<AdminAuditLogEvent, AdminAuditLogState> {
  AdminAuditLogBloc(this._getAuditLog) : super(const AdminAuditLogLoading()) {
    on<AdminAuditLogRequested>(_onRequested);
    on<AdminAuditLogTabChanged>(_onTabChanged);
    on<AdminAuditLogSearchChanged>(_onSearchChanged);
  }

  final GetAuditLog _getAuditLog;

  Future<void> _onRequested(
    AdminAuditLogRequested event,
    Emitter<AdminAuditLogState> emit,
  ) async {
    emit(const AdminAuditLogLoading());
    try {
      emit(AdminAuditLogLoaded(page: await _getAuditLog(const NoParams())));
    } catch (e) {
      emit(AdminAuditLogFailure(errorMessage(e), reference: errorReference(e)));
    }
  }

  void _onTabChanged(
    AdminAuditLogTabChanged event,
    Emitter<AdminAuditLogState> emit,
  ) {
    if (state case final AdminAuditLogLoaded s) {
      emit(s.copyWith(tab: event.tab));
    }
  }

  void _onSearchChanged(
    AdminAuditLogSearchChanged event,
    Emitter<AdminAuditLogState> emit,
  ) {
    if (state case final AdminAuditLogLoaded s) {
      emit(s.copyWith(query: event.query));
    }
  }
}
