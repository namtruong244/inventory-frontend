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
import '../widgets/tappable.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import '../widgets/app_icon.dart';
import '../widgets/inventory_metrics_banner.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final ScrollController _homeScrollController;
  int _currentIndex = 0;

  // Keys for sub-tab screens to enable scroll-to-top
  final GlobalKey<ScrollToTopHostState> _boxesKey = GlobalKey();
  final GlobalKey<ScrollToTopHostState> _itemsKey = GlobalKey();
  final GlobalKey<ScrollToTopHostState> _settingsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    _tabController.addListener(_handleTabChange);
    _homeScrollController = ScrollController();
  }

  void _handleTabChange() {
    if (_currentIndex != _tabController.index) {
      setState(() {
        _currentIndex = _tabController.index;
      });
      _updateSystemOverlay();
    }
  }

  void _updateSystemOverlay() {
    SystemChrome.setSystemUIOverlayStyle(_currentOverlayStyle);
  }

  Future<T?> _navigateWithOverlayRestore<T>(Widget page) async {
    final result = await Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    _updateSystemOverlay();
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
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _homeScrollController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (_currentIndex == index) {
      _scrollToTop(index);
      return;
    }
    setState(() {
      _currentIndex = index;
    });
    _tabController.animateTo(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
    _updateSystemOverlay();
    _scrollToTop(index);
  }

  void _scrollToTop(int index) {
    switch (index) {
      case 0:
        if (_homeScrollController.hasClients) {
          _homeScrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
        break;
      case 1:
        _boxesKey.currentState?.scrollToTop();
        break;
      case 2:
        _itemsKey.currentState?.scrollToTop();
        break;
      case 3:
        _settingsKey.currentState?.scrollToTop();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _currentOverlayStyle,
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: Stack(
          children: [
            Positioned.fill(
              child: TabBarView(
                controller: _tabController,
                children: [
                  KeepAliveTab(child: _buildHomeTab(context)),
                  KeepAliveTab(
                    child: ScrollToTopHost(
                      key: _boxesKey,
                      child: const BoxesScreen(),
                    ),
                  ),
                  KeepAliveTab(
                    child: ScrollToTopHost(
                      key: _itemsKey,
                      child: const ItemsScreen(),
                    ),
                  ),
                  KeepAliveTab(
                    child: ScrollToTopHost(
                      key: _settingsKey,
                      child: const SettingsScreen(),
                    ),
                  ),
                ],
              ),
            ),
            _buildBottomNav(context),
          ],
        ),
      ),
    );
  }

  /// The nav bar floats above the bottom edge; keep it off the home indicator / gesture bar.
  double _navBottomInset(BuildContext context) {
    final inset = MediaQuery.of(context).padding.bottom;
    return inset > 16 ? inset : 16;
  }

  HomeSections _sections(BuildContext context) => HomeSections(
    context,
    navigate: (page) => _navigateWithOverlayRestore(page),
    selectTab: _onTabSelected,
  );

  Widget _buildHomeTab(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context, listen: false);

    return RefreshIndicator(
      onRefresh: () => provider.fetchAllData(),
      color: context.colors.textPrimary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _homeScrollController,
        padding: const EdgeInsets.only(bottom: 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderWithSearch(context),
            const SizedBox(height: 20),
            _sections(context).buildConnectionBanner(),
            _sections(context).buildAlertBanner(),
            Consumer<InventoryProvider>(
              builder: (context, p, _) {
                // A brand-new account: ask where things are kept instead of showing empty lists.
                final firstRun =
                    p.boxes.isEmpty && !p.isLoading && !p.isSyncing;
                return firstRun
                    ? const FirstRoomsCard()
                    : const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: InventoryMetricsBanner(),
                      );
              },
            ),
            const SizedBox(height: 16),
            _sections(context).buildQuickModulesSection(),
            const SizedBox(height: 32),
            _sections(context).buildRecentItemsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderWithSearch(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final c = context.colors;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, topPadding + 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Consumer<InventoryProvider>(
                builder: (context, provider, _) {
                  final initial = provider.userName.trim().isNotEmpty
                      ? provider.userName.trim()[0].toUpperCase()
                      : 'U';
                  return CircleAvatar(
                    radius: 22,
                    backgroundColor: c.accent,
                    child: Text(
                      initial,
                      style: TextStyle(
                        color: c.onAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Consumer<InventoryProvider>(
                  builder: (context, provider, _) {
                    final firstName = provider.userName.trim().split(' ').first;
                    return Text(
                      context.l10n.heyName(
                        firstName.isNotEmpty
                            ? firstName
                            : context.l10n.heyFallbackName,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: c.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
              Consumer<InventoryProvider>(
                builder: (context, provider, _) {
                  final alertCount = provider.totalAlertCount;
                  return Tappable(
                    semanticLabel: context.l10n.commonAlerts,
                    onTap: () =>
                        _navigateWithOverlayRestore(const AlertsScreen()),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: c.surface,
                            shape: BoxShape.circle,
                            boxShadow: c.cardShadow,
                          ),
                          child: AppIcon(
                            Icons.notifications_none_rounded,
                            color: c.textPrimary,
                            size: 22,
                          ),
                        ),
                        if (alertCount > 0)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),
                              decoration: BoxDecoration(
                                color: c.dangerStrong,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Center(
                                child: Text(
                                  '$alertCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            context.l10n.trackManageYourInventory,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.15,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 20),
          Tappable(
            semanticLabel: context.l10n.commonSearch,
            onTap: () => _navigateWithOverlayRestore(const SearchScreen()),
            child: Container(
              height: 56,
              padding: const EdgeInsets.fromLTRB(18, 0, 8, 0),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: c.cardShadow,
              ),
              child: Row(
                children: [
                  AppIcon(Icons.search_rounded, color: c.textMuted, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.l10n.commonSearch,
                      style: TextStyle(
                        color: c.textMuted,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: c.fill,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: AppIcon(
                      Icons.tune_rounded,
                      color: c.textPrimary,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final c = context.colors;
    final bottom = _navBottomInset(context);
    final showAdd = _currentIndex == 1 || _currentIndex == 2;
    return Positioned.fill(
      child: Stack(
        children: [
          // Floating add button, only on the Box (1) and Item (2) tabs.
          Positioned(
            right: 20,
            bottom: bottom + 68 + 16,
            child: IgnorePointer(
              ignoring: !showAdd,
              child: AnimatedScale(
                scale: showAdd ? 1 : 0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                child: _buildQuickAddButton(),
              ),
            ),
          ),
          Positioned(
            bottom: bottom,
            left: 20,
            right: 20,
            child: Container(
              height: 68,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(34),
                boxShadow: c.cardShadow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 25,
                children: [
                  _buildNavItem(
                    index: 0,
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    tooltip: context.l10n.commonHome,
                  ),
                  _buildNavItem(
                    index: 1,
                    icon: Icons.inventory_2_outlined,
                    activeIcon: Icons.inventory_2_rounded,
                    tooltip: context.l10n.commonBox,
                  ),
                  _buildCenterQRButton(),
                  _buildNavItem(
                    index: 2,
                    icon: Icons.category_outlined,
                    activeIcon: Icons.category_rounded,
                    tooltip: context.l10n.commonItem,
                  ),
                  _buildNavItem(
                    index: 3,
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings_rounded,
                    tooltip: context.l10n.commonSetting,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Quick add floats at the right edge above the nav pill: a new
  /// location on the Box tab, a new item on the Item tab.
  Widget _buildQuickAddButton() {
    final c = context.colors;
    final isBoxTab = _currentIndex == 1;
    final label = isBoxTab ? context.l10n.newLocation : context.l10n.addItem;
    return Tooltip(
      message: label,
      child: Tappable(
        semanticLabel: label,
        onTap: () => isBoxTab
            ? _navigateWithOverlayRestore(const BoxCreateScreen())
            : startAddItemFlow(context),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: c.accent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: c.accent.withValues(alpha: 0.55),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: AppIcon(Icons.add_rounded, color: c.onAccent, size: 32),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String tooltip,
  }) {
    final isSelected = _currentIndex == index;
    final c = context.colors;

    return Tooltip(
      message: tooltip,
      child: Tappable(
        semanticLabel: tooltip,
        onTap: () => _onTabSelected(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? c.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: AppIcon(
            isSelected ? activeIcon : icon,
            size: 24,
            color: isSelected ? c.onAccent : c.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildCenterQRButton() {
    final c = context.colors;
    return Tooltip(
      message: context.l10n.scanQrCode,
      child: Tappable(
        semanticLabel: context.l10n.scanQrCode,
        onTap: () =>
            _navigateWithOverlayRestore(const QRScannerTab(isFullScreen: true)),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: c.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AppIcon(
            Icons.qr_code_scanner_rounded,
            color: c.accent,
            size: 24,
          ),
        ),
      ),
    );
  }
}
