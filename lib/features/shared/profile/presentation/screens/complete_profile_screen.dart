import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/core.dart';
import '../../../../../core/di/injection.dart';
import '../../../auth/presentation/widgets/auth_focus_theme.dart';
import '../../../auth/presentation/widgets/auth_hero_layout.dart';
import '../../../common/onboarding_widgets.dart';
import '../../../common/same_height_steps.dart';
import '../../domain/entities/profile_details.dart';
import '../bloc/complete_profile_bloc.dart';
import '../widgets/profile_photo_picker.dart';

/// Onboarding "Profile", one small step per screen like sign up: name →
/// gender and birthday → city → neighbourhood, then "Save and continue".
/// "Log out" sits top-right over the illustration; one line at the bottom
/// shows the onboarding stages (Profile › Store › KYC).
class CompleteProfileScreen extends StatelessWidget {
  const CompleteProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<CompleteProfileBloc>()..add(const CompleteProfileStarted()),
      child: const _CompleteProfileView(),
    );
  }
}

enum _Step { name, photo, about, region, area }

class _CompleteProfileView extends StatefulWidget {
  const _CompleteProfileView();

  @override
  State<_CompleteProfileView> createState() => _CompleteProfileViewState();
}

class _CompleteProfileViewState extends State<_CompleteProfileView> {
  _Step _step = _Step.name;

  void _next() => setState(() => _step = _Step.values[_step.index + 1]);

  void _back() {
    if (_step.index > 0) {
      setState(() => _step = _Step.values[_step.index - 1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Read above the Scaffold, which hides the keyboard inset from its body.
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final role = sl<AuthSession>().role ?? AppRole.customer;
    final stages = onboardingStages(role);
    return PopScope(
      // Back walks the steps; nothing before the first.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: AppColors.white,
          // One line, like sign up's "Already have an account?": where the
          // account is in onboarding (Profile › Store › KYC).
          bottomNavigationBar: keyboardOpen || stages.length < 2
              ? null
              : const OnboardingStageTrail(OnboardingStep.profile),
          body: BlocConsumer<CompleteProfileBloc, CompleteProfileState>(
            listenWhen: (_, current) =>
                current is CompleteProfileReady &&
                (current.isDone ||
                    current.error != null ||
                    current.photoUploaded),
            listener: (context, state) {
              final ready = state as CompleteProfileReady;
              if (ready.error case final error?) {
                EdsToast.show(context, error, kind: EdsToastKind.error);
                return;
              }
              if (ready.photoUploaded) {
                EdsToast.show(
                  context,
                  'Photo uploaded',
                  kind: EdsToastKind.success,
                );
                return;
              }
              EdsToast.show(
                context,
                'Profile saved',
                kind: EdsToastKind.success,
              );
              // On to the next step (the router picks it) or home.
              context.go(role.homeRoute);
            },
            builder: (context, state) => switch (state) {
              CompleteProfileLoading() => const EdsLoadingView(),
              CompleteProfileFailure(:final message) => SafeArea(
                child: EdsErrorView(
                  message: message,
                  onRetry: () => context.read<CompleteProfileBloc>().add(
                    const CompleteProfileStarted(),
                  ),
                ),
              ),
              CompleteProfileReady() => AuthHeroLayout(
                onBack: _step.index > 0 ? _back : null,
                heroAction: const OnboardingLogout(),
                divider: OnboardingProgressLine(
                  stage: OnboardingStep.profile,
                  step: _step.index + 1,
                  total: _Step.values.length,
                ),
                form: _StepForm(state: state, step: _step, onNext: _next),
              ),
            },
          ),
        ),
      ),
    );
  }
}

/// "PROFILE · STEP 2 OF 4", the step's title and context, its fields (all
/// steps share one height, so the button stays put), then Next or "Save
/// and continue".
AppRole get _role => sl<AuthSession>().role ?? AppRole.customer;

/// Shops and riders must be at least their minimum age on the birthday
/// given; customers any age.
bool _oldEnough(CompleteProfileReady state) {
  final birthday = state.details.dateOfBirth;
  final minimum = _role.minimumAge;
  if (minimum == 0) return true;
  if (birthday == null) return false;
  return !turnsAge(birthday, minimum).isAfter(DateTime.now());
}

class _StepForm extends StatelessWidget {
  const _StepForm({
    required this.state,
    required this.step,
    required this.onNext,
  });

  final CompleteProfileReady state;
  final _Step step;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CompleteProfileBloc>();
    final isLast = step == _Step.area;
    // Retailers must add a profile photo while setting up their account.
    final photoRequired = _role == AppRole.retailer;
    final canContinue = switch (step) {
      _Step.name => state.hasName,
      _Step.photo =>
        !state.isUploadingPhoto && (!photoRequired || state.photo != null),
      _Step.about => _oldEnough(state),
      _Step.region => state.details.location.containsKey(GeoLevel.city),
      _Step.area => state.canSave,
    };
    final (title, subtitle) = switch (step) {
      _Step.name => (
        'What’s your name?',
        'This is how ${(sl<AuthSession>().role ?? AppRole.customer).seenBy} '
            'will see you.',
      ),
      _Step.photo => (
        'Add a profile photo',
        photoRequired
            ? 'Required — a clear photo helps customers trust your shop.'
            : 'Optional, but it helps people recognise you.',
      ),
      _Step.about => (
        'A bit about you',
        _role.minimumAge > 0
            ? 'You must be ${_role.minimumAge} or older to '
                  '${_role == AppRole.rider ? 'deliver' : 'sell'} on EDS.'
            : 'Helps us personalise EDS for you.',
      ),
      _Step.region => ('Where are you based?', 'Pick your city.'),
      _Step.area => ('Your neighbourhood', 'So deliveries can find you.'),
    };
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'PROFILE · STEP ${step.index + 1} OF ${_Step.values.length}',
              textAlign: TextAlign.center,
              style: AppTextStyles.eyebrow.copyWith(color: AppColors.crimson),
            ),
            AppSpacing.gapXs,
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.headline,
            ),
            AppSpacing.gapXs,
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),
            AppSpacing.gapLg,
            AuthFocusTheme(
              child: SameHeightSteps(
                shown: step.index,
                children: [
                  _NameStep(state),
                  _PhotoStep(state),
                  _AboutStep(state),
                  _RegionStep(state),
                  _AreaStep(state),
                ],
              ),
            ),
            AppSpacing.gapXl,
            isLast
                ? EdsButton.primary(
                    label: 'Save and continue',
                    isLoading: state.isSaving,
                    onPressed: canContinue
                        ? () => bloc.add(const CompleteProfileSaved())
                        : null,
                  )
                : EdsButton.primary(
                    label: 'Next',
                    onPressed: canContinue ? onNext : null,
                  ),
          ],
        ),
      ),
    );
  }
}

class _NameStep extends StatelessWidget {
  const _NameStep(this.state);

  final CompleteProfileReady state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CompleteProfileBloc>();
    return Column(
      children: [
        EdsTextField(
          hint: 'First name',
          initialValue: state.details.firstName,
          prefix: const Icon(Icons.person_outline),
          textInputAction: TextInputAction.next,
          onChanged: (value) =>
              bloc.add(CompleteProfileEdited(firstName: value)),
        ),
        AppSpacing.gapLg,
        EdsTextField(
          hint: 'Last name',
          initialValue: state.details.lastName,
          prefix: const Icon(Icons.badge_outlined),
          textInputAction: TextInputAction.done,
          onChanged: (value) =>
              bloc.add(CompleteProfileEdited(lastName: value)),
        ),
      ],
    );
  }
}

/// A round avatar: the photo, else the initials. Tap to take or choose
/// one; it uploads straight away.
class _PhotoStep extends StatelessWidget {
  const _PhotoStep(this.state);

  final CompleteProfileReady state;

  static const _size = 112.0;

  @override
  Widget build(BuildContext context) {
    final photo = state.photo;
    final initials = state.details.initials;
    return Column(
      children: [
        Semantics(
          button: true,
          label: photo == null ? 'Add a profile photo' : 'Change your photo',
          child: GestureDetector(
            onTap: state.isUploadingPhoto ? null : () => _pick(context),
            child: SizedBox.square(
              dimension: _size,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: _size,
                    height: _size,
                    alignment: Alignment.center,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTint,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.crimson, width: 2),
                      image: photo == null
                          ? null
                          : DecorationImage(
                              image: MemoryImage(photo),
                              fit: BoxFit.cover,
                            ),
                    ),
                    child: photo != null
                        ? null
                        : initials.isEmpty
                        ? const Icon(
                            Icons.person_outline,
                            size: 44,
                            color: AppColors.crimson,
                          )
                        : Text(
                            initials,
                            style: AppTextStyles.headline.copyWith(
                              color: AppColors.crimson,
                            ),
                          ),
                  ),
                  if (state.isUploadingPhoto)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.scrim,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const SizedBox.square(
                        dimension: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.crimson,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.photo_camera_outlined,
                        size: 18,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AppSpacing.gapMd,
        Builder(
          builder: (context) {
            final required = _role == AppRole.retailer && photo == null;
            final label = state.isUploadingPhoto
                ? 'Uploading…'
                : photo == null
                ? (required
                      ? 'A profile photo is required to continue'
                      : 'Tap to take or choose a photo')
                : 'Looks good. Tap to change it.';
            return Text(
              label,
              textAlign: TextAlign.center,
              style: required
                  ? AppTextStyles.bodySecondary.copyWith(
                      color: AppColors.crimson,
                    )
                  : AppTextStyles.bodySecondary,
            );
          },
        ),
      ],
    );
  }

  Future<void> _pick(BuildContext context) async {
    final bloc = context.read<CompleteProfileBloc>();
    final choice = await pickProfilePhoto(
      context,
      hasPhoto: state.photo != null,
    );
    switch (choice) {
      case ProfilePhotoPicked(:final bytes):
        bloc.add(CompleteProfilePhotoPicked(bytes));
      case ProfilePhotoRemove():
        bloc.add(const CompleteProfilePhotoRemoved());
      case null:
        break;
    }
  }
}

class _AboutStep extends StatelessWidget {
  const _AboutStep(this.state);

  final CompleteProfileReady state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CompleteProfileBloc>();
    final details = state.details;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GenderChoice(
          value: details.gender,
          onChanged: (gender) =>
              bloc.add(CompleteProfileEdited(gender: gender)),
        ),
        AppSpacing.gapLg,
        _PickerField(
          icon: Icons.cake_outlined,
          label: 'Date of birth',
          value: switch (details.dateOfBirth) {
            final date? => _formatDate(date),
            null => null,
          },
          onTap: () => _pickBirthday(context, details.dateOfBirth),
        ),
        if (!_oldEnough(state)) ...[
          AppSpacing.gapSm,
          Text(
            'You must be ${_role.minimumAge} or older.',
            style: AppTextStyles.caption.copyWith(color: AppColors.crimson),
          ),
        ],
      ],
    );
  }

  Future<void> _pickBirthday(BuildContext context, DateTime? current) async {
    final bloc = context.read<CompleteProfileBloc>();
    // Shops and riders can't pick a date under their minimum age.
    final latest = yearsAgo(_role.minimumAge);
    final initial = current == null || current.isAfter(latest)
        ? latest
        : current;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: yearsAgo(100),
      lastDate: latest,
    );
    if (picked != null) bloc.add(CompleteProfileEdited(dateOfBirth: picked));
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _RegionStep extends StatelessWidget {
  const _RegionStep(this.state);

  final CompleteProfileReady state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final level in const [
          GeoLevel.country,
          GeoLevel.province,
          GeoLevel.city,
        ]) ...[
          if (level != GeoLevel.country) AppSpacing.gapMd,
          _GeoField(state: state, level: level),
        ],
      ],
    );
  }
}

class _AreaStep extends StatelessWidget {
  const _AreaStep(this.state);

  final CompleteProfileReady state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CompleteProfileBloc>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GeoField(state: state, level: GeoLevel.town),
        AppSpacing.gapMd,
        // Pick the neighbourhood when the town lists areas.
        if (!state.needsAddress) ...[
          _GeoField(state: state, level: GeoLevel.area),
          AppSpacing.gapMd,
        ],
        // House / street — always required so deliveries can find you.
        EdsTextField(
          hint: 'House / street address',
          initialValue: state.details.address,
          prefix: const Icon(Icons.home_outlined),
          textInputAction: TextInputAction.done,
          onChanged: (value) =>
              bloc.add(CompleteProfileEdited(address: value)),
        ),
      ],
    );
  }
}

/// Male / Female / Other as pills; the chosen one is Crimson.
class _GenderChoice extends StatelessWidget {
  const _GenderChoice({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String> onChanged;

  static const _options = [
    ('male', 'Male'),
    ('female', 'Female'),
    ('other', 'Other'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _options.length; i++) ...[
          if (i > 0) AppSpacing.gapSm,
          Expanded(child: _pill(_options[i])),
        ],
      ],
    );
  }

  Widget _pill((String, String) option) {
    final (key, label) = option;
    final selected = value == key;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: AppColors.none,
        child: InkWell(
          onTap: () => onChanged(key),
          borderRadius: AppRadius.pillAll,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColors.primaryTint : AppColors.white,
              borderRadius: AppRadius.pillAll,
              border: Border.all(
                color: selected ? AppColors.crimson : AppColors.border,
              ),
            ),
            child: Text(
              label,
              style: AppTextStyles.itemTitle.copyWith(
                color: selected ? AppColors.crimson : AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One level of the location cascade; opens a searchable list.
class _GeoField extends StatelessWidget {
  const _GeoField({required this.state, required this.level});

  final CompleteProfileReady state;
  final GeoLevel level;

  @override
  Widget build(BuildContext context) {
    final options = state.options[level];
    final loading = state.loading == level;
    final enabled = !loading && options != null && options.isNotEmpty;
    return _PickerField(
      icon: switch (level) {
        GeoLevel.country => Icons.public,
        GeoLevel.province => Icons.map_outlined,
        GeoLevel.city => Icons.location_city_outlined,
        GeoLevel.town => Icons.holiday_village_outlined,
        GeoLevel.area => Icons.place_outlined,
      },
      label: switch ((options, loading)) {
        (_, true) => 'Loading ${level.label.toLowerCase()}s…',
        (null, _) => level.label,
        ([], _) => 'No ${level.label.toLowerCase()}s here',
        _ => 'Select ${level.label.toLowerCase()}',
      },
      value: state.chosen(level)?.name,
      loading: loading,
      onTap: enabled
          ? () async {
              final bloc = context.read<CompleteProfileBloc>();
              final picked = await showModalBottomSheet<GeoOption>(
                context: context,
                isScrollControlled: true,
                backgroundColor: AppColors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.sheet),
                  ),
                ),
                builder: (_) => _GeoSheet(
                  level: level,
                  options: options,
                  selectedId: state.details.location[level],
                ),
              );
              if (picked != null) {
                bloc.add(CompleteProfileLocationChosen(level, picked.id));
              }
            }
          : null,
    );
  }
}

/// A field-shaped button: icon, the chosen value (or a prompt) and a
/// chevron.
class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
    this.loading = false,
  });

  final IconData icon;
  final String label;
  final String? value;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: enabled ? AppColors.white : AppColors.sectionBackground,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdAll,
        side: BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: SizedBox(
          height: AppSizes.inputHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: AppSizes.icon,
                  color: enabled ? AppColors.crimson : AppColors.gray,
                ),
                AppSpacing.gapMd,
                Expanded(
                  child: Text(
                    value ?? label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: value == null ? AppColors.gray : AppColors.ink,
                    ),
                  ),
                ),
                if (loading)
                  const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.crimson,
                    ),
                  )
                else
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: enabled ? AppColors.ink : AppColors.gray,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Searchable list for one location level.
class _GeoSheet extends StatefulWidget {
  const _GeoSheet({
    required this.level,
    required this.options,
    required this.selectedId,
  });

  final GeoLevel level;
  final List<GeoOption> options;
  final String? selectedId;

  @override
  State<_GeoSheet> createState() => _GeoSheetState();
}

class _GeoSheetState extends State<_GeoSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final shown = [
      for (final option in widget.options)
        if (query.isEmpty || option.name.toLowerCase().contains(query)) option,
    ];
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      builder: (context, controller) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSpacing.gapSm,
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: AppRadius.pillAll,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Text(
              'Select ${widget.level.label.toLowerCase()}',
              style: AppTextStyles.title,
            ),
          ),
          if (widget.options.length > 6)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: AuthFocusTheme(
                child: EdsSearchField(
                  hint: 'Search',
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
            ),
          AppSpacing.gapSm,
          Expanded(
            child: ListView.builder(
              controller: controller,
              itemCount: shown.length,
              itemBuilder: (context, i) {
                final option = shown[i];
                final selected = option.id == widget.selectedId;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  title: Text(
                    option.name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: selected ? AppColors.crimson : AppColors.ink,
                      fontWeight: selected ? FontWeight.w600 : null,
                    ),
                  ),
                  trailing: selected
                      ? const Icon(Icons.check, color: AppColors.crimson)
                      : null,
                  onTap: () => Navigator.of(context).pop(option),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
