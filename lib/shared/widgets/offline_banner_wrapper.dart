import 'package:flutter/material.dart';
import '../../shared/widgets/app_text.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class OfflineBannerWrapper extends StatelessWidget {
  final Widget child;

  const OfflineBannerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          child,
          StreamBuilder<InternetConnectionStatus>(
            stream: InternetConnectionChecker.createInstance().onStatusChange,
            builder: (context, snapshot) {
              final isOffline = snapshot.data == InternetConnectionStatus.disconnected;
              if (!isOffline) {
                return const SizedBox.shrink();
              }
              return Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Material(
                  color: Colors.redAccent,
                  child: SafeArea(
                    top: false,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      alignment: Alignment.center,
                      child: const AppText(
                        'No Internet Connection',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
