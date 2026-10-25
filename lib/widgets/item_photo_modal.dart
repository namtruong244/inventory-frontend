import 'package:flutter/material.dart';

import 'app_feedback.dart';
import 'app_form_field.dart';
import 'tappable.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';


void showAddPhotoModal(
  BuildContext context, {
  required bool isReceipt,
  required VoidCallback onCamera,
  required VoidCallback onGallery,
  required ValueChanged<String> onPhotoAdded,
}) {
  final urlController = TextEditingController();

  // Sample presets for quick testing
  final presets = isReceipt
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

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Material(
      color: context.colors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(color: context.colors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isReceipt ? context.l10n.addReceiptPhoto : context.l10n.addProductPhoto,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
 tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Camera and Gallery Action Buttons
            Row(
              children: [
                // Camera Button
                Expanded(
                  child: Material(
                    color: context.colors.primary,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.pop(ctx);
                        onCamera();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Column(
                          children: [
                            Icon(Icons.camera_alt_rounded, color: Colors.white, size: 26),
                            SizedBox(height: 6),
                            Text(
                              context.l10n.commonCamera,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Gallery Button
                Expanded(
                  child: Material(
                    color: context.colors.fill,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.pop(ctx);
                        onGallery();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Column(
                          children: [
                            Icon(Icons.photo_library_rounded, color: context.colors.textPrimary, size: 26),
                            SizedBox(height: 6),
                            Text(
                              context.l10n.commonGallery,
                              style: TextStyle(
                                color: context.colors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Divider
            Row(
              children: [
                Expanded(child: Divider(color: context.colors.border)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    context.l10n.orViaUrl,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: context.colors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: context.colors.border)),
              ],
            ),
            const SizedBox(height: 14),

            // Image URL input
            AppFormField(
              label: context.l10n.imageUrl,
              hintText: 'https://example.com/image.jpg',
              controller: urlController,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  final text = urlController.text.trim();
                  if (text.isNotEmpty) {
                    onPhotoAdded(text);
                    Navigator.pop(ctx);
                    AppFeedback.showSuccess(context, context.l10n.photoAdded);
                  }
                },
                child: Text(context.l10n.addViaUrl),
              ),
            ),
            const SizedBox(height: 20),

            // Quick preset photos
            Text(
              context.l10n.orChooseSamplePhoto,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: context.colors.textPrimary),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: presets.length,
                itemBuilder: (context, idx) {
                  final p = presets[idx];
                  return Tappable(
                    onTap: () {
                      onPhotoAdded(p['url']!);
                      Navigator.pop(ctx);
                      AppFeedback.showSuccess(context, context.l10n.samplePhotoSelected);
                    },
                    child: Container(
                      width: 76,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: context.colors.border),
                      ),
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
                                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
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
            ),
          ],
        ),
      ),
    ),
  );
}
