import 'package:flutter/material.dart';
import 'package:onlinegroceries/common_widget/round_button.dart';

import '../../common/color_extension.dart';

class OrderCompletedView extends StatefulWidget {
  const OrderCompletedView({super.key});

  @override
  State<OrderCompletedView> createState() => _OrderCompletedViewState();
}

class _OrderCompletedViewState extends State<OrderCompletedView> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Image.asset(
            "assets/img/bottom_bg.png",
            width: media.width,
            height: media.height,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  const Spacer(),
                  Image.asset(
                    "assets/img/order_accpeted.png",
                    width: media.width * 0.7,
                  ),
                  const SizedBox(height: 40,),
                  Text(
                    "Payment Successful!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20,),
                  Text(
                    "Your order has been completed successfully!\n\n"
                        "Thank you for shopping with Smart Cart.\n"
                        "We hope you had a wonderful experience ! \n and look forward to seeing you again!"
                    ,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  const Spacer(),
                  RoundButton(title: "View Order Details", onPressed: () {}),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Back To Home",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: TColor.primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
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
}
