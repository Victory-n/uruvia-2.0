import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../theme/business/business_theme.dart';
import '../../../widgets/app_text.dart';

class InventoryImagePicker extends StatelessWidget {
  final String? imagePath;
  final ValueChanged<String?> onImageSelected;

  const InventoryImagePicker({
    super.key,
    required this.imagePath,
    required this.onImageSelected,
  });

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        onImageSelected(pickedFile.path);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  void _showSourceSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: BusinessTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, bottom: 12.0),
                  child: AppText.subtitle(
                    'Select Item Image',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: BusinessTheme.charcoal,
                    ),
                  ),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: BusinessTheme.primaryAmber.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.camera,
                      size: 16,
                      color: BusinessTheme.primaryAmber,
                    ),
                  ),
                  title: const AppText.paragraph(
                    'Take a Photo',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const AppText.paragraph(
                    'Use your camera to capture the product',
                    style: TextStyle(fontSize: 11, color: BusinessTheme.textMuted),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(context, ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: BusinessTheme.charcoal.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.image,
                      size: 16,
                      color: BusinessTheme.charcoal,
                    ),
                  ),
                  title: const AppText.paragraph(
                    'Upload from Gallery',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const AppText.paragraph(
                    'Choose an existing photo from your device',
                    style: TextStyle(fontSize: 11, color: BusinessTheme.textMuted),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(context, ImageSource.gallery);
                  },
                ),
                if (imagePath != null && imagePath!.isNotEmpty) ...[
                  const Divider(height: 16),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: BusinessTheme.danger.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const FaIcon(
                        FontAwesomeIcons.trashCan,
                        size: 16,
                        color: BusinessTheme.danger,
                      ),
                    ),
                    title: const AppText.paragraph(
                      'Remove Image',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: BusinessTheme.danger,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      onImageSelected(null);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImage =
        imagePath != null && imagePath!.isNotEmpty && File(imagePath!).existsSync();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText.paragraph(
          'Product Photo (Optional)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: BusinessTheme.charcoal,
          ),
        ),
        const SizedBox(height: 8),
        if (hasImage)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(imagePath!),
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showSourceSelectionSheet(context),
                      icon: const FaIcon(FontAwesomeIcons.arrowsRotate, size: 12),
                      label: const AppText.button('Change'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BusinessTheme.charcoal.withValues(alpha: 0.85),
                        foregroundColor: BusinessTheme.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => onImageSelected(null),
                      icon: const FaIcon(
                        FontAwesomeIcons.trashCan,
                        size: 14,
                        color: BusinessTheme.white,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: BusinessTheme.danger.withValues(alpha: 0.85),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        else
          GestureDetector(
            onTap: () => _showSourceSelectionSheet(context),
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: BusinessTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: BusinessTheme.primaryAmber.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.camera,
                      size: 20,
                      color: BusinessTheme.primaryAmber,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const AppText.paragraph(
                    'Tap to add product photo',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: BusinessTheme.charcoal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const AppText.paragraph(
                    'Camera or Gallery',
                    style: TextStyle(fontSize: 11, color: BusinessTheme.textMuted),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
