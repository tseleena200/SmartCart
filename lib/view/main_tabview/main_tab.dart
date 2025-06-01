import 'package:flutter/material.dart';
import 'package:onlinegroceries/common/color_extension.dart';
import 'package:onlinegroceries/view/account/account_screen.dart';
import 'package:onlinegroceries/view/explore/explore_screen.dart';
import 'package:onlinegroceries/view/favourite/favourite_screen.dart';
import 'package:onlinegroceries/view/home/home_screen.dart';
import 'package:onlinegroceries/view/my_cart/cart_screen.dart';
import 'package:onlinegroceries/view/recommendation/recommendation_screen.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeView(),
    ExploreView(),
    MyCartView(),
    FavouriteView(),
    RecommendationsView(),
    AccountView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(26),
            topRight: Radius.circular(26),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: TColor.primary,
            unselectedItemColor: TColor.primaryText,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            items: [
              BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/img/store_tab.png",
                  width: 24,
                  height: 24,
                  color: _selectedIndex == 0 ? TColor.primary : TColor.primaryText.withOpacity(0.6),
                ),
                label: "Shop",
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/img/explore_tab.png",
                  width: 24,
                  height: 24,
                  color: _selectedIndex == 1 ? TColor.primary : TColor.primaryText.withOpacity(0.6),
                ),
                label: "Explore",
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/img/cart_tab.png",
                  width: 24,
                  height: 24,
                  color: _selectedIndex == 2 ? TColor.primary : TColor.primaryText.withOpacity(0.6),
                ),
                label: "Cart",
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/img/fav_tab.png",
                  width: 24,
                  height: 24,
                  color: _selectedIndex == 3 ? TColor.primary : TColor.primaryText.withOpacity(0.6),
                ),
                label: "Favour",
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/img/recommendation.png",
                  width: 24,
                  height: 24,
                  color: _selectedIndex == 4 ? TColor.primary : TColor.primaryText.withOpacity(0.6),
                ),
                label: "Recom",
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/img/account_tab.png",
                  width: 24,
                  height: 24,
                  color: _selectedIndex == 5 ? TColor.primary : TColor.primaryText.withOpacity(0.6),
                ),
                label: "Account",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
