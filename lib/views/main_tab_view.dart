// lib/views/main_tab_view.dart

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';

import 'package:realestate_app/viewmodels/property_viewmodel.dart';
import 'package:realestate_app/viewmodels/favorite_viewmodel.dart';
import 'package:realestate_app/views/properties/favorite_list_view.dart';
import 'package:realestate_app/views/properties/home_view.dart';
import 'package:realestate_app/views/properties/my_properties_list_view.dart';
import 'package:realestate_app/views/profile_view.dart';

class MainTabView extends StatelessWidget {
  const MainTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final client = GraphQLProvider.of(context).value;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PropertyViewModel(client: client)..fetchProperties(),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoriteViewModel()..fetchFavorites(),
        ),
      ],
      child: const _MainTabViewContent(),
    );
  }
}

class _MainTabViewContent extends StatefulWidget {
  const _MainTabViewContent();
  @override
  State<_MainTabViewContent> createState() => _MainTabViewContentState();
}

class _MainTabViewContentState extends State<_MainTabViewContent>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeView(),
    MyPropertiesListView(),
    FavHistoryView(),
    ProfileView(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _pages.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index != _currentIndex &&
          !_tabController.indexIsChanging) {
        _onTabChanged(_tabController.index);
      }
    });
  }

  void _onTabChanged(int newIndex) {
    setState(() => _currentIndex = newIndex);

    // Lazy-load "Mis Propiedades"
    if (newIndex == 1 &&
        context.read<PropertyViewModel>().myPropertiesState ==
            PropertyState.initial) {
      context.read<PropertyViewModel>().fetchMyProperties();
    }
    // Lazy-load "Favoritos"
    if (newIndex == 2 &&
        context.read<FavoriteViewModel>().state == FavoriteState.initial) {
      context.read<FavoriteViewModel>().fetchFavorites();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const activeColor = Colors.white;
    final unselectedColor =
        activeColor.computeLuminance() < 0.5 ? Colors.white70 : Colors.black54;

    return Scaffold(
      body: BottomBar(
        body: (context, scrollController) => TabBarView(
          controller: _tabController,
          children: _pages
              .map((w) => PrimaryScrollController(
                    controller: scrollController,
                    child: w,
                  ))
              .toList(),
        ),
        // Styling
        barColor: cs.primary,
        borderRadius: BorderRadius.circular(32),
        width: MediaQuery.of(context).size.width * 0.9,
        hideOnScroll: true,
        icon: (w, h) => Center(
          child: Icon(Icons.arrow_upward, size: w, color: activeColor),
        ),
        showIcon: true,
        offset: 20,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        respectSafeArea: true,
        barDecoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [], // <- no hairline
        ),
        // The floating bar itself
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              // <- hide the hairline

              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(color: activeColor, width: 4),
                insets: EdgeInsets.fromLTRB(16, 0, 16, 8),
              ),
              tabs: [
                _buildTabIcon(Icons.home, 0, activeColor, unselectedColor),
                _buildTabIcon(Icons.business, 1, activeColor, unselectedColor),
                _buildTabIcon(Icons.favorite, 2, activeColor, unselectedColor),
                _buildTabIcon(Icons.person, 3, activeColor, unselectedColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabIcon(IconData icon, int index, Color active, Color inactive) {
    return SizedBox(
      height: 55,
      width: 60,
      child: Center(
        child: Icon(
          icon,
          size: 28,
          color: _currentIndex == index ? active : inactive,
        ),
      ),
    );
  }
}
