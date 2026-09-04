import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shatbha/core/core.dart';

class LocalMediaPick {
  const LocalMediaPick({
    required this.path,
    required this.name,
    this.isPdf = false,
  });

  final String path;
  final String name;
  final bool isPdf;
}

/// Tap opens a bottom sheet (صور / PDF). Files stay local until the parent uploads.
class MediaPickField extends StatelessWidget {
  const MediaPickField({
    super.key,
    required this.files,
    required this.onChanged,
    this.enabled = true,
    this.emptyLabel = 'إضافة صور أو PDF',
    this.hint = 'يمكن اختيار عدة صور، أو ملف PDF واحد.',
  });

  final List<LocalMediaPick> files;
  final ValueChanged<List<LocalMediaPick>> onChanged;
  final bool enabled;
  final String emptyLabel;
  final String hint;

  Future<void> _openSheet(BuildContext context) async {
    final choice = await showAtelierBottomSheet<_PickKind>(
      context: context,
      builder: (ctx) {
        final c = ctx.atelier;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'اختر نوع المرفق',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: c.stone,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: Icon(Icons.photo_library_outlined, color: c.brass),
                  title: Text('صور', style: TextStyle(color: c.stone)),
                  subtitle: Text(
                    'اختيار عدة صور',
                    style: TextStyle(color: c.stone.withValues(alpha: 0.6)),
                  ),
                  onTap: () => Navigator.pop(ctx, _PickKind.images),
                ),
                ListTile(
                  leading:
                      Icon(Icons.picture_as_pdf_outlined, color: c.terracotta),
                  title: Text('PDF', style: TextStyle(color: c.stone)),
                  subtitle: Text(
                    'ملف واحد',
                    style: TextStyle(color: c.stone.withValues(alpha: 0.6)),
                  ),
                  onTap: () => Navigator.pop(ctx, _PickKind.pdf),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (choice == null || !context.mounted) return;
    if (choice == _PickKind.images) {
      await _pickImages();
    } else {
      await _pickPdf();
    }
  }

  Future<void> _pickImages() async {
    final picked = await ImagePicker().pickMultiImage();
    if (picked.isEmpty) return;
    onChanged([
      for (final file in picked)
        LocalMediaPick(path: file.path, name: file.name),
    ]);
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    final file = result?.files.single;
    final path = file?.path;
    if (path == null || path.isEmpty) return;
    onChanged([
      LocalMediaPick(path: path, name: file!.name, isPdf: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: c.ivory,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: enabled ? () => _openSheet(context) : null,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: c.brass.withValues(alpha: 0.5),
                  width: 1.2,
                ),
              ),
              child: files.isEmpty
                  ? SizedBox(
                      height: 120,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              color: c.brass,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              emptyLabel,
                              style: TextStyle(
                                color: c.stone,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hint,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: c.stone.withValues(alpha: 0.55),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _SelectedFilesPreview(
                      files: files,
                      enabled: enabled,
                      onClear: () => onChanged(const []),
                      onRemoveAt: (i) {
                        final next = [...files]..removeAt(i);
                        onChanged(next);
                      },
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

enum _PickKind { images, pdf }

class _SelectedFilesPreview extends StatelessWidget {
  const _SelectedFilesPreview({
    required this.files,
    required this.enabled,
    required this.onClear,
    required this.onRemoveAt,
  });

  final List<LocalMediaPick> files;
  final bool enabled;
  final VoidCallback onClear;
  final ValueChanged<int> onRemoveAt;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    final isPdf = files.length == 1 && files.first.isPdf;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                isPdf ? Icons.picture_as_pdf_outlined : Icons.photo_library_outlined,
                color: isPdf ? c.terracotta : c.brass,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isPdf
                      ? files.first.name
                      : '${files.length} صور',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: c.stone,
                  ),
                ),
              ),
              if (enabled)
                TextButton(
                  onPressed: onClear,
                  child: const Text('مسح'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (isPdf)
            DecoratedBox(
              decoration: BoxDecoration(
                color: c.raised.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.brass.withValues(alpha: 0.35)),
              ),
              child: SizedBox(
                height: 96,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.picture_as_pdf, color: c.terracotta, size: 36),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          files.first.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            DecoratedBox(
              decoration: BoxDecoration(
                color: c.raised.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.brass.withValues(alpha: 0.35)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < files.length; i++)
                      _Thumb(
                        file: files[i],
                        onRemove: enabled ? () => onRemoveAt(i) : null,
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

class _Thumb extends StatelessWidget {
  const _Thumb({required this.file, this.onRemove});

  final LocalMediaPick file;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 72,
            height: 72,
            child: kIsWeb
                ? ColoredBox(
                    color: c.ivory,
                    child: const Icon(Icons.image_outlined),
                  )
                : Image.file(File(file.path), fit: BoxFit.cover),
          ),
        ),
        if (onRemove != null)
          Positioned(
            top: -6,
            left: -6,
            child: Material(
              color: c.terracotta,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onRemove,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close, size: 12, color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Legacy inline buttons + chips (floor-plan screens). Prefer [MediaPickField].
class MediaAttachPicker extends StatelessWidget {
  const MediaAttachPicker({
    super.key,
    required this.files,
    required this.onChanged,
    this.enabled = true,
  });

  final List<LocalMediaPick> files;
  final ValueChanged<List<LocalMediaPick>> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return MediaPickField(
      files: files,
      onChanged: onChanged,
      enabled: enabled,
      emptyLabel: 'إضافة مخطط (صور أو PDF)',
      hint: 'عدة صور في حاوية واحدة أو PDF واحد.',
    );
  }
}
