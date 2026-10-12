import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/theme/app_palette.dart';
import '../../app/theme/tokens.dart';
import '../errors/friendly_error.dart';
import '../widgets/app_sheet.dart';
import 'photo_service.dart';

/// Shows a stored photo, or [placeholder] while it loads, if it is missing, or when [path] is null.
class StoredImage extends ConsumerWidget {
  const StoredImage({super.key, required this.bucket, required this.path, required this.size, this.circle = false, this.placeholder});
  final String bucket;
  final String? path;
  final double size;
  final bool circle;
  final IconData? placeholder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = Theme.of(context).extension<AppPalette>()!;
    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: palette.tint,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(AppRadius.control),
      ),
      child: Icon(placeholder ?? Icons.image_outlined, color: palette.action, size: size * 0.45),
    );
    final p = path;
    if (p == null || p.isEmpty) return fallback;
    final url = ref.watch(signedUrlProvider(StoredFile(bucket, p))).valueOrNull;
    if (url == null) return fallback;
    final image = Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
      semanticLabel: 'Photo',
    );
    return circle ? ClipOval(child: image) : ClipRRect(borderRadius: BorderRadius.circular(AppRadius.control), child: image);
  }
}

/// A photo with Add, Change and Remove. Uploads as soon as a photo is chosen and reports the stored path.
/// Before the camera or gallery opens, a plain sentence says why the photo is needed.
class PhotoField extends ConsumerStatefulWidget {
  const PhotoField({
    super.key,
    required this.label,
    required this.bucket,
    required this.folder,
    required this.path,
    required this.onChanged,
    this.reason = 'The photo is stored privately and only you and your team can see it.',
    this.size = 88,
    this.circle = false,
    this.placeholder,
  });

  final String label;
  final String bucket;

  /// Folder inside the bucket, starting with the account or user id, e.g. "<account>/products".
  final String folder;
  final String? path;
  final ValueChanged<String?> onChanged;
  final String reason;
  final double size;
  final bool circle;
  final IconData? placeholder;

  @override
  ConsumerState<PhotoField> createState() => _PhotoFieldState();
}

class _PhotoFieldState extends ConsumerState<PhotoField> {
  bool _busy = false;

  Future<void> _choose() async {
    final source = await showAppSheet<ImageSource>(
      context,
      title: widget.label,
      builder: (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.reason, style: Theme.of(ctx).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Take a photo'),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from gallery'),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
          if (widget.path != null)
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded),
              title: const Text('Remove photo'),
              onTap: () {
                Navigator.pop(ctx);
                widget.onChanged(null);
              },
            ),
        ],
      ),
    );
    if (source == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final service = ref.read(photoServiceProvider);
      final picked = await service.pick(source);
      if (picked == null) return;
      final stored = await service.upload(
        bucket: widget.bucket,
        folder: widget.folder,
        bytes: picked.bytes,
        contentType: picked.contentType,
        ext: picked.ext,
      );
      if (mounted) widget.onChanged(stored);
    } on PlatformException catch (e) {
      if (!mounted) return;
      final denied = e.code.contains('denied');
      _tell(denied
          ? 'Uruvia does not have permission. Turn on ${source == ImageSource.camera ? 'camera' : 'photo'} access for Uruvia in your phone settings, or choose another option.'
          : 'Could not open the picker. Try again.');
    } catch (e) {
      if (mounted) _tell(friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _tell(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final has = widget.path != null && widget.path!.isNotEmpty;
    return Semantics(
      button: true,
      label: has ? 'Change ${widget.label}' : 'Add ${widget.label}',
      child: InkWell(
        onTap: _busy ? null : _choose,
        borderRadius: BorderRadius.circular(AppRadius.control),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  StoredImage(bucket: widget.bucket, path: widget.path, size: widget.size, circle: widget.circle, placeholder: widget.placeholder),
                  if (_busy) const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5)),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.label, style: theme.textTheme.bodyLarge),
                    Text(has ? 'Tap to change or remove' : 'Tap to add a photo',
                        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.inkSoft)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
