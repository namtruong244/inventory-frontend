import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Drop-in replacement for [Icon]: draws the app's own line icons (24 grid,
/// round caps, 2.2 stroke, "Soft Line" set from the design) for every Material glyph listed below and falls back
/// to the Material font for anything else. Extends [Icon] so
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
    final svg = data == null ? null : _glyphs[data.codePoint];
    if (svg == null) return super.build(context);
    final theme = IconTheme.of(context);
    final s = size ?? theme.size ?? 24.0;
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

const _head =
    "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' "
    "stroke='currentColor' stroke-width='2.2' stroke-linecap='round' stroke-linejoin='round'>";

final Map<int, String> _glyphs = _build();

@visibleForTesting
Iterable<String> get appIconSvgs => _glyphs.values.toSet();

Map<int, String> _build() {
  final m = <int, String>{};
  void g(List<IconData> icons, String body) {
    final svg = '$_head$body</svg>';
    for (final i in icons) {
      m[i.codePoint] = svg;
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
    [Icons.handshake_outlined, Icons.sync_alt_rounded],
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
  g(
    [Icons.play_circle_outline],
    "<circle cx='12' cy='12' r='8.5'/><path d='M10.500 8.800l4.500 3.200-4.500 3.200z'/>",
  );

  // --- Soft Line set (design frame BkGih); glyph names are the design node names. ---
  void d(String name, List<IconData> icons) {
    final body = _softLine[name]!;
    final svg = "$_head<path d='$body'/></svg>";
    for (final i in icons) {
      m[i.codePoint] = svg;
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

/// Path data of the design's Soft Line glyphs (24 grid, stroke 2.2).
const _softLine = <String, String>{
  'house': 'M4 10.3c0-0.8 0.4-1.5 1-2l5.2-4c1.1-0.8 2.5-0.8 3.6 0l5.2 4c0.6 0.5 1 1.2 1 2v7.2a3.5 3.5 0 0 1-3.5 3.5h-9a3.5 3.5 0 0 1-3.5-3.5z m8 7.2v-3',
  'search': 'M4 11a7 7 0 1 0 14 0 7 7 0 1 0-14 0m16.5 9.5l-4.6-4.6',
  'bell': 'M6 16.5v-5.5a6 6 0 0 1 12 0v5.5l1.1 1.2c0.5 0.6 0.1 1.5-0.7 1.5h-12.8c-0.8 0-1.2-0.9-0.7-1.5z m4 4.8c0.5 0.5 1.2 0.7 2 0.7s1.5-0.2 2-0.7',
  'bell-ring': 'M6 16.5v-5.5a6 6 0 0 1 12 0v5.5l1.1 1.2c0.5 0.6 0.1 1.5-0.7 1.5h-12.8c-0.8 0-1.2-0.9-0.7-1.5z m4 4.8c0.5 0.5 1.2 0.7 2 0.7s1.5-0.2 2-0.7m-11.2-12.8c0.5-1.8 1.5-3.3 2.9-4.4m15.5 4.4c-0.5-1.8-1.5-3.3-2.9-4.4',
  'user-round': 'M8.4 7.6a3.6 3.6 0 1 0 7.2 0 3.6 3.6 0 1 0-7.2 0m-3.4 10.8c0-2.3 3.1-3.7 7-3.7s7 1.4 7 3.7-3.1 3.6-7 3.6-7-1.3-7-3.6z',
  'user-x': 'M6.4 7.6a3.6 3.6 0 1 0 7.2 0 3.6 3.6 0 1 0-7.2 0m-3.4 10.8c0-2.3 3.1-3.7 7-3.7 1 0 1.9 0.1 2.7 0.3m3.8-0.5l4.5 4.5m0-4.5l-4.5 4.5',
  'settings': 'M4 7.5h9m5 0h2m-16 9h2m5 0h9m-7-9a2.5 2.5 0 1 0 5 0 2.5 2.5 0 1 0-5 0m-7 9a2.5 2.5 0 1 0 5 0 2.5 2.5 0 1 0-5 0',
  'tag': 'M3.5 5.6v5c0 0.7 0.3 1.3 0.8 1.8l7.8 7.8c0.9 0.9 2.3 0.9 3.2 0l4.9-4.9c0.9-0.9 0.9-2.3 0-3.2l-7.8-7.8c-0.5-0.5-1.1-0.8-1.8-0.8h-5c-1.2 0-2.1 0.9-2.1 2.1z m3.1 2.4a1.4 1.4 0 1 0 2.8 0 1.4 1.4 0 1 0-2.8 0',
  'box': 'M12 3.2l7.4 4.1c0.4 0.2 0.6 0.6 0.6 1v7.4c0 0.4-0.2 0.8-0.6 1l-7.4 4.1-7.4-4.1c-0.4-0.2-0.6-0.6-0.6-1v-7.4c0-0.4 0.2-0.8 0.6-1z m-7.6 4.5l7.6 4.3 7.6-4.3m-7.6 4.3v8.6',
  'package': 'M12 3.2l7.4 4.1c0.4 0.2 0.6 0.6 0.6 1v7.4c0 0.4-0.2 0.8-0.6 1l-7.4 4.1-7.4-4.1c-0.4-0.2-0.6-0.6-0.6-1v-7.4c0-0.4 0.2-0.8 0.6-1z m-7.6 4.5l7.6 4.3 7.6-4.3m-7.6 4.3v8.6m-3.8-15.3l7.6 4.3',
  'package-open': 'M3.5 8.5l8.5 4.5 8.5-4.5m-17 0l2.5-4 6 3 6-3 2.5 4m-15.5 0.8v6.8c0 0.4 0.2 0.8 0.6 1l6.4 3.7 6.4-3.7c0.4-0.2 0.6-0.6 0.6-1v-6.8m-7 3.7v7.8',
  'package-plus': 'M20 11v-2.7c0-0.4-0.2-0.8-0.6-1l-7.4-4.1-7.4 4.1c-0.4 0.2-0.6 0.6-0.6 1v7.4c0 0.4 0.2 0.8 0.6 1l7.4 4.1 1.3-0.7m-8.9-12.4l7.6 4.3 7.6-4.3m-7.6 4.3v8.6m6.5-5.6v6m-3-3h6',
  'package-x': 'M20 11v-2.7c0-0.4-0.2-0.8-0.6-1l-7.4-4.1-7.4 4.1c-0.4 0.2-0.6 0.6-0.6 1v7.4c0 0.4 0.2 0.8 0.6 1l7.4 4.1 1.3-0.7m-8.9-12.4l7.6 4.3 7.6-4.3m-7.6 4.3v8.6m4-5.1l4.5 4.5m0-4.5l-4.5 4.5',
  'archive': 'M7 3h10a3 3 0 0 1 3 3v12a3 3 0 0 1-3 3h-10a3 3 0 0 1-3-3v-12a3 3 0 0 1 3-3z m-3 9h16m-10-4.5h4m-4 9h4',
  'door-open': 'M6 21v-15.5a2.5 2.5 0 0 1 2.5-2.5h7a2.5 2.5 0 0 1 2.5 2.5v15.5m-14.5 0h17m-6.3-8.5a0.4 0.4 0 1 0 0.8 0 0.4 0.4 0 1 0-0.8 0',
  'rows-3': 'M4.5 3.5v17m15-17v17m-15-12h15m-15 5.5h15m-15 5.5h15',
  'inbox': 'M6 5h12a3 3 0 0 1 3 3v8a3 3 0 0 1-3 3h-12a3 3 0 0 1-3-3v-8a3 3 0 0 1 3-3z m-3 5.5h18m-11 4h4',
  'shapes': 'M3.9 7.5a3.6 3.6 0 1 0 7.2 0 3.6 3.6 0 1 0-7.2 0m11.1 5.5h3.5a2 2 0 0 1 2 2v3.5a2 2 0 0 1-2 2h-3.5a2 2 0 0 1-2-2v-3.5a2 2 0 0 1 2-2z m2-9.5l3.4 5.8c0.2 0.4-0.1 0.9-0.5 0.9h-5.8c-0.4 0-0.7-0.5-0.5-0.9z m-13 13h7m-3.5-3.5v7',
  'scan-line': 'M3 8v-1.5a3.5 3.5 0 0 1 3.5-3.5h1.5m8 0h1.5a3.5 3.5 0 0 1 3.5 3.5v1.5m0 8v1.5a3.5 3.5 0 0 1-3.5 3.5h-1.5m-8 0h-1.5a3.5 3.5 0 0 1-3.5-3.5v-1.5m4-4h10',
  'qr-code': 'M5.8 4h2.9a1.8 1.8 0 0 1 1.8 1.8v2.9a1.8 1.8 0 0 1-1.8 1.8h-2.9a1.8 1.8 0 0 1-1.8-1.8v-2.9a1.8 1.8 0 0 1 1.8-1.8z m9.5 0h2.9a1.8 1.8 0 0 1 1.8 1.8v2.9a1.8 1.8 0 0 1-1.8 1.8h-2.9a1.8 1.8 0 0 1-1.8-1.8v-2.9a1.8 1.8 0 0 1 1.8-1.8z m-9.5 9.5h2.9a1.8 1.8 0 0 1 1.8 1.8v2.9a1.8 1.8 0 0 1-1.8 1.8h-2.9a1.8 1.8 0 0 1-1.8-1.8v-2.9a1.8 1.8 0 0 1 1.8-1.8z m7.7 0h2.5m4 0v0.01m-6.5 3.49v3m3.5-3h3v3',
  'scan-barcode': 'M3 8v-1.5a3.5 3.5 0 0 1 3.5-3.5h1.5m8 0h1.5a3.5 3.5 0 0 1 3.5 3.5v1.5m0 8v1.5a3.5 3.5 0 0 1-3.5 3.5h-1.5m-8 0h-1.5a3.5 3.5 0 0 1-3.5-3.5v-1.5m5-8v8m4-8v8m4-8v8',
  'scan-search': 'M3 8v-1.5a3.5 3.5 0 0 1 3.5-3.5h1.5m8 0h1.5a3.5 3.5 0 0 1 3.5 3.5v1.5m0 8v1.5a3.5 3.5 0 0 1-3.5 3.5h-1.5m-8 0h-1.5a3.5 3.5 0 0 1-3.5-3.5v-1.5m5.2-4.8a3 3 0 1 0 6 0 3 3 0 1 0-6 0m7.8 4.8l-2.6-2.6',
  'plus': 'M12 5v14m-7-7h14',
  'minus': 'M5 12h14',
  'x': 'M6.5 6.5l11 11m0-11l-11 11',
  'check': 'M5 12.5l4.5 4.5 9.5-9.5',
  'chevron-right': 'M9.5 6l6 6-6 6',
  'chevron-down': 'M6 9.5l6 6 6-6',
  'chevron-up': 'M6 14.5l6-6 6 6',
  'chevrons-down-up': 'M7 4l5 5 5-5m-10 16l5-5 5 5',
  'arrow-left': 'M19.5 12h-15m6-6l-6 6 6 6',
  'arrow-right': 'M4.5 12h15m-6-6l6 6-6 6',
  'arrow-up-right': 'M7 17l10-10m-8.5 0h8.5v8.5',
  'arrow-up-down': 'M7.5 4v16m-3.5-12.5l3.5-3.5 3.5 3.5m5.5 12.5v-16m-3.5 12.5l3.5 3.5 3.5-3.5',
  'corner-down-right': 'M5 4v6.5a3.5 3.5 0 0 0 3.5 3.5h10.5m-4-4l4 4-4 4',
  'ellipsis': 'M5.4 12a0.6 0.6 0 1 0 1.2 0 0.6 0.6 0 1 0-1.2 0m6 0a0.6 0.6 0 1 0 1.2 0 0.6 0.6 0 1 0-1.2 0m6 0a0.6 0.6 0 1 0 1.2 0 0.6 0.6 0 1 0-1.2 0',
  'trash-2': 'M4 6.8h16m-10.5 0v-1.4c0-0.8 0.7-1.4 1.5-1.4h2c0.8 0 1.5 0.6 1.5 1.4v1.4m-8.5 0l0.8 11.4c0.1 1.6 1.4 2.8 3 2.8h4.4c1.6 0 2.9-1.2 3-2.8l0.8-11.4m-8 4.2v5.5m4-5.5v5.5',
  'pencil': 'M4.5 19.5l0.9-4.2 10.2-10.2c0.8-0.8 2.1-0.8 2.9 0l0.4 0.4c0.8 0.8 0.8 2.1 0 2.9l-10.2 10.2z m9.1-12.4l3.3 3.3',
  'move': 'M12 3.5v17m-8.5-8.5h17m-11.5-5.5l3-3 3 3m-6 11l3 3 3-3m-8.5-8.5l-3 3 3 3m11-6l3 3-3 3',
  'history': 'M3.5 12a8.5 8.5 0 1 0 2.5-6m-2.5-1.5v3.7h3.7m4.8-0.2v4.3l3 2',
  'rotate-cw': 'M20 12a8 8 0 1 1-2.3-5.7m2.3-1.8v3.7h-3.7',
  'rotate-ccw': 'M4 12a8 8 0 1 0 2.3-5.7m-2.3-1.8v3.7h3.7',
  'undo-2': 'M9 14.5l-4.5-4.5 4.5-4.5m-4.5 4.5h10.5a4.5 4.5 0 0 1 0 9h-3',
  'copy': 'M11.5 8.5h6a3 3 0 0 1 3 3v6a3 3 0 0 1-3 3h-6a3 3 0 0 1-3-3v-6a3 3 0 0 1 3-3z m4 0v-2a3 3 0 0 0-3-3h-6a3 3 0 0 0-3 3v6a3 3 0 0 0 3 3h2',
  'share': 'M12 14.5v-11m-4 4l4-4 4 4m-11 4.5v5.5a3.5 3.5 0 0 0 3.5 3.5h7a3.5 3.5 0 0 0 3.5-3.5v-5.5',
  'printer': 'M7 9v-4a2 2 0 0 1 2-2h6a2 2 0 0 1 2 2v4m-10 8h-1a3 3 0 0 1-3-3v-2a3 3 0 0 1 3-3h12a3 3 0 0 1 3 3v2a3 3 0 0 1-3 3h-1m-8.5-3h7a1.5 1.5 0 0 1 1.5 1.5v4a1.5 1.5 0 0 1-1.5 1.5h-7a1.5 1.5 0 0 1-1.5-1.5v-4a1.5 1.5 0 0 1 1.5-1.5z',
  'file-down': 'M14 3h-6a3 3 0 0 0-3 3v12a3 3 0 0 0 3 3h8a3 3 0 0 0 3-3v-10z m0 0v5h5m-7 3v6m-2.5-2.5l2.5 2.5 2.5-2.5',
  'camera': 'M3.5 9a2.5 2.5 0 0 1 2.5-2.5h1.8l1.5-2.5h5.4l1.5 2.5h1.8a2.5 2.5 0 0 1 2.5 2.5v8.5a2.5 2.5 0 0 1-2.5 2.5h-12a2.5 2.5 0 0 1-2.5-2.5z m5 4a3.5 3.5 0 1 0 7 0 3.5 3.5 0 1 0-7 0',
  'image': 'M6.5 4h11a3.5 3.5 0 0 1 3.5 3.5v9a3.5 3.5 0 0 1-3.5 3.5h-11a3.5 3.5 0 0 1-3.5-3.5v-9a3.5 3.5 0 0 1 3.5-3.5z m0.4 5.5a1.6 1.6 0 1 0 3.2 0 1.6 1.6 0 1 0-3.2 0m-3.4 7.5l5-4.5 4 3.5 2.5-2 5.5 4.5',
  'link': 'M10 14a4 4 0 0 0 5.7 0l3.1-3.1a4 4 0 0 0-5.7-5.7l-1 1m1.9 3.8a4 4 0 0 0-5.7 0l-3.1 3.1a4 4 0 0 0 5.7 5.7l1-1',
  'clipboard-paste': 'M8 4.5h8a3 3 0 0 1 3 3v10.5a3 3 0 0 1-3 3h-8a3 3 0 0 1-3-3v-10.5a3 3 0 0 1 3-3z m2.5-2h3a1.5 1.5 0 0 1 1.5 1.5v1a1.5 1.5 0 0 1-1.5 1.5h-3a1.5 1.5 0 0 1-1.5-1.5v-1a1.5 1.5 0 0 1 1.5-1.5z m-1.5 9.5h6m-6 4h4',
  'eye': 'M2.5 12s3.5-7 9.5-7 9.5 7 9.5 7-3.5 7-9.5 7-9.5-7-9.5-7z m6.5 0a3 3 0 1 0 6 0 3 3 0 1 0-6 0',
  'lock': 'M8 10.5h8a3 3 0 0 1 3 3v4.5a3 3 0 0 1-3 3h-8a3 3 0 0 1-3-3v-4.5a3 3 0 0 1 3-3z m0 0v-3a4 4 0 0 1 8 0v3m-4 4v2.5',
  'mail': 'M6.5 5h11a3.5 3.5 0 0 1 3.5 3.5v7a3.5 3.5 0 0 1-3.5 3.5h-11a3.5 3.5 0 0 1-3.5-3.5v-7a3.5 3.5 0 0 1 3.5-3.5z m-2.5 3l8 5.5 8-5.5',
  'phone': 'M6.5 3.5h2c0.6 0 1.1 0.4 1.3 0.9l1 2.7c0.2 0.6 0 1.2-0.5 1.6l-1.2 1.1a11.5 11.5 0 0 0 5.1 5.1l1.1-1.2c0.4-0.5 1-0.7 1.6-0.5l2.7 1c0.5 0.2 0.9 0.7 0.9 1.3v2c0 1-0.8 1.8-1.8 1.8-8.5 0-14-5.5-14-14 0-1 0.8-1.8 1.8-1.8z',
  'map-pin': 'M12 21s-7-6-7-11.3a7 7 0 0 1 14 0c0 5.3-7 11.3-7 11.3z m-2.6-11.4a2.6 2.6 0 1 0 5.2 0 2.6 2.6 0 1 0-5.2 0',
  'calendar': 'M7 5h10a3.5 3.5 0 0 1 3.5 3.5v9a3.5 3.5 0 0 1-3.5 3.5h-10a3.5 3.5 0 0 1-3.5-3.5v-9a3.5 3.5 0 0 1 3.5-3.5z m-3.5 5h17m-12.5-7v4m8-4v4',
  'calendar-x': 'M7 5h10a3.5 3.5 0 0 1 3.5 3.5v9a3.5 3.5 0 0 1-3.5 3.5h-10a3.5 3.5 0 0 1-3.5-3.5v-9a3.5 3.5 0 0 1 3.5-3.5z m-3.5 5h17m-12.5-7v4m8-4v4m-6 6.5l4 4m0-4l-4 4',
  'calendar-clock': 'M20.5 10v-1.5a3.5 3.5 0 0 0-3.5-3.5h-10a3.5 3.5 0 0 0-3.5 3.5v9a3.5 3.5 0 0 0 3.5 3.5h4m-7.5-11h17m-12.5-7v4m8-4v4m-3 10a4 4 0 1 0 8 0 4 4 0 1 0-8 0m4-1.7v1.7l1.2 1',
  'hourglass': 'M6.5 3h11m-11 18h11m-10-18v2.6c0 1.5 0.7 2.9 1.9 3.8l2.6 2.6 2.6-2.6c1.2-0.9 1.9-2.3 1.9-3.8v-2.6m-9 18v-2.6c0-1.5 0.7-2.9 1.9-3.8l2.6-2.6 2.6 2.6c1.2 0.9 1.9 2.3 1.9 3.8v2.6',
  'clock-alert':
      'M3.5 12a8.5 8.5 0 1 0 17 0 8.5 8.5 0 1 0-17 0m8.5-4.5v4.5l3 2',
  'triangle-alert': 'M10.3 4.3c0.8-1.3 2.6-1.3 3.4 0l7.1 12.3c0.8 1.3-0.2 2.9-1.7 2.9h-14.2c-1.5 0-2.5-1.6-1.7-2.9z m1.7 5.2v4m-0.35 3.1a0.35 0.35 0 1 0 0.7 0 0.35 0.35 0 1 0-0.7 0',
  'circle-alert': 'M3 12a9 9 0 1 0 18 0 9 9 0 1 0-18 0m9-4.2v4.7m-0.35 3.4a0.35 0.35 0 1 0 0.7 0 0.35 0.35 0 1 0-0.7 0',
  'circle-check': 'M3 12a9 9 0 1 0 18 0 9 9 0 1 0-18 0m5.3 0.2l2.5 2.5 4.9-5',
  'circle-help': 'M3 12a9 9 0 1 0 18 0 9 9 0 1 0-18 0m6.6-2.5a2.5 2.5 0 1 1 3.4 2.3c-0.6 0.3-1 0.8-1 1.5v0.3m-0.35 3a0.35 0.35 0 1 0 0.7 0 0.35 0.35 0 1 0-0.7 0',
  'info': 'M3 12a9 9 0 1 0 18 0 9 9 0 1 0-18 0m9-1v5.3m-0.35-8.4a0.35 0.35 0 1 0 0.7 0 0.35 0.35 0 1 0-0.7 0',
  'cloud-off': 'M7.2 18.5a4.4 4.4 0 0 1-0.7-8.8 5.8 5.8 0 0 1 11.2 0.4 4.2 4.2 0 0 1-0.4 8.4z m-3.7-15l17 17',
  'cloud-alert': 'M7.2 18.5a4.4 4.4 0 0 1-0.7-8.8 5.8 5.8 0 0 1 11.2 0.4 4.2 4.2 0 0 1-0.4 8.4z m4.8-7.5v2.8m-0.3 2.2a0.3 0.3 0 1 0 0.6 0 0.3 0.3 0 1 0-0.6 0',
  'loader-circle': 'M12 3a9 9 0 1 0 9 9',
  'shield': 'M12 3l7 2.8v5.5c0 4.2-2.9 8.1-7 9.7-4.1-1.6-7-5.5-7-9.7v-5.5z',
  'shield-check': 'M12 3l7 2.8v5.5c0 4.2-2.9 8.1-7 9.7-4.1-1.6-7-5.5-7-9.7v-5.5z m-3 9l2.2 2.2 4-4.2',
  'shield-alert': 'M12 3l7 2.8v5.5c0 4.2-2.9 8.1-7 9.7-4.1-1.6-7-5.5-7-9.7v-5.5z m0 5.5v3.8m-0.35 3a0.35 0.35 0 1 0 0.7 0 0.35 0.35 0 1 0-0.7 0',
  'handshake': 'M3 15h3.2l3.4-1.5h4.1c0.8 0 1.5 0.7 1.5 1.5s-0.7 1.5-1.5 1.5h-3.4m4.3-0.5l4.4-2.2c0.8-0.4 1.7 0 2 0.8 0.2 0.6 0 1.3-0.6 1.7l-6.4 4.2h-5.7l-2.1-1.5h-3.2m8.1-15.5h3.8a1.6 1.6 0 0 1 1.6 1.6v3.3a1.6 1.6 0 0 1-1.6 1.6h-3.8a1.6 1.6 0 0 1-1.6-1.6v-3.3a1.6 1.6 0 0 1 1.6-1.6z',
  'hand': 'M8 13.5v-6.5a1.5 1.5 0 0 1 3 0v4.5m0-0.5v-5.5a1.5 1.5 0 0 1 3 0v5.5m0 0.5v-4.5a1.5 1.5 0 0 1 3 0v7a7 7 0 0 1-7 7h-0.6a6 6 0 0 1-4.6-2.2l-2.4-2.9a1.6 1.6 0 0 1 2.4-2.1l3.2 1.8',
  'headphones': 'M4 15v-3a8 8 0 0 1 16 0v3m-16 0.5a1.5 1.5 0 0 1 1.5-1.5h0.5a2 2 0 0 1 2 2v2.5a2 2 0 0 1-2 2h-0.5a1.5 1.5 0 0 1-1.5-1.5z m16 0a1.5 1.5 0 0 0-1.5-1.5h-0.5a2 2 0 0 0-2 2v2.5a2 2 0 0 0 2 2h0.5a1.5 1.5 0 0 0 1.5-1.5z',
  'battery': 'M5.5 7h10a3 3 0 0 1 3 3v4a3 3 0 0 1-3 3h-10a3 3 0 0 1-3-3v-4a3 3 0 0 1 3-3z m16 3.5v3m-15-3v3m3.5-3v3',
  'battery-charging': 'M5.5 7h10a3 3 0 0 1 3 3v4a3 3 0 0 1-3 3h-10a3 3 0 0 1-3-3v-4a3 3 0 0 1 3-3z m16 3.5v3m-10-4l-2.3 2.7h3.3l-2.3 2.8',
  'pill': 'M10.6 20.1a5 5 0 0 1-7.1-7.1l6.9-6.9a5 5 0 0 1 7.1 7.1z m-3.6-10.6l7.5 7.5',
  'plug': 'M9 3v4m6-4v4m-8.5 0h11v3.5a5.5 5.5 0 0 1-11 0z m5.5 9v5',
  'laptop': 'M7 5h10a2.5 2.5 0 0 1 2.5 2.5v5.5a2.5 2.5 0 0 1-2.5 2.5h-10a2.5 2.5 0 0 1-2.5-2.5v-5.5a2.5 2.5 0 0 1 2.5-2.5z m-4.5 14h19',
  'monitor': 'M6 4h12a3 3 0 0 1 3 3v6.5a3 3 0 0 1-3 3h-12a3 3 0 0 1-3-3v-6.5a3 3 0 0 1 3-3z m3 16.5h6m-3-4v4',
  'tablet': 'M8.5 2.5h7a3.5 3.5 0 0 1 3.5 3.5v12a3.5 3.5 0 0 1-3.5 3.5h-7a3.5 3.5 0 0 1-3.5-3.5v-12a3.5 3.5 0 0 1 3.5-3.5z m2.5 15.5h2',
  'gamepad-2': 'M7.5 7h9a5 5 0 0 1 4.9 5.9l-0.6 3.5a2.6 2.6 0 0 1-4.4 1.4l-1.8-1.8h-5.2l-1.8 1.8a2.6 2.6 0 0 1-4.4-1.4l-0.6-3.5a5 5 0 0 1 4.9-5.9z m0.5 3v3m-1.5-1.5h3m5.6-0.7a0.4 0.4 0 1 0 0.8 0 0.4 0.4 0 1 0-0.8 0m2 2a0.4 0.4 0 1 0 0.8 0 0.4 0.4 0 1 0-0.8 0',
  'drill': 'M4 6.5h10.5a2 2 0 0 1 2 2v2.5a2 2 0 0 1-2 2h-10.5z m12.5 3.25h4.5m-14 3.25l1 7.5h3.5l-0.8-7.5',
  'wrench': 'M14.8 4.2a4.6 4.6 0 0 0-4.4 6l-6 6a2 2 0 0 0 2.8 2.8l6-6a4.6 4.6 0 0 0 6-4.4l-2.7 1.1-2.7-2.7z',
  'cpu': 'M9 6h6a3 3 0 0 1 3 3v6a3 3 0 0 1-3 3h-6a3 3 0 0 1-3-3v-6a3 3 0 0 1 3-3z m1.5 3.5h3a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1h-3a1 1 0 0 1-1-1v-3a1 1 0 0 1 1-1z m-1-6.5v3m5-3v3m-5 12v3m5-3v3m-11.5-11.5h3m-3 5h3m12-5h3m-3 5h3',
  'shirt': 'M8 3.5l-4.5 2.7 1.6 3.9 2-0.8v9.7a1.5 1.5 0 0 0 1.5 1.5h6.8a1.5 1.5 0 0 0 1.5-1.5v-9.7l2 0.8 1.6-3.9-4.5-2.7c-0.6 1.5-2.2 2.5-4 2.5s-3.4-1-4-2.5z',
  'utensils':
      'M6 3v6.5a2 2 0 0 0 4 0v-6.5m-2 8.5v9.5m9 0v-18c-2.2 0-4 2.6-4 6.5v3.5h4',
  'cooking-pot': 'M4 10.5h16v5.5a4 4 0 0 1-4 4h-8a4 4 0 0 1-4-4z m-2 0h2m16 0h2m-13.5-3.5c0-1.2 1.5-2.2 3.5-2.2s3.5 1 3.5 2.2',
  'book-open': 'M12 6.8c-1.6-1.4-4-2.1-8-2.1v13.8c4 0 6.4 0.7 8 2.1 1.6-1.4 4-2.1 8-2.1v-13.8c-4 0-6.4 0.7-8 2.1z m0 0v13.8',
  'sparkles': 'M11 4l1.5 4c0.3 0.9 1 1.6 1.9 1.9l4 1.5-4 1.5c-0.9 0.3-1.6 1-1.9 1.9l-1.5 4.2-1.5-4.2c-0.3-0.9-1-1.6-1.9-1.9l-4.1-1.5 4.1-1.5c0.9-0.3 1.6-1 1.9-1.9z m8-1v3.5m-1.75-1.75h3.5',
  'sofa': 'M5 11v-3a3 3 0 0 1 3-3h8a3 3 0 0 1 3 3v3m-16 2a2 2 0 0 1 4 0v1.5h10v-1.5a2 2 0 0 1 4 0v4a2 2 0 0 1-2 2h-14a2 2 0 0 1-2-2z m3 6v1.5m12-1.5v1.5',
  'bed-double': 'M3 19.5v-13.5m0 6.5h15a3 3 0 0 1 3 3v4m-18-3h18m-14.5-4v-2a1.5 1.5 0 0 1 1.5-1.5h3a1.5 1.5 0 0 1 1.5 1.5v2',
  'bath': 'M3 12h18v2.5a5 5 0 0 1-5 5h-8a5 5 0 0 1-5-5z m3 0v-6a2.5 2.5 0 0 1 4.7-1.2m-3.7 14.7l-1 1.5m11-1.5l1 1.5',
  'car': 'M5 11l1.6-4.1c0.4-1.1 1.4-1.9 2.6-1.9h5.6c1.2 0 2.2 0.8 2.6 1.9l1.6 4.1m-14.5 0h15a1.5 1.5 0 0 1 1.5 1.5v4.5h-18v-4.5a1.5 1.5 0 0 1 1.5-1.5z m1 6v2m13-2v2m-11.4-5a0.4 0.4 0 1 0 0.8 0 0.4 0.4 0 1 0-0.8 0m9 0a0.4 0.4 0 1 0 0.8 0 0.4 0.4 0 1 0-0.8 0',
  'milk': 'M8 3h8m-7.5 0v2.3l-2 3.3v10.9a1.5 1.5 0 0 0 1.5 1.5h8a1.5 1.5 0 0 0 1.5-1.5v-10.9l-2-3.3v-2.3m-9 9.5h11',
  'sun': 'M8 12a4 4 0 1 0 8 0 4 4 0 1 0-8 0m4-9.5v2m0 15v2m-9.5-9.5h2m15 0h2m-16.2-6.7l1.4 1.4m10.6 10.6l1.4 1.4m-13.4 0l1.4-1.4m10.6-10.6l1.4-1.4',
  'wind': 'M3 9h10.5a2.5 2.5 0 1 0-2.5-2.5m-8 8.5h14.5a2.5 2.5 0 1 1-2.5 2.5m-12-5.5h7',
  'flashlight': 'M7 3h10v3.5l-2 3v11.5h-6v-11.5l-2-3z m0 3.5h10m-5 6.5v2',
  'palette': 'M12 21a9 9 0 1 1 9-9c0 2.4-1.9 4-4.3 4h-1.7a2 2 0 0 0-1.5 3.3c0.5 0.6 0.2 1.7-1.5 1.7z m-5.1-9.5a0.6 0.6 0 1 0 1.2 0 0.6 0.6 0 1 0-1.2 0m2.5-4.2a0.6 0.6 0 1 0 1.2 0 0.6 0.6 0 1 0-1.2 0m4.8 0a0.6 0.6 0 1 0 1.2 0 0.6 0.6 0 1 0-1.2 0',
  'languages': 'M3 5.5h9m-4.5-2v2m-2.5 0c0.5 3 2.5 5.5 5.5 7m-0.5-7c-0.7 3.5-3 6.5-6.5 8m9 7.5l4-9.5 4 9.5m-6.5-3.5h5',
  'banknote': 'M5.5 6h13a3 3 0 0 1 3 3v6a3 3 0 0 1-3 3h-13a3 3 0 0 1-3-3v-6a3 3 0 0 1 3-3z m4 6a2.5 2.5 0 1 0 5 0 2.5 2.5 0 1 0-5 0m-3.8-2.5a0.3 0.3 0 1 0 0.6 0 0.3 0.3 0 1 0-0.6 0m12 5a0.3 0.3 0 1 0 0.6 0 0.3 0.3 0 1 0-0.6 0',
  'ruler':
      'M3.5 16.5l13-13 4 4-13 13z m3.5-3.5l1.5 1.5m1.5-4.5l2 2m1-5l1.5 1.5',
  'activity': 'M3 12h3.8l2.6-6.5 5.2 13 2.6-6.5h3.8',
  'trending-down': 'M3 7l6.5 6.5 4-4 7.5 7.5m-5.5 0h5.5v-5.5',
  'log-out': 'M10 4h-2.5a3.5 3.5 0 0 0-3.5 3.5v9a3.5 3.5 0 0 0 3.5 3.5h2.5m5-12l4 4-4 4m4-4h-9.5',
  'folder-plus': 'M3 7.5a2.5 2.5 0 0 1 2.5-2.5h3.6l2 2.5h7.4a2.5 2.5 0 0 1 2.5 2.5v7.5a2.5 2.5 0 0 1-2.5 2.5h-13a2.5 2.5 0 0 1-2.5-2.5z m9 3.5v5m-2.5-2.5h5',
  'list-tree':
      'M4 5h4m-4 0v11.5a2.5 2.5 0 0 0 2.5 2.5h2.5m-5-7h5m3-7h8m-7 7h7m-7 7h7',
  'list': 'M9 6h11m-11 6h11m-11 6h11m-15.7-12a0.5 0.5 0 1 0 1 0 0.5 0.5 0 1 0-1 0m0 6a0.5 0.5 0 1 0 1 0 0.5 0.5 0 1 0-1 0m0 6a0.5 0.5 0 1 0 1 0 0.5 0.5 0 1 0-1 0',
  'text-cursor-input': 'M6 7h12a3 3 0 0 1 3 3v4a3 3 0 0 1-3 3h-12a3 3 0 0 1-3-3v-4a3 3 0 0 1 3-3z m2 3v4',
  'sticky-note': 'M6.5 3.5h11a3 3 0 0 1 3 3v8l-6 6h-8a3 3 0 0 1-3-3v-11a3 3 0 0 1 3-3z m8 17v-4a2 2 0 0 1 2-2h4',
};
