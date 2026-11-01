import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Drop-in replacement for [Icon]: draws the design's "Soft Duo" icons (24
/// grid, round line + at most one small solid accent, single colour) for every
/// Material glyph listed below and falls back to the Material font for
/// anything else. Extends [Icon] so
/// `find.byIcon(...)` keeps working in tests.
class AppIcon extends Icon {
  const AppIcon(
    super.icon, {
    super.key,
    super.size,
    super.color,
    super.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final data = icon;
    final glyph = data == null ? null : _glyphs[data.codePoint];
    if (glyph == null) return super.build(context);
    final theme = IconTheme.of(context);
    final s = size ?? theme.size ?? 24.0;
    final svg = glyph(_weight(s));
    var c = color ?? theme.color ?? const Color(0xFF000000);
    final op = theme.opacity;
    if (op != null && op != 1) c = c.withValues(alpha: c.a * op);
    // Same layout contract as [Icon]: the outer box may be stretched by tight
    // parent constraints (e.g. InputDecoration.prefixIcon is forced to 48x48),
    // so the glyph itself sits in a Center instead of filling it.
    final picture = SizedBox(
      width: s,
      height: s,
      child: Center(
        child: SvgPicture.string(
          svg,
          width: s,
          height: s,
          theme: SvgTheme(currentColor: c),
        ),
      ),
    );
    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(child: picture),
    );
  }
}

/// Stroke scale for an icon drawn at [size] px. As in the design, lines are
/// 2 units of the 24 grid (size/12 px) but never thinner than 1.5px, so small
/// icons get relatively heavier strokes.
double _weight(double size) => math.max(1, 18 / size);

String _w(double v) => v.toStringAsFixed(2);

String _head(double weight) =>
    "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' "
    "stroke='currentColor' stroke-width='${_w(2 * weight)}' stroke-linecap='round' stroke-linejoin='round'>";

/// Builds a glyph's SVG for a stroke weight (see [_weight]).
typedef _Glyph = String Function(double weight);

final Map<int, _Glyph> _glyphs = _build();

@visibleForTesting
Iterable<String> get appIconSvgs => [
  for (final glyph in _glyphs.values.toSet()) ...[glyph(1), glyph(18 / 12)],
];

Map<int, _Glyph> _build() {
  final m = <int, _Glyph>{};
  // Hand-drawn line glyphs the Soft Duo set does not cover.
  void g(List<IconData> icons, String body) {
    String glyph(double weight) => '${_head(weight)}$body</svg>';
    for (final i in icons) {
      m[i.codePoint] = glyph;
    }
  }

  g([Icons.arrow_upward_rounded], "<path d='M12 21V3M12 3L6.500 8.500'/>");
  g([Icons.unfold_more_rounded], "<path d='M8 9l4-4 4 4M8 15l4 4 4-4'/>");
  g(
    [Icons.edit_note_outlined],
    "<path d='M4 7h9M4 12h5M4 17h6'/><path d='M13 18.5l.7-3L19 10.2a1.6 1.6 0 012.3 2.3L16 17.8z'/>",
  );
  g(
    [Icons.delete_forever_outlined],
    "<path d='M5 7h14M10 7V5.2h4V7M7 7l.8 11.2a1.5 1.5 0 001.5 1.3h5.4a1.5 1.5 0 001.5-1.3L17 7'/><path d='M10.2 11.5l3.6 3.6M13.8 11.5l-3.6 3.6'/>",
  );
  g([Icons.priority_high_rounded], "<path d='M12 5v9.5M12 19v.01'/>");
  g([
    Icons.remove_circle_outline,
  ], "<circle cx='12' cy='12' r='8.5'/><path d='M8.5 12h7'/>");
  g([
    Icons.add_circle_outline_rounded,
  ], "<circle cx='12' cy='12' r='8.5'/><path d='M12 8.5v7M8.5 12h7'/>");
  g(
    [Icons.event_available_rounded],
    "<rect x='4' y='5.5' width='16' height='14.5' rx='3.5'/><path d='M4 10.5h16M8.5 3.5v4M15.5 3.5v4'/><path d='M9 15.2l2 2 3.5-3.8'/>",
  );
  g(
    [
      Icons.handshake_outlined,
      Icons.sync_alt_rounded,
      Icons.swap_horiz_rounded,
    ],
    "<path d='M5 8h13M14.5 4.5L18 8l-3.5 3.5M19 16H6M9.5 12.5L6 16l3.5 3.5'/>",
  );
  g(
    [Icons.sync_rounded, Icons.sync_problem_rounded, Icons.refresh_rounded],
    "<path d='M19.5 12a7.5 7.5 0 01-13 5.1M4.5 12a7.5 7.5 0 0113-5.1'/><path d='M17.5 3.5v3.6h-3.6M6.5 20.5v-3.6h3.6'/>",
  );
  g(
    [Icons.visibility_off_outlined],
    "<path d='M3 12s3.500-6.500 9-6.500c1.500 0 2.800.4 4 1M21 12s-3.500 6.500-9 6.500c-1.500 0-2.800-.4-4-1'/><path d='M4 4l16 16'/>",
  );
  g(
    [Icons.assignment_ind_outlined],
    "<rect x='5' y='4.5' width='14' height='16' rx='3.5'/><path d='M9 4.5h6'/><circle cx='12' cy='11' r='1.8'/><path d='M8.800 17c.4-1.800 1.700-2.800 3.200-2.800s2.800 1 3.200 2.800'/>",
  );
  g(
    [Icons.assignment_turned_in_outlined],
    "<rect x='5' y='4.5' width='14' height='16' rx='3.5'/><path d='M9 4.5h6'/><path d='M9 13l2.200 2.200L15 11'/>",
  );
  g(
    [Icons.assignment_late_outlined],
    "<rect x='5' y='4.5' width='14' height='16' rx='3.5'/><path d='M9 4.5h6'/><path d='M12 9.500v3.500M12 16v.01'/>",
  );
  g(
    [Icons.receipt_long_outlined, Icons.receipt_long_rounded],
    "<path d='M6 3.500h12v17l-2.500-1.700-1.800 1.700-1.700-1.700-1.800 1.700-1.700-1.700L6 20.500z'/><path d='M9 8.500h6M9 12h6'/>",
  );
  g(
    [Icons.summarize_outlined],
    "<path d='M7 3.5h7.5L19 8v10.5a2 2 0 01-2 2H7a2 2 0 01-2-2v-13a2 2 0 012-2z'/><path d='M14 3.5V8h5'/><path d='M9 12.500h6M9 16h4'/>",
  );
  g(
    [Icons.picture_as_pdf_rounded],
    "<path d='M7 3.5h7.5L19 8v10.5a2 2 0 01-2 2H7a2 2 0 01-2-2v-13a2 2 0 012-2z'/><path d='M14 3.5V8h5'/><path d='M8.500 15.500h1.500a1.200 1.200 0 000-2.400H8.500v4.400'/>",
  );
  g(
    [Icons.open_in_new_rounded],
    "<path d='M13 4.500h6.500V11M19.500 4.500L11 13M17 14v3.500a2 2 0 01-2 2H6.500a2 2 0 01-2-2V9a2 2 0 012-2H10'/>",
  );
  g([
    Icons.more_vert_rounded,
  ], "<path d='M12 6h.01M12 12h.01M12 18h.01' stroke-width='3'/>");
  g(
    [Icons.language_rounded, Icons.public],
    "<circle cx='12' cy='12' r='8.5'/><path d='M3.500 12h17M12 3.500c2.500 2.500 3.500 5.300 3.500 8.500s-1 6-3.500 8.500c-2.500-2.500-3.500-5.300-3.500-8.500s1-6 3.500-8.500z'/>",
  );
  g(
    [Icons.brightness_6_outlined],
    "<circle cx='12' cy='12' r='8.5'/><path d='M12 3.500a8.500 8.500 0 010 17z' fill='currentColor'/>",
  );
  g(
    [Icons.volume_up_outlined],
    "<path d='M4.500 10v4h3l4.500 3.500v-11L7.500 10z'/><path d='M15.500 9a4 4 0 010 6M18 6.500a7.500 7.500 0 010 11'/>",
  );
  g(
    [Icons.vibration_rounded],
    "<rect x='8' y='4' width='8' height='16' rx='2.500'/><path d='M4.500 9v6M19.500 9v6'/>",
  );
  g(
    [Icons.keyboard_outlined],
    "<rect x='3' y='6.500' width='18' height='11' rx='3'/><path d='M7 10.500h.01M10.500 10.500h.01M14 10.500h.01M17.500 10.500h.01M8 14h8'/>",
  );
  g(
    [Icons.view_agenda_outlined],
    "<rect x='4' y='4.500' width='16' height='6.500' rx='2.500'/><rect x='4' y='13' width='16' height='6.500' rx='2.500'/>",
  );
  g(
    [Icons.grid_view_rounded],
    "<rect x='4' y='4' width='7' height='7' rx='2.200'/><rect x='13' y='4' width='7' height='7' rx='2.200'/><rect x='4' y='13' width='7' height='7' rx='2.200'/><rect x='13' y='13' width='7' height='7' rx='2.200'/>",
  );
  g(
    [Icons.dns_rounded],
    "<rect x='4' y='4.500' width='16' height='6' rx='2.500'/><rect x='4' y='13.500' width='16' height='6' rx='2.500'/><path d='M8 7.500h.01M8 16.500h.01'/>",
  );
  g(
    [Icons.attach_money_rounded],
    "<path d='M12 4v16M15.500 8.200C15 7 13.700 6.300 12 6.300c-2 0-3.500 1-3.500 2.600 0 3.500 7 1.800 7 5.300 0 1.600-1.500 2.600-3.500 2.600-1.800 0-3.200-.8-3.700-2.200'/>",
  );
  g([
    Icons.donut_large_outlined,
  ], "<circle cx='12' cy='12' r='8.5'/><circle cx='12' cy='12' r='3.500'/>");
  g(
    [Icons.dangerous_outlined],
    "<path d='M8.500 3.500h7l5 5v7l-5 5h-7l-5-5v-7z'/><path d='M9 9l6 6M15 9l-6 6'/>",
  );
  g(
    [Icons.content_cut_rounded],
    "<circle cx='6.500' cy='7' r='2.500'/><circle cx='6.500' cy='17' r='2.500'/><path d='M8.500 8.500L20 18M8.500 15.500L20 6'/>",
  );
  g(
    [Icons.outbox_rounded],
    "<path d='M4.500 13v4.500a2 2 0 002 2h11a2 2 0 002-2V13M12 15V4.500M7.500 9L12 4.500 16.500 9'/>",
  );
  g(
    [Icons.folder_outlined],
    "<path d='M3.500 7.500A2.500 2.500 0 016 5h3.500l2 2.500H18a2.500 2.500 0 012.500 2.500v7.500A2.500 2.500 0 0118 20H6a2.500 2.500 0 01-2.500-2.500z'/>",
  );
  g(
    [Icons.route_outlined],
    "<circle cx='6.500' cy='6.500' r='2.300'/><circle cx='17.500' cy='17.500' r='2.300'/><path d='M8.800 6.500H14a3 3 0 010 6h-4a3 3 0 000 6h5.200'/>",
  );
  g(
    [Icons.kitchen_outlined],
    "<rect x='6' y='3.500' width='12' height='17' rx='3'/><path d='M6 10.500h12M9.500 7v1.500M9.500 13v3'/>",
  );
  g(
    [Icons.devices_outlined],
    "<rect x='3.500' y='5.500' width='14' height='10' rx='2'/><path d='M2.500 19h11'/><rect x='16.500' y='9.500' width='4' height='9' rx='1.200'/>",
  );
  g([
    Icons.fitness_center_outlined,
  ], "<path d='M6.500 8v8M17.500 8v8M3.500 10v4M20.500 10v4M6.500 12h11'/>");
  g(
    [Icons.medical_services_outlined],
    "<rect x='3.500' y='7' width='17' height='13' rx='3'/><path d='M9 7V5.500A1.500 1.500 0 0110.500 4h3A1.500 1.500 0 0115 5.500V7M12 10.500v6M9 13.500h6'/>",
  );
  g(
    [Icons.luggage_outlined],
    "<rect x='6' y='6.500' width='12' height='13' rx='3'/><path d='M9.500 6.500V4h5v2.500M9.500 10v6M14.500 10v6'/>",
  );
  g(
    [Icons.watch_outlined],
    "<rect x='7.500' y='7' width='9' height='10' rx='3'/><path d='M9 7l.7-3.500h4.600L15 7M9 17l.7 3.500h4.600L15 17M12 10v2l1.400 1'/>",
  );
  g(
    [Icons.music_note_outlined],
    "<path d='M9 18V6l10-2v12'/><circle cx='6.500' cy='18' r='2.500'/><circle cx='16.500' cy='16' r='2.500'/>",
  );
  g(
    [Icons.shopping_basket_outlined],
    "<path d='M3.500 10h17l-1.700 8.200A2 2 0 0116.800 20H7.200a2 2 0 01-2-1.800z'/><path d='M8 10l3-5.500M16 10l-3-5.500'/>",
  );
  g(
    [Icons.add_shopping_cart_outlined],
    "<path d='M3 4h2.500l1.800 9h9.500l1.700-6.500H8'/><circle cx='9' cy='19' r='1.300'/><circle cx='16' cy='19' r='1.300'/>",
  );
  g([
    Icons.production_quantity_limits_rounded,
  ], "<path d='M4 8l8-4 8 4v9l-8 4-8-4z'/><path d='M12 10.500v4M12 17v.01'/>");
  g(
    [Icons.account_balance_wallet_outlined],
    "<path d='M4 7.500A2.500 2.500 0 016.500 5H17a2 2 0 012 2v1.500'/><rect x='4' y='8.500' width='16' height='11' rx='3'/><path d='M16 14h.01' stroke-width='3'/>",
  );
  g(
    [Icons.drive_file_move_outlined],
    "<path d='M3.500 7.500A2.500 2.500 0 016 5h3.500l2 2.500H18a2.500 2.500 0 012.500 2.500v7.500A2.500 2.500 0 0118 20H6a2.500 2.500 0 01-2.500-2.500z'/><path d='M8.500 13.500h7M13 11l2.500 2.500-2.500 2.500'/>",
  );
  g([Icons.circle_outlined], "<circle cx='12' cy='12' r='8.5'/>");
  g(
    [Icons.play_circle_outline],
    "<circle cx='12' cy='12' r='8.5'/><path d='M10.500 8.800l4.500 3.200-4.500 3.200z'/>",
  );

  // --- Soft Duo set (design frame WlhiR); glyph names are the design node
  // names. Layers stack like the design: solid accent, line, bold stroke.
  void d(String name, List<IconData> icons) {
    final p = _softDuo[name]!;
    String glyph(double weight) =>
        '${_head(weight)}'
        "${p.solid == null ? '' : "<path d='${p.solid}' fill='currentColor' fill-rule='evenodd' stroke-width='${_w(0.45 * weight)}'/>"}"
        "${p.line == null ? '' : "<path d='${p.line}'/>"}"
        "${p.bold == null ? '' : "<path d='${p.bold}' stroke-width='${_w(3.8 * weight)}'/>"}"
        '</svg>';
    for (final i in icons) {
      m[i.codePoint] = glyph;
    }
  }

  d('house', [Icons.home_outlined, Icons.home_rounded, Icons.home]);
  d('search', [Icons.search, Icons.search_rounded]);
  d('bell', [
    Icons.notifications_none_rounded,
    Icons.notifications_active_outlined,
    Icons.notifications_outlined,
  ]);
  d('bell-ring', [
    Icons.notifications_active_rounded,
    Icons.notifications_active,
  ]);
  d('user-round', [
    Icons.person_outline_rounded,
    Icons.person_outline,
    Icons.person_rounded,
  ]);
  d('user-x', [Icons.person_off_outlined, Icons.person_remove_outlined]);
  d('settings', [
    Icons.settings_outlined,
    Icons.settings_rounded,
    Icons.tune_rounded,
    Icons.tune,
  ]);
  d('tag', [
    Icons.tag_rounded,
    Icons.sell_outlined,
    Icons.label_outline_rounded,
  ]);
  d('box', [Icons.view_in_ar_outlined, Icons.view_in_ar_rounded]);
  d('package', [
    Icons.inventory_2_outlined,
    Icons.inventory_2_rounded,
    Icons.inventory_2,
  ]);
  d('package-open', [Icons.unarchive_outlined, Icons.unarchive_rounded]);
  d('package-plus', [
    Icons.library_add_outlined,
    Icons.add_box_outlined,
    Icons.add_box_rounded,
  ]);
  d('package-x', [
    Icons.remove_shopping_cart_outlined,
    Icons.disabled_by_default_outlined,
  ]);
  d('archive', [
    Icons.archive_outlined,
    Icons.archive_rounded,
    Icons.warehouse_outlined,
    Icons.warehouse_rounded,
  ]);
  d('door-open', [
    Icons.meeting_room_outlined,
    Icons.meeting_room_rounded,
    Icons.door_front_door_outlined,
  ]);
  d('rows-3', [
    Icons.shelves,
    Icons.table_rows_outlined,
    Icons.table_rows_rounded,
  ]);
  d('inbox', [
    Icons.inbox_outlined,
    Icons.inbox_rounded,
    Icons.all_inbox_outlined,
  ]);
  d('shapes', [Icons.category_outlined, Icons.category_rounded]);
  d('scan-line', [
    Icons.qr_code_scanner_rounded,
    Icons.qr_code_scanner,
    Icons.document_scanner_outlined,
  ]);
  d('qr-code', [Icons.qr_code_2_rounded, Icons.qr_code_rounded, Icons.qr_code]);
  d('scan-barcode', [Icons.barcode_reader]);
  d('scan-search', [Icons.manage_search_rounded]);
  d('plus', [Icons.add, Icons.add_rounded]);
  d('minus', [Icons.remove, Icons.remove_rounded]);
  d('x', [Icons.close, Icons.close_rounded, Icons.clear]);
  d('check', [Icons.check, Icons.check_rounded, Icons.done_rounded]);
  d('chevron-right', [
    Icons.chevron_right,
    Icons.chevron_right_rounded,
    Icons.arrow_forward_ios_rounded,
  ]);
  d('chevron-down', [
    Icons.keyboard_arrow_down_rounded,
    Icons.arrow_drop_down_rounded,
    Icons.expand_more_rounded,
    Icons.expand_more,
  ]);
  d('chevron-up', [
    Icons.keyboard_arrow_up_rounded,
    Icons.expand_less_rounded,
    Icons.expand_less,
  ]);
  d('chevrons-down-up', [Icons.unfold_less_rounded, Icons.unfold_less]);
  d('arrow-left', [
    Icons.arrow_back,
    Icons.arrow_back_rounded,
    Icons.arrow_back_ios_new,
    Icons.arrow_back_ios_new_rounded,
  ]);
  d('arrow-right', [Icons.arrow_forward, Icons.arrow_forward_rounded]);
  d('arrow-up-right', [Icons.north_east_rounded, Icons.north_east]);
  d('arrow-up-down', [
    Icons.swap_vert_rounded,
    Icons.swap_vert,
    Icons.sort_rounded,
  ]);
  d('corner-down-right', [
    Icons.subdirectory_arrow_right_rounded,
    Icons.subdirectory_arrow_right,
  ]);
  d('ellipsis', [Icons.more_horiz_rounded, Icons.more_horiz]);
  d('trash-2', [
    Icons.delete_outline,
    Icons.delete_outline_rounded,
    Icons.delete_sweep_outlined,
    Icons.delete,
    Icons.delete_rounded,
  ]);
  d('pencil', [
    Icons.edit_outlined,
    Icons.edit_rounded,
    Icons.edit,
    Icons.design_services_outlined,
  ]);
  d('move', [Icons.open_with_rounded, Icons.open_with]);
  d('history', [
    Icons.history,
    Icons.history_rounded,
    Icons.restore_rounded,
    Icons.restore,
  ]);
  d('rotate-cw', [Icons.rotate_right_rounded, Icons.rotate_right]);
  d('rotate-ccw', [Icons.rotate_left_rounded, Icons.rotate_left]);
  d('undo-2', [Icons.undo_rounded, Icons.undo]);
  d('copy', [
    Icons.copy_rounded,
    Icons.content_copy_rounded,
    Icons.content_copy_outlined,
  ]);
  d('share', [
    Icons.share_outlined,
    Icons.share_rounded,
    Icons.ios_share_rounded,
    Icons.ios_share,
  ]);
  d('printer', [Icons.print_outlined, Icons.print_rounded, Icons.print]);
  d('file-down', [
    Icons.file_download_outlined,
    Icons.download_outlined,
    Icons.download_rounded,
  ]);
  d('camera', [
    Icons.camera_alt_rounded,
    Icons.camera_alt_outlined,
    Icons.add_a_photo_outlined,
    Icons.photo_camera_outlined,
  ]);
  d('image', [
    Icons.image_outlined,
    Icons.broken_image_outlined,
    Icons.photo_library_rounded,
    Icons.photo_library_outlined,
  ]);
  d('link', [Icons.link_rounded, Icons.link]);
  d('clipboard-paste', [
    Icons.content_paste_rounded,
    Icons.content_paste_outlined,
  ]);
  d('eye', [Icons.visibility_outlined, Icons.visibility_rounded]);
  d('lock', [
    Icons.lock_outline,
    Icons.lock_outline_rounded,
    Icons.lock_outlined,
  ]);
  d('mail', [
    Icons.mail_outline_rounded,
    Icons.mail_outline,
    Icons.mail_outlined,
  ]);
  d('phone', [Icons.phone_outlined, Icons.phone_rounded]);
  d('map-pin', [Icons.location_on_outlined, Icons.location_on_rounded]);
  d('calendar', [
    Icons.calendar_today_outlined,
    Icons.calendar_month_outlined,
    Icons.event_outlined,
  ]);
  d('calendar-x', [Icons.event_busy_outlined, Icons.event_busy_rounded]);
  d('calendar-clock', [
    Icons.event_repeat_outlined,
    Icons.schedule_send_outlined,
  ]);
  d('hourglass', [
    Icons.hourglass_top_rounded,
    Icons.hourglass_empty_rounded,
    Icons.hourglass_bottom_rounded,
  ]);
  d('clock-alert', [
    Icons.alarm_rounded,
    Icons.access_time_rounded,
    Icons.schedule_rounded,
    Icons.schedule_outlined,
  ]);
  d('triangle-alert', [
    Icons.warning_amber_rounded,
    Icons.warning_rounded,
    Icons.warning_amber_outlined,
  ]);
  d('circle-alert', [
    Icons.error_outline_rounded,
    Icons.error_outline,
    Icons.error_rounded,
  ]);
  d('circle-check', [
    Icons.check_circle_rounded,
    Icons.check_circle_outline,
    Icons.check_circle_outline_rounded,
    Icons.check_circle,
  ]);
  d('circle-help', [Icons.help_outline, Icons.help_outline_rounded]);
  d('info', [
    Icons.info_outline,
    Icons.info_outline_rounded,
    Icons.info_outlined,
  ]);
  d('cloud-off', [Icons.cloud_off_rounded, Icons.cloud_off_outlined]);
  d('cloud-alert', [
    Icons.cloud_sync_rounded,
    Icons.cloud_sync_outlined,
    Icons.dns_outlined,
  ]);
  d('loader-circle', [Icons.autorenew_rounded, Icons.autorenew]);
  d('shield', [Icons.shield_outlined, Icons.security_outlined]);
  d('shield-check', [
    Icons.verified_user_outlined,
    Icons.verified_user_rounded,
    Icons.verified_rounded,
  ]);
  d('shield-alert', [Icons.gpp_maybe_outlined, Icons.gpp_maybe_rounded]);
  d('handshake', [Icons.handshake_outlined, Icons.handshake_rounded]);
  d('hand', [Icons.touch_app_outlined, Icons.back_hand_outlined]);
  d('headphones', [Icons.headphones_outlined, Icons.headphones_rounded]);
  d('battery', [Icons.battery_5_bar_outlined, Icons.battery_full_rounded]);
  d('battery-charging', [Icons.battery_charging_full_rounded]);
  d('pill', [Icons.medication_outlined, Icons.medication_rounded]);
  d('plug', [Icons.power_outlined, Icons.cable_outlined, Icons.power_rounded]);
  d('laptop', [Icons.laptop_outlined, Icons.laptop_mac_outlined]);
  d('monitor', [Icons.desktop_windows_outlined, Icons.monitor_outlined]);
  d('tablet', [Icons.tablet_outlined, Icons.tablet_mac_outlined]);
  d('gamepad-2', [Icons.sports_esports_outlined, Icons.sports_esports_rounded]);
  d('drill', [Icons.hardware_outlined, Icons.hardware_rounded]);
  d('wrench', [
    Icons.build_outlined,
    Icons.build_rounded,
    Icons.build_circle_outlined,
    Icons.handyman_outlined,
  ]);
  d('cpu', [Icons.memory_outlined, Icons.memory_rounded]);
  d('shirt', [Icons.checkroom_outlined, Icons.checkroom_rounded]);
  d('utensils', [Icons.restaurant_outlined, Icons.restaurant_rounded]);
  d('cooking-pot', [Icons.soup_kitchen_outlined, Icons.soup_kitchen_rounded]);
  d('book-open', [Icons.menu_book_outlined, Icons.menu_book_rounded]);
  d('sparkles', [Icons.auto_awesome_outlined, Icons.auto_awesome_rounded]);
  d('sofa', [
    Icons.weekend_outlined,
    Icons.chair_outlined,
    Icons.chair_rounded,
  ]);
  d('bed-double', [Icons.bed_outlined, Icons.bed_rounded]);
  d('bath', [Icons.bathtub_outlined, Icons.bathtub_rounded]);
  d('car', [Icons.directions_car_outlined, Icons.directions_car_rounded]);
  d('milk', [Icons.local_drink_outlined, Icons.local_drink_rounded]);
  d('sun', [
    Icons.wb_sunny_outlined,
    Icons.light_mode_outlined,
    Icons.light_mode_rounded,
  ]);
  d('wind', [Icons.air_rounded, Icons.air]);
  d('flashlight', [Icons.flashlight_on_outlined, Icons.flashlight_on_rounded]);
  d('palette', [Icons.palette_outlined, Icons.palette_rounded]);
  d('languages', [
    Icons.translate_rounded,
    Icons.language_rounded,
    Icons.translate,
  ]);
  d('banknote', [Icons.payments_outlined, Icons.payments_rounded]);
  d('ruler', [Icons.straighten_rounded, Icons.straighten]);
  d('activity', [Icons.show_chart_rounded, Icons.monitor_heart_outlined]);
  d('trending-down', [Icons.trending_down_rounded, Icons.trending_down]);
  d('log-out', [Icons.logout_rounded, Icons.logout]);
  d('folder-plus', [
    Icons.create_new_folder_outlined,
    Icons.create_new_folder_rounded,
  ]);
  d('list-tree', [Icons.account_tree_rounded, Icons.account_tree_outlined]);
  d('list', [
    Icons.list_rounded,
    Icons.format_list_bulleted_rounded,
    Icons.list,
  ]);
  d('text-cursor-input', [Icons.input_rounded, Icons.input]);
  d('sticky-note', [Icons.sticky_note_2_outlined, Icons.sticky_note_2_rounded]);
  return m;
}

/// Path data of the design's Soft Duo glyphs (frame WlhiR, 24 grid): a round
/// line, an optional small solid accent and an optional bold stroke.
const _softDuo = <String, ({String? solid, String? line, String? bold})>{
  'house': (
    solid: 'M11.2 13.2h1.6a1.8 1.8 0 0 1 1.8 1.8v1.6a1.8 1.8 0 0 1-1.8 1.8h-1.6a1.8 1.8 0 0 1-1.8-1.8v-1.6a1.8 1.8 0 0 1 1.8-1.8z',
    line: 'M4 10.3c0-0.8 0.4-1.5 1-2l5.2-4c1.1-0.8 2.5-0.8 3.6 0l5.2 4c0.6 0.5 1 1.2 1 2v7.2a3.5 3.5 0 0 1-3.5 3.5h-9a3.5 3.5 0 0 1-3.5-3.5z',
    bold: null,
  ),
  'search': (
    solid: null,
    line: 'M4.2 10.8a6.6 6.6 0 1 0 13.2 0 6.6 6.6 0 1 0-13.2 0z',
    bold: 'M16.2 16.2l3.6 3.6',
  ),
  'bell': (
    solid: 'M9.7 19.4h4.6a2.3 2.3 0 0 1-4.6 0z',
    line: 'M5.2 16.8h13.6l-1.3-1.9a2.4 2.4 0 0 1-0.4-1.3v-3.2a5.1 5.1 0 0 0-10.2 0v3.2a2.4 2.4 0 0 1-0.4 1.3z',
    bold: null,
  ),
  'bell-ring': (
    solid: 'M9.7 19.4h4.6a2.3 2.3 0 0 1-4.6 0z',
    line: 'M5.2 16.8h13.6l-1.3-1.9a2.4 2.4 0 0 1-0.4-1.3v-3.2a5.1 5.1 0 0 0-10.2 0v3.2a2.4 2.4 0 0 1-0.4 1.3z m-2.3-7.2a8.4 8.4 0 0 1 2.4-4.9m15.8 4.9a8.4 8.4 0 0 0-2.4-4.9',
    bold: null,
  ),
  'user-round': (
    solid: 'M7.8 7.6a4.2 4.2 0 1 0 8.4 0 4.2 4.2 0 1 0-8.4 0z',
    line: 'M4.5 20.5c0-3.6 3.4-6 7.5-6s7.5 2.4 7.5 6',
    bold: null,
  ),
  'user-x': (
    solid: 'M5.8 7.6a4.2 4.2 0 1 0 8.4 0 4.2 4.2 0 1 0-8.4 0z',
    line: 'M3 20.5c0-3.6 3.1-6 7-6 1.2 0 2.3 0.2 3.3 0.6m3.2 0.4l4.5 4.5m0-4.5l-4.5 4.5',
    bold: null,
  ),
  'settings': (
    solid: 'M9.4 12a2.6 2.6 0 1 0 5.2 0 2.6 2.6 0 1 0-5.2 0z',
    line: 'M10.02 5.08l0.59-2.38 2.78 0 0.59 2.38 1.51 0.62 2.1-1.26 1.97 1.97-1.26 2.1 0.62 1.51 2.38 0.59 0 2.78-2.38 0.59-0.62 1.51 1.26 2.1-1.97 1.97-2.1-1.26-1.51 0.62-0.59 2.38-2.78 0-0.59-2.38-1.51-0.62-2.1 1.26-1.97-1.97 1.26-2.1-0.62-1.51-2.38-0.59 0-2.78 2.38-0.59 0.62-1.51-1.26-2.1 1.97-1.97 2.1 1.26z',
    bold: null,
  ),
  'sliders-horizontal': (
    solid: 'M4.6 7a2.9 2.9 0 1 0 5.8 0 2.9 2.9 0 1 0-5.8 0z m9 10a2.9 2.9 0 1 0 5.8 0 2.9 2.9 0 1 0-5.8 0z',
    line: 'M12.8 7h8.2m-18 10h8.2',
    bold: null,
  ),
  'tag': (
    solid: 'M6.1 8a1.9 1.9 0 1 0 3.8 0 1.9 1.9 0 1 0-3.8 0z',
    line: 'M3.5 5.6v5c0 0.7 0.3 1.3 0.8 1.8l7.8 7.8c0.9 0.9 2.3 0.9 3.2 0l4.9-4.9c0.9-0.9 0.9-2.3 0-3.2l-7.8-7.8c-0.5-0.5-1.1-0.8-1.8-0.8h-5c-1.2 0-2.1 0.9-2.1 2.1z',
    bold: null,
  ),
  'box': (
    solid: 'M12 2.6l8.4 4.4-8.4 4.4-8.4-4.4z',
    line: 'M4 10.2v6.8l8 4.2 8-4.2v-6.8m-8 4v7',
    bold: null,
  ),
  'boxes': (
    solid: 'M10.1 2.8h3.8a2 2 0 0 1 2 2v3.4a2 2 0 0 1-2 2h-3.8a2 2 0 0 1-2-2v-3.4a2 2 0 0 1 2-2z',
    line: 'M4.8 12.6h3.8a2 2 0 0 1 2 2v3.8a2 2 0 0 1-2 2h-3.8a2 2 0 0 1-2-2v-3.8a2 2 0 0 1 2-2z m10.6 0h3.8a2 2 0 0 1 2 2v3.8a2 2 0 0 1-2 2h-3.8a2 2 0 0 1-2-2v-3.8a2 2 0 0 1 2-2z',
    bold: null,
  ),
  'package': (
    solid: 'M9.8 3.5h4.4v6.3a0.9 0.9 0 0 1-1.3 0.8l-0.9-1.2-0.9 0.5a0.9 0.9 0 0 1-1.3-0.8z',
    line: 'M7 3.5h10a3.5 3.5 0 0 1 3.5 3.5v10a3.5 3.5 0 0 1-3.5 3.5h-10a3.5 3.5 0 0 1-3.5-3.5v-10a3.5 3.5 0 0 1 3.5-3.5z m7.5 13.3h2.5',
    bold: null,
  ),
  'package-open': (
    solid: 'M4.2 7.4l-1.7-2.7a1 1 0 0 1 0.85-1.5h5.2l2.3 4.2z m15.6 0l1.7-2.7a1 1 0 0 0-0.85-1.5h-5.2l-2.3 4.2z',
    line: 'M4 9.6v8.4a2.5 2.5 0 0 0 2.5 2.5h11a2.5 2.5 0 0 0 2.5-2.5v-8.4m-16 0h16',
    bold: null,
  ),
  'package-plus': (
    solid: 'M9.8 3.5h4.4v5a0.9 0.9 0 0 1-1.3 0.8l-0.9-1.2-0.9 0.5a0.9 0.9 0 0 1-1.3-0.8z',
    line: 'M7 3.5h10a3.5 3.5 0 0 1 3.5 3.5v10a3.5 3.5 0 0 1-3.5 3.5h-10a3.5 3.5 0 0 1-3.5-3.5v-10a3.5 3.5 0 0 1 3.5-3.5z m5 9.3v5m-2.5-2.5h5',
    bold: null,
  ),
  'package-x': (
    solid: 'M9.8 3.5h4.4v5a0.9 0.9 0 0 1-1.3 0.8l-0.9-1.2-0.9 0.5a0.9 0.9 0 0 1-1.3-0.8z',
    line: 'M7 3.5h10a3.5 3.5 0 0 1 3.5 3.5v10a3.5 3.5 0 0 1-3.5 3.5h-10a3.5 3.5 0 0 1-3.5-3.5v-10a3.5 3.5 0 0 1 3.5-3.5z m3 9.9l4 4m0-4l-4 4',
    bold: null,
  ),
  'archive': (
    solid: 'M4.3 3.5h15.4a1.8 1.8 0 0 1 1.8 1.8v1.4a1.8 1.8 0 0 1-1.8 1.8h-15.4a1.8 1.8 0 0 1-1.8-1.8v-1.4a1.8 1.8 0 0 1 1.8-1.8z',
    line: 'M4.5 11v6.5a3 3 0 0 0 3 3h9a3 3 0 0 0 3-3v-6.5m-9.5 3.2h4',
    bold: null,
  ),
  'warehouse': (
    solid: 'M8.4 11.4h7.2a0.9 0.9 0 0 1 0.9 0.9v0.4a0.9 0.9 0 0 1-0.9 0.9h-7.2a0.9 0.9 0 0 1-0.9-0.9v-0.4a0.9 0.9 0 0 1 0.9-0.9z m0 3.5h7.2a0.9 0.9 0 0 1 0.9 0.9v0.4a0.9 0.9 0 0 1-0.9 0.9h-7.2a0.9 0.9 0 0 1-0.9-0.9v-0.4a0.9 0.9 0 0 1 0.9-0.9z m0 3.5h7.2a0.9 0.9 0 0 1 0.9 0.9v0.4a0.9 0.9 0 0 1-0.9 0.9h-7.2a0.9 0.9 0 0 1-0.9-0.9v-0.4a0.9 0.9 0 0 1 0.9-0.9z',
    line: 'M3 20.5v-11.1a2 2 0 0 1 1.1-1.8l7-3.6a2 2 0 0 1 1.8 0l7 3.6a2 2 0 0 1 1.1 1.8v11.1',
    bold: null,
  ),
  'door-open': (
    solid: 'M10.85 14a0.85 0.85 0 1 0 1.7 0 0.85 0.85 0 1 0-1.7 0z',
    line: 'M2.5 20.5h2.5m14 0h2.5m-16.5 0v-15.5a1.5 1.5 0 0 1 1.5-1.5h11a1.5 1.5 0 0 1 1.5 1.5v15.5m-11-12.5l6.6-1.6 0 14.5-6.6-1.2z',
    bold: null,
  ),
  'rows-3': (
    solid: 'M5.3 3.4h13.4a2.3 2.3 0 0 1 2.3 2.3v0a2.3 2.3 0 0 1-2.3 2.3h-13.4a2.3 2.3 0 0 1-2.3-2.3v0a2.3 2.3 0 0 1 2.3-2.3z',
    line: 'M3.5 12.4h17m-17 6h17',
    bold: null,
  ),
  'inbox': (
    solid: 'M9.4 8h5.2a0.9 0.9 0 0 1 0.9 0.9v0a0.9 0.9 0 0 1-0.9 0.9h-5.2a0.9 0.9 0 0 1-0.9-0.9v0a0.9 0.9 0 0 1 0.9-0.9z',
    line: 'M3 13.5l2.8-8.2a2 2 0 0 1 1.9-1.3h8.6a2 2 0 0 1 1.9 1.3l2.8 8.2v4.5a2.5 2.5 0 0 1-2.5 2.5h-13a2.5 2.5 0 0 1-2.5-2.5z m0 0h4.5l1.5 2.5h6l1.5-2.5h4.5',
    bold: null,
  ),
  'shapes': (
    solid: 'M11.1 3.2a1 1 0 0 1 1.8 0l3.9 6.3a1 1 0 0 1-0.9 1.5h-7.8a1 1 0 0 1-0.9-1.5z',
    line: 'M4.8 14h3.8a1.6 1.6 0 0 1 1.6 1.6v3.8a1.6 1.6 0 0 1-1.6 1.6h-3.8a1.6 1.6 0 0 1-1.6-1.6v-3.8a1.6 1.6 0 0 1 1.6-1.6z m9 3.5a3.5 3.5 0 1 0 7 0 3.5 3.5 0 1 0-7 0z',
    bold: null,
  ),
  'scan-line': (
    solid: 'M7 9.6v-1a2 2 0 0 1 2-2h6a2 2 0 0 1 2 2v1z m0 4.8h10v1a2 2 0 0 1-2 2h-6a2 2 0 0 1-2-2z',
    line: 'M3 8v-1.5a3.5 3.5 0 0 1 3.5-3.5h1.5m8 0h1.5a3.5 3.5 0 0 1 3.5 3.5v1.5m0 8v1.5a3.5 3.5 0 0 1-3.5 3.5h-1.5m-8 0h-1.5a3.5 3.5 0 0 1-3.5-3.5v-1.5m-1-4h20',
    bold: null,
  ),
  'qr-code': (
    solid: 'M6.2 5.5h1a0.7 0.7 0 0 1 0.7 0.7v1a0.7 0.7 0 0 1-0.7 0.7h-1a0.7 0.7 0 0 1-0.7-0.7v-1a0.7 0.7 0 0 1 0.7-0.7z m10.6 0h1a0.7 0.7 0 0 1 0.7 0.7v1a0.7 0.7 0 0 1-0.7 0.7h-1a0.7 0.7 0 0 1-0.7-0.7v-1a0.7 0.7 0 0 1 0.7-0.7z m-10.6 10.6h1a0.7 0.7 0 0 1 0.7 0.7v1a0.7 0.7 0 0 1-0.7 0.7h-1a0.7 0.7 0 0 1-0.7-0.7v-1a0.7 0.7 0 0 1 0.7-0.7z m8.3-2.5h1.4a0.9 0.9 0 0 1 0.9 0.9v1.4a0.9 0.9 0 0 1-0.9 0.9h-1.4a0.9 0.9 0 0 1-0.9-0.9v-1.4a0.9 0.9 0 0 1 0.9-0.9z m4.5 4.6h1.2a0.8 0.8 0 0 1 0.8 0.8v1.2a0.8 0.8 0 0 1-0.8 0.8h-1.2a0.8 0.8 0 0 1-0.8-0.8v-1.2a0.8 0.8 0 0 1 0.8-0.8z m0-4.6h1.2a0.8 0.8 0 0 1 0.8 0.8v1.2a0.8 0.8 0 0 1-0.8 0.8h-1.2a0.8 0.8 0 0 1-0.8-0.8v-1.2a0.8 0.8 0 0 1 0.8-0.8z',
    line: 'M5.2 3h3a2.2 2.2 0 0 1 2.2 2.2v3a2.2 2.2 0 0 1-2.2 2.2h-3a2.2 2.2 0 0 1-2.2-2.2v-3a2.2 2.2 0 0 1 2.2-2.2z m10.6 0h3a2.2 2.2 0 0 1 2.2 2.2v3a2.2 2.2 0 0 1-2.2 2.2h-3a2.2 2.2 0 0 1-2.2-2.2v-3a2.2 2.2 0 0 1 2.2-2.2z m-10.6 10.6h3a2.2 2.2 0 0 1 2.2 2.2v3a2.2 2.2 0 0 1-2.2 2.2h-3a2.2 2.2 0 0 1-2.2-2.2v-3a2.2 2.2 0 0 1 2.2-2.2z',
    bold: null,
  ),
  'scan-barcode': (
    solid: 'M7.15 7.5h0.8a0.7 0.7 0 0 1 0.7 0.7v7.6a0.7 0.7 0 0 1-0.7 0.7h-0.8a0.7 0.7 0 0 1-0.7-0.7v-7.6a0.7 0.7 0 0 1 0.7-0.7z m3.5 0h0a0.7 0.7 0 0 1 0.7 0.7v7.6a0.7 0.7 0 0 1-0.7 0.7h0a0.7 0.7 0 0 1-0.7-0.7v-7.6a0.7 0.7 0 0 1 0.7-0.7z m2.7 0h0.8a0.7 0.7 0 0 1 0.7 0.7v7.6a0.7 0.7 0 0 1-0.7 0.7h-0.8a0.7 0.7 0 0 1-0.7-0.7v-7.6a0.7 0.7 0 0 1 0.7-0.7z m3.5 0h0a0.7 0.7 0 0 1 0.7 0.7v7.6a0.7 0.7 0 0 1-0.7 0.7h0a0.7 0.7 0 0 1-0.7-0.7v-7.6a0.7 0.7 0 0 1 0.7-0.7z',
    line: 'M3 8v-1.5a3.5 3.5 0 0 1 3.5-3.5h1.5m8 0h1.5a3.5 3.5 0 0 1 3.5 3.5v1.5m0 8v1.5a3.5 3.5 0 0 1-3.5 3.5h-1.5m-8 0h-1.5a3.5 3.5 0 0 1-3.5-3.5v-1.5',
    bold: null,
  ),
  'scan-search': (
    solid: null,
    line: 'M3 8v-1.5a3.5 3.5 0 0 1 3.5-3.5h1.5m8 0h1.5a3.5 3.5 0 0 1 3.5 3.5v1.5m0 8v1.5a3.5 3.5 0 0 1-3.5 3.5h-1.5m-8 0h-1.5a3.5 3.5 0 0 1-3.5-3.5v-1.5m4.6-5a3.4 3.4 0 1 0 6.8 0 3.4 3.4 0 1 0-6.8 0z',
    bold: 'M14.4 14.4l2.4 2.4',
  ),
  'plus': (solid: null, line: 'M12 5v14m-7-7h14', bold: null),
  'minus': (solid: null, line: 'M5 12h14', bold: null),
  'x': (solid: null, line: 'M6.5 6.5l11 11m0-11l-11 11', bold: null),
  'check': (solid: null, line: 'M4.5 12.5l4.8 4.8 10.2-10.3', bold: null),
  'chevron-right': (solid: null, line: 'M9.5 6l6 6-6 6', bold: null),
  'chevron-down': (solid: null, line: 'M6 9.5l6 6 6-6', bold: null),
  'chevron-up': (solid: null, line: 'M6 14.5l6-6 6 6', bold: null),
  'chevrons-down-up': (
    solid: null,
    line: 'M7 4l5 5 5-5m-10 16l5-5 5 5',
    bold: null,
  ),
  'arrow-left': (solid: null, line: 'M19.5 14.2h-15l4.6-4.6', bold: null),
  'arrow-right': (solid: null, line: 'M4.5 14.2h15l-4.6-4.6', bold: null),
  'arrow-up-right': (solid: null, line: 'M6.5 17.5l11-11h-6', bold: null),
  'arrow-up-down': (
    solid: null,
    line: 'M8 20v-16l-3.8 3.8m11.8-3.8v16l3.8-3.8',
    bold: null,
  ),
  'corner-down-right': (
    solid: null,
    line: 'M4.5 4.5v6.5a4 4 0 0 0 4 4h11l-4.2 4.2',
    bold: null,
  ),
  'ellipsis': (
    solid: 'M3.6 12a1.9 1.9 0 1 0 3.8 0 1.9 1.9 0 1 0-3.8 0z m6.5 0a1.9 1.9 0 1 0 3.8 0 1.9 1.9 0 1 0-3.8 0z m6.5 0a1.9 1.9 0 1 0 3.8 0 1.9 1.9 0 1 0-3.8 0z',
    line: null,
    bold: null,
  ),
  'trash-2': (
    solid: 'M4.5 4.6h15a1.5 1.5 0 0 1 1.5 1.5v0a1.5 1.5 0 0 1-1.5 1.5h-15a1.5 1.5 0 0 1-1.5-1.5v0a1.5 1.5 0 0 1 1.5-1.5z',
    line: 'M9.5 4.6v-0.8a1.3 1.3 0 0 1 1.3-1.3h2.4a1.3 1.3 0 0 1 1.3 1.3v0.8m-8.9 5.6l0.8 9a2 2 0 0 0 2 1.8h7.2a2 2 0 0 0 2-1.8l0.8-9m-8.4 3.4v4m4-4v4',
    bold: null,
  ),
  'trash': (
    solid: 'M4.5 4.6h15a1.5 1.5 0 0 1 1.5 1.5v0a1.5 1.5 0 0 1-1.5 1.5h-15a1.5 1.5 0 0 1-1.5-1.5v0a1.5 1.5 0 0 1 1.5-1.5z',
    line: 'M9.5 4.6v-0.8a1.3 1.3 0 0 1 1.3-1.3h2.4a1.3 1.3 0 0 1 1.3 1.3v0.8m-8.9 5.6l0.8 9a2 2 0 0 0 2 1.8h7.2a2 2 0 0 0 2-1.8l0.8-9',
    bold: null,
  ),
  'pencil': (
    solid: 'M17.86 9.26l1.7-1.7-3.12-3.12-1.7 1.7z',
    line: 'M4 20l4.38-1.27 7.79-7.78-3.12-3.12-7.78 7.78z',
    bold: null,
  ),
  'pencil-ruler': (
    solid: 'M16.5 2.5h2a1 1 0 0 1 1 1v0.4a1 1 0 0 1-1 1h-2a1 1 0 0 1-1-1v-0.4a1 1 0 0 1 1-1z',
    line: 'M5.3 3h2.9a1.8 1.8 0 0 1 1.8 1.8v14.4a1.8 1.8 0 0 1-1.8 1.8h-2.9a1.8 1.8 0 0 1-1.8-1.8v-14.4a1.8 1.8 0 0 1 1.8-1.8z m-1.8 4.5h2.8m-2.8 4.5h2.8m-2.8 4.5h2.8m9.2-9.5v10l2 3.5 2-3.5v-10z',
    bold: null,
  ),
  'move': (
    solid: 'M10 12a2 2 0 1 0 4 0 2 2 0 1 0-4 0z',
    line: 'M12 3v5m0 8v5m-9-9h5m8 0h5m-11.5-6.5l2.5-2.5 2.5 2.5m-5 13l2.5 2.5 2.5-2.5m-9-9l-2.5 2.5 2.5 2.5m13-5l2.5 2.5-2.5 2.5',
    bold: null,
  ),
  'history': (
    solid: null,
    line: 'M3.5 12a8.5 8.5 0 1 0 8.5-8.5 9.2 9.2 0 0 0-6.4 2.6l-2.1 2.1m0-4.7v4.7h4.7m3.8-0.4v4.2l3 1.8',
    bold: null,
  ),
  'rotate-cw': (
    solid: null,
    line: 'M20.5 12a8.5 8.5 0 1 1-8.5-8.5 9.2 9.2 0 0 1 6.4 2.6l2.1 2.1m0-4.7v4.7h-4.7',
    bold: null,
  ),
  'rotate-ccw': (
    solid: null,
    line: 'M3.5 12a8.5 8.5 0 1 0 8.5-8.5 9.2 9.2 0 0 0-6.4 2.6l-2.1 2.1m0-4.7v4.7h4.7',
    bold: null,
  ),
  'refresh-cw': (
    solid: null,
    line: 'M3.5 12a8.5 8.5 0 0 1 8.5-8.5 9.2 9.2 0 0 1 6.4 2.6l2.1 2.1m0-4.7v4.7h-4.7m4.7 3.8a8.5 8.5 0 0 1-8.5 8.5 9.2 9.2 0 0 1-6.4-2.6l-2.1-2.1m0 4.7v-4.7h4.7',
    bold: null,
  ),
  'undo-2': (
    solid: null,
    line: 'M8.5 4.5l-4.5 4.5h10.5a5.5 5.5 0 0 1 0 11h-3.5',
    bold: null,
  ),
  'copy': (
    solid: null,
    line: 'M11.3 8.5h6.9a2.8 2.8 0 0 1 2.8 2.8v6.9a2.8 2.8 0 0 1-2.8 2.8h-6.9a2.8 2.8 0 0 1-2.8-2.8v-6.9a2.8 2.8 0 0 1 2.8-2.8z m-5.5 7h-0.8a2 2 0 0 1-2-2v-8.5a2 2 0 0 1 2-2h8.5a2 2 0 0 1 2 2v0.8',
    bold: null,
  ),
  'share': (
    solid: null,
    line: 'M4 12.5v5.5a2.5 2.5 0 0 0 2.5 2.5h11a2.5 2.5 0 0 0 2.5-2.5v-5.5m-8 2.5v-11.5m-4.5 4.5l4.5-4.5 4.5 4.5',
    bold: null,
  ),
  'share-2': (
    solid: 'M15.2 5.2a2.8 2.8 0 1 0 5.6 0 2.8 2.8 0 1 0-5.6 0z m-12 6.8a2.8 2.8 0 1 0 5.6 0 2.8 2.8 0 1 0-5.6 0z m12 6.8a2.8 2.8 0 1 0 5.6 0 2.8 2.8 0 1 0-5.6 0z',
    line: 'M10.5 9.45l3-1.7m-3 6.8l3 1.7',
    bold: null,
  ),
  'printer': (
    solid: 'M8.5 13.5h7a1.5 1.5 0 0 1 1.5 1.5v4.5a1.5 1.5 0 0 1-1.5 1.5h-7a1.5 1.5 0 0 1-1.5-1.5v-4.5a1.5 1.5 0 0 1 1.5-1.5z',
    line: 'M7 9.5v-5a1.5 1.5 0 0 1 1.5-1.5h7a1.5 1.5 0 0 1 1.5 1.5v5m-12.5 7.9a2 2 0 0 1-1.5-1.9v-4a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v4a2 2 0 0 1-1.5 1.9',
    bold: null,
  ),
  'file-down': (
    solid: 'M14 3.6v3.2a1.4 1.4 0 0 0 1.4 1.4h3.2z',
    line: 'M14 3h-6.5a2.5 2.5 0 0 0-2.5 2.5v13a2.5 2.5 0 0 0 2.5 2.5h9a2.5 2.5 0 0 0 2.5-2.5v-10.5z m-2 8v6.2m-2.8-2.6l2.8 2.8 2.8-2.8',
    bold: null,
  ),
  'camera': (
    solid: 'M8.6 13.3a3.4 3.4 0 1 0 6.8 0 3.4 3.4 0 1 0-6.8 0z',
    line: 'M3 9a2.5 2.5 0 0 1 2.5-2.5h1.8l1.4-2.1a2 2 0 0 1 1.7-0.9h3.2a2 2 0 0 1 1.7 0.9l1.4 2.1h1.8a2.5 2.5 0 0 1 2.5 2.5v9a2.5 2.5 0 0 1-2.5 2.5h-13a2.5 2.5 0 0 1-2.5-2.5z',
    bold: null,
  ),
  'image': (
    solid: 'M5.8 18.2l4.4-5.6 3.5 3.6 1.9-1.9 2.6 2.8 0 1.1z',
    line: 'M7 3h10a4 4 0 0 1 4 4v10a4 4 0 0 1-4 4h-10a4 4 0 0 1-4-4v-10a4 4 0 0 1 4-4z m7 5.4a1.6 1.6 0 1 0 3.2 0 1.6 1.6 0 1 0-3.2 0z',
    bold: null,
  ),
  'images': (
    solid: 'M5.6 18.4l3.4-4.6 2.6 2.6 1.3-1.2 1.5 1.6 0 1.6z',
    line: 'M6.5 7h7a3.5 3.5 0 0 1 3.5 3.5v7a3.5 3.5 0 0 1-3.5 3.5h-7a3.5 3.5 0 0 1-3.5-3.5v-7a3.5 3.5 0 0 1 3.5-3.5z m0.5-3.5h10.5a3.5 3.5 0 0 1 3.5 3.5v10.5',
    bold: null,
  ),
  'link': (
    solid: null,
    line: 'M10 14a4 4 0 0 0 5.7 0l3.1-3.1a4 4 0 0 0-5.7-5.7l-1 1m1.9 3.8a4 4 0 0 0-5.7 0l-3.1 3.1a4 4 0 0 0 5.7 5.7l1-1',
    bold: null,
  ),
  'clipboard-paste': (
    solid: 'M10.3 2.5h3.4a1.3 1.3 0 0 1 1.3 1.3v1.4a1.3 1.3 0 0 1-1.3 1.3h-3.4a1.3 1.3 0 0 1-1.3-1.3v-1.4a1.3 1.3 0 0 1 1.3-1.3z',
    line: 'M6.5 4.5a2.5 2.5 0 0 0-2.5 2.5v11.5a2.5 2.5 0 0 0 2.5 2.5h11a2.5 2.5 0 0 0 2.5-2.5v-11.5a2.5 2.5 0 0 0-2.5-2.5m-9 7h7m-7 4h4.5',
    bold: null,
  ),
  'eye': (
    solid: 'M8.8 12a3.2 3.2 0 1 0 6.4 0 3.2 3.2 0 1 0-6.4 0z',
    line: 'M2.5 12c1.8-4.3 5.3-7 9.5-7s7.7 2.7 9.5 7c-1.8 4.3-5.3 7-9.5 7s-7.7-2.7-9.5-7z',
    bold: null,
  ),
  'lock': (
    solid: 'M12 13.6h0a1 1 0 0 1 1 1v2a1 1 0 0 1-1 1h0a1 1 0 0 1-1-1v-2a1 1 0 0 1 1-1z',
    line: 'M7 10h10a3 3 0 0 1 3 3v5a3 3 0 0 1-3 3h-10a3 3 0 0 1-3-3v-5a3 3 0 0 1 3-3z m0.5-2.1v-0.4a4.5 4.5 0 0 1 9 0v0.4',
    bold: null,
  ),
  'mail': (
    solid: 'M6.6 8.2h10.8a0.6 0.6 0 0 1 0.35 1.1l-5.2 3.8a1 1 0 0 1-1.1 0l-5.2-3.8a0.6 0.6 0 0 1 0.35-1.1z',
    line: 'M6 5h12a3 3 0 0 1 3 3v8a3 3 0 0 1-3 3h-12a3 3 0 0 1-3-3v-8a3 3 0 0 1 3-3z',
    bold: null,
  ),
  'phone': (
    solid: 'M14.15 8.6a1.25 1.25 0 1 0 2.5 0 1.25 1.25 0 1 0-2.5 0z',
    line: 'M6.5 3.5h2c0.6 0 1.1 0.4 1.3 0.9l1 2.7c0.2 0.6 0 1.2-0.5 1.6l-1.2 1.1a11.5 11.5 0 0 0 5.1 5.1l1.1-1.2c0.4-0.5 1-0.7 1.6-0.5l2.7 1c0.5 0.2 0.9 0.7 0.9 1.3v2c0 1-0.8 1.8-1.8 1.8-8.5 0-14-5.5-14-14 0-1 0.8-1.8 1.8-1.8z m8 0a6 6 0 0 1 6 6',
    bold: null,
  ),
  'map-pin': (
    solid: 'M9.4 10a2.6 2.6 0 1 0 5.2 0 2.6 2.6 0 1 0-5.2 0z',
    line: 'M12 2.8a7.2 7.2 0 0 0-7.2 7.2c0 4.8 5.2 9.6 6.4 10.6a1.2 1.2 0 0 0 1.6 0c1.2-1 6.4-5.8 6.4-10.6a7.2 7.2 0 0 0-7.2-7.2z',
    bold: null,
  ),
  'calendar': (
    solid: 'M8.1 13h1.6a1.1 1.1 0 0 1 1.1 1.1v1.6a1.1 1.1 0 0 1-1.1 1.1h-1.6a1.1 1.1 0 0 1-1.1-1.1v-1.6a1.1 1.1 0 0 1 1.1-1.1z',
    line: 'M6.5 4.5h11a3.5 3.5 0 0 1 3.5 3.5v9.5a3.5 3.5 0 0 1-3.5 3.5h-11a3.5 3.5 0 0 1-3.5-3.5v-9.5a3.5 3.5 0 0 1 3.5-3.5z m-3 5.5h17m-12.5-7.5v4m8-4v4',
    bold: null,
  ),
  'calendar-x': (
    solid: null,
    line: 'M6.5 4.5h11a3.5 3.5 0 0 1 3.5 3.5v9.5a3.5 3.5 0 0 1-3.5 3.5h-11a3.5 3.5 0 0 1-3.5-3.5v-9.5a3.5 3.5 0 0 1 3.5-3.5z m-3 5.5h17m-12.5-7.5v4m8-4v4m-6 7.1l4 4m0-4l-4 4',
    bold: null,
  ),
  'calendar-clock': (
    solid: 'M7.4 13h1.2a0.9 0.9 0 0 1 0.9 0.9v1.2a0.9 0.9 0 0 1-0.9 0.9h-1.2a0.9 0.9 0 0 1-0.9-0.9v-1.2a0.9 0.9 0 0 1 0.9-0.9z',
    line: 'M21 9.6v-1.6a3.5 3.5 0 0 0-3.5-3.5h-11a3.5 3.5 0 0 0-3.5 3.5v9.5a3.5 3.5 0 0 0 3.5 3.5h3.5m-2-18.5v4m8-4v4m-12.5 3.5h5.5m3.7 7a4.3 4.3 0 1 0 8.6 0 4.3 4.3 0 1 0-8.6 0z m4.3-2v2l1.4 1',
    bold: null,
  ),
  'hourglass': (
    solid: 'M9.3 18.8c0-1.4 0.9-2.4 2.7-3.2 1.8 0.8 2.7 1.8 2.7 3.2z',
    line: 'M6 3h12m-12 18h12m-11-18v3.2a4 4 0 0 0 1.6 3.2l3.4 2.6 3.4-2.6a4 4 0 0 0 1.6-3.2v-3.2m-10 18v-3.2a4 4 0 0 1 1.6-3.2l3.4-2.6 3.4 2.6a4 4 0 0 1 1.6 3.2v3.2',
    bold: null,
  ),
  'clock-alert': (
    solid: 'M19.55 12.8h0a0.95 0.95 0 0 1 0.95 0.95v2.9a0.95 0.95 0 0 1-0.95 0.95h0a0.95 0.95 0 0 1-0.95-0.95v-2.9a0.95 0.95 0 0 1 0.95-0.95z m-1.1 7.4a1.1 1.1 0 1 0 2.2 0 1.1 1.1 0 1 0-2.2 0z',
    line: 'M19.31 10.23a8.5 8.5 0 1 0-6.83 10.14m-1.48-12.77v4.4l2.8 1.8',
    bold: null,
  ),
  'triangle-alert': (
    solid: 'M10.75 16.1a1.25 1.25 0 1 0 2.5 0 1.25 1.25 0 1 0-2.5 0z',
    line: 'M10.3 4.3c0.8-1.3 2.6-1.3 3.4 0l7.1 12.3c0.8 1.3-0.2 2.9-1.7 2.9h-14.2c-1.5 0-2.5-1.6-1.7-2.9z m1.7 5.2v3.6',
    bold: null,
  ),
  'circle-alert': (
    solid: 'M10.65 16.3a1.35 1.35 0 1 0 2.7 0 1.35 1.35 0 1 0-2.7 0z',
    line: 'M3 12a9 9 0 1 0 18 0 9 9 0 1 0-18 0z m9-4.4v5',
    bold: null,
  ),
  'circle-check': (
    solid: 'M7.15 13.15l3.57 3.56 6.14-6.38 0 0 0.26-0.39 0.08-0.46-0.1-0.46-0.27-0.38-0.39-0.26-0.46-0.08-0.46 0.1-0.38 0.27 0 0-4.46 4.62-1.83-1.84 0 0-0.39-0.26-0.46-0.09-0.46 0.09-0.39 0.26-0.26 0.39-0.09 0.46 0.09 0.46 0.26 0.39z',
    line: 'M3 12a9 9 0 1 0 18 0 9 9 0 1 0-18 0z',
    bold: null,
  ),
  'circle-help': (
    solid: 'M10.7 16.9a1.3 1.3 0 1 0 2.6 0 1.3 1.3 0 1 0-2.6 0z',
    line: 'M3 12a9 9 0 1 0 18 0 9 9 0 1 0-18 0z m6.4-2.6a2.6 2.6 0 1 1 3.6 2.4c-0.6 0.3-1 0.8-1 1.5v0.3',
    bold: null,
  ),
  'info': (
    solid: 'M10.65 7.7a1.35 1.35 0 1 0 2.7 0 1.35 1.35 0 1 0-2.7 0z',
    line: 'M3 12a9 9 0 1 0 18 0 9 9 0 1 0-18 0z m9-1v5.4',
    bold: null,
  ),
  'cloud-off': (
    solid: null,
    line: 'M14.07 19l-0.15 0-0.15 0-0.15 0-0.15 0-0.15 0-0.15 0-0.15 0-0.15 0-0.15 0-0.15 0-0.15 0-0.15 0-0.14 0-0.15 0-0.15 0-0.15 0-0.15 0-0.15 0-0.15 0-0.15 0-0.15 0-0.15 0-0.15 0-0.15 0-0.15 0-0.14 0-0.15 0-0.15 0-0.15 0-0.15 0-0.15 0-0.15 0-0.15 0-0.15 0-0.15 0-0.15 0-0.15 0-0.15 0-0.15 0-0.14 0-0.15 0-0.15 0-0.15 0-0.15 0-0.15 0-0.15 0-0.14-0.01-0.15-0.01-0.14-0.01-0.14-0.01-0.14-0.03-0.14-0.03-0.14-0.03-0.14-0.03-0.14-0.04-0.13-0.05-0.14-0.05-0.13-0.05-0.13-0.06-0.13-0.07-0.12-0.06-0.13-0.07-0.12-0.08-0.11-0.09-0.12-0.08-0.12-0.08-0.1-0.1-0.11-0.1-0.1-0.09-0.11-0.1-0.09-0.11-0.09-0.11-0.09-0.11-0.09-0.12-0.07-0.12-0.08-0.12-0.07-0.12-0.08-0.12-0.05-0.14-0.06-0.13-0.06-0.13-0.06-0.13-0.03-0.14-0.04-0.13-0.04-0.14-0.04-0.14-0.02-0.14-0.02-0.14-0.02-0.15-0.02-0.14 0-0.14 0-0.14 0-0.15 0-0.14 0.02-0.14 0.02-0.14 0.02-0.15 0.02-0.14 0.03-0.14 0.04-0.13 0.04-0.14 0.04-0.14 0.06-0.13 0.05-0.13 0.06-0.13 0.06-0.14 0.07-0.12 0.08-0.12 0.07-0.12 0.07-0.13 0.09-0.11 0.09-0.11 0.09-0.11 0.09-0.11 0.11-0.1 0.1-0.1 0.11-0.09 0.1-0.1 0.12-0.09 0.12-0.08 0.11-0.08 0.12-0.08 0.13-0.07 0.12-0.07 0.13-0.06 0.13-0.07 0.13-0.05 0.14-0.04 0.13-0.05m4.02-5.72l0.11-0.05 0.12-0.05 0.12-0.04 0.11-0.05 0.12-0.04 0.12-0.03 0.12-0.03 0.13-0.03 0.12-0.03 0.12-0.03 0.12-0.03 0.13-0.01 0.12-0.01 0.13-0.02 0.12-0.01 0.13-0.01 0.12-0.02 0.13 0.01 0.12 0 0.13 0.01 0.12 0 0.13 0 0.12 0.01 0.13 0.02 0.12 0.02 0.12 0.02 0.13 0.02 0.12 0.02 0.12 0.02 0.12 0.04 0.12 0.04 0.12 0.03 0.12 0.04 0.12 0.04 0.12 0.03 0.12 0.06 0.11 0.05 0.11 0.05 0.12 0.06 0.11 0.05 0.12 0.05 0.1 0.07 0.11 0.07 0.1 0.06 0.11 0.07 0.1 0.07 0.11 0.07 0.1 0.08 0.09 0.08 0.1 0.08 0.09 0.08 0.1 0.08 0.09 0.08 0.09 0.1 0.08 0.09 0.08 0.09 0.09 0.1 0.08 0.09 0.09 0.09 0.07 0.11 0.07 0.1 0.07 0.11 0.07 0.1 0.07 0.1 0.07 0.11 0.06 0.11 0.05 0.11 0.06 0.11 0.05 0.11 0.06 0.12 0.06 0.11 0.04 0.12 0.04 0.12 0.04 0.12 0.04 0.11 0.04 0.12 0.04 0.12 0.02 0.12 0.03 0.13 0.02 0.12 0.03 0.12 0.02 0.13 0.02 0.12 0.01 0.13 0.01 0.12 0.01 0.13 0 0.12 0.01 0.13 0.01 0.12 0 0 0.12 0.03 0.12 0.02 0.11 0.02 0.12 0.03 0.12 0.02 0.11 0.04 0.11 0.04 0.12 0.04 0.11 0.04 0.11 0.04 0.11 0.06 0.11 0.06 0.1 0.05 0.11 0.06 0.11 0.05 0.09 0.07 0.1 0.07 0.1 0.07 0.1 0.07 0.1 0.07 0.09 0.08 0.08 0.08 0.09 0.08 0.09 0.09 0.09 0.08 0.07 0.09 0.08 0.09 0.07 0.1 0.08 0.09 0.07 0.09 0.07 0.11 0.06 0.1 0.06 0.1 0.06 0.1 0.07 0.11 0.04 0.11 0.05 0.11 0.05 0.11 0.05 0.11 0.05 0.11 0.03 0.11 0.03 0.12 0.03 0.11 0.04 0.12 0.03 0.12 0.01 0.11 0.02 0.12 0.02 0.12 0.01 0.12 0.02 0.12 0 0.12 0 0.12 0 0.12 0 0.12 0 0.12-0.02 0.12-0.01 0.12-0.02 0.12-0.02 0.12-0.01 0.12-0.03 0.11-0.04 0.12-0.03 0.11-0.03 0.12-0.03 0.11-0.05 0.11-0.05 0.11m-17.75-12.79l17 17',
    bold: null,
  ),
  'cloud-alert': (
    solid: 'M10.75 15.7a1.25 1.25 0 1 0 2.5 0 1.25 1.25 0 1 0-2.5 0z',
    line: 'M7.2 19l-0.57-0.04-0.56-0.12-0.54-0.19-0.51-0.26-0.47-0.33-0.42-0.39-0.36-0.45-0.3-0.48-0.23-0.53-0.15-0.55-0.08-0.57 0-0.57 0.08-0.57 0.15-0.55 0.23-0.53 0.29-0.49 0.36-0.44 0.42-0.39 0.47-0.33 0.51-0.27 0.54-0.19 0.56-0.12 0 0-0.01-0.75 0.09-0.75 0.19-0.73 0.29-0.69 0.38-0.65 0.46-0.6 0.54-0.52 0.6-0.45 0.66-0.37 0.7-0.27 0.73-0.18 0.75-0.08 0.75 0.03 0.74 0.12 0.72 0.22 0.69 0.32 0.63 0.41 0.57 0.48 0.51 0.56 0.42 0.63 0.34 0.67 0.24 0.71 0.14 0.74 0.05 0.75 0 0 0.59 0.12 0.56 0.2 0.54 0.28 0.49 0.35 0.44 0.41 0.37 0.46 0.32 0.52 0.24 0.55 0.16 0.58 0.08 0.59 0 0.6-0.08 0.6-0.16 0.57-0.24 0.55-0.32 0.52-0.37 0.46-0.44 0.41-0.49 0.35-0.54 0.28-0.56 0.2-0.59 0.12-0.6 0.04z m4.8-9.8v3.4',
    bold: null,
  ),
  'server-crash': (
    solid: 'M5.8 6.5a1.2 1.2 0 1 0 2.4 0 1.2 1.2 0 1 0-2.4 0z',
    line: 'M5.2 3h13.6a2.2 2.2 0 0 1 2.2 2.2v2.6a2.2 2.2 0 0 1-2.2 2.2h-13.6a2.2 2.2 0 0 1-2.2-2.2v-2.6a2.2 2.2 0 0 1 2.2-2.2z m2.3 17.5h-2a2.5 2.5 0 0 1-2.5-2.5v-2.5a2.5 2.5 0 0 1 2.5-2.5h2m9.7 0h1.3a2.5 2.5 0 0 1 2.5 2.5v2.5a2.5 2.5 0 0 1-2.5 2.5h-1.3m-4-8.5l-2.6 4h3.6l-2.6 4.5',
    bold: null,
  ),
  'loader-circle': (solid: null, line: 'M21 12a9 9 0 1 1-6.2-8.56', bold: null),
  'shield': (
    solid: 'M12 8l3 1.1v2.2c0 1.9-1.3 3.4-3 4.1-1.7-0.7-3-2.2-3-4.1v-2.2z',
    line: 'M12 2.8l7.2 2.7a1 1 0 0 1 0.6 0.9v5.2c0 4.4-3.1 8.2-7.8 10-4.7-1.8-7.8-5.6-7.8-10v-5.2a1 1 0 0 1 0.6-0.9z',
    bold: null,
  ),
  'shield-check': (
    solid: 'M7.95 12.95l3.05 3.05 5.15-5.15 0 0 0.26-0.39 0.09-0.46-0.09-0.46-0.26-0.39-0.39-0.26-0.46-0.09-0.46 0.09-0.39 0.26 0 0-3.45 3.45-1.35-1.35 0 0-0.39-0.26-0.46-0.09-0.46 0.09-0.39 0.26-0.26 0.39-0.09 0.46 0.09 0.46 0.26 0.39z',
    line: 'M12 2.8l7.2 2.7a1 1 0 0 1 0.6 0.9v5.2c0 4.4-3.1 8.2-7.8 10-4.7-1.8-7.8-5.6-7.8-10v-5.2a1 1 0 0 1 0.6-0.9z',
    bold: null,
  ),
  'shield-alert': (
    solid: 'M10.7 15.4a1.3 1.3 0 1 0 2.6 0 1.3 1.3 0 1 0-2.6 0z',
    line: 'M12 2.8l7.2 2.7a1 1 0 0 1 0.6 0.9v5.2c0 4.4-3.1 8.2-7.8 10-4.7-1.8-7.8-5.6-7.8-10v-5.2a1 1 0 0 1 0.6-0.9z m0 4.8v4.4',
    bold: null,
  ),
  'handshake': (
    solid: 'M10.6 3.2h4a1.8 1.8 0 0 1 1.8 1.8v3.4a1.8 1.8 0 0 1-1.8 1.8h-4a1.8 1.8 0 0 1-1.8-1.8v-3.4a1.8 1.8 0 0 1 1.8-1.8z',
    line: 'M3 15h3.2l3.4-1.5h4.1c0.8 0 1.5 0.7 1.5 1.5s-0.7 1.5-1.5 1.5h-3.4m4.3-0.5l4.4-2.2c0.8-0.4 1.7 0 2 0.8 0.2 0.6 0 1.3-0.6 1.7l-6.4 4.2h-5.7l-2.1-1.5h-3.2',
    bold: null,
  ),
  'hand': (
    solid: null,
    line: 'M8 13.5v-6.5a1.5 1.5 0 0 1 3 0v4.5m0-0.5v-5.5a1.5 1.5 0 0 1 3 0v5.5m0 0.5v-4.5a1.5 1.5 0 0 1 3 0v7a7 7 0 0 1-7 7h-0.6a6 6 0 0 1-4.6-2.2l-2.4-2.9a1.6 1.6 0 0 1 2.4-2.1l3.2 1.8',
    bold: null,
  ),
  'headphones': (
    solid: 'M5 14.2h1a2 2 0 0 1 2 2v2.8a2 2 0 0 1-2 2h-1a2 2 0 0 1-2-2v-2.8a2 2 0 0 1 2-2z m13 0h1a2 2 0 0 1 2 2v2.8a2 2 0 0 1-2 2h-1a2 2 0 0 1-2-2v-2.8a2 2 0 0 1 2-2z',
    line: 'M4 15v-3a8 8 0 0 1 16 0v3',
    bold: null,
  ),
  'battery': (
    solid: 'M6.6 10.1h4.2a1 1 0 0 1 1 1v1.8a1 1 0 0 1-1 1h-4.2a1 1 0 0 1-1-1v-1.8a1 1 0 0 1 1-1z',
    line: 'M5.5 7h10a3 3 0 0 1 3 3v4a3 3 0 0 1-3 3h-10a3 3 0 0 1-3-3v-4a3 3 0 0 1 3-3z m16 3.5v3',
    bold: null,
  ),
  'battery-charging': (
    solid: 'M11.6 9.2l-3.6 3.4 2.6 0-1 2.2 3.8-3.4-2.6 0z',
    line: 'M5.5 7h10a3 3 0 0 1 3 3v4a3 3 0 0 1-3 3h-10a3 3 0 0 1-3-3v-4a3 3 0 0 1 3-3z m16 3.5v3',
    bold: null,
  ),
  'pill': (
    solid: 'M15.18 11.84l3.13-3.13 0 0 0.47-0.69 0.16-0.82-0.16-0.82-0.47-0.69-0.69-0.47-0.82-0.16-0.82 0.16-0.69 0.47 0 0-3.13 3.13z',
    line: 'M10.38 19.98l9.6-9.6 0 0 0.98-1.46 0.34-1.72-0.34-1.72-0.98-1.46-1.46-0.98-1.72-0.34-1.72 0.34-1.46 0.98 0 0-9.6 9.6 0 0-0.98 1.46-0.34 1.72 0.34 1.72 0.98 1.46 1.46 0.98 1.72 0.34 1.72-0.34 1.46-0.98z m-1.56-11.16l6.36 6.36',
    bold: null,
  ),
  'plug': (
    solid: null,
    line: 'M6.5 7h11v3.5a5.5 5.5 0 0 1-11 0z m2.5-4v4m6-4v4m-3 9v5',
    bold: null,
  ),
  'cable': (
    solid: 'M10 7h4a2 2 0 0 1 2 2v3.5a2 2 0 0 1-2 2h-4a2 2 0 0 1-2-2v-3.5a2 2 0 0 1 2-2z',
    line: 'M10 3.5v3.5m4-3.5v3.5m-2 7.5v2a4 4 0 0 0 4 4h4',
    bold: null,
  ),
  'laptop': (
    solid: null,
    line: 'M7 4.5h10a2.5 2.5 0 0 1 2.5 2.5v5.5a2.5 2.5 0 0 1-2.5 2.5h-10a2.5 2.5 0 0 1-2.5-2.5v-5.5a2.5 2.5 0 0 1 2.5-2.5z m-4.5 14.5h19',
    bold: null,
  ),
  'monitor': (
    solid: null,
    line: 'M6 4h12a3 3 0 0 1 3 3v6.5a3 3 0 0 1-3 3h-12a3 3 0 0 1-3-3v-6.5a3 3 0 0 1 3-3z m3 16.5h6m-3-4v4',
    bold: null,
  ),
  'tablet': (
    solid: 'M11.35 17.4h1.3a0.85 0.85 0 0 1 0.85 0.85v0a0.85 0.85 0 0 1-0.85 0.85h-1.3a0.85 0.85 0 0 1-0.85-0.85v0a0.85 0.85 0 0 1 0.85-0.85z',
    line: 'M8.5 2.5h7a3.5 3.5 0 0 1 3.5 3.5v12a3.5 3.5 0 0 1-3.5 3.5h-7a3.5 3.5 0 0 1-3.5-3.5v-12a3.5 3.5 0 0 1 3.5-3.5z',
    bold: null,
  ),
  'gamepad-2': (
    solid: 'M14 10.6a1 1 0 1 0 2 0 1 1 0 1 0-2 0z m2.4 2.4a1 1 0 1 0 2 0 1 1 0 1 0-2 0z',
    line: 'M7.5 7h9a5 5 0 0 1 4.9 5.9l-0.6 3.5a2.6 2.6 0 0 1-4.4 1.4l-1.8-1.8h-5.2l-1.8 1.8a2.6 2.6 0 0 1-4.4-1.4l-0.6-3.5a5 5 0 0 1 4.9-5.9z m0.5 3v3m-1.5-1.5h3',
    bold: null,
  ),
  'drill': (
    solid: 'M19.05 8.9h1.6a0.85 0.85 0 0 1 0.85 0.85v0a0.85 0.85 0 0 1-0.85 0.85h-1.6a0.85 0.85 0 0 1-0.85-0.85v0a0.85 0.85 0 0 1 0.85-0.85z',
    line: 'M4 6.5h10.5a2 2 0 0 1 2 2v2.5a2 2 0 0 1-2 2h-10.5z m2.5 8.7l0.8 5.3h3.5l-0.6-5.3',
    bold: null,
  ),
  'wrench': (
    solid: null,
    line: 'M14.8 4.2a4.6 4.6 0 0 0-4.4 6l-6 6a2 2 0 0 0 2.8 2.8l6-6a4.6 4.6 0 0 0 6-4.4l-2.7 1.1-2.7-2.7z',
    bold: null,
  ),
  'cpu': (
    solid: 'M10.8 9.6h2.4a1.2 1.2 0 0 1 1.2 1.2v2.4a1.2 1.2 0 0 1-1.2 1.2h-2.4a1.2 1.2 0 0 1-1.2-1.2v-2.4a1.2 1.2 0 0 1 1.2-1.2z',
    line: 'M9 6h6a3 3 0 0 1 3 3v6a3 3 0 0 1-3 3h-6a3 3 0 0 1-3-3v-6a3 3 0 0 1 3-3z m0.5-3v3m5-3v3m-5 12v3m5-3v3m-11.5-11.5h3m-3 5h3m12-5h3m-3 5h3',
    bold: null,
  ),
  'shirt': (
    solid: 'M13.2 11.2h1.4a0.8 0.8 0 0 1 0.8 0.8v1.2a0.8 0.8 0 0 1-0.8 0.8h-1.4a0.8 0.8 0 0 1-0.8-0.8v-1.2a0.8 0.8 0 0 1 0.8-0.8z',
    line: 'M8 3.5l-4.5 2.7 1.6 3.9 2-0.8v9.7a1.5 1.5 0 0 0 1.5 1.5h6.8a1.5 1.5 0 0 0 1.5-1.5v-9.7l2 0.8 1.6-3.9-4.5-2.7c-0.6 1.5-2.2 2.5-4 2.5s-3.4-1-4-2.5z',
    bold: null,
  ),
  'utensils': (
    solid: 'M17 3.2v9.8h-4v-3.3c0-3.6 1.8-6.1 4-6.5z',
    line: 'M6 3v6.5a2 2 0 0 0 4 0v-6.5m-2 8.5v9.5m9-5.5v5.5',
    bold: null,
  ),
  'cooking-pot': (
    solid: 'M11.5 3.6h1a0.9 0.9 0 0 1 0.9 0.9v0a0.9 0.9 0 0 1-0.9 0.9h-1a0.9 0.9 0 0 1-0.9-0.9v0a0.9 0.9 0 0 1 0.9-0.9z',
    line: 'M4 10.5h16v5.5a4 4 0 0 1-4 4h-8a4 4 0 0 1-4-4z m-2 0h2m16 0h2m-15-2.7h10',
    bold: null,
  ),
  'book-open': (
    solid: 'M15.4 5.7h2.6v4.8l-1.3-1-1.3 1z',
    line: 'M12 6.8c-1.6-1.4-4-2.1-8-2.1v13.8c4 0 6.4 0.7 8 2.1 1.6-1.4 4-2.1 8-2.1v-13.8c-4 0-6.4 0.7-8 2.1z m0 0v13.8',
    bold: null,
  ),
  'sparkles': (
    solid: 'M18.5 2.6l0.7 1.7 1.7 0.7-1.7 0.7-0.7 1.7-0.7-1.7-1.7-0.7 1.7-0.7z',
    line: 'M11 4l1.5 4c0.3 0.9 1 1.6 1.9 1.9l4 1.5-4 1.5c-0.9 0.3-1.6 1-1.9 1.9l-1.5 4.2-1.5-4.2c-0.3-0.9-1-1.6-1.9-1.9l-4.1-1.5 4.1-1.5c0.9-0.3 1.6-1 1.9-1.9z',
    bold: null,
  ),
  'sofa': (
    solid: 'M7.7 4h8.6a2.2 2.2 0 0 1 2.2 2.2v1.4a2.2 2.2 0 0 1-2.2 2.2h-8.6a2.2 2.2 0 0 1-2.2-2.2v-1.4a2.2 2.2 0 0 1 2.2-2.2z',
    line: 'M3 14a2 2 0 0 1 4 0v1h10v-1a2 2 0 0 1 4 0v3.5a2 2 0 0 1-2 2h-14a2 2 0 0 1-2-2z m2.5 5.5v1.5m13-1.5v1.5',
    bold: null,
  ),
  'armchair': (
    solid: 'M9.2 4h5.6a2.2 2.2 0 0 1 2.2 2.2v1.4a2.2 2.2 0 0 1-2.2 2.2h-5.6a2.2 2.2 0 0 1-2.2-2.2v-1.4a2.2 2.2 0 0 1 2.2-2.2z',
    line: 'M4 14a2 2 0 0 1 4 0v1h8v-1a2 2 0 0 1 4 0v3.5a2 2 0 0 1-2 2h-12a2 2 0 0 1-2-2z m2.5 5.5v1.5m11-1.5v1.5',
    bold: null,
  ),
  'bed-double': (
    solid: 'M7.7 7.2h3.1a1.2 1.2 0 0 1 1.2 1.2v0.5a1.2 1.2 0 0 1-1.2 1.2h-3.1a1.2 1.2 0 0 1-1.2-1.2v-0.5a1.2 1.2 0 0 1 1.2-1.2z',
    line: 'M3 19.5v-13.5m0 6.5h15a3 3 0 0 1 3 3v4m-18-3h18',
    bold: null,
  ),
  'bath': (
    solid: 'M10.2 8a1.1 1.1 0 1 0 2.2 0 1.1 1.1 0 1 0-2.2 0z',
    line: 'M3 12h18v2.5a5 5 0 0 1-5 5h-8a5 5 0 0 1-5-5z m3-2.2v-3.8a2.5 2.5 0 0 1 4.7-1.2m-3.2 16.4l0.5-0.8m8.5 0.8l-0.5-0.8',
    bold: null,
  ),
  'car': (
    solid: 'M5.8 15.8a1 1 0 1 0 2 0 1 1 0 1 0-2 0z m10.4 0a1 1 0 1 0 2 0 1 1 0 1 0-2 0z',
    line: 'M5 11l1.6-4.1c0.4-1.1 1.4-1.9 2.6-1.9h5.6c1.2 0 2.2 0.8 2.6 1.9l1.6 4.1m-14.5 1.8h15a1.5 1.5 0 0 1 1.5 1.5v4.5h-18v-4.5a1.5 1.5 0 0 1 1.5-1.5z m1 7.2v1m13-1v1',
    bold: null,
  ),
  'milk': (
    solid: 'M10 12h4a1 1 0 0 1 1 1v3.5a1 1 0 0 1-1 1h-4a1 1 0 0 1-1-1v-3.5a1 1 0 0 1 1-1z',
    line: 'M8 3h8m-7.5 0v2.3l-2 3.3v10.9a1.5 1.5 0 0 0 1.5 1.5h8a1.5 1.5 0 0 0 1.5-1.5v-10.9l-2-3.3v-2.3',
    bold: null,
  ),
  'sun': (
    solid: 'M7.8 12a4.2 4.2 0 1 0 8.4 0 4.2 4.2 0 1 0-8.4 0z',
    line: 'M12 2.5v2m0 15v2m-9.5-9.5h2m15 0h2m-16.2-6.7l1.4 1.4m10.6 10.6l1.4 1.4m-13.4 0l1.4-1.4m10.6-10.6l1.4-1.4',
    bold: null,
  ),
  'wind': (
    solid: null,
    line: 'M3 9h10.5a2.5 2.5 0 1 0-2.5-2.5m-8 8.5h14.5a2.5 2.5 0 1 1-2.5 2.5m-12-5.5h7',
    bold: null,
  ),
  'flashlight': (
    solid: 'M7 3h10v3.5l-2 3h-6l-2-3z',
    line: 'M9 11.5v9.5h6v-9.5m-3 2.7v2',
    bold: null,
  ),
  'palette': (
    solid: 'M6.3 11.5a1.3 1.3 0 1 0 2.6 0 1.3 1.3 0 1 0-2.6 0z m2.4-4.1a1.3 1.3 0 1 0 2.6 0 1.3 1.3 0 1 0-2.6 0z m4.6 0a1.3 1.3 0 1 0 2.6 0 1.3 1.3 0 1 0-2.6 0z',
    line: 'M12 21a9 9 0 1 1 9-9c0 2.4-1.9 4-4.3 4h-1.7a2 2 0 0 0-1.5 3.3c0.5 0.6 0.2 1.7-1.5 1.7z',
    bold: null,
  ),
  'languages': (
    solid: null,
    line: 'M3 5.5h9m-4.5-2v2m-2.5 0c0.5 3 2.5 5.5 5.5 7m-0.5-7c-0.7 3.5-3 6.5-6.5 8m9 7.5l4-9.5 4 9.5m-6.5-3.5h5',
    bold: null,
  ),
  'banknote': (
    solid: 'M9.6 12a2.4 2.4 0 1 0 4.8 0 2.4 2.4 0 1 0-4.8 0z',
    line: 'M5.5 6h13a3 3 0 0 1 3 3v6a3 3 0 0 1-3 3h-13a3 3 0 0 1-3-3v-6a3 3 0 0 1 3-3z',
    bold: null,
  ),
  'ruler': (
    solid: null,
    line: 'M3.5 16.5l13-13 4 4-13 13z m3.5-3.5l1.5 1.5m1.5-4.5l2 2m1-5l1.5 1.5',
    bold: null,
  ),
  'activity': (
    solid: null,
    line: 'M3 12h3.8l2.6-6.5 5.2 13 2.6-6.5h3.8',
    bold: null,
  ),
  'trending-down': (
    solid: null,
    line: 'M3 7l6.5 6.5 4-4 7.5 7.5h-5.5',
    bold: null,
  ),
  'log-out': (
    solid: null,
    line: 'M10 4h-2.5a3.5 3.5 0 0 0-3.5 3.5v9a3.5 3.5 0 0 0 3.5 3.5h2.5m0.5-8h9.5l-4-4',
    bold: null,
  ),
  'folder-plus': (
    solid: null,
    line: 'M3 7.5a2.5 2.5 0 0 1 2.5-2.5h3.6l2 2.5h7.4a2.5 2.5 0 0 1 2.5 2.5v7.5a2.5 2.5 0 0 1-2.5 2.5h-13a2.5 2.5 0 0 1-2.5-2.5z m9 3.8v5m-2.5-2.5h5',
    bold: null,
  ),
  'list-tree': (
    solid: 'M13.3 3.7h5.9a1.3 1.3 0 0 1 1.3 1.3v0a1.3 1.3 0 0 1-1.3 1.3h-5.9a1.3 1.3 0 0 1-1.3-1.3v0a1.3 1.3 0 0 1 1.3-1.3z m0 7h5.9a1.3 1.3 0 0 1 1.3 1.3v0a1.3 1.3 0 0 1-1.3 1.3h-5.9a1.3 1.3 0 0 1-1.3-1.3v0a1.3 1.3 0 0 1 1.3-1.3z m0 7h5.9a1.3 1.3 0 0 1 1.3 1.3v0a1.3 1.3 0 0 1-1.3 1.3h-5.9a1.3 1.3 0 0 1-1.3-1.3v0a1.3 1.3 0 0 1 1.3-1.3z',
    line: 'M4 5h4m-4 0v11.5a2.5 2.5 0 0 0 2.5 2.5h2.5m-5-7h5',
    bold: null,
  ),
  'list': (
    solid: 'M3.3 6a1.5 1.5 0 1 0 3 0 1.5 1.5 0 1 0-3 0z m0 6a1.5 1.5 0 1 0 3 0 1.5 1.5 0 1 0-3 0z m0 6a1.5 1.5 0 1 0 3 0 1.5 1.5 0 1 0-3 0z',
    line: 'M9 6h11m-11 6h11m-11 6h11',
    bold: null,
  ),
  'text-cursor-input': (
    solid: 'M8.1 9.8h0a0.9 0.9 0 0 1 0.9 0.9v2.6a0.9 0.9 0 0 1-0.9 0.9h0a0.9 0.9 0 0 1-0.9-0.9v-2.6a0.9 0.9 0 0 1 0.9-0.9z',
    line: 'M6 7h12a3 3 0 0 1 3 3v4a3 3 0 0 1-3 3h-12a3 3 0 0 1-3-3v-4a3 3 0 0 1 3-3z m6 5h4.5',
    bold: null,
  ),
  'sticky-note': (
    solid: 'M15.5 19.5v-2.8a1.6 1.6 0 0 1 1.6-1.6h2.8z',
    line:
        'M6.5 3.5h11a3 3 0 0 1 3 3v8l-6 6h-8a3 3 0 0 1-3-3v-11a3 3 0 0 1 3-3z',
    bold: null,
  ),
  'flash': (
    solid: 'M13.6 2.6l-8.2 10.5 6 0-1 8.3 8.2-10.5-6 0z',
    line: null,
    bold: null,
  ),
  'flash-off': (
    solid: 'M7.25 10.73l-1.85 2.37 4.22 0 1.59 1.59-0.81 6.71 3.3-4.22z m6.35-8.13l-3.3 4.22 6.45 6.45 1.85-2.37-4.22 0-1.59-1.59z',
    line: 'M3.5 3.5l17 17',
    bold: null,
  ),
};
