import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [url] in the phone's browser. Says so on screen when it cannot.
Future<void> openLink(BuildContext context, String url) async {
  var ok = false;
  try {
    ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (_) {}
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open the page. Try again later.')));
  }
}
