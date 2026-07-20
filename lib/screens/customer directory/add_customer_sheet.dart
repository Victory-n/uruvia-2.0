import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/screens/customer directory/customer_model.dart';
import 'package:uruvia/screens/customer directory/customer_repository.dart';
import 'package:uruvia/widgets/custom_text.dart';

class AddCustomerSheet extends StatefulWidget {
  final Customer? customer;

  const AddCustomerSheet({super.key, this.customer});

  @override
  State<AddCustomerSheet> createState() => _AddCustomerSheetState();
}

class _AddCustomerSheetState extends State<AddCustomerSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _companyController;
  late TextEditingController _addressController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name ?? '');
    _phoneController = TextEditingController(
      text: widget.customer?.phone ?? '',
    );
    _emailController = TextEditingController(
      text: widget.customer?.email ?? '',
    );
    _companyController = TextEditingController(
      text: widget.customer?.company ?? '',
    );
    _addressController = TextEditingController(
      text: widget.customer?.address ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final isEditing = widget.customer != null;
    final customer = Customer(
      id:
          widget.customer?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      company: _companyController.text.trim(),
      address: _addressController.text.trim(),
      createdAt: widget.customer?.createdAt ?? DateTime.now(),
    );

    if (isEditing) {
      await CustomerRepository.instance.updateCustomer(customer);
    } else {
      await CustomerRepository.instance.addCustomer(customer);
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.customer != null;

    return Padding(
      padding: EdgeInsets.only(
        top: 20.0,
        left: 20.0,
        right: 20.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              googleSansText(
                text: isEditing ? "Edit Customer" : "Add New Customer",
                colors: ConstantColor.headingTextPrimary,
                fontWeight: FontWeight.bold,
                size: 20.0,
              ),
              const SizedBox(height: 20.0),

              // Name
              _buildTextField(
                controller: _nameController,
                label: "Full Name",
                hint: "e.g. John Doe",
                icon: CupertinoIcons.person_fill,
                validator: (val) => val == null || val.trim().isEmpty
                    ? "Customer name is required"
                    : null,
              ),
              const SizedBox(height: 14.0),

              // Phone / WhatsApp
              _buildTextField(
                controller: _phoneController,
                label: "Phone / WhatsApp Number",
                hint: "e.g. +234 812 345 6789",
                icon: CupertinoIcons.phone_fill,
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.trim().isEmpty
                    ? "Phone number is required"
                    : null,
              ),
              const SizedBox(height: 14.0),

              // Email
              _buildTextField(
                controller: _emailController,
                label: "Email Address (Optional)",
                hint: "e.g. john@example.com",
                icon: CupertinoIcons.mail_solid,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14.0),

              // Company
              _buildTextField(
                controller: _companyController,
                label: "Company / Business Name (Optional)",
                hint: "e.g. Apex Ltd",
                icon: CupertinoIcons.building_2_fill,
              ),
              const SizedBox(height: 14.0),

              // Address
              _buildTextField(
                controller: _addressController,
                label: "Address (Optional)",
                hint: "e.g. Victoria Island, Lagos",
                icon: CupertinoIcons.location_fill,
              ),
              const SizedBox(height: 24.0),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50.0,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveCustomer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ConstantColor.blueBackground,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 0.0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20.0,
                          width: 20.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : googleSansText(
                          text: isEditing ? "Update Customer" : "Save Customer",
                          colors: Colors.white,
                          fontWeight: FontWeight.bold,
                          size: 16.0,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    FormFieldValidator<String>? validator,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: const Color(0xFFE8E9EB)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(
          fontFamily: "googleSans",
          fontSize: 14.5,
          color: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontFamily: "googleSans",
            color: ConstantColor.paragraphTextSecondary,
            fontSize: 13.0,
          ),
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: "googleSans",
            color: Color(0xFFBBBBBB),
            fontSize: 13.5,
          ),
          prefixIcon: Icon(
            icon,
            color: ConstantColor.paragraphTextSecondary,
            size: 18.0,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 6.0),
        ),
      ),
    );
  }
}
