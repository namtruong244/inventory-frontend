import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/inventory_models.dart';
import '../providers/inventory_provider.dart';
import '../widgets/app_image_view.dart';
import '../widgets/home_tab_support.dart';
import 'alerts_screen.dart';
import 'box_details_screen.dart';
import 'boxes_screen.dart';
import 'item_details_screen.dart';
import 'items_screen.dart';
import 'lending_tracker_screen.dart';
import 'qr_scanner_tab.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

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
        backgroundColor: const Color(0xFFF8F9FA),
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
                      color: const Color(0xFFF8F9FA).withValues(alpha: 0.95),
                    ),
                  ),
                ),
              ),
            _buildBottomNav(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context, listen: false);

    return RefreshIndicator(
      onRefresh: () => provider.fetchAllData(),
      color: const Color(0xFF18181B),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _homeScrollController,
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderWithSearch(context),
            const SizedBox(height: 38), // Space for overlapping search bar
            _buildConnectionBanner(context),
            _buildAlertBanner(context),
            _buildQuickModulesSection(context),
            const SizedBox(height: 28),
            _buildStorageSpacesSection(context),
            const SizedBox(height: 32),
            _buildRecentItemsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionBanner(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, provider, _) {
        if (provider.isConnected) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFCA5A5)),
          ),
          child: Row(
            children: [
              const Icon(Icons.cloud_off_rounded, color: Color(0xFFEF4444), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Cannot connect to backend (${provider.serverUrl})',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF991B1B)),
                ),
              ),
              TextButton(
                onPressed: () => provider.fetchAllData(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Retry', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlertBanner(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, provider, _) {
        final alertCount = provider.totalAlertCount;
        final overdueCount = provider.getOverdueLoans().length;
        final expiredCount = provider.getExpiredItems().length;
        if (alertCount == 0) return const SizedBox.shrink();

        String alertMessage = '';
        if (overdueCount > 0 && expiredCount > 0) {
          alertMessage = '$overdueCount overdue loan & $expiredCount expired item require action';
        } else if (overdueCount > 0) {
          alertMessage = '$overdueCount item loan is currently overdue!';
        } else {
          alertMessage = '$alertCount items/warranties require your attention';
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFCA5A5).withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFDC2626),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Action Required',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF991B1B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      alertMessage,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.25,
                        color: Color(0xFFB91C1C),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _navigateWithOverlayRestore(const AlertsScreen()),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF18181B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Review',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickModulesSection(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final activeLoans = provider.getActiveLoans().length;
    final totalAlerts = provider.totalAlertCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          // Lending Tracker Quick Card
          Expanded(
            child: GestureDetector(
              onTap: () => _navigateWithOverlayRestore(const LendingTrackerScreen()),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.handshake_outlined,
                        color: Color(0xFF2563EB),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lending',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF18181B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            activeLoans > 0 ? '$activeLoans Active' : 'No Loans',
                            style: TextStyle(
                              fontSize: 12,
                              color: activeLoans > 0 ? const Color(0xFF2563EB) : Colors.grey.shade500,
                              fontWeight: activeLoans > 0 ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Expiration & Alerts Quick Card
          Expanded(
            child: GestureDetector(
              onTap: () => _navigateWithOverlayRestore(const AlertsScreen()),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (totalAlerts > 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981))
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        totalAlerts > 0 ? Icons.notifications_active_outlined : Icons.shield_outlined,
                        color: totalAlerts > 0 ? const Color(0xFFDC2626) : const Color(0xFF059669),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Alerts',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF18181B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            totalAlerts > 0 ? '$totalAlerts Issues' : 'All Clear',
                            style: TextStyle(
                              fontSize: 12,
                              color: totalAlerts > 0 ? const Color(0xFFDC2626) : const Color(0xFF059669),
                              fontWeight: totalAlerts > 0 ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
          decoration: const BoxDecoration(
            color: Color(0xFF18181B), // Dark Charcoal
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
                              'Hey ${firstName.isNotEmpty ? firstName : "there"} !',
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
                        const Text(
                          "Track & manage\nyour inventory!",
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
                          return GestureDetector(
                            onTap: () => _navigateWithOverlayRestore(const AlertsScreen()),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.12),
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
                          return GestureDetector(
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
                                backgroundColor: const Color(0xFF27272A),
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
          child: GestureDetector(
            onTap: () => _navigateWithOverlayRestore(const SearchScreen()),
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
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
                  Icon(Icons.search, color: Colors.grey.shade400, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Search',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF18181B),
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

  Widget _buildStorageSpacesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header: "Storage Spaces" & "View all"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'Storage Spaces',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF18181B),
                  letterSpacing: -0.5,
                ),
              ),
              GestureDetector(
                onTap: () => _onTabSelected(1), // Go to Box tab
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View all',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Horizontal Storage Spaces Carousel
        SizedBox(
          height: 232,
          child: Consumer<InventoryProvider>(
            builder: (context, provider, _) {
              final boxes = provider.boxes;
              if (boxes.isEmpty) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F6),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 36, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          'No storage spaces yet',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: boxes.length,
                itemBuilder: (context, index) {
                  final box = boxes[index];
                  final itemCount = provider.countTotalItemsIn(box.id);
                  final subBoxCount = provider.getBoxesIn(box.id).length;

                  return _buildStorageSpaceCard(
                    box: box,
                    itemCount: itemCount,
                    subBoxCount: subBoxCount,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStorageSpaceCard({
    required Box box,
    required int itemCount,
    required int subBoxCount,
  }) {
    IconData boxIcon;
    final nameLower = box.name.toLowerCase();
    if (nameLower.contains('game')) {
      boxIcon = Icons.sports_esports_outlined;
    } else if (nameLower.contains('elec') || nameLower.contains('tech') || nameLower.contains('gadget')) {
      boxIcon = Icons.devices_outlined;
    } else if (nameLower.contains('cloth') || nameLower.contains('wardrobe')) {
      boxIcon = Icons.checkroom_outlined;
    } else if (nameLower.contains('tool') || nameLower.contains('garage') || nameLower.contains('hardware')) {
      boxIcon = Icons.handyman_outlined;
    } else if (nameLower.contains('kitchen') || nameLower.contains('pantry') || nameLower.contains('food')) {
      boxIcon = Icons.restaurant_outlined;
    } else if (nameLower.contains('book') || nameLower.contains('doc') || nameLower.contains('office')) {
      boxIcon = Icons.menu_book_outlined;
    } else {
      boxIcon = box.type.icon;
    }

    return GestureDetector(
      onTap: () => _navigateWithOverlayRestore(BoxDetailsScreen(boxId: box.id)),
      child: Container(
        width: 215,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFE4E4E7), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Icon circle + Storage Type pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF4F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    boxIcon,
                    color: const Color(0xFF18181B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      box.type.displayName.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: Color(0xFF52525B),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              box.name,
              style: const TextStyle(
                color: Color(0xFF18181B),
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            // Description / Location
            Text(
              box.description.isNotEmpty
                  ? box.description
                  : (box.parentId != null ? 'Sub-container in location' : 'Primary storage space'),
              style: const TextStyle(
                color: Color(0xFF71717A),
                fontSize: 12,
                height: 1.35,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const Spacer(),

            // Bottom Row: Item count & Nested containers badge + Arrow button
            Row(
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE4E4E7)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 13,
                          color: Color(0xFF18181B),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            '$itemCount ${itemCount == 1 ? "item" : "items"}${subBoxCount > 0 ? " • $subBoxCount ${subBoxCount == 1 ? (box.type == StorageType.room ? "box" : "container") : (box.type == StorageType.room ? "boxes" : "containers")}" : ""}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF18181B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFF18181B),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentItemsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header: "Recent Items" & "View all"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'Recent Items',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF18181B),
                  letterSpacing: -0.5,
                ),
              ),
              GestureDetector(
                onTap: () => _onTabSelected(2), // Go to Item tab
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View all',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Vertical Item Cards
        Consumer<InventoryProvider>(
          builder: (context, provider, _) {
            final items = provider.items;
            if (items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF1F1F4)),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 36, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          'No items in inventory yet',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap + to add your first item',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // Show recent items (up to 6)
            final recentItems = items.reversed.take(6).toList();

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: recentItems.length,
              itemBuilder: (context, index) {
                final item = recentItems[index];
                final parentBox = provider.getBoxById(item.boxId);

                return _buildRecentItemRowCard(
                  item: item,
                  boxName: parentBox?.name ?? 'Storage Box',
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentItemRowCard({
    required Item item,
    required String boxName,
  }) {
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    final qtyText = provider.formatQty(item.quantity, item.unit);

    return GestureDetector(
      onTap: () => _navigateWithOverlayRestore(ItemDetailsScreen(itemId: item.id)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F1F4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Item Visual (Image or Category Icon)
            if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
              AppImageView(
                imageUrlOrPath: item.imageUrl!,
                width: 48,
                height: 48,
                borderRadius: BorderRadius.circular(14),
                fit: BoxFit.cover,
              )
            else
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  CategoryHelper.getCategoryIcon(item.categoryId),
                  color: const Color(0xFF18181B),
                  size: 22,
                ),
              ),
            const SizedBox(width: 14),

            // Item Content: Name, Storage Box & Category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF18181B),
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 13,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          boxName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          '•',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          item.categoryId,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Trailing: Quantity & Status Badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  qtyText,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF18181B),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (item.isLowStock ? const Color(0xFFF59E0B) : item.status.color)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.isLowStock ? 'Low Stock' : item.status.displayName,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: item.isLowStock ? const Color(0xFFD97706) : item.status.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
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
              tooltip: 'Home',
            ),
            // 1: Box
            _buildNavItem(
              index: 1,
              icon: Icons.inventory_2_outlined,
              activeIcon: Icons.inventory_2_rounded,
              tooltip: 'Box',
            ),
            // QR Scan Action Button (opens camera fullscreen, no navbar)
            _buildCenterQRButton(),
            // 2: Item
            _buildNavItem(
              index: 2,
              icon: Icons.category_outlined,
              activeIcon: Icons.category_rounded,
              tooltip: 'Item',
            ),
            // 3: Setting
            _buildNavItem(
              index: 3,
              icon: Icons.settings_outlined,
              activeIcon: Icons.settings_rounded,
              tooltip: 'Setting',
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
      child: GestureDetector(
        onTap: () => _onTabSelected(index),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 48,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                size: 24,
                color: isSelected
                    ? const Color(0xFF18181B)
                    : Colors.grey.shade400,
              ),
              const SizedBox(height: 4),
              // Small active indicator dot - close and snug to the icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isSelected ? 4 : 0,
                height: 4,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF18181B)
                      : Colors.transparent,
                  shape: BoxShape.circle,
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
      message: 'Scan QR Code',
      child: GestureDetector(
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
                color: const Color(0xFF18181B), // Inner dark charcoal circle
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
