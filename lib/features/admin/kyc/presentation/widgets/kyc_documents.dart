import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../../core/core.dart';
import '../../../../../core/di/injection.dart';
import '../../../../shared/kyc/domain/kyc_record.dart';
import '../../domain/entities/kyc_applicant.dart';
import '../../domain/usecase/get_kyc_document.dart';

/// The applicant's KYC images (`GET /admin/kyc/{userId}/images/{slot}`):
/// CNIC both sides and a selfie, plus the vehicle card for riders. Tap one
/// to see it full screen.
class KycDocuments extends StatelessWidget {
  const KycDocuments({super.key, required this.applicant});

  final KycApplicant applicant;

  @override
  Widget build(BuildContext context) {
    final slots = KycImageSlot.requiredFor(
      applicant.role == KycApplicantRole.rider
          ? AppRole.rider
          : AppRole.retailer,
    );
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.3,
      children: [
        for (final slot in slots)
          _DocumentTile(userId: applicant.userId, slot: slot),
      ],
    );
  }
}

class _DocumentTile extends StatefulWidget {
  const _DocumentTile({required this.userId, required this.slot});

  final String userId;
  final KycImageSlot slot;

  @override
  State<_DocumentTile> createState() => _DocumentTileState();
}

class _DocumentTileState extends State<_DocumentTile> {
  late final Future<Uint8List?> _image = sl<GetKycDocument>()((
    userId: widget.userId,
    slot: widget.slot.path,
  ));

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _image,
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        final loading = snapshot.connectionState != ConnectionState.done;
        return Semantics(
          button: bytes != null,
          label: widget.slot.label,
          child: Material(
            color: AppColors.sectionBackground,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.mdAll,
              side: BorderSide(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: bytes == null
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (_) =>
                            _FullImage(title: widget.slot.label, bytes: bytes),
                      ),
                    ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (bytes != null)
                    EdsBytesImage(bytes)
                  else
                    Center(
                      child: loading
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.crimson,
                              ),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.image_not_supported_outlined,
                                  color: AppColors.gray,
                                ),
                                AppSpacing.gapXs,
                                Text(
                                  snapshot.hasError
                                      ? 'Couldn’t load'
                                      : 'Not provided',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                    ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      child: EdsBadge(widget.slot.label, tone: EdsTone.warning),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A document full screen, pinch to zoom.
class _FullImage extends StatelessWidget {
  const _FullImage({required this.title, required this.bytes});

  final String title;
  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.white,
        title: Text(
          title,
          style: AppTextStyles.title.copyWith(color: AppColors.white),
        ),
      ),
      body: InteractiveViewer(
        maxScale: 5,
        child: Center(
          child: EdsBytesImage(bytes, fit: BoxFit.contain, onDark: true),
        ),
      ),
    );
  }
}
