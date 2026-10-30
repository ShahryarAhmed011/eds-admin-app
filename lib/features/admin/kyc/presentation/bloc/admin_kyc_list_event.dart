part of 'admin_kyc_list_bloc.dart';

sealed class AdminKycListEvent extends Equatable {
  const AdminKycListEvent();

  @override
  List<Object?> get props => [];
}

final class AdminKycListRequested extends AdminKycListEvent {
  const AdminKycListRequested();
}

final class AdminKycListTabChanged extends AdminKycListEvent {
  const AdminKycListTabChanged(this.tab);

  final KycListTab tab;

  @override
  List<Object?> get props => [tab];
}

final class AdminKycListSearchChanged extends AdminKycListEvent {
  const AdminKycListSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}
