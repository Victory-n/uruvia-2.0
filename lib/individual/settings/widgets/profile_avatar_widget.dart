import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import '../../../shared/widgets/custom_text.dart';

class ProfileAvatarWidget extends StatelessWidget {
  final String? profileImageUrl;
  final String initials;
  final VoidCallback onCameraTap;

  const ProfileAvatarWidget({
    super.key,
    this.profileImageUrl,
    required this.initials,
    required this.onCameraTap,
  });

  ImageProvider? _getImageProvider(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    return FileImage(File(path));
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _getImageProvider(profileImageUrl);

    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [ConstantColor.blueBackground, Color(0xFF003C8F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: ConstantColor.blueBackground.withOpacity(0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 46,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 44,
                backgroundColor: ConstantColor.blueBackground.withOpacity(0.08),
                backgroundImage: imageProvider,
                child: imageProvider == null
                    ? googleSansText(
                        text: initials.isNotEmpty ? initials[0].toUpperCase() : 'U',
                        colors: ConstantColor.blueBackground,
                        fontWeight: FontWeight.bold,
                        size: 32.0,
                      )
                    : null,
              ),
            ),
          ),
          InkWell(
            onTap: onCameraTap,
            borderRadius: BorderRadius.circular(20.0),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: ConstantColor.blueBackground,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
