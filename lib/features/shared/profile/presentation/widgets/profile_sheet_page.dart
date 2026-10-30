import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/core.dart';
import '../../../../../core/di/injection.dart';
import '../../../common/field_sheets.dart';
import '../bloc/profile_bloc.dart';
import 'profile_photo_picker.dart' as picker;

/// The owner's profile as a page of the account sheet: the photo, then the
/// details as rows that edit in place — the Store tab's look.
class ProfileSheetPage extends StatelessWidget {
  const ProfileSheetPage({super.key, this.onSaved});

  /// After a save or a photo change, so the screen behind can refresh.
  final VoidCallback? onSaved;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileBloc>()..add(const ProfileRequested()),
      child: _ProfilePage(onSaved: onSaved),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage({this.onSaved});

  final VoidCallback? onSaved;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (_, current) =>
          current is ProfileLoaded &&
          (current.message != null || current.phoneError != null),
      listener: (context, state) {
        final loaded = state as ProfileLoaded;
        final message = loaded.message ?? loaded.phoneError!;
        final saved =
            message == ProfileBloc.savedMessage ||
            message == ProfileBloc.photoSavedMessage ||
            message == ProfileBloc.photoRemovedMessage;
        EdsToast.show(
          context,
          message,
          kind: saved ? EdsToastKind.success : EdsToastKind.error,
        );
        if (saved) onSaved?.call();
      },
      builder: (context, state) => EdsSheetPage(
        title: 'Profile',
        busy:
            state is ProfileLoaded &&
            (state.isSaving || state.isUploadingPhoto),
        scrollable: state is ProfileLoaded,
        body: switch (state) {
          ProfileLoading() => const EdsLoadingView(),
          ProfileFailure(:final message, :final reference) => EdsErrorView(
            message: message,
            reference: reference,
            onRetry: () =>
                context.read<ProfileBloc>().add(const ProfileRequested()),
          ),
          ProfileLoaded() => _ProfileDetails(state),
        },
      ),
    );
  }
}

class _ProfileDetails extends StatelessWidget {
  const _ProfileDetails(this.state);

  final ProfileLoaded state;

  /// The label column of the detail rows, as on the Store tab.
  static const double _labelWidth = 124;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ProfileBloc>();
    final profile = state.saved;
    final phoneVerified = profile.phoneVerified == true;
    final emailVerified = profile.emailVerified == true;
    // Each row saves on its own, like the store's.
    void save(ProfileChanged change) {
      bloc
        ..add(change)
        ..add(const ProfileSaveRequested());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EdsIdentityHeader(
          name: profile.fullName.isEmpty ? profile.email : profile.fullName,
          photo: state.photo,
          photoBusy: state.isUploadingPhoto,
          onPhotoTap: state.isUploadingPhoto
              ? null
              : () =>
                    changeProfilePhoto(context, hasPhoto: state.photo != null),
          lines: [
            [profile.role.label, ?profile.city].join(' · '),
          ],
        ),
        AppSpacing.gapXl,
        EdsSettingsSection(
          title: 'Details',
          children: [
            EdsDetailRow(
              'Name',
              profile.fullName.isEmpty ? 'Not set' : profile.fullName,
              labelWidth: _labelWidth,
              onEdit: () => showTextFieldSheet(
                context,
                title: 'Your name',
                subtitle: 'As customers and riders see it.',
                label: 'Full name',
                initial: profile.fullName,
                minLength: 2,
                onSave: (value) => save(ProfileChanged(fullName: value)),
              ),
            ),
            // A verified number is locked; changing it would need a new
            // code.
            EdsDetailRow(
              'Mobile',
              profile.phone.isEmpty ? 'Not set' : profile.phone,
              labelWidth: _labelWidth,
              valueIcon: phoneVerified ? Icons.verified : null,
              valueColor: phoneVerified ? AppColors.verified : null,
              onEdit: phoneVerified
                  ? null
                  : () => showTextFieldSheet(
                      context,
                      title: 'Mobile number',
                      label: 'Mobile number',
                      initial: profile.phone,
                      minLength: 7,
                      keyboardType: TextInputType.phone,
                      onSave: (value) => save(ProfileChanged(phone: value)),
                    ),
            ),
            EdsDetailRow(
              'Email',
              profile.email,
              labelWidth: _labelWidth,
              valueIcon: emailVerified ? Icons.verified : null,
              valueColor: emailVerified ? AppColors.verified : null,
            ),
            EdsDetailRow(
              'Language',
              profile.language,
              labelWidth: _labelWidth,
              onEdit: () => showChoiceSheet<String>(
                context,
                title: 'Language',
                options: profile.availableLanguages,
                value: profile.language,
                label: (language) => language,
                onSave: (value) => save(ProfileChanged(language: value)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Camera or library, then the bloc uploads it; "remove" clears it.
Future<void> changeProfilePhoto(
  BuildContext context, {
  required bool hasPhoto,
}) async {
  final bloc = context.read<ProfileBloc>();
  final choice = await picker.pickProfilePhoto(context, hasPhoto: hasPhoto);
  switch (choice) {
    case picker.ProfilePhotoPicked(:final bytes):
      bloc.add(ProfilePhotoPicked(bytes));
    case picker.ProfilePhotoRemove():
      bloc.add(const ProfilePhotoRemoved());
    case null:
      break;
  }
}
