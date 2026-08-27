import 'dart:io';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/models/user_model.dart';
import 'package:uruvia/services/auth_service.dart';
import 'package:uruvia/shared/widgets/custom_text.dart';
import 'widgets/profile_avatar_widget.dart';
import 'widgets/profile_input_field.dart';

/// Data payload for isolate validation.
class ProfileValidationData {
  final String firstname;
  final String lastname;
  final String phoneNumber;
  final String region;
  final String currency;

  const ProfileValidationData({
    required this.firstname,
    required this.lastname,
    required this.phoneNumber,
    required this.region,
    required this.currency,
  });
}

/// Validation result produced by background Isolate.
class ProfileValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String sanitizedFirstname;
  final String sanitizedLastname;
  final String sanitizedPhone;

  const ProfileValidationResult({
    required this.isValid,
    this.errorMessage,
    required this.sanitizedFirstname,
    required this.sanitizedLastname,
    required this.sanitizedPhone,
  });
}

/// Offloaded background Isolate function to ensure 60/120 FPS UI performance (Rule 1).
ProfileValidationResult _validateProfileIsolate(ProfileValidationData data) {
  final cleanFirst = data.firstname.trim();
  final cleanLast = data.lastname.trim();
  final cleanPhone = data.phoneNumber.trim().replaceAll(RegExp(r'[\s\-]+'), '');

  if (cleanFirst.isEmpty) {
    return ProfileValidationResult(
      isValid: false,
      errorMessage: 'First name cannot be empty.',
      sanitizedFirstname: cleanFirst,
      sanitizedLastname: cleanLast,
      sanitizedPhone: cleanPhone,
    );
  }

  if (cleanLast.isEmpty) {
    return ProfileValidationResult(
      isValid: false,
      errorMessage: 'Last name cannot be empty.',
      sanitizedFirstname: cleanFirst,
      sanitizedLastname: cleanLast,
      sanitizedPhone: cleanPhone,
    );
  }

  if (cleanPhone.isNotEmpty && cleanPhone.length < 7) {
    return ProfileValidationResult(
      isValid: false,
      errorMessage: 'Please enter a valid phone number.',
      sanitizedFirstname: cleanFirst,
      sanitizedLastname: cleanLast,
      sanitizedPhone: cleanPhone,
    );
  }

  return ProfileValidationResult(
    isValid: true,
    sanitizedFirstname: cleanFirst,
    sanitizedLastname: cleanLast,
    sanitizedPhone: cleanPhone,
  );
}

/// Dedicated Profile Information Screen (Rule 5 - strictly Scaffold).
class ProfileInformationScreen extends StatefulWidget {
  const ProfileInformationScreen({super.key});

  @override
  State<ProfileInformationScreen> createState() => _ProfileInformationScreenState();
}

class _ProfileInformationScreenState extends State<ProfileInformationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _selectedRegion = "Africa";
  String _selectedCurrency = "NGN";
  String? _profileImageUrl;
  File? _pickedImageFile;
  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _regions = const [
    "Africa",
    "North America",
    "Europe",
    "Asia Pacific",
    "Latin America",
    "Middle East",
  ];

  final List<String> _currencies = const [
    "NGN",
    "USD",
    "GBP",
    "EUR",
    "CAD",
    "GHS",
    "KES",
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    try {
      final userId = AuthService.instance.currentUserId;
      UserModel? profile;

      if (userId != null) {
        profile = await AuthService.instance.getUserProfile(userId);
      }

      final currentUser = Supabase.instance.client.auth.currentUser;
      final meta = currentUser?.userMetadata;

      if (mounted) {
        setState(() {
          _firstNameController.text = profile?.firstname ?? meta?['firstname'] ?? meta?['first_name'] ?? "";
          _lastNameController.text = profile?.lastname ?? meta?['lastname'] ?? meta?['last_name'] ?? "";
          _emailController.text = profile?.email ?? currentUser?.email ?? "";
          _phoneController.text = profile?.phoneNumber ?? meta?['phone_number'] ?? "";
          _selectedRegion = profile?.region ?? meta?['region'] ?? "Africa";
          _selectedCurrency = profile?.currency ?? meta?['currency'] ?? "NGN";
          _profileImageUrl = profile?.profileImage;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _pickedImageFile = File(image.path);
          _profileImageUrl = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to select image: ${e.toString()}"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showImageSourceModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
              const SizedBox(height: 16.0),
              googleSansText(
                text: "Choose Profile Photo",
                colors: ConstantColor.headingTextPrimary,
                fontWeight: FontWeight.bold,
                size: 16.0,
              ),
              const SizedBox(height: 16.0),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: ConstantColor.blueBackground.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: ConstantColor.blueBackground,
                  ),
                ),
                title: googleSansText(
                  text: "Choose from Gallery",
                  colors: ConstantColor.headingTextPrimary,
                  fontWeight: FontWeight.w600,
                  size: 14.5,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: ConstantColor.blueBackground.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: ConstantColor.blueBackground,
                  ),
                ),
                title: googleSansText(
                  text: "Take Photo with Camera",
                  colors: ConstantColor.headingTextPrimary,
                  fontWeight: FontWeight.w600,
                  size: 14.5,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;

    FocusScope.of(context).unfocus();

    final validationData = ProfileValidationData(
      firstname: _firstNameController.text,
      lastname: _lastNameController.text,
      phoneNumber: _phoneController.text,
      region: _selectedRegion,
      currency: _selectedCurrency,
    );

    // Offload validation to background Isolate (Rule 1)
    final validationResult = await Isolate.run(
      () => _validateProfileIsolate(validationData),
    );

    if (!validationResult.isValid) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationResult.errorMessage ?? "Validation failed"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? finalAvatarUrl = _profileImageUrl;

      // Upload avatar image to Supabase Storage if user selected a new file
      if (_pickedImageFile != null) {
        finalAvatarUrl = await AuthService.instance.uploadProfileAvatar(_pickedImageFile!);
      }

      await AuthService.instance.updateUserProfile(
        firstname: validationResult.sanitizedFirstname,
        lastname: validationResult.sanitizedLastname,
        phoneNumber: validationResult.sanitizedPhone,
        profileImage: finalAvatarUrl,
        region: _selectedRegion,
        currency: _selectedCurrency,
      );

      if (!mounted) return;

      setState(() {
        _profileImageUrl = finalAvatarUrl;
        _pickedImageFile = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully!"),
          backgroundColor: ConstantColor.blueBackground,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update profile: ${e.toString()}"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initials = "${_firstNameController.text} ${_lastNameController.text}".trim();

    return Scaffold(
      backgroundColor: ConstantColor.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: ConstantColor.headingTextPrimary,
            size: 20.0,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: googleSansText(
          text: "Profile Information",
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 18.0,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: ConstantColor.blueBackground,
                      ),
                    )
                  : googleSansText(
                      text: "Save",
                      colors: ConstantColor.blueBackground,
                      fontWeight: FontWeight.bold,
                      size: 15.0,
                    ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: ConstantColor.blueBackground,
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar Header Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          ProfileAvatarWidget(
                            profileImageUrl: _profileImageUrl,
                            initials: initials,
                            onCameraTap: _showImageSourceModal,
                          ),
                          const SizedBox(height: 12.0),
                          googleSansText(
                            text: initials.isNotEmpty ? initials : "Uruvia User",
                            colors: ConstantColor.headingTextPrimary,
                            fontWeight: FontWeight.bold,
                            size: 18.0,
                          ),
                          const SizedBox(height: 4.0),
                          googleSansText(
                            text: _emailController.text.isNotEmpty
                                ? _emailController.text
                                : "user@uruvia.app",
                            colors: ConstantColor.paragraphTextSecondary,
                            fontWeight: FontWeight.w400,
                            size: 13.0,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Personal Details Section
                    googleSansText(
                      text: "Personal Details",
                      colors: ConstantColor.paragraphTextSecondary,
                      fontWeight: FontWeight.bold,
                      size: 13.0,
                    ),
                    const SizedBox(height: 10.0),
                    Container(
                      padding: const EdgeInsets.all(18.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          ProfileInputField(
                            label: "First Name",
                            controller: _firstNameController,
                            prefixIcon: Icons.person_outline_rounded,
                            hintText: "Enter your first name",
                          ),
                          const SizedBox(height: 16.0),
                          ProfileInputField(
                            label: "Last Name",
                            controller: _lastNameController,
                            prefixIcon: Icons.person_outline_rounded,
                            hintText: "Enter your last name",
                          ),
                          const SizedBox(height: 16.0),
                          ProfileInputField(
                            label: "Email Address",
                            controller: _emailController,
                            prefixIcon: Icons.email_outlined,
                            isReadOnly: true,
                            helperText: "Primary security email (read-only)",
                          ),
                          const SizedBox(height: 16.0),
                          ProfileInputField(
                            label: "Phone Number",
                            controller: _phoneController,
                            prefixIcon: Icons.phone_outlined,
                            hintText: "+234 800 000 0000",
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Regional & Account Preferences
                    googleSansText(
                      text: "Regional & Account Preferences",
                      colors: ConstantColor.paragraphTextSecondary,
                      fontWeight: FontWeight.bold,
                      size: 13.0,
                    ),
                    const SizedBox(height: 10.0),
                    Container(
                      padding: const EdgeInsets.all(18.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          googleSansText(
                            text: "Operating Region",
                            colors: ConstantColor.headingTextPrimary,
                            fontWeight: FontWeight.w600,
                            size: 13.0,
                          ),
                          const SizedBox(height: 6.0),
                          DropdownButtonFormField<String>(
                            value: _regions.contains(_selectedRegion) ? _selectedRegion : _regions.first,
                            style: const TextStyle(
                              fontFamily: "googleSans",
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              color: ConstantColor.headingTextPrimary,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: const Icon(
                                Icons.public_rounded,
                                color: ConstantColor.blueBackground,
                                size: 20.0,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 14.0,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.2),
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: const BorderSide(
                                  color: ConstantColor.blueBackground,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            items: _regions.map((region) {
                              return DropdownMenuItem<String>(
                                value: region,
                                child: Text(region),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedRegion = val);
                              }
                            },
                          ),
                          const SizedBox(height: 16.0),
                          googleSansText(
                            text: "Default Currency",
                            colors: ConstantColor.headingTextPrimary,
                            fontWeight: FontWeight.w600,
                            size: 13.0,
                          ),
                          const SizedBox(height: 6.0),
                          DropdownButtonFormField<String>(
                            value: _currencies.contains(_selectedCurrency) ? _selectedCurrency : _currencies.first,
                            style: const TextStyle(
                              fontFamily: "googleSans",
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              color: ConstantColor.headingTextPrimary,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: const Icon(
                                Icons.payments_outlined,
                                color: ConstantColor.blueBackground,
                                size: 20.0,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 14.0,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.2),
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: const BorderSide(
                                  color: ConstantColor.blueBackground,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            items: _currencies.map((currency) {
                              return DropdownMenuItem<String>(
                                value: currency,
                                child: Text(currency),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedCurrency = val);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28.0),

                    // Save Changes Primary Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ConstantColor.blueBackground,
                          elevation: 2,
                          shadowColor: ConstantColor.blueBackground.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : googleSansText(
                                text: "Save Changes",
                                colors: Colors.white,
                                fontWeight: FontWeight.bold,
                                size: 15.5,
                              ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                  ],
                ),
              ),
            ),
    );
  }
}
