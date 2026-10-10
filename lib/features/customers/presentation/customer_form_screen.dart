import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/errors/friendly_error.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/sub_page.dart';
import '../application/customers_controller.dart';
import '../domain/customer_models.dart';

/// Add a customer, or edit one when [customerId] is given.
class CustomerFormScreen extends ConsumerWidget {
  const CustomerFormScreen({super.key, this.customerId});
  final String? customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = customerId;
    if (id == null) {
      return const SubPage(title: 'New customer', fallbackRoute: AppRoutes.customers, body: CustomerForm());
    }
    final value = ref.watch(customerProvider(id));
    return SubPage(
      title: 'Edit customer',
      fallbackRoute: AppRoutes.customers,
      body: AsyncView<Customer?>(
        value: value,
        onRetry: () => ref.invalidate(customerProvider(id)),
        isEmpty: (c) => c == null,
        empty: const EmptyState(icon: Icons.search_off_rounded, title: 'Customer not found'),
        data: (c) => CustomerForm(existing: c),
      ),
    );
  }
}

/// The form on its own, so the invoice screen can show it in a sheet.
class CustomerForm extends ConsumerStatefulWidget {
  const CustomerForm({super.key, this.existing, this.onSaved, this.scrollable = true});
  final Customer? existing;

  /// Called with the saved customer instead of closing the page (used by the quick-add sheet).
  final ValueChanged<Customer>? onSaved;
  final bool scrollable;

  @override
  ConsumerState<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends ConsumerState<CustomerForm> {
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _phone = TextEditingController(text: widget.existing?.phone ?? '');
  late final _email = TextEditingController(text: widget.existing?.email ?? '');
  late final _address = TextEditingController(text: widget.existing?.address ?? '');
  late final _notes = TextEditingController(text: widget.existing?.notes ?? '');
  String? _nameError;
  String? _emailError;
  String? _formError;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_name, _phone, _email, _address, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final email = _email.text.trim();
    setState(() {
      _nameError = name.isEmpty ? 'Enter the customer name.' : (name.length > 120 ? 'Keep the name under 120 characters.' : null);
      _emailError = email.isNotEmpty && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email) ? 'Enter a valid email address.' : null;
      _formError = null;
    });
    if (_nameError != null || _emailError != null) return;

    setState(() => _saving = true);
    try {
      final actions = ref.read(customerActionsProvider);
      final existing = widget.existing;
      Customer saved;
      if (existing == null) {
        saved = await actions.create(
          name: name,
          phone: _phone.text,
          email: email,
          address: _address.text,
          notes: _notes.text,
        );
      } else {
        await actions.update(
          existing.id,
          name: name,
          phone: _phone.text,
          email: email,
          address: _address.text,
          notes: _notes.text,
        );
        saved = Customer(id: existing.id, name: name, phone: _phone.text, email: email);
      }
      if (!mounted) return;
      if (widget.onSaved != null) {
        widget.onSaved!(saved);
      } else if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.customers);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _formError = friendlyError(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fields = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'Name',
          controller: _name,
          errorText: _nameError,
          enabled: !_saving,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Phone (optional)',
          controller: _phone,
          enabled: !_saving,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Email (optional)',
          controller: _email,
          errorText: _emailError,
          enabled: !_saving,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Address (optional)',
          controller: _address,
          enabled: !_saving,
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Notes (optional)',
          controller: _notes,
          enabled: !_saving,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
        ),
        if (_formError != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(_formError!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: StatusColors.errorText)),
        ],
        const SizedBox(height: AppSpacing.xxl),
        AppButton(label: 'Save customer', onPressed: _save, loading: _saving),
      ],
    );
    if (!widget.scrollable) return fields;
    return SingleChildScrollView(padding: const EdgeInsets.all(AppSpacing.pageMargin), child: fields);
  }
}
