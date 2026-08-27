import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/shared/widgets/custom_text.dart';

/// Slide 3 Visual Graphic: Offline-First Power & Auto-Sync.
class OfflineSyncGraphic extends StatelessWidget {
  const OfflineSyncGraphic({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        color: ConstantColor.blueBackground.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulse ring
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: ConstantColor.blueBackground.withOpacity(0.15),
                width: 1.5,
              ),
            ),
          ),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: ConstantColor.blueBackground.withOpacity(0.3),
                width: 1.5,
              ),
            ),
          ),

          // Central SQLite & Cloud Connection Nodes
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Local SQLite Node
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1C30),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.storage_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    interText(
                      text: 'Local DB',
                      colors: Colors.white70,
                      fontWeight: FontWeight.bold,
                      size: 10.0,
                    ),
                  ],
                ),
              ),

              // Syncing Bridge Icon
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ConstantColor.blueBackground,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ConstantColor.blueBackground.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.sync_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),

              // Cloud Server Node
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0058BE), Color(0xFF003C8F)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ConstantColor.blueBackground.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.cloud_done_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    interText(
                      text: 'Cloud Sync',
                      colors: Colors.white,
                      fontWeight: FontWeight.bold,
                      size: 10.0,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Floating Offline Guaranteed Badge
          Positioned(
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  googleSansText(
                    text: '100% Offline Capability • Zero Data Loss',
                    colors: ConstantColor.headingTextPrimary,
                    fontWeight: FontWeight.w600,
                    size: 11.0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
