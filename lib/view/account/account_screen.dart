import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onlinegroceries/common/color_extension.dart';
import 'package:onlinegroceries/common_widget/account_row.dart';
import 'package:onlinegroceries/view/account/payment_methods.dart';
import 'package:onlinegroceries/view/login/login_view.dart';
import '../favourite/favourite_screen.dart';
import '../my_cart/transaction_history_view.dart';
import '../recommendation/recommendation_screen.dart';
import 'Help_screen.dart';
import 'about_view.dart';
import 'my_details_screen.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  String userName = '';
  String userEmail = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc =
      await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        setState(() {
          userName = data['name'] ?? '';
          userEmail = data['email'] ?? '';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(35),
                      child: Image.asset(
                        "assets/img/u1.png",
                        width: 60,
                        height: 60,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                userName.isEmpty ? 'Smart Cart User' : userName,
                                style: TextStyle(
                                  color: TColor.primaryText,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.edit,
                                color: TColor.primary,
                                size: 18,
                              )
                            ],
                          ),
                          Text(
                            userEmail.isEmpty ? 'No email found' : userEmail,
                            style: TextStyle(
                              color: TColor.secondaryText,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const Divider(color: Colors.black26, height: 1),

              AccountRow(
                title: 'Transaction History',
                icon: "assets/img/a_order.png",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TransactionHistoryView()),
                  );
                },
              ),
              AccountRow(
                title: 'My Details',
                icon: "assets/img/a_my_detail.png",
                onPressed: () => Get.to(() => MyDetailsView()),
              ),
              AccountRow(title: 'Payment Methods', icon: "assets/img/paymenth_methods.png",  onPressed: () => Get.to(() => PaymentMethodsView()),),
              AccountRow(title: 'Favorites', icon: "assets/img/paymenth_methods.png", onPressed: () => Get.to(() => FavouriteView()),),
              AccountRow(title: 'My Recommendations', icon: "assets/img/paymenth_methods.png", onPressed: () => Get.to(() => RecommendationsView()),),
              AccountRow(title: 'Promo Codes', icon: "assets/img/a_promocode.png", onPressed: () {}),
              AccountRow(title: 'Help', icon: "assets/img/a_help.png",  onPressed: () => Get.to(() => HelpView()),),
              AccountRow(title: 'About', icon: "assets/img/a_about.png", onPressed: () => Get.to(() => AboutView()),),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MaterialButton(
                      onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser;

                        if (user != null) {
                          await FirebaseFirestore.instance
                              .collection('Users')
                              .doc(user.uid)
                              .update({
                            'accountStatus': 'Inactive',
                            'lastActiveAt': FieldValue.serverTimestamp(),
                          });
                        }

                        await FirebaseAuth.instance.signOut();

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LogInView()),
                              (route) => false,
                        );
                      },
                      height: 60,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(19),
                      ),
                      minWidth: double.maxFinite,
                      elevation: 0.1,
                      color: const Color(0xffF2F3F2),
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Log Out",
                                style: TextStyle(
                                  color: TColor.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Image.asset("assets/img/logout.png", width: 20, height: 20),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
