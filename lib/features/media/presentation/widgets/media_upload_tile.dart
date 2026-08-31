import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shatbha/core/core.dart';

import '../../data/models/media_models.dart';
import '../../data/repositories/media_repository.dart';

class MediaUploadTile extends StatelessWidget {
  const MediaUploadTile({
    super.key,
    required this.projectId,
    required this.onUploaded,
    this.uploading = false,
  });

  final int projectId;
  final ValueChanged<MediaFile> onUploaded;
  final bool uploading;

  Future<void> _pick(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null || !context.mounted) return;
    try {
      final media = await sl<MediaRepository>().upload(
        picked.path,
        filename: picked.name,
        projectId: projectId,
      );
      if (!context.mounted) return;
      onUploaded(media);
      await showAtelierSuccess(context, body: 'تم رفع الصورة بنجاح');
    } on Failure catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Material(
      color: c.ivory,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: uploading ? null : () => _pick(context),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.brass.withValues(alpha: 0.5), width: 1.2),
          ),
          child: SizedBox(
            height: 120,
            child: Center(
              child: uploading
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, color: c.brass, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          'رفع صورة',
                          style: TextStyle(
                            color: c.stone,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
