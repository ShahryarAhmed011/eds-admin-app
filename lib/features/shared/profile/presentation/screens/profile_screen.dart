import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/core.dart';
import '../../../../../core/di/injection.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/profile_sheet_page.dart' show changeProfilePhoto;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileBloc>()..add(const ProfileRequested()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (_, current) =>
          current is ProfileLoaded && current.message != null,
      listener: (context, state) {
        final message = (state as ProfileLoaded).message!;
        final saved =
            message == ProfileBloc.savedMessage ||
            message == ProfileBloc.photoSavedMessage ||
            message == ProfileBloc.photoRemovedMessage;
        EdsToast.show(
          context,
          message,
          kind: saved ? EdsToastKind.success : EdsToastKind.error,
        );
      },
      builder: (context, state) {
        return EdsScaffold(
          background: AppColors.canvas,
          title: 'Your profile',
          bottomAction: state is ProfileLoaded
              ? EdsButton.primary(
                  label: 'Save changes',
                  isLoading: state.isSaving,
                  onPressed:
                      state.hasChanges && state.draft.fullName.trim().isNotEmpty
                      ? () => context.read<ProfileBloc>().add(
                          const ProfileSaveRequested(),
                        )
                      : null,
                )
              : null,
          body: switch (state) {
            ProfileLoading() => const EdsLoadingView(),
            ProfileFailure(:final message, :final reference) => EdsErrorView(
              message: message,
              reference: reference,
              onRetry: () =>
                  context.read<ProfileBloc>().add(const ProfileRequested()),
            ),
            ProfileLoaded() => _ProfileForm(state),
          },
        );
      },
    );
  }
}

class _ProfileForm extends StatelessWidget {
  const _ProfileForm(this.state);

  final ProfileLoaded state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ProfileBloc>();
    final saved = state.saved;
    final draft = state.draft;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSpacing.gapSm,
        EdsIdentityHeader(
          name: saved.fullName.isEmpty ? saved.email : saved.fullName,
          photo: state.photo,
          photoBusy: state.isUploadingPhoto,
          onPhotoTap: state.isUploadingPhoto
              ? null
              : () =>
                    changeProfilePhoto(context, hasPhoto: state.photo != null),
          verified: saved.phoneVerified == true,
          lines: [
            [saved.role.label, ?saved.city].join(' · '),
          ],
        ),
        AppSpacing.gapXxl,
        EdsTextField(
          label: 'Full name',
          initialValue: draft.fullName,
          textInputAction: TextInputAction.next,
          onChanged: (value) => bloc.add(ProfileChanged(fullName: value)),
        ),
        AppSpacing.gapLg,
        // A verified number is locked; changing it would need a new code.
        EdsTextField(
          label: 'Mobile number',
          errorText: state.phoneError,
          initialValue: draft.phone,
          enabled: saved.phoneVerified != true,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          suffix: saved.phoneVerified == true ? const _VerifiedChip() : null,
          onChanged: (value) => bloc.add(ProfileChanged(phone: value)),
        ),
        AppSpacing.gapLg,
        EdsTextField(
          label: 'Email',
          initialValue: draft.email,
          enabled: false,
          suffix: saved.emailVerified == true
              ? const _VerifiedChip()
              : const _UnverifiedChip('Verify email'),
        ),
        AppSpacing.gapLg,
        EdsDropdownField<String>(
          label: 'Language',
          items: draft.availableLanguages,
          value: draft.language,
          itemLabel: (language) => language,
          onChanged: (value) => bloc.add(ProfileChanged(language: value)),
        ),
      ],
    );
  }
}

/// Green "Verified" inside a field.
class _VerifiedChip extends StatelessWidget {
  const _VerifiedChip();

  @override
  Widget build(BuildContext context) {
    return _Chip(
      icon: Icons.verified,
      label: 'Verified',
      color: AppColors.verified,
      background: AppColors.verifiedTint,
    );
  }
}

/// Amber chip for something still to verify.
class _UnverifiedChip extends StatelessWidget {
  const _UnverifiedChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return _Chip(
      icon: Icons.error_outline,
      label: label,
      color: AppColors.ink,
      background: AppColors.secondaryTint,
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: background,
              borderRadius: AppRadius.pillAll,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: AppSpacing.xxs),
                Text(label, style: AppTextStyles.badge.copyWith(color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
