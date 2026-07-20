import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/screens/customer directory/add_customer_sheet.dart';
import 'package:uruvia/screens/customer directory/customer_model.dart';
import 'package:uruvia/screens/customer directory/customer_repository.dart';
import 'package:uruvia/services/subscription_service.dart';
import 'package:uruvia/widgets/custom_text.dart';
import 'package:uruvia/widgets/paywall_dialog.dart';
import 'package:uruvia/classes/custom_snackbar.dart';

class CustomerDirectoryPage extends StatefulWidget {
  const CustomerDirectoryPage({super.key});

  @override
  State<CustomerDirectoryPage> createState() => _CustomerDirectoryPageState();
}

class _CustomerDirectoryPageState extends State<CustomerDirectoryPage> {
  List<Customer> _allCustomers = [];
  List<Customer> _filteredCustomers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);
    final customers = await CustomerRepository.instance.getCustomers();
    setState(() {
      _allCustomers = customers;
      _filterCustomers(_searchController.text);
      _isLoading = false;
    });
  }

  void _filterCustomers(String query) {
    if (query.trim().isEmpty) {
      _filteredCustomers = List.from(_allCustomers);
    } else {
      final q = query.toLowerCase();
      _filteredCustomers = _allCustomers.where((c) {
        return c.name.toLowerCase().contains(q) ||
            c.company.toLowerCase().contains(q) ||
            c.phone.contains(q) ||
            c.email.toLowerCase().contains(q);
      }).toList();
    }
  }

  Future<void> _launchWhatsApp(String phone, String name) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final String urlString = cleanPhone.isNotEmpty
        ? "https://wa.me/$cleanPhone?text=${Uri.encodeComponent('Hello $name, messaging you from Uruvia.')}"
        : "https://wa.me/";
    final Uri url = Uri.parse(urlString);

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar("Could not launch WhatsApp");
      }
    } catch (e) {
      _showSnackBar("Could not launch WhatsApp");
    }
  }

  Future<void> _launchCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri url = Uri.parse("tel:$cleanPhone");
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        _showSnackBar("Could not launch dialer");
      }
    } catch (e) {
      _showSnackBar("Could not launch dialer");
    }
  }

  void _showSnackBar(String msg) {
    CustomSnackbar.showNormal(context, msg);
  }

  void _showAddEditSheet([Customer? customer]) async {
    if (customer == null) {
      final canAdd = await SubscriptionService.instance.canAddCustomerContact();
      if (!canAdd && mounted) {
        PaywallDialog.show(
          context,
          title: "Customer Limit Reached",
          description: "Your Free plan allows up to 10 contacts. Upgrade to Uruvia Premium for unlimited customer contacts.",
        );
        return;
      }
    }

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (context) => AddCustomerSheet(customer: customer),
    );

    if (result == true) {
      _loadCustomers();
    }
  }

  Future<void> _deleteCustomer(Customer customer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: googleSansText(
          text: "Delete Contact?",
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 18.0,
        ),
        content: googleSansText(
          text: "Are you sure you want to remove ${customer.name} from your customer directory?",
          colors: ConstantColor.paragraphTextPrimary,
          fontWeight: FontWeight.normal,
          size: 14.0,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: googleSansText(
              text: "Cancel",
              colors: ConstantColor.paragraphTextSecondary,
              fontWeight: FontWeight.bold,
              size: 14.0,
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: googleSansText(
              text: "Delete",
              colors: Colors.white,
              fontWeight: FontWeight.bold,
              size: 14.0,
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await CustomerRepository.instance.deleteCustomer(customer.id);
      _loadCustomers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        leading: Navigator.canPop(context)
            ? null
            : IconButton(
                icon: const Icon(
                  CupertinoIcons.bars,
                  color: ConstantColor.headingTextPrimary,
                ),
                onPressed: () => Scaffold.maybeOf(context)?.openDrawer(),
              ),
        title: googleSansText(
          text: "Customer Directory",
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 20.0,
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditSheet(),
        backgroundColor: ConstantColor.blueBackground,
        icon: const Icon(CupertinoIcons.person_add_solid, color: Colors.white, size: 20.0),
        label: googleSansText(
          text: "Add Customer",
          colors: Colors.white,
          fontWeight: FontWeight.bold,
          size: 14.0,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _filterCustomers(val);
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: "Search customers by name, company, or phone...",
                    hintStyle: TextStyle(
                      fontFamily: "googleSans",
                      color: Color(0xFF94A3B8),
                      fontSize: 13.5,
                    ),
                    prefixIcon: Icon(CupertinoIcons.search, size: 18.0, color: Color(0xFF64748B)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                  ),
                ),
              ),
            ),
            _buildQuotaBanner(),

            // Content List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredCustomers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                CupertinoIcons.person_2_square_stack,
                                size: 56.0,
                                color: Color(0xFFCBD5E1),
                              ),
                              const SizedBox(height: 12.0),
                              googleSansText(
                                text: "No customers found",
                                colors: ConstantColor.paragraphTextSecondary,
                                fontWeight: FontWeight.bold,
                                size: 16.0,
                              ),
                              const SizedBox(height: 4.0),
                              googleSansText(
                                text: "Tap '+ Add Customer' to save a contact.",
                                colors: ConstantColor.paragraphTextSecondary.withOpacity(0.7),
                                fontWeight: FontWeight.normal,
                                size: 13.0,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _filteredCustomers.length,
                          itemBuilder: (context, index) {
                            final customer = _filteredCustomers[index];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(color: const Color(0xFFEEEEEE)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.015),
                                    blurRadius: 10.0,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                leading: CircleAvatar(
                                  radius: 22.0,
                                  backgroundColor: ConstantColor.blueBackground.withOpacity(0.1),
                                  child: googleSansText(
                                    text: customer.initials,
                                    colors: ConstantColor.blueBackground,
                                    fontWeight: FontWeight.bold,
                                    size: 15.0,
                                  ),
                                ),
                                title: googleSansText(
                                  text: customer.name,
                                  colors: ConstantColor.headingTextPrimary,
                                  fontWeight: FontWeight.bold,
                                  size: 15.0,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (customer.company.isNotEmpty) ...[
                                      const SizedBox(height: 2.0),
                                      googleSansText(
                                        text: customer.company,
                                        colors: ConstantColor.paragraphTextSecondary,
                                        fontWeight: FontWeight.w500,
                                        size: 12.5,
                                      ),
                                    ],
                                    const SizedBox(height: 4.0),
                                    Row(
                                      children: [
                                        const Icon(
                                          CupertinoIcons.phone_fill,
                                          size: 11.0,
                                          color: ConstantColor.paragraphTextSecondary,
                                        ),
                                        const SizedBox(width: 4.0),
                                        googleSansText(
                                          text: customer.phone,
                                          colors: ConstantColor.paragraphTextSecondary,
                                          fontWeight: FontWeight.normal,
                                          size: 12.0,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // WhatsApp Quick Action
                                    IconButton(
                                      onPressed: () => _launchWhatsApp(customer.phone, customer.name),
                                      icon: const Icon(
                                        CupertinoIcons.chat_bubble_2_fill,
                                        color: Color(0xFF25D366),
                                        size: 20.0,
                                      ),
                                      tooltip: "WhatsApp Chat",
                                    ),
                                    // Call Action
                                    IconButton(
                                      onPressed: () => _launchCall(customer.phone),
                                      icon: const Icon(
                                        CupertinoIcons.phone_fill,
                                        color: ConstantColor.blueBackground,
                                        size: 18.0,
                                      ),
                                      tooltip: "Call Customer",
                                    ),
                                    // More options
                                    PopupMenuButton<String>(
                                      onSelected: (val) {
                                        if (val == 'edit') {
                                          _showAddEditSheet(customer);
                                        } else if (val == 'delete') {
                                          _deleteCustomer(customer);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Text("Edit Contact"),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Text("Delete Contact", style: TextStyle(color: Colors.redAccent)),
                                        ),
                                      ],
                                      icon: const Icon(
                                        CupertinoIcons.ellipsis_vertical,
                                        color: ConstantColor.paragraphTextSecondary,
                                        size: 18.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuotaBanner() {
    final capabilities = SubscriptionService.instance.currentCapabilities;
    final count = _allCustomers.length;
    final isFree = capabilities.isFree;
    final max = capabilities.maxCustomerContacts;

    return Container(
      margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: isFree && count >= 8 ? const Color(0xFFFFF7ED) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: isFree && count >= 8 ? Colors.orange.shade300 : const Color(0xFFBFDBFE),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isFree ? CupertinoIcons.person_3_fill : CupertinoIcons.sparkles,
                size: 16.0,
                color: isFree && count >= 8 ? Colors.orange.shade800 : ConstantColor.blueBackground,
              ),
              const SizedBox(width: 8.0),
              googleSansText(
                text: isFree ? "Free Plan: $count / $max Contacts Used" : "Pro Plan: Unlimited Contacts",
                colors: isFree && count >= 8 ? Colors.orange.shade900 : ConstantColor.headingTextPrimary,
                fontWeight: FontWeight.bold,
                size: 12.5,
              ),
            ],
          ),
          if (isFree)
            GestureDetector(
              onTap: () async {
                await PaywallDialog.show(context);
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: ConstantColor.blueBackground,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: googleSansText(
                  text: "Upgrade",
                  colors: Colors.white,
                  fontWeight: FontWeight.bold,
                  size: 11.0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
