import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/errors/friendly_error.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/sub_page.dart';
import '../application/inventory_controller.dart';
import '../domain/inventory_models.dart';

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(productCategoriesProvider);
    return SubPage(
      title: 'Product categories',
      fallbackRoute: AppRoutes.inventory,
      body: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _edit(context, null),
          icon: const Icon(Icons.add_rounded),
          label: const Text('New category'),
        ),
        body: AsyncView<List<ProductCategory>>(
          value: value,
          onRetry: () => ref.invalidate(productCategoriesProvider),
          isEmpty: (l) => l.isEmpty,
          empty: EmptyState(
            icon: Icons.category_outlined,
            title: 'No categories yet',
            message: 'Group your products, for example Drinks, Grains or Clothing.',
            actionLabel: 'New category',
            onAction: () => _edit(context, null),
          ),
          data: (list) => ListView.separated(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, i) => ListTile(
              minTileHeight: 56,
              title: Text(list[i].name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Rename',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _edit(context, list[i]),
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: () => _delete(context, ref, list[i]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context, ProductCategory? existing) {
    return showAppSheet<void>(
      context,
      title: existing == null ? 'New category' : 'Rename category',
      builder: (_) => _CategoryForm(existing: existing),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, ProductCategory c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${c.name}"?'),
        content: const Text('You can only delete a category that has no products in it.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(inventoryActionsProvider).deleteCategory(c.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyError(e))));
      }
    }
  }
}

class _CategoryForm extends ConsumerStatefulWidget {
  const _CategoryForm({this.existing});
  final ProductCategory? existing;

  @override
  ConsumerState<_CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends ConsumerState<_CategoryForm> {
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty || name.length > 60) {
      setState(() => _error = 'Enter a name up to 60 characters.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final actions = ref.read(inventoryActionsProvider);
      if (widget.existing == null) {
        await actions.addCategory(name);
      } else {
        await actions.renameCategory(widget.existing!.id, name);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = friendlyError(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppTextField(
          label: 'Category name',
          controller: _name,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          errorText: _error,
          enabled: !_saving,
          onSubmitted: (_) => _save(),
        ),
        const SizedBox(height: AppSpacing.xxl),
        AppButton(label: 'Save', onPressed: _save, loading: _saving),
      ],
    );
  }
}
