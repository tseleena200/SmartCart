import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../AdminCategory/add_category.dart';
import '../../AdminCategory/admin_category.dart';
import '../../products/add_product_view.dart';
import '../../products/product_list_view.dart';
import '../../users/users_screen.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset("assets/images/logo.png"),
          ),
          DrawerListTile(
            title: "Dashboard",
            svgSrc: "assets/icons/menu_dashboard.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Manage Users",
            svgSrc: "assets/icons/menu_tran.svg",
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UsersScreen()),
              );
            },
          ),
          DrawerListTile(
            title: "Manage Products",
            svgSrc: "assets/icons/menu_task.svg",
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductListView()),
              );
            },
          ),
          DrawerListTile(
            title: "Add Products",
            svgSrc: "assets/icons/menu_task.svg",
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddProductView()),
              );
            },
          ),
          DrawerListTile(
            title: "Manage Categories",
            svgSrc: "assets/icons/menu_task.svg",
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminCategoryListView()),
              );
            },
          ),
          DrawerListTile(
            title: " Add Categories",
            svgSrc: "assets/icons/menu_task.svg",
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddCategoryView()),
              );
            },
          ),
          DrawerListTile(
            title: "Notification",
            svgSrc: "assets/icons/menu_notification.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Profile",
            svgSrc: "assets/icons/menu_profile.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Settings",
            svgSrc: "assets/icons/menu_setting.svg",
            press: () {},
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        colorFilter: ColorFilter.mode(Colors.white54, BlendMode.srcIn),
        height: 16,
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}
