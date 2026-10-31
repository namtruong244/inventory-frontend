import 'package:flutter/material.dart';

import '../l10n/l10n_ext.dart';
import '../theme/app_theme.dart';
import '../utils/e2e.dart';
import 'app_feedback.dart';
import 'app_icon.dart';
import 'soft_sheet.dart';
import 'tappable.dart';

/// Opens the "Add photo" sheet. Every callback receives whether the photo is a
/// receipt (the user can switch between Product / Receipt inside the sheet).
void showAddPhotoModal(
  BuildContext context, {
  required bool isReceipt,
  required ValueChanged<bool> onCamera,
  required ValueChanged<bool> onGallery,
  required void Function(String url, bool isReceipt) onPhotoAdded,
}) {
  showSoftSheet<void>(
    context,
    title: context.l10n.photoSheetTitle,
    subtitle: context.l10n.photoSheetSubtitle,
    builder: (ctx) => _AddPhotoBody(
      initialReceipt: isReceipt,
      onCamera: onCamera,
      onGallery: onGallery,
      onPhotoAdded: onPhotoAdded,
    ),
  );
}

List<Map<String, String>> _presets(BuildContext context, bool isReceipt) =>
    isReceipt
    ? [
        {
          'title': context.l10n.paperReceipt,
          'url': 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=800&auto=format&fit=crop&q=80',
        },
        {
          'title': context.l10n.storeInvoice,
          'url': 'https://images.unsplash.com/photo-1450133064473-71024230f91b?w=800&auto=format&fit=crop&q=80',
        },
        {
          'title': context.l10n.warrantyCard,
          'url': 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=800&auto=format&fit=crop&q=80',
        },
      ]
    : [
        {
          'title': 'Laptop',
          'url': 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&auto=format&fit=crop&q=80',
        },
        {
          'title': 'Gamepad',
          'url': 'https://images.unsplash.com/photo-1600080972464-8e5f35f63d08?w=800&auto=format&fit=crop&q=80',
        },
        {
          'title': 'Charger',
          'url': 'https://images.unsplash.com/photo-1583863788434-e58a36330cf0?w=800&auto=format&fit=crop&q=80',
        },
        {
          'title': 'Jacket',
          'url': 'https://images.unsplash.com/photo-1544923246-77307dd654cb?w=800&auto=format&fit=crop&q=80',
        },
        {
          'title': 'Medicine',
          'url': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=800&auto=format&fit=crop&q=80',
        },
        {
          'title': 'Batteries',
          'url': 'https://images.unsplash.com/photo-1619725002198-6a689b72f41d?w=800&auto=format&fit=crop&q=80',
        },
      ];

class _AddPhotoBody extends StatefulWidget {
  final bool initialReceipt;
  final ValueChanged<bool> onCamera;
  final ValueChanged<bool> onGallery;
  final void Function(String url, bool isReceipt) onPhotoAdded;

  const _AddPhotoBody({
    required this.initialReceipt,
    required this.onCamera,
    required this.onGallery,
    required this.onPhotoAdded,
  });

  @override
  State<_AddPhotoBody> createState() => _AddPhotoBodyState();
}

class _AddPhotoBodyState extends State<_AddPhotoBody> {
  late bool _receipt = widget.initialReceipt;
  final _urlController = TextEditingController();
  final _urlFocus = FocusNode();
  bool _showSamples = false;

  @override
  void dispose() {
    _urlController.dispose();
    _urlFocus.dispose();
    super.dispose();
  }

  void _addUrl() {
    final text = _urlController.text.trim();
    if (text.isEmpty) return;
    widget.onPhotoAdded(text, _receipt);
    Navigator.pop(context);
    AppFeedback.showSuccess(context, context.l10n.photoAdded);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: c.fill,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _tab(l10n.photoTabProduct, !_receipt, 'photo_tab_product', () {
                  setState(() {
                    _receipt = false;
                    _showSamples = false;
                  });
                }),
                const SizedBox(width: 4),
                _tab(l10n.photoTabReceipt, _receipt, 'photo_tab_receipt', () {
                  setState(() {
                    _receipt = true;
                    _showSamples = false;
                  });
                }),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _source(
                  id: 'photo_camera',
                  icon: Icons.camera_alt_rounded,
                  label: l10n.commonCamera,
                  fg: c.onAccent,
                  bg: c.accent,
                  onTap: () {
                    Navigator.pop(context);
                    widget.onCamera(_receipt);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _source(
                  id: 'photo_gallery',
                  icon: Icons.photo_library_rounded,
                  label: l10n.commonGallery,
                  fg: AppTones.sky,
                  bg: AppTones.skySoft,
                  onTap: () {
                    Navigator.pop(context);
                    widget.onGallery(_receipt);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _source(
                  id: 'photo_url',
                  icon: Icons.link_rounded,
                  label: l10n.photoPasteUrl,
                  fg: AppTones.lilac,
                  bg: AppTones.lilacSoft,
                  onTap: () => _urlFocus.requestFocus(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _source(
                  id: 'photo_sample',
                  icon: Icons.auto_awesome_rounded,
                  label: l10n.photoSamplePhoto,
                  fg: AppTones.amber,
                  bg: AppTones.amberSoft,
                  onTap: () => setState(() => _showSamples = !_showSamples),
                ),
              ),
            ],
          ),
          if (_showSamples) ...[const SizedBox(height: 12), _samples(context)],
          const SizedBox(height: 14),
          Text(
            l10n.imageUrl,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: c.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 52,
            padding: const EdgeInsets.only(left: 16, right: 6),
            decoration: BoxDecoration(
              color: c.fill,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                AppIcon(Icons.link_rounded, size: 18, color: c.textSecondary),
                const SizedBox(width: 10),
                Expanded(
                  child: e2eId(
                    'photo_url_input',
                    TextField(
                      controller: _urlController,
                      focusNode: _urlFocus,
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addUrl(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: c.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'https://',
                        hintStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: c.textMuted,
                        ),
                        isCollapsed: true,
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                Tappable(
                  semanticLabel: l10n.addViaUrl,
                  onTap: _addUrl,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: c.accent,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: AppIcon(
                      Icons.check_rounded,
                      size: 18,
                      color: c.onAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String label, bool selected, String id, VoidCallback onTap) {
    final c = context.colors;
    return Expanded(
      child: e2eId(
        id,
        Tappable(
          onTap: onTap,
          child: Container(
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? c.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: selected ? c.cardShadow : null,
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? c.textPrimary : c.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _source({
    required String id,
    required IconData icon,
    required String label,
    required Color fg,
    required Color bg,
    required VoidCallback onTap,
  }) {
    final c = context.colors;
    return e2eId(
      id,
      Tappable(
        semanticLabel: label,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.fill,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: AppIcon(icon, size: 20, color: fg),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: c.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _samples(BuildContext context) {
    final presets = _presets(context, _receipt);
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: presets.length,
        itemBuilder: (context, idx) {
          final p = presets[idx];
          return Tappable(
            onTap: () {
              widget.onPhotoAdded(p['url']!, _receipt);
              Navigator.pop(context);
              AppFeedback.showSuccess(
                context,
                context.l10n.samplePhotoSelected,
              );
            },
            child: Container(
              width: 76,
              margin: const EdgeInsets.only(right: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(p['url']!, fit: BoxFit.cover),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        color: Colors.black.withValues(alpha: 0.6),
                        child: Text(
                          p['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
