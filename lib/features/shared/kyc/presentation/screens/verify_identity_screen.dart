import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/core.dart';
import '../../../../../core/di/injection.dart';
import '../../../auth/presentation/widgets/auth_focus_theme.dart';
import '../../../auth/presentation/widgets/auth_hero_layout.dart';
import '../../../common/onboarding_widgets.dart';
import '../../../common/same_height_steps.dart';
import '../../domain/kyc_record.dart';
import '../bloc/verify_identity_bloc.dart';

/// Onboarding "KYC" (retailers and riders), one small step per screen like
/// sign up: CNIC → dates → photos → review, then "Submit for review". Once
/// sent it shows the review status until an admin approves.
class VerifyIdentityScreen extends StatelessWidget {
  const VerifyIdentityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VerifyIdentityBloc>()
        ..add(
          VerifyIdentityStarted(sl<AuthSession>().role ?? AppRole.retailer),
        ),
      child: const _VerifyIdentityView(),
    );
  }
}

enum _Step { card, dates, photos, selfie, vehicle, review }

/// The steps for [role]: riders also photograph their vehicle card.
List<_Step> _stepsFor(AppRole role) => [
  _Step.card,
  _Step.dates,
  _Step.photos,
  _Step.selfie,
  if (role == AppRole.rider) _Step.vehicle,
  _Step.review,
];

class _VerifyIdentityView extends StatefulWidget {
  const _VerifyIdentityView();

  @override
  State<_VerifyIdentityView> createState() => _VerifyIdentityViewState();
}

class _VerifyIdentityViewState extends State<_VerifyIdentityView> {
  late final List<_Step> _steps = _stepsFor(
    sl<AuthSession>().role ?? AppRole.retailer,
  );
  _Step _step = _Step.card;

  int get _index => _steps.indexOf(_step);

  void _next() => setState(() => _step = _steps[_index + 1]);

  void _back() {
    if (_index > 0) setState(() => _step = _steps[_index - 1]);
  }

  @override
  Widget build(BuildContext context) {
    // Read above the Scaffold, which hides the keyboard inset from its body.
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final role = sl<AuthSession>().role ?? AppRole.retailer;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: AppColors.white,
          bottomNavigationBar: keyboardOpen
              ? null
              : const OnboardingStageTrail(OnboardingStep.kyc),
          body: BlocConsumer<VerifyIdentityBloc, VerifyIdentityState>(
            listenWhen: (previous, current) =>
                current is VerifyIdentityReady &&
                (current.error != null ||
                    current.isApproved ||
                    // Just sent: back to the first step for a resubmit.
                    (previous is VerifyIdentityReady &&
                        previous.editing &&
                        !current.editing)),
            listener: (context, state) {
              final ready = state as VerifyIdentityReady;
              if (ready.error case final error?) {
                EdsToast.show(context, error, kind: EdsToastKind.error);
              } else if (ready.isApproved) {
                EdsToast.show(
                  context,
                  'You’re verified',
                  kind: EdsToastKind.success,
                );
                context.go(role.homeRoute);
              } else {
                setState(() => _step = _Step.card);
                EdsToast.show(
                  context,
                  'Submitted for review',
                  kind: EdsToastKind.success,
                );
              }
            },
            builder: (context, state) => switch (state) {
              VerifyIdentityLoading() => const EdsLoadingView(),
              VerifyIdentityFailure(:final message) => SafeArea(
                child: EdsErrorView(
                  message: message,
                  onRetry: () => context.read<VerifyIdentityBloc>().add(
                    VerifyIdentityStarted(role),
                  ),
                ),
              ),
              VerifyIdentityReady(:final editing) when !editing =>
                AuthHeroLayout(
                  heroAction: const OnboardingLogout(),
                  divider: const OnboardingProgressLine(
                    stage: OnboardingStep.kyc,
                    step: 1,
                    total: 1,
                  ),
                  form: _StatusPanel(state),
                ),
              VerifyIdentityReady() => AuthHeroLayout(
                onBack: _index > 0 ? _back : null,
                heroAction: const OnboardingLogout(),
                divider: OnboardingProgressLine(
                  stage: OnboardingStep.kyc,
                  step: _index + 1,
                  total: _steps.length,
                ),
                form: _StepForm(
                  state: state,
                  steps: _steps,
                  step: _step,
                  onNext: _next,
                ),
              ),
            },
          ),
        ),
      ),
    );
  }
}

/// "KYC · STEP 2 OF 4", the step's title and context, its fields (all
/// steps share one height, so the button stays put), then Next or "Submit
/// for review".
class _StepForm extends StatelessWidget {
  const _StepForm({
    required this.state,
    required this.steps,
    required this.step,
    required this.onNext,
  });

  final VerifyIdentityReady state;
  final List<_Step> steps;
  final _Step step;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<VerifyIdentityBloc>();
    final form = state.form;
    final isLast = step == _Step.review;
    final canContinue = switch (step) {
      _Step.card => form.hasCard,
      _Step.dates => form.hasDates,
      _Step.photos => form.hasImages(_cnicSlots),
      _Step.selfie => form.hasImages(const [KycImageSlot.selfie]),
      _Step.vehicle => form.hasImages(_vehicleSlots),
      _Step.review => form.isComplete,
    };
    final (title, subtitle) = switch (step) {
      _Step.card => ('Your CNIC', 'As printed on your national identity card.'),
      _Step.dates => ('Card dates', 'Your CNIC must not be expired.'),
      _Step.photos => (
        'Photos of your CNIC',
        'Clear photos of the front and the back.',
      ),
      _Step.selfie => (
        'Take a selfie',
        'A clear photo of your face, to match your CNIC.',
      ),
      _Step.vehicle => (
        'Your vehicle card',
        'Front and back of your vehicle registration card.',
      ),
      _Step.review => (
        'Check your details',
        'An admin usually reviews within 1 working day.',
      ),
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
              'KYC · STEP ${steps.indexOf(step) + 1} OF ${steps.length}',
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
                shown: steps.indexOf(step),
                children: [
                  for (final each in steps)
                    switch (each) {
                      _Step.card => _CardStep(form),
                      _Step.dates => _DatesStep(form),
                      _Step.photos => _ImagesStep(form, _cnicSlots),
                      _Step.selfie => _ImagesStep(form, const [
                        KycImageSlot.selfie,
                      ]),
                      _Step.vehicle => _ImagesStep(form, _vehicleSlots),
                      _Step.review => _ReviewStep(form),
                    },
                ],
              ),
            ),
            AppSpacing.gapXl,
            isLast
                ? EdsButton.primary(
                    label: 'Submit for review',
                    isLoading: state.isSubmitting,
                    onPressed: canContinue
                        ? () => bloc.add(const VerifyIdentitySubmitted())
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

class _CardStep extends StatelessWidget {
  const _CardStep(this.form);

  final KycForm form;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<VerifyIdentityBloc>();
    return Column(
      children: [
        EdsTextField(
          hint: '12345-1234567-1',
          initialValue: formatCnic(form.nicNumber),
          prefix: const Icon(Icons.credit_card),
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          inputFormatters: const [_CnicFormatter()],
          onChanged: (value) => bloc.add(
            VerifyIdentityEdited(nicNumber: value.replaceAll('-', '')),
          ),
        ),
        AppSpacing.gapLg,
        // The name comes from the profile and must match the CNIC, so it's
        // shown locked rather than edited here.
        EdsTextField(
          label: 'Name on card',
          initialValue: form.nameOnCard,
          prefix: const Icon(Icons.person_outline),
          helper: 'From your profile',
          enabled: false,
        ),
      ],
    );
  }
}

class _DatesStep extends StatelessWidget {
  const _DatesStep(this.form);

  final KycForm form;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<VerifyIdentityBloc>();
    final today = yearsAgo(0);
    final issued = form.issueDate;
    final expires = form.expiryDate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FieldButton(
          icon: Icons.event_available_outlined,
          label: 'Issue date',
          value: issued == null ? null : formatDate(issued),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: issued ?? yearsAgo(1),
              firstDate: yearsAgo(30),
              lastDate: today,
            );
            if (picked != null) {
              bloc.add(VerifyIdentityEdited(issueDate: picked));
            }
          },
        ),
        AppSpacing.gapLg,
        _FieldButton(
          icon: Icons.event_busy_outlined,
          label: 'Expiry date',
          value: expires == null ? null : formatDate(expires),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: expires ?? yearsAgo(-5),
              firstDate: today,
              lastDate: yearsAgo(-30),
            );
            if (picked != null) {
              bloc.add(VerifyIdentityEdited(expiryDate: picked));
            }
          },
        ),
        if (issued != null && expires != null && !form.hasDates) ...[
          AppSpacing.gapSm,
          Text(
            'The expiry date must be after the issue date.',
            style: AppTextStyles.caption.copyWith(color: AppColors.crimson),
          ),
        ],
      ],
    );
  }
}

const _cnicSlots = [KycImageSlot.nicFront, KycImageSlot.nicBack];
const _vehicleSlots = [
  KycImageSlot.vehicleCardFront,
  KycImageSlot.vehicleCardBack,
];

/// One tile per image slot, side by side (one tall tile for the selfie).
class _ImagesStep extends StatelessWidget {
  const _ImagesStep(this.form, this.slots);

  final KycForm form;
  final List<KycImageSlot> slots;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<VerifyIdentityBloc>();
    return Row(
      children: [
        for (var i = 0; i < slots.length; i++) ...[
          if (i > 0) AppSpacing.gapMd,
          Expanded(
            child: _PhotoTile(
              slot: slots[i],
              bytes: form.images[slots[i]],
              onPicked: (bytes) =>
                  bloc.add(VerifyIdentityImagePicked(slots[i], bytes)),
            ),
          ),
        ],
      ],
    );
  }
}

/// One image: tap to take or choose it from the library. The selfie's
/// camera opens the front lens.
class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.slot,
    required this.bytes,
    required this.onPicked,
  });

  final KycImageSlot slot;
  final Uint8List? bytes;
  final ValueChanged<Uint8List> onPicked;

  static const _height = 132.0;

  bool get _isSelfie => slot == KycImageSlot.selfie;

  @override
  Widget build(BuildContext context) {
    final photo = bytes;
    return Semantics(
      button: true,
      label: photo == null ? 'Add ${slot.label}' : 'Change ${slot.label}',
      child: Material(
        color: AppColors.sectionBackground,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: BorderSide(
            color: photo == null ? AppColors.border : AppColors.crimson,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _pick(context),
          child: SizedBox(
            height: _height,
            child: photo == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isSelfie
                            ? Icons.face_retouching_natural_outlined
                            : Icons.add_a_photo_outlined,
                        color: AppColors.crimson,
                      ),
                      AppSpacing.gapSm,
                      Text(slot.label, style: AppTextStyles.label),
                    ],
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.memory(photo, fit: BoxFit.cover),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          child: EdsBadge(slot.label, tone: EdsTone.warning),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  /// Camera (front for a selfie) or library, kept under the API's 1 MB.
  Future<void> _pick(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_camera_outlined,
                color: AppColors.crimson,
              ),
              title: Text(_isSelfie ? 'Take a selfie' : 'Take a photo'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.crimson,
              ),
              title: const Text('Choose from library'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final file = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 75,
      preferredCameraDevice: _isSelfie ? CameraDevice.front : CameraDevice.rear,
    );
    if (file == null) return;
    onPicked(await file.readAsBytes());
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep(this.form);

  final KycForm form;

  @override
  Widget build(BuildContext context) {
    final issued = form.issueDate;
    final expires = form.expiryDate;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.sectionBackground,
        borderRadius: AppRadius.mdAll,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _row('CNIC', formatCnic(form.nicNumber)),
          _row('Name', form.nameOnCard),
          _row('Issued', issued == null ? '—' : formatDate(issued)),
          _row('Expires', expires == null ? '—' : formatDate(expires)),
          if (form.requiredImages.isNotEmpty) ...[
            AppSpacing.gapSm,
            Text('Photos', style: AppTextStyles.bodySecondary),
            AppSpacing.gapSm,
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final slot in form.requiredImages)
                  _ReviewThumb(slot: slot, bytes: form.images[slot]),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
    child: Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(label, style: AppTextStyles.bodySecondary),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.itemTitle,
          ),
        ),
      ],
    ),
  );
}

/// A small labelled preview of one submitted KYC image on the review step.
class _ReviewThumb extends StatelessWidget {
  const _ReviewThumb({required this.slot, required this.bytes});

  final KycImageSlot slot;
  final Uint8List? bytes;

  static const _width = 100.0;
  static const _height = 74.0;

  @override
  Widget build(BuildContext context) {
    final photo = bytes;
    return SizedBox(
      width: _width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: AppRadius.smAll,
            child: SizedBox(
              width: _width,
              height: _height,
              child: photo == null
                  ? ColoredBox(
                      color: AppColors.white,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.gray,
                      ),
                    )
                  : EdsBytesImage(photo),
            ),
          ),
          AppSpacing.gapXs,
          Text(
            slot.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

/// After sending: under review ("Check status") or rejected ("Fix and
/// resubmit").
class _StatusPanel extends StatelessWidget {
  const _StatusPanel(this.state);

  final VerifyIdentityReady state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<VerifyIdentityBloc>();
    final record = state.record;
    final rejected = record.status == KycStatus.rejected;
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
              'KYC',
              textAlign: TextAlign.center,
              style: AppTextStyles.eyebrow.copyWith(color: AppColors.crimson),
            ),
            AppSpacing.gapXs,
            Text(
              rejected
                  ? 'Please check your details'
                  : 'We’re checking your details',
              textAlign: TextAlign.center,
              style: AppTextStyles.headline,
            ),
            AppSpacing.gapXs,
            Text(
              rejected
                  ? record.reason ?? 'Some details couldn’t be verified.'
                  : 'Usually within 1 working day. We’ll let you know.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),
            AppSpacing.gapLg,
            Container(
              decoration: BoxDecoration(
                color: AppColors.sectionBackground,
                borderRadius: AppRadius.mdAll,
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  const Icon(Icons.badge_outlined, color: AppColors.crimson),
                  AppSpacing.gapMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(record.nameOnCard, style: AppTextStyles.itemTitle),
                        Text(
                          formatCnic(record.nicNumber),
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  EdsBadge(
                    rejected ? 'Rejected' : 'In review',
                    tone: rejected ? EdsTone.danger : EdsTone.warning,
                  ),
                ],
              ),
            ),
            AppSpacing.gapXl,
            rejected
                ? EdsButton.primary(
                    label: 'Fix and resubmit',
                    onPressed: () =>
                        bloc.add(const VerifyIdentityResubmitRequested()),
                  )
                : EdsButton.primary(
                    label: 'Check status',
                    isLoading: state.isRefreshing,
                    onPressed: () => bloc.add(
                      VerifyIdentityStarted(
                        sl<AuthSession>().role ?? AppRole.retailer,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

/// A field-shaped button: icon, the value (or a prompt) and a chevron.
class _FieldButton extends StatelessWidget {
  const _FieldButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
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
                Icon(icon, size: AppSizes.icon, color: AppColors.crimson),
                AppSpacing.gapMd,
                Expanded(
                  child: Text(
                    value ?? label,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: value == null ? AppColors.gray : AppColors.ink,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: AppColors.ink),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "3520112345671" → "35201-1234567-1" (partial input formats as far as
/// it goes).
String formatCnic(String digits) {
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i == 5 || i == 12) buffer.write('-');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// "17 Apr 2021".
String formatDate(DateTime date) {
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

/// Digits only, at most 13, shown as 12345-1234567-1.
class _CnicFormatter extends TextInputFormatter {
  const _CnicFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 13) digits = digits.substring(0, 13);
    final text = formatCnic(digits);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
