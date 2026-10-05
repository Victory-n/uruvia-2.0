import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../theme/business/business_theme.dart';
import '../../../widgets/app_text.dart';
import '../models/inventory_item.dart';
import '../models/stock_movement.dart';
import '../services/inventory_service.dart';
import '../widgets/quick_restock_sheet.dart';
import '../widgets/stock_deduction_sheet.dart';
import '../widgets/stock_status_badge.dart';
import 'add_edit_inventory_screen.dart';

class InventoryDetailScreen extends StatefulWidget {
  final InventoryItem item;

  const InventoryDetailScreen({
    super.key,
    required this.item,
  });

  @override
  State<InventoryDetailScreen> createState() => _InventoryDetailScreenState();
}

class _InventoryDetailScreenState extends State<InventoryDetailScreen> {
  late InventoryItem _item;
  List<StockMovement> _movements = [];
  bool _isLoadingMovements = true;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _loadMovements();
  }

  Future<void> _loadMovements() async {
    setState(() => _isLoadingMovements = true);
    final movements = await InventoryService.instance.getItemMovements(_item.id);
    if (mounted) {
      setState(() {
        _movements = movements;
        _isLoadingMovements = false;
      });
    }
  }

  Future<void> _refreshItemData() async {
    final allItems = await InventoryService.instance.getItems();
    final updated = allItems.where((i) => i.id == _item.id).toList();
    if (updated.isNotEmpty && mounted) {
      setState(() {
        _item = updated.first;
      });
    }
    await _loadMovements();
  }

  void _openRestockSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: BusinessTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => QuickRestockSheet(
        item: _item,
        onConfirm: (qty, newCost, note) async {
          await InventoryService.instance.restockItem(
            itemId: _item.id,
            quantityToAdd: qty,
            newCostPrice: newCost,
            note: note,
          );
          await _refreshItemData();
        },
      ),
    );
  }

  void _openDeductSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: BusinessTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StockDeductionSheet(
        item: _item,
        onConfirm: (qty, ref, note) async {
          await InventoryService.instance.deductStock(
            itemId: _item.id,
            quantityToDeduct: qty,
            referenceId: ref,
            note: note,
          );
          await _refreshItemData();
        },
      ),
    );
  }

  Future<void> _editItem() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditInventoryScreen(itemToEdit: _item),
      ),
    );
    if (updated == true && mounted) {
      await _refreshItemData();
    }
  }

  Future<void> _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const AppText.subtitle('Delete Inventory Item?'),
        content: AppText.paragraph(
          'Are you sure you want to delete ${_item.itemName}? This will remove it from local records.',
          style: const TextStyle(color: BusinessTheme.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const AppText.button('Cancel', style: TextStyle(color: BusinessTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: BusinessTheme.danger),
            child: const AppText.button('Delete', style: TextStyle(color: BusinessTheme.white)),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      await InventoryService.instance.deleteItem(_item.id);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      symbol: '₦',
      decimalDigits: 0,
    );
    final bool hasImage = _item.imagePath != null &&
        _item.imagePath!.isNotEmpty &&
        File(_item.imagePath!).existsSync();

    return Scaffold(
      backgroundColor: BusinessTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.arrowLeft,
            color: BusinessTheme.charcoal,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: AppText.subtitle(
          _item.itemName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: BusinessTheme.charcoal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.penToSquare,
              size: 16,
              color: BusinessTheme.charcoal,
            ),
            tooltip: 'Edit Item',
            onPressed: _editItem,
          ),
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.trashCan,
              size: 16,
              color: BusinessTheme.danger,
            ),
            tooltip: 'Delete Item',
            onPressed: _confirmDelete,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshItemData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Display (if uploaded)
              if (hasImage) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    File(_item.imagePath!),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Stock Overview Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: BusinessTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: BusinessTheme.backgroundLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: AppText.paragraph(
                                _item.category,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: BusinessTheme.textMuted,
                                ),
                              ),
                            ),
                            if (_item.sku.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              AppText.paragraph(
                                'SKU: ${_item.sku}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: BusinessTheme.textMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                        StockStatusBadge(item: _item),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Big Quantity Display
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        AppText.title(
                          '${_item.quantity}',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: _item.isOutOfStock
                                ? BusinessTheme.danger
                                : _item.isLowStock
                                    ? const Color(0xFFD97706)
                                    : BusinessTheme.charcoal,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AppText.subtitle(
                          _item.unit,
                          style: const TextStyle(
                            fontSize: 16,
                            color: BusinessTheme.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Financial metrics grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricTile(
                            'Selling Price',
                            currencyFormatter.format(_item.sellingPrice),
                          ),
                        ),
                        Expanded(
                          child: _buildMetricTile(
                            'Cost Price',
                            currencyFormatter.format(_item.costPrice),
                          ),
                        ),
                        Expanded(
                          child: _buildMetricTile(
                            'Unit Profit',
                            currencyFormatter.format(_item.profitMargin),
                            highlightColor: BusinessTheme.success,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricTile(
                            'Total Cost Value',
                            currencyFormatter.format(_item.totalCostValue),
                          ),
                        ),
                        Expanded(
                          child: _buildMetricTile(
                            'Potential Revenue',
                            currencyFormatter.format(_item.totalPotentialRevenue),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Low Stock Threshold Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _item.isLowStock
                      ? const Color(0xFFF59E0B).withValues(alpha: 0.1)
                      : BusinessTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _item.isLowStock
                        ? const Color(0xFFF59E0B).withValues(alpha: 0.4)
                        : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _item.lowStockAlert
                            ? BusinessTheme.primaryAmber.withValues(alpha: 0.15)
                            : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: FaIcon(
                        FontAwesomeIcons.bell,
                        size: 16,
                        color: _item.lowStockAlert
                            ? BusinessTheme.primaryAmber
                            : BusinessTheme.textMuted,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.subtitle(
                            _item.lowStockAlert
                                ? 'Alert Threshold: ${_item.lowStockThreshold} ${_item.unit}'
                                : 'Low Stock Alerts Disabled',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: BusinessTheme.charcoal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          AppText.paragraph(
                            _item.lowStockAlert
                                ? 'You will be notified whenever stock is at or below ${_item.lowStockThreshold} ${_item.unit}.'
                                : 'Turn on alert notifications in item edit screen.',
                            style: const TextStyle(
                              fontSize: 11,
                              color: BusinessTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Stock Movements History / Audit Trail Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      FaIcon(
                        FontAwesomeIcons.clockRotateLeft,
                        size: 14,
                        color: BusinessTheme.charcoal,
                      ),
                      SizedBox(width: 8),
                      AppText.subtitle(
                        'Stock History & Deductions',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: BusinessTheme.charcoal,
                        ),
                      ),
                    ],
                  ),
                  AppText.paragraph(
                    '${_movements.length} records',
                    style: const TextStyle(
                      fontSize: 11,
                      color: BusinessTheme.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Movements list
              if (_isLoadingMovements)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (_movements.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: BusinessTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: const [
                      FaIcon(
                        FontAwesomeIcons.fileLines,
                        size: 28,
                        color: BusinessTheme.textMuted,
                      ),
                      SizedBox(height: 10),
                      AppText.paragraph(
                        'No stock movements recorded yet.',
                        style: TextStyle(color: BusinessTheme.textMuted),
                      ),
                    ],
                  ),
                )
              else
                ..._movements.map((mov) => _buildMovementItem(mov)),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: BusinessTheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openRestockSheet,
                  icon: const FaIcon(FontAwesomeIcons.plus, size: 14),
                  label: const AppText.button(
                    'Restock',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BusinessTheme.primaryAmber,
                    foregroundColor: BusinessTheme.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openDeductSheet,
                  icon: const FaIcon(FontAwesomeIcons.tag, size: 14),
                  label: const AppText.button(
                    'Record Sale',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BusinessTheme.charcoal,
                    foregroundColor: BusinessTheme.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile(String title, String value, {Color? highlightColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.paragraph(
          title,
          style: const TextStyle(
            fontSize: 10,
            color: BusinessTheme.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        AppText.subtitle(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: highlightColor ?? BusinessTheme.charcoal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildMovementItem(StockMovement mov) {
    final dateFormatter = DateFormat('MMM dd, yyyy • hh:mm a');
    final isDeduction = mov.isDeduction;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BusinessTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDeduction
                  ? BusinessTheme.danger.withValues(alpha: 0.1)
                  : BusinessTheme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FaIcon(
              isDeduction
                  ? FontAwesomeIcons.arrowDown
                  : FontAwesomeIcons.arrowUp,
              size: 12,
              color: isDeduction ? BusinessTheme.danger : BusinessTheme.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText.subtitle(
                      mov.movementType.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: BusinessTheme.charcoal,
                      ),
                    ),
                    AppText.subtitle(
                      '${isDeduction ? "" : "+"}${mov.changeQuantity} ${_item.unit}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDeduction
                            ? BusinessTheme.danger
                            : BusinessTheme.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                if (mov.note != null && mov.note!.isNotEmpty)
                  AppText.paragraph(
                    mov.note!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: BusinessTheme.textDark,
                    ),
                  ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText.paragraph(
                      dateFormatter.format(mov.createdAt),
                      style: const TextStyle(
                        fontSize: 10,
                        color: BusinessTheme.textMuted,
                      ),
                    ),
                    AppText.paragraph(
                      'Balance: ${mov.resultingQuantity}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: BusinessTheme.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
