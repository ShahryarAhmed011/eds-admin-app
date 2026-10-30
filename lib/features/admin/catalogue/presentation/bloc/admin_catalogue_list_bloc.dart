import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/core.dart';
import '../../domain/entities/admin_catalogue_variant.dart';
import '../../domain/usecase/get_catalogue_variants.dart';

part 'admin_catalogue_list_event.dart';
part 'admin_catalogue_list_state.dart';

class AdminCatalogueListBloc
    extends Bloc<AdminCatalogueListEvent, AdminCatalogueListState> {
  AdminCatalogueListBloc(this._getVariants)
    : super(const AdminCatalogueListLoading()) {
    on<AdminCatalogueListRequested>(_onRequested);
    on<AdminCatalogueListTabChanged>(_onTabChanged);
    on<AdminCatalogueListSearchChanged>(_onSearchChanged);
  }

  final GetCatalogueVariants _getVariants;

  Future<void> _onRequested(
    AdminCatalogueListRequested event,
    Emitter<AdminCatalogueListState> emit,
  ) async {
    emit(const AdminCatalogueListLoading());
    try {
      emit(
        AdminCatalogueListLoaded(page: await _getVariants(const NoParams())),
      );
    } catch (e) {
      emit(
        AdminCatalogueListFailure(
          errorMessage(e),
          reference: errorReference(e),
        ),
      );
    }
  }

  void _onTabChanged(
    AdminCatalogueListTabChanged event,
    Emitter<AdminCatalogueListState> emit,
  ) {
    if (state case final AdminCatalogueListLoaded s) {
      emit(s.copyWith(tab: event.tab));
    }
  }

  void _onSearchChanged(
    AdminCatalogueListSearchChanged event,
    Emitter<AdminCatalogueListState> emit,
  ) {
    if (state case final AdminCatalogueListLoaded s) {
      emit(s.copyWith(query: event.query));
    }
  }
}
