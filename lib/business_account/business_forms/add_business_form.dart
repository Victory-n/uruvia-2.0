import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../shared/widgets/app_text.dart';
import 'package:uruvia/theme/business/business_theme.dart';
import '../screens/business_dashboard_screen.dart';

class AddBusinessForm extends StatefulWidget {
  const AddBusinessForm({super.key});

  @override
  State<AddBusinessForm> createState() => _AddBusinessFormState();
}

class _AddBusinessFormState extends State<AddBusinessForm> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Section 1 Controllers
  final _nameController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  // Section 2 Uploads
  XFile? _certificateFile;
  XFile? _logoFile;

  Future<void> _pickImage(bool isLogo) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isLogo) {
          _logoFile = image;
        } else {
          _certificateFile = image;
        }
      });
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: AppText.subtitle(title),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isOptional = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label + (isOptional ? ' (Optional)' : ''),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: BusinessTheme.primaryAmber,
              width: 2,
            ),
          ),
        ),
        validator: isOptional
            ? null
            : (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter $label';
                }
                return null;
              },
      ),
    );
  }

  Widget _buildUploadField({
    required String label,
    required XFile? file,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: BusinessTheme.backgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            Icon(
              file == null ? Icons.upload_file : Icons.check_circle,
              color: file == null
                  ? BusinessTheme.textMuted
                  : BusinessTheme.primaryAmber,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.custom(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (file != null)
                    AppText.custom(
                      file.name,
                      style: const TextStyle(
                        color: BusinessTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taxIdController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Business Added Successfully!')),
      );
      // Navigate to business dashboard
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const BusinessDashboardScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BusinessTheme.backgroundLight,
      appBar: AppBar(
        title: const AppText.subtitle('Add Business'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: BusinessTheme.textDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Section 1: Business Details'),
              _buildTextField(
                controller: _nameController,
                label: 'Business Name',
              ),
              _buildTextField(
                controller: _taxIdController,
                label: 'TAX ID',
                isOptional: true,
              ),
              _buildTextField(
                controller: _addressController,
                label: 'Business Address',
              ),
              _buildTextField(
                controller: _phoneController,
                label: 'Business Phone Number',
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                controller: _emailController,
                label: 'Business Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildSectionHeader('Section 2: Uploads (Optional)'),
              _buildUploadField(
                label: 'Certificate of Registration',
                file: _certificateFile,
                onTap: () => _pickImage(false),
              ),
              _buildUploadField(
                label: 'Business Logo',
                file: _logoFile,
                onTap: () => _pickImage(true),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const AppText.button('Complete Setup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
