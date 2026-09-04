import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens an image fullscreen or a PDF via download + system viewer.
Future<void> openAttachment(
  BuildContext context, {
  required String title,
  required String? url,
  required bool isPdf,
}) async {
  if (url == null || url.trim().isEmpty) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('لا يوجد مرفق')),
    );
    return;
  }

  if (isPdf) {
    // Prefer download + open_filex (works without url_launcher native rebuild).
    await downloadAttachment(
      context,
      title: title,
      url: url,
      isPdf: true,
      openAfter: true,
    );
    return;
  }

  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.92),
    builder: (ctx) => _ImageAttachmentDialog(title: title, url: url),
  );
}

Future<void> downloadAttachment(
  BuildContext context, {
  required String title,
  required String? url,
  required bool isPdf,
  bool openAfter = false,
}) async {
  if (url == null || url.trim().isEmpty) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('لا يوجد مرفق للتحميل')),
    );
    return;
  }

  final messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(
    const SnackBar(content: Text('جاري التحميل…')),
  );

  try {
    final path = await AttachmentDownloader.save(
      url: url,
      title: title,
      isPdf: isPdf,
    );
    if (!context.mounted) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(openAfter ? 'جاري فتح الملف…' : 'تم التحميل'),
        action: SnackBarAction(
          label: 'فتح',
          onPressed: () => _openLocal(path),
        ),
      ),
    );
    if (openAfter) {
      await _openLocal(path);
    }
  } catch (e) {
    if (!context.mounted) return;
    messenger.hideCurrentSnackBar();
    final msg = e is DioException && e.response?.statusCode == 403
        ? 'فشل التحميل: الملف غير متاح (تحقق من ربط التخزين على السيرفر)'
        : 'فشل التحميل: تعذر الوصول للملف';
    messenger.showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}

Future<void> _openLocal(String path) async {
  try {
    await OpenFilex.open(path);
  } catch (_) {
    // Ignore — snackbar already shown.
  }
}

Future<void> _openExternal(BuildContext context, String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('رابط غير صالح')),
    );
    return;
  }
  try {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح الملف')),
      );
    }
  } on MissingPluginException {
    if (!context.mounted) return;
    // Hot-restart after adding url_launcher: fall back to download.
    await downloadAttachment(
      context,
      title: 'مرفق',
      url: url,
      isPdf: url.toLowerCase().contains('.pdf'),
      openAfter: true,
    );
  } on PlatformException {
    if (!context.mounted) return;
    await downloadAttachment(
      context,
      title: 'مرفق',
      url: url,
      isPdf: url.toLowerCase().contains('.pdf'),
      openAfter: true,
    );
  }
}

class AttachmentDownloader {
  static Future<String> save({
    required String url,
    required String title,
    required bool isPdf,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = p.join(dir.path, 'downloads');
    await Directory(folder).create(recursive: true);

    final uriPath = Uri.tryParse(url)?.path ?? url;
    final fromUrl = p.extension(uriPath).replaceFirst('.', '');
    final ext = isPdf
        ? 'pdf'
        : (fromUrl.isNotEmpty ? fromUrl : 'jpg');
    final safe = title
        .replaceAll(RegExp(r'[^\w\u0600-\u06FF\- ]'), '_')
        .trim();
    final name = '${safe.isEmpty ? 'attachment' : safe}_'
        '${DateTime.now().millisecondsSinceEpoch}.$ext';
    final filePath = p.join(folder, name);

    await Dio().download(url, filePath);
    return filePath;
  }
}

class _ImageAttachmentDialog extends StatelessWidget {
  const _ImageAttachmentDialog({required this.title, required this.url});

  final String title;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  tooltip: 'تحميل',
                  icon: const Icon(Icons.download_outlined),
                  onPressed: () => downloadAttachment(
                    context,
                    title: title,
                    url: url,
                    isPdf: false,
                  ),
                ),
                IconButton(
                  tooltip: 'فتح خارجياً',
                  icon: const Icon(Icons.open_in_new),
                  onPressed: () => _openExternal(context, url),
                ),
              ],
            ),
            Expanded(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 5,
                child: Center(
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const CircularProgressIndicator();
                    },
                    errorBuilder: (_, __, ___) => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'تعذر عرض الصورة',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact trailing actions: view + download.
class AttachmentActionRow extends StatelessWidget {
  const AttachmentActionRow({
    super.key,
    required this.title,
    required this.url,
    required this.isPdf,
  });

  final String title;
  final String? url;
  final bool isPdf;

  bool get _hasUrl => url != null && url!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!_hasUrl) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: isPdf ? 'فتح PDF' : 'عرض',
          icon: Icon(
            isPdf ? Icons.picture_as_pdf_outlined : Icons.visibility_outlined,
          ),
          onPressed: () => openAttachment(
            context,
            title: title,
            url: url,
            isPdf: isPdf,
          ),
        ),
        IconButton(
          tooltip: 'تحميل',
          icon: const Icon(Icons.download_outlined),
          onPressed: () => downloadAttachment(
            context,
            title: title,
            url: url,
            isPdf: isPdf,
          ),
        ),
      ],
    );
  }
}
