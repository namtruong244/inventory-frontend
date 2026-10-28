import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Drop-in replacement for [Icon]: draws the app's own line icons (24 grid,
/// round caps, 1.8 stroke) for every Material glyph listed below and falls back
/// to the Material font for anything else. Extends [Icon] so
/// `find.byIcon(...)` keeps working in tests.
class AppIcon extends Icon {
  const AppIcon(super.icon, {super.key, super.size, super.color, super.semanticLabel});

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
    final picture = SvgPicture.string(
      svg,
      width: s,
      height: s,
      theme: SvgTheme(currentColor: c),
    );
    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(child: picture),
    );
  }
}

const _head = "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' "
    "stroke='currentColor' stroke-width='1.8' stroke-linecap='round' stroke-linejoin='round'>";

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

  g([Icons.add, Icons.add_rounded],
      "<path d='M12 5v14M5 12h14'/>");
  g([Icons.remove],
      "<path d='M5 12h14'/>");
  g([Icons.close, Icons.close_rounded, Icons.clear],
      "<path d='M6.5 6.5l11 11M17.5 6.5l-11 11'/>");
  g([Icons.check_rounded],
      "<path d='M5 12.5l4.5 4.5L19 7.5'/>");
  g([Icons.chevron_right, Icons.chevron_right_rounded, Icons.arrow_forward_ios_rounded],
      "<path d='M9.5 6l6 6-6 6'/>");
  g([Icons.keyboard_arrow_down_rounded, Icons.arrow_drop_down_rounded],
      "<path d='M6 9.5l6 6 6-6'/>");
  g([Icons.arrow_back_ios_new, Icons.arrow_back_ios_new_rounded],
      "<path d='M14.5 6l-6 6 6 6'/>");
  g([Icons.arrow_forward, Icons.arrow_forward_rounded],
      "<path d='M5 12h14M13 6l6 6-6 6'/>");
  g([Icons.arrow_upward_rounded],
      "<path d='M12 19V5M6 11l6-6 6 6'/>");
  g([Icons.unfold_more_rounded],
      "<path d='M8 9l4-4 4 4M8 15l4 4 4-4'/>");
  g([Icons.unfold_less_rounded],
      "<path d='M8 5l4 4 4-4M8 19l4-4 4 4'/>");
  g([Icons.subdirectory_arrow_right_rounded],
      "<path d='M6 5v6a3 3 0 003 3h9M14 10l4 4-4 4'/>");
  g([Icons.search, Icons.search_rounded],
      "<circle cx='11' cy='11' r='6.5'/><path d='M16 16l4.5 4.5'/>");
  g([Icons.tune_rounded],
      "<path d='M4 8h8M18 8h2M4 16h2M12 16h8'/><circle cx='15' cy='8' r='2.4'/><circle cx='9' cy='16' r='2.4'/>");
  g([Icons.edit_outlined],
      "<path d='M4.5 19.5l1-4L16 5a2.1 2.1 0 013 3L8.5 18.5z'/><path d='M14 7l3 3'/>");
  g([Icons.edit_note_outlined],
      "<path d='M4 7h9M4 12h5M4 17h6'/><path d='M13 18.5l.7-3L19 10.2a1.6 1.6 0 012.3 2.3L16 17.8z'/>");
  g([Icons.delete_outline, Icons.delete_outline_rounded, Icons.delete_sweep_outlined],
      "<path d='M5 7h14M10 7V5.2h4V7M7 7l.8 11.2a1.5 1.5 0 001.5 1.3h5.4a1.5 1.5 0 001.5-1.3L17 7'/><path d='M10.5 11v5M13.5 11v5'/>");
  g([Icons.delete_forever_outlined],
      "<path d='M5 7h14M10 7V5.2h4V7M7 7l.8 11.2a1.5 1.5 0 001.5 1.3h5.4a1.5 1.5 0 001.5-1.3L17 7'/><path d='M10.2 11.5l3.6 3.6M13.8 11.5l-3.6 3.6'/>");
  g([Icons.inventory_2_outlined, Icons.inventory_2_rounded],
      "<rect x='3.5' y='4.5' width='17' height='4.5' rx='1.5'/><path d='M5 9v8.5A2 2 0 007 19.5h10a2 2 0 002-2V9M10 13h4'/>");
  g([Icons.category_outlined, Icons.category_rounded],
      "<rect x='4' y='4' width='6.5' height='6.5' rx='2'/><circle cx='17' cy='7.2' r='3.2'/><path d='M7.2 13.5l3.2 5.8H4z'/><rect x='13.5' y='13.5' width='6.5' height='6.5' rx='2'/>");
  g([Icons.home_outlined, Icons.home_rounded],
      "<path d='M4 11l8-6.5 8 6.5v8a1.5 1.5 0 01-1.5 1.5H15v-5.5H9v5.5H5.5A1.5 1.5 0 014 19z'/>");
  g([Icons.settings_outlined, Icons.settings_rounded],
      "<circle cx='12' cy='12' r='3'/><circle cx='12' cy='12' r='7.2' stroke-width='2.8' stroke-dasharray='3.1 2.5'/>");
  g([Icons.qr_code_2_rounded, Icons.qr_code_rounded, Icons.qr_code],
      "<rect x='4' y='4' width='6' height='6' rx='1.5'/><rect x='14' y='4' width='6' height='6' rx='1.5'/><rect x='4' y='14' width='6' height='6' rx='1.5'/><path d='M14 14h2.5v2.5M20 14v.01M14 20h.01M17 20h3v-3'/>");
  g([Icons.qr_code_scanner_rounded, Icons.document_scanner_outlined, Icons.barcode_reader],
      "<path d='M4 8V6.5A2.5 2.5 0 016.5 4H8M16 4h1.5A2.5 2.5 0 0120 6.5V8M20 16v1.5a2.5 2.5 0 01-2.5 2.5H16M8 20H6.5A2.5 2.5 0 014 17.5V16'/><path d='M8 12h8'/>");
  g([Icons.warning_amber_rounded],
      "<path d='M12 4.5l8.5 14.5h-17z'/><path d='M12 10v4M12 16.8v.01'/>");
  g([Icons.info_outline, Icons.info_outline_rounded],
      "<circle cx='12' cy='12' r='8.5'/><path d='M12 11v5M12 8v.01'/>");
  g([Icons.error_outline_rounded],
      "<circle cx='12' cy='12' r='8.5'/><path d='M12 7.5v5M12 16v.01'/>");
  g([Icons.priority_high_rounded],
      "<path d='M12 5v9.5M12 19v.01'/>");
  g([Icons.help_outline],
      "<circle cx='12' cy='12' r='8.5'/><path d='M9.7 9.6a2.4 2.4 0 114 1.7c-.8.7-1.7 1.1-1.7 2.3M12 17v.01'/>");
  g([Icons.check_circle_rounded, Icons.check_circle_outline, Icons.check_circle_outline_rounded],
      "<circle cx='12' cy='12' r='8.5'/><path d='M8.5 12.3l2.5 2.5 4.5-5'/>");
  g([Icons.remove_circle_outline],
      "<circle cx='12' cy='12' r='8.5'/><path d='M8.5 12h7'/>");
  g([Icons.add_circle_outline_rounded],
      "<circle cx='12' cy='12' r='8.5'/><path d='M12 8.5v7M8.5 12h7'/>");
  g([Icons.add_box_outlined],
      "<rect x='4' y='4' width='16' height='16' rx='4.5'/><path d='M12 8.5v7M8.5 12h7'/>");
  g([Icons.calendar_today_outlined, Icons.calendar_month_outlined, Icons.event_outlined],
      "<rect x='4' y='5.5' width='16' height='14.5' rx='3.5'/><path d='M4 10.5h16M8.5 3.5v4M15.5 3.5v4'/>");
  g([Icons.event_available_rounded],
      "<rect x='4' y='5.5' width='16' height='14.5' rx='3.5'/><path d='M4 10.5h16M8.5 3.5v4M15.5 3.5v4'/><path d='M9 15.2l2 2 3.5-3.8'/>");
  g([Icons.event_busy_outlined],
      "<rect x='4' y='5.5' width='16' height='14.5' rx='3.5'/><path d='M4 10.5h16M8.5 3.5v4M15.5 3.5v4'/><path d='M10 14l4 4M14 14l-4 4'/>");
  g([Icons.location_on_outlined],
      "<path d='M12 21s6.5-5.6 6.5-11a6.5 6.5 0 10-13 0c0 5.4 6.5 11 6.5 11z'/><circle cx='12' cy='10' r='2.3'/>");
  g([Icons.handshake_outlined, Icons.sync_alt_rounded],
      "<path d='M5 8h13M14.5 4.5L18 8l-3.5 3.5M19 16H6M9.5 12.5L6 16l3.5 3.5'/>");
  g([Icons.sync_rounded, Icons.sync_problem_rounded, Icons.refresh_rounded],
      "<path d='M19.5 12a7.5 7.5 0 01-13 5.1M4.5 12a7.5 7.5 0 0113-5.1'/><path d='M17.5 3.5v3.6h-3.6M6.5 20.5v-3.6h3.6'/>");
  g([Icons.restore_rounded, Icons.history, Icons.history_rounded],
      "<path d='M4 12a8 8 0 108-8 8.2 8.2 0 00-5.6 2.4L4 8.8'/><path d='M4 4v4.8h4.8M12 8v4.2l2.8 1.800'/>");
  g([Icons.notifications_none_rounded, Icons.notifications_active_outlined],
      "<path d='M6 16.5V11a6 6 0 1112 0v5.5l1.5 1.5h-15z'/><path d='M10 20.5a2.2 2.2 0 004 0'/>");
  g([Icons.cloud_off_rounded],
      "<path d='M7 18.5h10a4 4 0 00.8-7.9A6 6 0 006.7 9.2 4.7 4.7 0 007 18.5z'/><path d='M4 4l16 16'/>");
  g([Icons.shield_outlined, Icons.security_outlined],
      "<path d='M12 3.5l7 2.8v5.4c0 4.3-2.9 7.6-7 9-4.1-1.4-7-4.7-7-9V6.3z'/>");
  g([Icons.verified_user_outlined, Icons.verified_rounded],
      "<path d='M12 3.5l7 2.8v5.4c0 4.3-2.9 7.6-7 9-4.1-1.4-7-4.7-7-9V6.3z'/><path d='M9 12l2.2 2.2L15 10'/>");
  g([Icons.lock_outline, Icons.lock_outline_rounded],
      "<rect x='5' y='10.5' width='14' height='10' rx='3'/><path d='M8 10.5V8a4 4 0 118 0v2.5'/>");
  g([Icons.visibility_outlined],
      "<path d='M2.5 12S6 5.5 12 5.5 21.5 12 21.5 12 18 18.5 12 18.5 2.5 12 2.5 12z'/><circle cx='12' cy='12' r='2.8'/>");
  g([Icons.visibility_off_outlined],
      "<path d='M3 12s3.500-6.500 9-6.500c1.500 0 2.800.4 4 1M21 12s-3.500 6.500-9 6.500c-1.500 0-2.800-.4-4-1'/><path d='M4 4l16 16'/>");
  g([Icons.mail_outline_rounded],
      "<rect x='3.5' y='5.5' width='17' height='13' rx='3.5'/><path d='M4.5 8l7.5 5.500L19.500 8'/>");
  g([Icons.phone_outlined],
      "<path d='M6.5 4h3l1.500 4-2 1.300a10 10 0 005.700 5.700l1.300-2 4 1.500v3a2 2 0 01-2.200 2A15 15 0 014.500 6.200 2 2 0 016.500 4z'/>");
  g([Icons.person_outline_rounded],
      "<circle cx='12' cy='8.5' r='3.7'/><path d='M5 20c.6-3.700 3.400-5.800 7-5.800s6.400 2.100 7 5.800'/>");
  g([Icons.assignment_ind_outlined],
      "<rect x='5' y='4.5' width='14' height='16' rx='3.5'/><path d='M9 4.5h6'/><circle cx='12' cy='11' r='1.8'/><path d='M8.800 17c.4-1.800 1.700-2.800 3.200-2.800s2.800 1 3.200 2.800'/>");
  g([Icons.assignment_turned_in_outlined],
      "<rect x='5' y='4.5' width='14' height='16' rx='3.5'/><path d='M9 4.5h6'/><path d='M9 13l2.200 2.200L15 11'/>");
  g([Icons.assignment_late_outlined],
      "<rect x='5' y='4.5' width='14' height='16' rx='3.5'/><path d='M9 4.5h6'/><path d='M12 9.500v3.500M12 16v.01'/>");
  g([Icons.receipt_long_outlined, Icons.receipt_long_rounded],
      "<path d='M6 3.500h12v17l-2.500-1.700-1.800 1.700-1.700-1.700-1.800 1.700-1.700-1.700L6 20.500z'/><path d='M9 8.500h6M9 12h6'/>");
  g([Icons.summarize_outlined],
      "<path d='M7 3.5h7.5L19 8v10.5a2 2 0 01-2 2H7a2 2 0 01-2-2v-13a2 2 0 012-2z'/><path d='M14 3.5V8h5'/><path d='M9 12.500h6M9 16h4'/>");
  g([Icons.picture_as_pdf_rounded],
      "<path d='M7 3.5h7.5L19 8v10.5a2 2 0 01-2 2H7a2 2 0 01-2-2v-13a2 2 0 012-2z'/><path d='M14 3.5V8h5'/><path d='M8.500 15.500h1.500a1.200 1.200 0 000-2.400H8.500v4.400'/>");
  g([Icons.menu_book_outlined],
      "<path d='M12 6.500C10 5 7 4.500 4.500 5v13c2.500-.5 5.500 0 7.500 1.500 2-1.500 5-2 7.500-1.500V5c-2.500-.5-5.500 0-7.500 1.500zM12 6.500v13'/>");
  g([Icons.print_outlined, Icons.print_rounded, Icons.print],
      "<path d='M7 9V4h10v5M7 17H5.500a2 2 0 01-2-2v-4a2 2 0 012-2h13a2 2 0 012 2v4a2 2 0 01-2 2H17'/><rect x='7' y='14' width='10' height='6.500' rx='1.500'/>");
  g([Icons.image_outlined, Icons.broken_image_outlined, Icons.photo_library_rounded],
      "<rect x='3.500' y='4.500' width='17' height='15' rx='4'/><circle cx='9' cy='10' r='1.700'/><path d='M4 17l5-4.500 3.500 3 3-2.500 5 4'/>");
  g([Icons.camera_alt_rounded, Icons.add_a_photo_outlined],
      "<path d='M4 8.500A2.500 2.500 0 016.500 6H8l1.300-2h5.400L16 6h1.500A2.500 2.500 0 0120 8.500v8a2.500 2.500 0 01-2.500 2.500h-11A2.500 2.500 0 014 16.500z'/><circle cx='12' cy='12.500' r='3.400'/>");
  g([Icons.copy_rounded],
      "<rect x='8.500' y='8.500' width='11' height='11' rx='3'/><path d='M15.500 8.500V7a2.500 2.500 0 00-2.500-2.500H7A2.500 2.500 0 004.500 7v6A2.500 2.500 0 007 15.500h1.500'/>");
  g([Icons.link_rounded],
      "<path d='M10 14a3.500 3.500 0 005 0l3-3a3.500 3.500 0 00-5-5l-1 1M14 10a3.500 3.500 0 00-5 0l-3 3a3.500 3.500 0 005 5l1-1'/>");
  g([Icons.open_in_new_rounded],
      "<path d='M13 4.500h6.500V11M19.500 4.500L11 13M17 14v3.500a2 2 0 01-2 2H6.500a2 2 0 01-2-2V9a2 2 0 012-2H10'/>");
  g([Icons.more_horiz_rounded],
      "<path d='M6 12h.01M12 12h.01M18 12h.01' stroke-width='3'/>");
  g([Icons.more_vert_rounded],
      "<path d='M12 6h.01M12 12h.01M12 18h.01' stroke-width='3'/>");
  g([Icons.logout_rounded],
      "<path d='M10 4.500H7A2.500 2.500 0 004.500 7v10A2.500 2.500 0 007 19.500h3M15 8l4 4-4 4M19 12H9.500'/>");
  g([Icons.language_rounded, Icons.public],
      "<circle cx='12' cy='12' r='8.5'/><path d='M3.500 12h17M12 3.500c2.500 2.500 3.500 5.300 3.500 8.500s-1 6-3.500 8.500c-2.500-2.500-3.500-5.300-3.500-8.500s1-6 3.500-8.500z'/>");
  g([Icons.palette_outlined],
      "<path d='M12 3.500a8.500 8.500 0 100 17c1.400 0 2-1 1.500-2-.6-1.200.2-2.500 1.600-2.500H17a3.500 3.500 0 003.500-3.500C20.500 7 16.800 3.500 12 3.500z'/><path d='M8 11h.01M11 7.800h.01M15.200 8.600h.01' stroke-width='2.4'/>");
  g([Icons.brightness_6_outlined],
      "<circle cx='12' cy='12' r='8.5'/><path d='M12 3.500a8.500 8.500 0 010 17z' fill='currentColor'/>");
  g([Icons.volume_up_outlined],
      "<path d='M4.500 10v4h3l4.500 3.500v-11L7.500 10z'/><path d='M15.500 9a4 4 0 010 6M18 6.500a7.500 7.500 0 010 11'/>");
  g([Icons.vibration_rounded],
      "<rect x='8' y='4' width='8' height='16' rx='2.500'/><path d='M4.500 9v6M19.500 9v6'/>");
  g([Icons.keyboard_outlined],
      "<rect x='3' y='6.500' width='18' height='11' rx='3'/><path d='M7 10.500h.01M10.500 10.500h.01M14 10.500h.01M17.500 10.500h.01M8 14h8'/>");
  g([Icons.touch_app_outlined],
      "<path d='M9 12V6.500a1.500 1.500 0 013 0V12M12 11a1.500 1.500 0 013 0v1.500a1.500 1.500 0 013 0V15a6 6 0 01-6 6h-.5a5 5 0 01-4-2l-2.700-3.500a1.500 1.500 0 012.300-1.800L9 14.500'/>");
  g([Icons.view_agenda_outlined],
      "<rect x='4' y='4.500' width='16' height='6.500' rx='2.500'/><rect x='4' y='13' width='16' height='6.500' rx='2.500'/>");
  g([Icons.grid_view_rounded],
      "<rect x='4' y='4' width='7' height='7' rx='2.200'/><rect x='13' y='4' width='7' height='7' rx='2.200'/><rect x='4' y='13' width='7' height='7' rx='2.200'/><rect x='13' y='13' width='7' height='7' rx='2.200'/>");
  g([Icons.dns_rounded],
      "<rect x='4' y='4.500' width='16' height='6' rx='2.500'/><rect x='4' y='13.500' width='16' height='6' rx='2.500'/><path d='M8 7.500h.01M8 16.500h.01'/>");
  g([Icons.tag_rounded],
      "<path d='M4 4h7.500l8.500 8.500-7.500 7.500L4 11.500z'/><path d='M8.500 8.500h.01' stroke-width='2.600'/>");
  g([Icons.straighten_rounded],
      "<rect x='3' y='8' width='18' height='8' rx='2.500'/><path d='M7 8v3M10.500 8v2M14 8v3M17.500 8v2'/>");
  g([Icons.payments_outlined],
      "<rect x='3' y='6.500' width='18' height='11' rx='3'/><circle cx='12' cy='12' r='2.600'/>");
  g([Icons.attach_money_rounded],
      "<path d='M12 4v16M15.500 8.200C15 7 13.700 6.300 12 6.300c-2 0-3.500 1-3.500 2.600 0 3.500 7 1.800 7 5.300 0 1.600-1.500 2.600-3.500 2.600-1.800 0-3.200-.8-3.700-2.200'/>");
  g([Icons.alarm_rounded],
      "<circle cx='12' cy='13' r='7'/><path d='M12 9.500V13l2.500 1.500M4.500 5.500L7 3.500M19.500 5.500L17 3.500'/>");
  g([Icons.hourglass_top_rounded],
      "<path d='M7 4h10M7 20h10M8 4c0 4 4 5 4 8s-4 4-4 8M16 4c0 4-4 5-4 8s4 4 4 8'/>");
  g([Icons.donut_large_outlined],
      "<circle cx='12' cy='12' r='8.5'/><circle cx='12' cy='12' r='3.500'/>");
  g([Icons.dangerous_outlined],
      "<path d='M8.500 3.500h7l5 5v7l-5 5h-7l-5-5v-7z'/><path d='M9 9l6 6M15 9l-6 6'/>");
  g([Icons.handyman_outlined, Icons.build_circle_outlined],
      "<path d='M14.700 6.300a4 4 0 005.200 5.200L10 21.400a2.400 2.400 0 01-3.400-3.400l10-10z'/>");
  g([Icons.content_cut_rounded],
      "<circle cx='6.500' cy='7' r='2.500'/><circle cx='6.500' cy='17' r='2.500'/><path d='M8.500 8.500L20 18M8.500 15.500L20 6'/>");
  g([Icons.outbox_rounded],
      "<path d='M4.500 13v4.500a2 2 0 002 2h11a2 2 0 002-2V13M12 15V4.500M7.500 9L12 4.500 16.500 9'/>");
  g([Icons.inbox_outlined],
      "<path d='M4 13l2.500-7.500A2 2 0 018.400 4h7.200a2 2 0 011.900 1.500L20 13v4.500a2 2 0 01-2 2H6a2 2 0 01-2-2z'/><path d='M4 13h4.500l1 2.500h5l1-2.500H20'/>");
  g([Icons.folder_outlined],
      "<path d='M3.500 7.500A2.500 2.500 0 016 5h3.500l2 2.500H18a2.500 2.500 0 012.500 2.500v7.500A2.500 2.500 0 0118 20H6a2.500 2.500 0 01-2.500-2.500z'/>");
  g([Icons.account_tree_rounded],
      "<rect x='3.500' y='4' width='6' height='5' rx='1.500'/><rect x='14.500' y='4' width='6' height='5' rx='1.500'/><rect x='9' y='15' width='6' height='5' rx='1.500'/><path d='M6.500 9v2.500h11V9M12 11.500V15'/>");
  g([Icons.shelves],
      "<rect x='4' y='3.500' width='16' height='17' rx='2.500'/><path d='M4 9.200h16M4 14.800h16'/>");
  g([Icons.meeting_room_outlined],
      "<path d='M6 20.500V5a1.500 1.500 0 011.500-1.500h9A1.500 1.500 0 0118 5v15.500M3.500 20.500h17M14.500 12v.01' />");
  g([Icons.route_outlined],
      "<circle cx='6.500' cy='6.500' r='2.300'/><circle cx='17.500' cy='17.500' r='2.300'/><path d='M8.800 6.500H14a3 3 0 010 6h-4a3 3 0 000 6h5.200'/>");
  g([Icons.kitchen_outlined],
      "<rect x='6' y='3.500' width='12' height='17' rx='3'/><path d='M6 10.500h12M9.500 7v1.500M9.500 13v3'/>");
  g([Icons.checkroom_outlined],
      "<path d='M12 8V6.500a2 2 0 10-2-2M12 8l8.500 6.200a1.500 1.500 0 01-.9 2.800H4.400a1.500 1.500 0 01-.9-2.800z'/>");
  g([Icons.devices_outlined],
      "<rect x='3.500' y='5.500' width='14' height='10' rx='2'/><path d='M2.500 19h11'/><rect x='16.500' y='9.500' width='4' height='9' rx='1.200'/>");
  g([Icons.sports_esports_outlined],
      "<path d='M7 8h10a4.500 4.500 0 014.400 5.400l-.6 3A2.800 2.800 0 0115 17.500l-1-1.500h-4l-1 1.500A2.800 2.800 0 013.200 16.400l-.6-3A4.500 4.500 0 017 8z'/><path d='M7.500 11v3M6 12.500h3M16 11.500h.01M18 13.500h.01'/>");
  g([Icons.fitness_center_outlined],
      "<path d='M6.500 8v8M17.500 8v8M3.500 10v4M20.500 10v4M6.500 12h11'/>");
  g([Icons.medical_services_outlined],
      "<rect x='3.500' y='7' width='17' height='13' rx='3'/><path d='M9 7V5.500A1.500 1.500 0 0110.500 4h3A1.500 1.500 0 0115 5.500V7M12 10.500v6M9 13.500h6'/>");
  g([Icons.luggage_outlined],
      "<rect x='6' y='6.500' width='12' height='13' rx='3'/><path d='M9.500 6.500V4h5v2.500M9.500 10v6M14.500 10v6'/>");
  g([Icons.watch_outlined],
      "<rect x='7.500' y='7' width='9' height='10' rx='3'/><path d='M9 7l.7-3.500h4.600L15 7M9 17l.7 3.500h4.600L15 17M12 10v2l1.400 1'/>");
  g([Icons.music_note_outlined],
      "<path d='M9 18V6l10-2v12'/><circle cx='6.500' cy='18' r='2.500'/><circle cx='16.500' cy='16' r='2.500'/>");
  g([Icons.restaurant_outlined],
      "<path d='M7 3.500v6a2 2 0 004 0v-6M9 3.500v17M16.500 20.500v-17c-2 1.500-3 4-3 7h3.500'/>");
  g([Icons.shopping_basket_outlined],
      "<path d='M3.500 10h17l-1.700 8.200A2 2 0 0116.800 20H7.200a2 2 0 01-2-1.800z'/><path d='M8 10l3-5.500M16 10l-3-5.500'/>");
  g([Icons.add_shopping_cart_outlined],
      "<path d='M3 4h2.500l1.800 9h9.500l1.700-6.500H8'/><circle cx='9' cy='19' r='1.300'/><circle cx='16' cy='19' r='1.300'/>");
  g([Icons.production_quantity_limits_rounded],
      "<path d='M4 8l8-4 8 4v9l-8 4-8-4z'/><path d='M12 10.500v4M12 17v.01'/>");
  g([Icons.play_circle_outline],
      "<circle cx='12' cy='12' r='8.5'/><path d='M10.500 8.800l4.500 3.200-4.500 3.200z'/>");
  return m;
}
