import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/inventory_provider.dart';
import '../widgets/add_item_flow.dart';
import 'box_create_screen.dart';
import '../widgets/first_rooms_card.dart';
import '../widgets/home_recent_section.dart';
import '../widgets/home_sections.dart';
import '../widgets/home_tab_support.dart';
import 'alerts_screen.dart';
import 'boxes_screen.dart';
import 'items_screen.dart';
import 'qr_scanner_tab.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/home_header.dart';
import '../widgets/inventory_metrics_banner.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final ScrollController _homeScrollController;
  int _currentIndex = 0;

  /// Fade-through between tabs: the tab being left fades out over the first
  /// [_fadeOutEnd] of [_fade], then the new one fades in while scaling up.
  late final AnimationController _fade;
  static const double _fadeOutEnd = 0.3;
  int _previousIndex = 0;

  /// "Skip - I'll do it later" on the new-account setup; session-local.
  bool _setupSkipped = false;

  // Keys for sub-tab screens to enable scroll-to-top
  final GlobalKey<ScrollToTopHostState> _boxesKey = GlobalKey();
  final GlobalKey<ScrollToTopHostState> _itemsKey = GlobalKey();
  final GlobalKey<ScrollToTopHostState> _settingsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentIndex = _previousIndex = widget.initialIndex;
    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1,
    );
    _homeScrollController = ScrollController();
  }

  void _updateSystemOverlay() {
    SystemChrome.setSystemUIOverlayStyle(_currentOverlayStyle);
  }

  Future<T?> _navigateWithOverlayRestore<T>(Widget page) async {
    final result = await Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    if (mounted) _updateSystemOverlay();
    return result;
  }

  SystemUiOverlayStyle get _currentOverlayStyle {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: dark ? Brightness.dark : Brightness.light,
      statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
    );
  }

  @override
  void dispose() {
    _fade.dispose();
    _homeScrollController.dispose();
    super.dispose();
  }

  /// The tab on screen: the one being left during the fade-out phase.
  int get _shownIndex =>
      _fade.value < _fadeOutEnd ? _previousIndex : _currentIndex;

  /// Switching keeps each tab where it was left. Tapping the open tab again
  /// scrolls it to the top, and once at the top clears its search and filters.
  /// [reset] opens the tab fresh (top, no filters), for links like "See all".
  void _onTabSelected(int index, {bool reset = false}) {
    if (_currentIndex == index) {
      if (reset) {
        _resetTab(index);
      } else if (!_scrollToTop(index)) {
        _hostOf(index)?.resetFilters();
      }
      return;
    }
    setState(() {
      _previousIndex = _shownIndex;
      _currentIndex = index;
    });
    if (reset) _resetTab(index);
    _fade.forward(from: 0);
    _updateSystemOverlay();
  }

  ScrollToTopHostState? _hostOf(int index) => switch (index) {
    1 => _boxesKey.currentState,
    2 => _itemsKey.currentState,
    3 => _settingsKey.currentState,
    _ => null,
  };

  /// Animates the tab to the top; false when it is already there.
  bool _scrollToTop(int index) => index == 0
      ? animateToTop(_homeScrollController)
      : _hostOf(index)?.scrollToTop() ?? false;

  void _resetTab(int index) {
    if (index == 0) {
      if (_homeScrollController.hasClients) _homeScrollController.jumpTo(0);
    } else {
      _hostOf(index)?.reset();
    }
  }

  /// The four tabs stay mounted; only the shown one paints, gets input and
  /// runs tickers.
  Widget _buildTabs(BuildContext context) {
    final tabs = [
      _buildHomeTab(context),
      ScrollToTopHost(key: _boxesKey, child: const BoxesScreen()),
      ScrollToTopHost(key: _itemsKey, child: const ItemsScreen()),
      ScrollToTopHost(key: _settingsKey, child: const SettingsScreen()),
    ];
    return AnimatedBuilder(
      animation: _fade,
      builder: (context, _) {
        final t = _fade.value;
        final shown = _shownIndex;
        final double opacity;
        final double scale;
        if (t < _fadeOutEnd) {
          opacity = 1 - Curves.easeIn.transform(t / _fadeOutEnd);
          scale = 1;
        } else {
          final p = (t - _fadeOutEnd) / (1 - _fadeOutEnd);
          opacity = Curves.easeOut.transform(p);
          scale = 0.96 + 0.04 * Curves.easeOutCubic.transform(p);
        }
        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: IndexedStack(
              index: shown,
              sizing: StackFit.expand,
              children: [
                for (var i = 0; i < tabs.length; i++)
                  TickerMode(enabled: i == shown, child: tabs[i]),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final outerMedia = MediaQuery.of(context);
    final showAdd = _currentIndex == 1 || _currentIndex == 2;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _currentOverlayStyle,
      child: Scaffold(
        backgroundColor: context.colors.background,
        // Invisible placeholder so floating toasts (SnackBars) sit above the
        // floating nav (and its quick-add button) instead of under it.
        extendBody: true,
        bottomNavigationBar: SizedBox(
          height: AppBottomNav.bottomInset(context) + 64 + (showAdd ? 76 : 0),
        ),
        body: MediaQuery(
          // extendBody grows padding.bottom; children expect the real inset.
          data: outerMedia,
          child: Stack(
            children: [
              Positioned.fill(child: _buildTabs(context)),
              Positioned.fill(child: _buildNav(context)),
            ],
          ),
        ),
      ),
    );
  }

  HomeSections _sections(BuildContext context) => HomeSections(
    context,
    navigate: (page) => _navigateWithOverlayRestore(page),
    selectTab: _onTabSelected,
  );

  Widget _buildNav(BuildContext context) {
    final l10n = context.l10n;
    final isBoxTab = _currentIndex == 1;
    final showAdd = isBoxTab || _currentIndex == 2;
    return AppBottomNav(
      currentIndex: _currentIndex,
      onSelect: _onTabSelected,
      onScan: () =>
          _navigateWithOverlayRestore(const QRScannerTab(isFullScreen: true)),
      addLabel: showAdd ? (isBoxTab ? l10n.newLocation : l10n.addItem) : null,
      onAdd: () => isBoxTab
          ? _navigateWithOverlayRestore(const BoxCreateScreen())
          : startAddItemFlow(context),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    final topPadding = MediaQuery.of(context).padding.top;
    final sections = _sections(context);

    return RefreshIndicator(
      onRefresh: () => provider.fetchAllData(),
      color: context.colors.textPrimary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _homeScrollController,
        padding: EdgeInsets.fromLTRB(
          24,
          topPadding + 8,
          24,
          AppBottomNav.bottomInset(context) + 64 + 32,
        ),
        child: Consumer<InventoryProvider>(
          builder: (context, p, _) {
            // A brand-new account: ask where things are kept first.
            final setup =
                p.boxes.isEmpty &&
                !p.isLoading &&
                !p.isSyncing &&
                !_setupSkipped;
            void openAlerts() =>
                _navigateWithOverlayRestore(const AlertsScreen());
            if (setup) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HomeHeader(onAlerts: openAlerts, setup: true),
                  const SizedBox(height: 24),
                  FirstRoomsCard(
                    onSkip: () => setState(() => _setupSkipped = true),
                  ),
                  const SizedBox(height: 24),
                  const FirstRoomsNextStep(),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HomeHeader(onAlerts: openAlerts),
                const SizedBox(height: 20),
                HomeSearchBar(
                  onSearch: () =>
                      _navigateWithOverlayRestore(const SearchScreen()),
                ),
                ..._gap(sections.buildConnectionBanner(), p),
                if (p.totalAlertCount > 0) ...[
                  const SizedBox(height: 24),
                  sections.buildAlertBanner(),
                ],
                const SizedBox(height: 24),
                const InventoryMetricsBanner(),
                const SizedBox(height: 24),
                sections.buildQuickModulesSection(),
                const SizedBox(height: 24),
                sections.buildRecentItemsSection(),
              ],
            );
          },
        ),
      ),
    );
  }

  /// A section that renders nothing when connected: only add its gap when shown.
  List<Widget> _gap(Widget section, InventoryProvider p) => [
    if (!p.isConnected && !p.isOffline) ...[
      const SizedBox(height: 24),
      section,
    ],
  ];
}
