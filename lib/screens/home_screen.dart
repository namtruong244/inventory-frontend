import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/inventory_provider.dart';
import '../widgets/add_item_flow.dart';
import '../widgets/first_rooms_card.dart';
import '../widgets/home_recent_section.dart';
import '../widgets/home_sections.dart';
import '../widgets/home_storage_section.dart';
import '../widgets/home_tab_support.dart';
import 'alerts_screen.dart';
import 'boxes_screen.dart';
import 'items_screen.dart';
import 'qr_scanner_tab.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';
import '../widgets/tappable.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final ScrollController _homeScrollController;
  int _currentIndex = 0;
  bool _isHeaderScrolledPast = false;

  // Keys for sub-tab screens to enable scroll-to-top
  final GlobalKey<ScrollToTopHostState> _boxesKey = GlobalKey();
  final GlobalKey<ScrollToTopHostState> _itemsKey = GlobalKey();
  final GlobalKey<ScrollToTopHostState> _settingsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _tabController = TabController(length: 4, vsync: this, initialIndex: widget.initialIndex);
    _tabController.addListener(_handleTabChange);
    _homeScrollController = ScrollController();
    _homeScrollController.addListener(_handleHomeScroll);
  }

  void _handleHomeScroll() {
    if (!_homeScrollController.hasClients) return;
    // Dark header extends down to around 160px.
    // When scrolled past ~80px, top notch area is over light background.
    final isScrolled = _homeScrollController.offset > 80;
    if (isScrolled != _isHeaderScrolledPast) {
      setState(() {
        _isHeaderScrolledPast = isScrolled;
      });
      _updateSystemOverlay();
    }
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
    // If on Home tab and NOT scrolled past dark header:
    // White/light icons for the dark header
    if (_currentIndex == 0 && !_isHeaderScrolledPast) {
      return const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark, // iOS: light/white icons
        statusBarIconBrightness: Brightness.light, // Android: light/white icons
      );
    }
    // Scrolled down on Home tab, or on other tabs (Boxes, Items, Settings):
    // Dark icons for light background
    return const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light, // iOS: dark icons
      statusBarIconBrightness: Brightness.dark, // Android: dark icons
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _homeScrollController.removeListener(_handleHomeScroll);
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
          _homeScrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
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
    final topPadding = MediaQuery.of(context).padding.top;

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
                  KeepAliveTab(child: ScrollToTopHost(key: _boxesKey, child: const BoxesScreen())),
                  KeepAliveTab(child: ScrollToTopHost(key: _itemsKey, child: const ItemsScreen())),
                  KeepAliveTab(child: ScrollToTopHost(key: _settingsKey, child: const SettingsScreen())),
                ],
              ),
            ),
            // Floating backing bar under status bar when scrolled past dark header on Home
            if (_currentIndex == 0)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: topPadding,
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isHeaderScrolledPast ? 1.0 : 0.0,
                    child: Container(
                      color: context.colors.fill.withValues(alpha: 0.95),
                    ),
                  ),
                ),
              ),
            _buildBottomNav(context),
          ],
        ),
        // Quick add from anywhere (not on Settings), clear of the floating nav bar.
        floatingActionButton: _currentIndex == 3
            ? null
            : Padding(
                padding: EdgeInsets.only(bottom: 84 + _navBottomInset(context)),
                child: FloatingActionButton(
                  tooltip: context.l10n.addItem,
                  onPressed: () => startAddItemFlow(context),
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.add_rounded, size: 28),
                ),
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
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderWithSearch(context),
            const SizedBox(height: 38), // Space for overlapping search bar
            _sections(context).buildConnectionBanner(),
            _sections(context).buildAlertBanner(),
            _sections(context).buildQuickModulesSection(),
            const SizedBox(height: 28),
            Consumer<InventoryProvider>(
              builder: (context, p, _) {
                // A brand-new account: ask where things are kept instead of showing empty lists.
                final firstRun = p.boxes.isEmpty && !p.isLoading && !p.isSyncing;
                return firstRun ? const FirstRoomsCard() : _sections(context).buildStorageSpacesSection();
              },
            ),
            const SizedBox(height: 32),
            _sections(context).buildRecentItemsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderWithSearch(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Dark Top Header with Wave lines
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(24, topPadding + 14, 24, 38),
          decoration: BoxDecoration(
            color: context.colors.primary, // Dark Charcoal
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
          ),
          child: Stack(
            children: [
              // Wave Curves in Background
              Positioned.fill(
                child: CustomPaint(
                  painter: HeaderWavePainter(),
                ),
              ),
              // Greeting, Alert Bell & User Avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer<InventoryProvider>(
                          builder: (context, provider, _) {
                            final firstName = provider.userName.trim().split(' ').first;
                            return Text(
                              context.l10n.heyName(firstName.isNotEmpty ? firstName : context.l10n.heyFallbackName),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.l10n.trackManageYourInventory,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Bell Notification + User Avatar
                  Row(
                    children: [
                      Consumer<InventoryProvider>(
                        builder: (context, provider, _) {
                          final alertCount = provider.totalAlertCount;
                          return Tappable(
                            onTap: () => _navigateWithOverlayRestore(const AlertsScreen()),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: context.colors.surface.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.notifications_none_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                if (alertCount > 0)
                                  Positioned(
                                    top: -2,
                                    right: -2,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFEF4444),
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                                      child: Center(
                                        child: Text(
                                          '$alertCount',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
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
                      const SizedBox(width: 12),
                      Consumer<InventoryProvider>(
                        builder: (context, provider, _) {
                          final initial = provider.userName.trim().isNotEmpty
                              ? provider.userName.trim()[0].toUpperCase()
                              : 'U';
                          return Tappable(
                            onTap: () => _navigateWithOverlayRestore(const LoginScreen()),
                            child: Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.45),
                                  width: 1.5,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 22,
                                backgroundColor: context.colors.primary,
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        // Overlapping Search Bar
        Positioned(
          bottom: -26,
          left: 24,
          right: 24,
          child: Tappable(
            onTap: () => _navigateWithOverlayRestore(const SearchScreen()),
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: context.colors.textMuted, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.l10n.commonSearch,
                      style: TextStyle(
                        color: context.colors.textMuted,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.tune,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Positioned(
      bottom: _navBottomInset(context),
      left: 24,
      right: 24,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // 0: Home
            _buildNavItem(
              index: 0,
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              tooltip: context.l10n.commonHome,
            ),
            // 1: Box
            _buildNavItem(
              index: 1,
              icon: Icons.inventory_2_outlined,
              activeIcon: Icons.inventory_2_rounded,
              tooltip: context.l10n.commonBox,
            ),
            // QR Scan Action Button (opens camera fullscreen, no navbar)
            _buildCenterQRButton(),
            // 2: Item
            _buildNavItem(
              index: 2,
              icon: Icons.category_outlined,
              activeIcon: Icons.category_rounded,
              tooltip: context.l10n.commonItem,
            ),
            // 3: Setting
            _buildNavItem(
              index: 3,
              icon: Icons.settings_outlined,
              activeIcon: Icons.settings_rounded,
              tooltip: context.l10n.commonSetting,
            ),
          ],
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

    return Tooltip(
      message: tooltip,
      child: Tappable(
        onTap: () => _onTabSelected(index),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 56,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                size: 24,
                color: isSelected
                    ? context.colors.textPrimary
                    : context.colors.textMuted,
              ),
              const SizedBox(height: 3),
              Text(
                tooltip,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? context.colors.textPrimary : context.colors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterQRButton() {
    return Tooltip(
      message: context.l10n.scanQrCode,
      child: Tappable(
        semanticLabel: context.l10n.scanQrCode,
        onTap: () => _navigateWithOverlayRestore(const QRScannerTab(isFullScreen: true)),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Color(0xFF8696A3), // Lighter muted outer circle
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 41,
              height: 41,
              decoration: BoxDecoration(
                color: context.colors.primary, // Inner dark charcoal circle
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
