import 'package:flutter/material.dart';
import 'package:onlinegroceries/common/color_extension.dart';
import 'package:onlinegroceries/view/home/home_screen.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView>
    with SingleTickerProviderStateMixin {
  TabController? controller;
  int selectTab = 0;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 5, vsync: this);
    controller?.addListener(() {
      selectTab = controller?.index ?? 0;
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: TabBarView(
          controller: controller,
          children: [
            const HomeView(),
            Container(),
            Container(),
            Container(),
            Container(),
          ],
        ),
        bottomNavigationBar: Container(
          child: BottomAppBar(
            child: TabBar(
              controller: controller,
              indicatorColor: Colors.transparent,
              indicatorWeight: 1,
              labelColor: TColor.primary,
              labelStyle: TextStyle(
                  color: TColor.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
              unselectedLabelColor: TColor.primaryText,
              unselectedLabelStyle: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
              tabs: [
                Tab(
                  text: "Shop",
                  icon: Image.asset(
                    "assets/img/store_tab.png",
                    width: 25,
                  ),
                ),
                Tab(
                  text: "Explore",
                  icon: Image.asset(
                    "assets/img/explore_tab.png",
                    width: 25,
                  ),
                ),
                Tab(
                  text: "cart",
                  icon: Image.asset(
                    "assets/img/cart_tab.png",
                    width: 25,
                  ),
                ),
                Tab(text: "Favourite",
                  icon: Image.asset(
                    "assets/img/fav_tab.png",
                    width: 25,

                  ),
                ),
                Tab(text: "Account",
                  icon: Image.asset(
                    "assets/img/account_tab.png",
                    width: 25,

                  ),
                )
              ],
            ),
          ),
        ));
  }
}
