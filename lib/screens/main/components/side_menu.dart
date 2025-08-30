import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../Reviews/review_list_view.dart';
import '../../../constants.dart';
import '../../AdminCategory/add_category.dart';
import '../../AdminCategory/admin_category.dart';
import '../../products/add_product_view.dart';
import '../../products/manage_stock_view.dart';
import '../../products/product_list_view.dart';
import '../../trasactions/transaction_list_view.dart';
import '../../users/users_screen.dart';
import '../../Recommendations/admin_recommendations_page.dart';
import '../../notifications/admin_notifications_view.dart';
import '../profile/admin_profile_view.dart';
import '../../auth/admin_login_view.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: sidebarColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: secondaryColor.withOpacity(0.35)),
            child: Image.asset("assets/images/logo.png"),
          ),

          _NavTile(
            title: "Dashboard",
            svg: "assets/icons/menu_dashboard.svg",
            onTap: () {},
          ),

          _NavTile(
            title: "Users",
            svg: "assets/icons/menu_tran.svg",
            onTap: () => _push(context, const UsersScreen()),
          ),

          _Group(
            title: "Products",
            svg: "assets/icons/menu_task.svg",
            children: [
              _SubTile(
                title: "Manage Products",
                onTap: () => _push(context, const ProductListView()),
              ),
              _SubTile(
                title: "Add Product",
                onTap: () => _push(context, const AddProductView()),
              ),
              _SubTile(
                title: "Manage Stock",
                onTap: () => _push(context, const ManageStockView()),
              ),
            ],
          ),

          _Group(
            title: "Categories",
            svg: "assets/icons/menu_task.svg",
            children: [
              _SubTile(
                title: "Manage Categories",
                onTap: () => _push(context, const AdminCategoryListView()),
              ),
              _SubTile(
                title: "Add Category",
                onTap: () => _push(context, const AddCategoryView()),
              ),
            ],
          ),

          _NavTile(
            title: "Reviews",
            svg: "assets/icons/menu_task.svg",
            onTap: () => _push(context, const AdminReviewListView()),
          ),

          _NavTile(
            title: "Transactions",
            svg: "assets/icons/menu_task.svg",
            onTap: () => _push(context, const TransactionListView()),
          ),

          _NavTile(
            title: "Recommendations",
            svg: "assets/icons/menu_task.svg",
            onTap: () => _push(context, const AdminRecommendationsPage()),
          ),

          _NavTile(
            title: "Notifications",
            svg: "assets/icons/menu_notification.svg",
            onTap: () => _push(context, const AdminNotificationsView()),
          ),

          const Divider(height: 24, thickness: 0.4, color: Colors.white24),

          _NavTile(
            title: "Profile",
            svg: "assets/icons/menu_profile.svg",
            onTap: () => _push(context, const AdminProfileView()),
          ),
          _NavTile(
            title: "Settings",
            svg: "assets/icons/menu_setting.svg",
            onTap: () {},
          ),

          // Pretty logout button (matches profile screen style)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: _LogoutButton(
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminLoginView()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ================== building blocks ==================

class _NavTile extends StatelessWidget {
  final String title;
  final String svg;
  final VoidCallback onTap;
  const _NavTile({required this.title, required this.svg, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      horizontalTitleGap: 10,
      leading: SvgPicture.asset(
        svg,
        height: 18,
        colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      hoverColor: Colors.white.withOpacity(0.05),
      selectedTileColor: secondaryColor.withOpacity(0.25),
    );
  }
}

class _Group extends StatelessWidget {
  final String title;
  final String svg;
  final List<Widget> children;
  const _Group({required this.title, required this.svg, required this.children});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        collapsedIconColor: Colors.white70,
        iconColor: Colors.white70,
        leading: SvgPicture.asset(
          svg,
          height: 18,
          colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        childrenPadding: const EdgeInsets.only(left: 54, right: 12),
        children: children,
      ),
    );
  }
}

class _SubTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const _SubTile({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      title: Text(title, style: const TextStyle(color: Colors.white70)),
      onTap: onTap,
      hoverColor: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

// Looks like profile screen action button: rounded, bordered, subtle primary tint
class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(.16),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryColor.withOpacity(.6)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

void _push(BuildContext context, Widget page) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => page));
}
