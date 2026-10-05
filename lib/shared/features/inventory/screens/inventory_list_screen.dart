import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../theme/business/business_theme.dart';
import '../../../widgets/app_text.dart';
import '../models/inventory_item.dart';
import '../services/inventory_service.dart';
import '../widgets/inventory_filter_bar.dart';
import '../widgets/inventory_item_card.dart';
import '../widgets/inventory_stats_header.dart';
import '../widgets/quick_restock_sheet.dart';
import '../widgets/stock_deduction_sheet.dart';
import 'add_edit_inventory_screen.dart';
import 'inventory_detail_screen.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final InventoryService _inventoryService = InventoryService.instance;

  List<InventoryItem> _allItems = [];
  List<InventoryItem> _filteredItems = [];
  InventoryStats _stats = InventoryStats.empty;
  List<String> _categories = [];

  String _selectedStatus = 'all';
  String _selectedCategory = 'all';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInventory() async {
    setState(() => _isLoading = true);

    try {
      final items = await _inventoryService.getItems();
      final stats = await _inventoryService.calculateStats(items);

      final uniqueCategories = items
          .map((i) => i.category.trim())
          .where((cat) => cat.isNotEmpty)
          .toSet()
          .toList();

      if (mounted) {
        setState(() {
          _allItems = items;
          _stats = stats;
          _categories = uniqueCategories;
        });
        await _applyFilters();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load inventory: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _applyFilters() async {
    final filtered = await _inventoryService.filterItems(
      sourceItems: _allItems,
      query: _searchController.text,
      statusFilter: _selectedStatus,
      categoryFilter: _selectedCategory,
    );

    if (mounted) {
      setState(() {
        _filteredItems = filtered;
      });
    }
  }

  void _openRestockSheet(InventoryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: BusinessTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => QuickRestockSheet(
        item: item,
        onConfirm: (qty, newCost, note) async {
          await _inventoryService.restockItem(
            itemId: item.id,
            quantityToAdd: qty,
            newCostPrice: newCost,
            note: note,
          );
          await _loadInventory();
        },
      ),
    );
  }

  void _openDeductSheet(InventoryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: BusinessTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StockDeductionSheet(
        item: item,
        onConfirm: (qty, ref, note) async {
          await _inventoryService.deductStock(
            itemId: item.id,
            quantityToDeduct: qty,
            referenceId: ref,
            note: note,
          );
          await _loadInventory();
        },
      ),
    );
  }

  Future<void> _navigateToAddItem() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddEditInventoryScreen(),
      ),
    );

    if (result == true && mounted) {
      await _loadInventory();
    }
  }

  Future<void> _navigateToEditItem(InventoryItem item) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditInventoryScreen(itemToEdit: item),
      ),
    );

    if (result == true && mounted) {
      await _loadInventory();
    }
  }

  Future<void> _navigateToDetail(InventoryItem item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InventoryDetailScreen(item: item),
      ),
    );
    if (mounted) {
      await _loadInventory();
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: const AppText.subtitle(
          'Inventory & Stock',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: BusinessTheme.charcoal,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.arrowsRotate,
              color: BusinessTheme.charcoal,
              size: 16,
            ),
            tooltip: 'Refresh Inventory',
            onPressed: _loadInventory,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadInventory,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Stats Header
                          InventoryStatsHeader(stats: _stats),
                          const SizedBox(height: 16),

                          // Search & Filter Controls
                          InventoryFilterBar(
                            searchController: _searchController,
                            onSearchChanged: (_) => _applyFilters(),
                            selectedStatus: _selectedStatus,
                            onStatusChanged: (status) {
                              setState(() => _selectedStatus = status);
                              _applyFilters();
                            },
                            selectedCategory: _selectedCategory,
                            availableCategories: _categories,
                            onCategoryChanged: (cat) {
                              setState(() => _selectedCategory = cat);
                              _applyFilters();
                            },
                          ),
                          const SizedBox(height: 16),

                          // Results Count Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppText.paragraph(
                                'Showing ${_filteredItems.length} of ${_allItems.length} products',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: BusinessTheme.textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),

                  // Item Cards List
                  if (_filteredItems.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: BusinessTheme.primaryAmber.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const FaIcon(
                                  FontAwesomeIcons.boxesStacked,
                                  size: 40,
                                  color: BusinessTheme.primaryAmber,
                                ),
                              ),
                              const SizedBox(height: 16),
                              AppText.subtitle(
                                _allItems.isEmpty
                                    ? 'No inventory items yet'
                                    : 'No items match your filter',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: BusinessTheme.charcoal,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              AppText.paragraph(
                                _allItems.isEmpty
                                    ? 'Add your first product to track stock levels, calculate profits, and receive low stock alerts.'
                                    : 'Try searching for something else or clearing filters.',
                                style: const TextStyle(
                                  color: BusinessTheme.textMuted,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (_allItems.isEmpty) ...[
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: _navigateToAddItem,
                                  icon: const FaIcon(FontAwesomeIcons.plus, size: 14),
                                  label: const AppText.button('Add First Item'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: BusinessTheme.charcoal,
                                    foregroundColor: BusinessTheme.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = _filteredItems[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: InventoryItemCard(
                                item: item,
                                onTap: () => _navigateToDetail(item),
                                onRestock: () => _openRestockSheet(item),
                                onDeduct: () => _openDeductSheet(item),
                                onEdit: () => _navigateToEditItem(item),
                              ),
                            );
                          },
                          childCount: _filteredItems.length,
                        ),
                      ),
                    ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddItem,
        backgroundColor: BusinessTheme.charcoal,
        elevation: 3,
        icon: const FaIcon(
          FontAwesomeIcons.plus,
          color: BusinessTheme.white,
          size: 16,
        ),
        label: const AppText.button(
          'Add Item',
          style: TextStyle(
            color: BusinessTheme.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
