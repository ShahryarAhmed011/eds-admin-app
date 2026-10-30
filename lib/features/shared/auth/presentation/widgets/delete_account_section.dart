import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/core.dart';
import '../../../../../core/di/injection.dart';
import '../../domain/usecase/delete_account_use_case.dart';

/// A quiet "Delete account" action that opens a clear, password-confirmed
/// warning before permanently deleting the signed-in account
/// (`DELETE /account`). Drop it into any role's account screen.
class DeleteAccountSection extends StatelessWidget {
  const DeleteAccountSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EdsButton.text(
          label: 'Delete account',
          icon: Icons.delete_outline,
          onPressed: () => confirmDeleteAccount(context),
        ),
      ],
    );
  }
}

/// Opens the password-confirmed delete flow and, on success, signs the user
/// out to the sign-in screen. Reusable from any account screen.
Future<void> confirmDeleteAccount(BuildContext context) async {
  final deleted = await showEdsBottomSheet<bool>(
    context: context,
    title: 'Delete your account?',
    subtitle:
        'This permanently deletes your EDoorStep account and your data — '
        'profile, orders, and any shop or listings. It can’t be undone.',
    builder: (_) => const _DeleteConfirm(),
  );
  if (deleted == true && context.mounted) {
    EdsToast.show(
      context,
      'Your account has been deleted',
      kind: EdsToastKind.success,
    );
    context.go(AppRoutes.signIn);
  }
}

class _DeleteConfirm extends StatefulWidget {
  const _DeleteConfirm();

  @override
  State<_DeleteConfirm> createState() => _DeleteConfirmState();
}

class _DeleteConfirmState extends State<_DeleteConfirm> {
  final _controller = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    final password = _controller.text;
    if (password.trim().isEmpty) {
      setState(() => _error = 'Enter your password to confirm.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await sl<DeleteAccountUseCase>()(password);
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const EdsBanner(
          tone: EdsTone.warning,
          title: 'This can’t be undone',
          message: 'Confirm your password to delete your account for good.',
        ),
        AppSpacing.gapLg,
        EdsTextField(
          label: 'Password',
          hint: 'Your current password',
          obscureText: true,
          controller: _controller,
          errorText: _error,
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
        ),
        AppSpacing.gapLg,
        EdsButton.destructive(
          label: 'Delete my account',
          isLoading: _busy,
          onPressed: _delete,
        ),
        AppSpacing.gapSm,
        EdsButton.text(
          label: 'Keep my account',
          onPressed: _busy ? () {} : () => Navigator.of(context).pop(false),
        ),
        AppSpacing.gapSm,
      ],
    );
  }
}
