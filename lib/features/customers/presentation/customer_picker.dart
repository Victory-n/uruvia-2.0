import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_sheet.dart';
import '../application/customers_controller.dart';
import '../domain/customer_models.dart';
import 'customer_form_screen.dart';

/// Lets the user pick a customer, or add a new one without leaving the invoice.
Future<Customer?> showCustomerPicker(BuildContext context) {
  return showAppSheet<Customer>(
    context,
    title: 'Choose a customer',
    builder: (_) => const _Picker(),
  );
}

class _Picker extends ConsumerStatefulWidget {
  const _Picker();

  @override
  ConsumerState<_Picker> createState() => _PickerState();
}

class _PickerState extends ConsumerState<_Picker> {
  String _query = '';
  bool _adding = false;

  @override
  Widget build(BuildContext context) {
    if (_adding) {
      return CustomerForm(
        scrollable: false,
        onSaved: (c) => Navigator.of(context).pop(c),
      );
    }
    final value = ref.watch(customersProvider);
    final q = _query.trim().toLowerCase();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          decoration: const InputDecoration(hintText: 'Search customers', prefixIcon: Icon(Icons.search_rounded)),
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: AppSpacing.md),
        value.when(
          loading: () => const Padding(padding: EdgeInsets.all(AppSpacing.xl), child: Center(child: CircularProgressIndicator())),
          error: (_, __) => Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text('We could not load your customers.', style: Theme.of(context).textTheme.bodyMedium),
          ),
          data: (all) {
            final shown = [for (final c in all) if (q.isEmpty || c.name.toLowerCase().contains(q) || (c.phone ?? '').contains(q)) c];
            return ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.4),
              child: shown.isEmpty
                  ? const Padding(padding: EdgeInsets.all(AppSpacing.lg), child: Text('No customers found.'))
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: shown.length,
                      itemBuilder: (_, i) => ListTile(
                        minTileHeight: 56,
                        title: Text(shown[i].name),
                        subtitle: shown[i].contactLine == null ? null : Text(shown[i].contactLine!),
                        onTap: () => Navigator.of(context).pop(shown[i]),
                      ),
                    ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: 'Add a new customer',
          icon: Icons.person_add_alt_1_rounded,
          style: AppButtonStyle.secondary,
          onPressed: () => setState(() => _adding = true),
        ),
      ],
    );
  }
}
