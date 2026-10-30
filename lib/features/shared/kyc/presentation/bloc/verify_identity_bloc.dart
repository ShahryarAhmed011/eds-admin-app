import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/core.dart';
import '../../domain/kyc_record.dart';
import '../../domain/kyc_repository.dart';

/// Onboarding "KYC": the CNIC form (number and name, dates, photos,
/// review), and once sent its review status.
class VerifyIdentityBloc
    extends Bloc<VerifyIdentityEvent, VerifyIdentityState> {
  VerifyIdentityBloc(this._getRecord, this._submit, this._profileName)
    : super(const VerifyIdentityLoading()) {
    on<VerifyIdentityImagePicked>(_onImagePicked);
    on<VerifyIdentityStarted>(_onStarted);
    on<VerifyIdentityEdited>(_onEdited);
    on<VerifyIdentityResubmitRequested>(_onResubmit);
    on<VerifyIdentitySubmitted>(_onSubmitted);
  }

  final GetKycRecord _getRecord;
  final SubmitKyc _submit;
  final GetKycProfileName _profileName;

  /// Loads (or reloads, "Check status") the record.
  Future<void> _onStarted(
    VerifyIdentityStarted event,
    Emitter<VerifyIdentityState> emit,
  ) async {
    final current = state;
    if (current is VerifyIdentityReady) {
      emit(current.copyWith(isRefreshing: true));
    } else {
      emit(const VerifyIdentityLoading());
    }
    try {
      final record = await _getRecord(const NoParams());
      final name = record.nameOnCard.isNotEmpty
          ? record.nameOnCard
          : await _profileName(const NoParams());
      final required = KycImageSlot.requiredFor(event.role);
      final form = current is VerifyIdentityReady
          ? current.form
          : KycForm(
              nicNumber: record.nicNumber,
              nameOnCard: name,
              issueDate: record.issueDate,
              expiryDate: record.expiryDate,
              requiredImages: required,
              // Already sent (e.g. fixing a rejection): the images on file.
              images: record.status == KycStatus.notSubmitted
                  ? const {}
                  : {for (final slot in required) slot: ?record.images[slot]},
            );
      emit(
        VerifyIdentityReady(
          record: record,
          form: form,
          editing: record.status == KycStatus.notSubmitted,
        ),
      );
    } catch (e) {
      if (current is VerifyIdentityReady) {
        emit(current.copyWith(error: errorMessage(e)));
      } else {
        emit(VerifyIdentityFailure(errorMessage(e)));
      }
    }
  }

  void _onEdited(
    VerifyIdentityEdited event,
    Emitter<VerifyIdentityState> emit,
  ) {
    final current = state;
    if (current is! VerifyIdentityReady) return;
    final form = current.form;
    emit(
      current.copyWith(
        form: KycForm(
          nicNumber: event.nicNumber ?? form.nicNumber,
          nameOnCard: event.nameOnCard ?? form.nameOnCard,
          issueDate: event.issueDate ?? form.issueDate,
          expiryDate: event.expiryDate ?? form.expiryDate,
          requiredImages: form.requiredImages,
          images: form.images,
        ),
      ),
    );
  }

  void _onImagePicked(
    VerifyIdentityImagePicked event,
    Emitter<VerifyIdentityState> emit,
  ) {
    final current = state;
    if (current is! VerifyIdentityReady) return;
    if (event.bytes.length > KycImageSlot.maxBytes) {
      emit(
        current.copyWith(
          error: 'That photo is over 1 MB. Please take it again.',
        ),
      );
      return;
    }
    emit(
      current.copyWith(form: current.form.withImage(event.slot, event.bytes)),
    );
  }

  void _onResubmit(
    VerifyIdentityResubmitRequested event,
    Emitter<VerifyIdentityState> emit,
  ) {
    final current = state;
    if (current is VerifyIdentityReady) emit(current.copyWith(editing: true));
  }

  Future<void> _onSubmitted(
    VerifyIdentitySubmitted event,
    Emitter<VerifyIdentityState> emit,
  ) async {
    final current = state;
    if (current is! VerifyIdentityReady ||
        !current.form.isComplete ||
        current.isSubmitting) {
      return;
    }
    emit(current.copyWith(isSubmitting: true));
    final form = current.form;
    try {
      final record = await _submit(
        KycSubmission(
          nicNumber: form.nicNumber,
          nameOnCard: form.nameOnCard,
          issueDate: form.issueDate!,
          expiryDate: form.expiryDate!,
          images: {
            for (final slot in form.requiredImages) slot: ?form.images[slot],
          },
        ),
      );
      emit(current.copyWith(record: record, editing: false));
    } catch (e) {
      emit(current.copyWith(error: errorMessage(e)));
    }
  }
}

/// What the form holds. Images are kept as bytes until submitted.
class KycForm extends Equatable {
  const KycForm({
    this.nicNumber = '',
    this.nameOnCard = '',
    this.issueDate,
    this.expiryDate,
    this.requiredImages = const [],
    this.images = const {},
  });

  /// Digits only.
  final String nicNumber;
  final String nameOnCard;
  final DateTime? issueDate;
  final DateTime? expiryDate;

  /// The slots this role must send.
  final List<KycImageSlot> requiredImages;
  final Map<KycImageSlot, Uint8List> images;

  bool get hasCard => nicNumber.length == 13 && nameOnCard.trim().length >= 3;

  /// Issued by today; expires after it was issued and not already.
  bool get hasDates {
    final issued = issueDate;
    final expires = expiryDate;
    if (issued == null || expires == null) return false;
    final today = yearsAgo(0);
    return !issued.isAfter(today) &&
        expires.isAfter(issued) &&
        !expires.isBefore(today);
  }

  /// Every one of [slots] has an image.
  bool hasImages(Iterable<KycImageSlot> slots) =>
      slots.every(images.containsKey);

  bool get isComplete => hasCard && hasDates && hasImages(requiredImages);

  KycForm withImage(KycImageSlot slot, Uint8List bytes) => KycForm(
    nicNumber: nicNumber,
    nameOnCard: nameOnCard,
    issueDate: issueDate,
    expiryDate: expiryDate,
    requiredImages: requiredImages,
    images: {...images, slot: bytes},
  );

  @override
  List<Object?> get props => [
    nicNumber,
    nameOnCard,
    issueDate,
    expiryDate,
    requiredImages,
    {for (final e in images.entries) e.key: e.value.length},
  ];
}

sealed class VerifyIdentityEvent extends Equatable {
  const VerifyIdentityEvent();

  @override
  List<Object?> get props => [];
}

/// First load, and "Check status". [role] decides the images required.
final class VerifyIdentityStarted extends VerifyIdentityEvent {
  const VerifyIdentityStarted(this.role);

  final AppRole role;

  @override
  List<Object?> get props => [role];
}

final class VerifyIdentityImagePicked extends VerifyIdentityEvent {
  const VerifyIdentityImagePicked(this.slot, this.bytes);

  final KycImageSlot slot;
  final Uint8List bytes;

  @override
  List<Object?> get props => [slot, bytes.length];
}

/// Only non-null values are applied.
final class VerifyIdentityEdited extends VerifyIdentityEvent {
  const VerifyIdentityEdited({
    this.nicNumber,
    this.nameOnCard,
    this.issueDate,
    this.expiryDate,
  });

  final String? nicNumber;
  final String? nameOnCard;
  final DateTime? issueDate;
  final DateTime? expiryDate;

  @override
  List<Object?> get props => [nicNumber, nameOnCard, issueDate, expiryDate];
}

final class VerifyIdentityResubmitRequested extends VerifyIdentityEvent {
  const VerifyIdentityResubmitRequested();
}

final class VerifyIdentitySubmitted extends VerifyIdentityEvent {
  const VerifyIdentitySubmitted();
}

sealed class VerifyIdentityState extends Equatable {
  const VerifyIdentityState();

  @override
  List<Object?> get props => [];
}

final class VerifyIdentityLoading extends VerifyIdentityState {
  const VerifyIdentityLoading();
}

final class VerifyIdentityFailure extends VerifyIdentityState {
  const VerifyIdentityFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class VerifyIdentityReady extends VerifyIdentityState {
  const VerifyIdentityReady({
    required this.record,
    required this.form,
    required this.editing,
    this.isSubmitting = false,
    this.isRefreshing = false,
    this.error,
  });

  /// As the API last reported it.
  final KycRecord record;
  final KycForm form;

  /// The form (first time, or fixing a rejection); otherwise the status.
  final bool editing;
  final bool isSubmitting;
  final bool isRefreshing;

  /// One-shot: shown in a toast.
  final String? error;

  bool get isApproved => record.status == KycStatus.approved;

  VerifyIdentityReady copyWith({
    KycRecord? record,
    KycForm? form,
    bool? editing,
    bool isSubmitting = false,
    bool isRefreshing = false,
    String? error,
  }) => VerifyIdentityReady(
    record: record ?? this.record,
    form: form ?? this.form,
    editing: editing ?? this.editing,
    isSubmitting: isSubmitting,
    isRefreshing: isRefreshing,
    error: error,
  );

  @override
  List<Object?> get props => [
    record,
    form,
    editing,
    isSubmitting,
    isRefreshing,
    error,
  ];
}
