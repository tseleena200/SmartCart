import 'package:flutter/material.dart';

import 'package:onlinegroceries/common_widget/round_button.dart';
import 'package:onlinegroceries/view/login/login_view.dart';

import '../../common/color_extension.dart';
import '../../common_widget/dropdown.dart';

class SelectLocationView extends StatefulWidget {
  const SelectLocationView({super.key});

  @override
  State<SelectLocationView> createState() => _SelectLocationViewState();
}

class _SelectLocationViewState extends State<SelectLocationView> {
  TextEditingController txtOTP = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);

    return Stack(
      children: [
        Container(
          color: Colors.white,
          child: Image.asset(
            "assets/img/bottom_bg.png",
            width: media.width,
            height: media.height,
            fit: BoxFit.cover,
          ),
        ),
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Image.asset(
                "assets/img/back.png",
                width: 20,
                height: 20,
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/img/select_location.png",
                      width: media.width * 0.6,
                    ),
                    SizedBox(
                      height: media.width * 0.1,
                    ),
                    Text(
                      "Select Your Location ",
                      style: TextStyle(
                        color: TColor.primaryText,
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: media.width * 0.03,
                    ),
                    Text(
                      "Switch on  Your Location ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: TColor.secondaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      height: media.width * 0.1,
                    ),
                    Dropdown(
                      title: "Your Zone",
                      placeholder: "Select your zone",
                      ValueList: const ["Zone 1", "Zone 2"],
                      didChange: (sObj) {},
                    ),
                    SizedBox(
                      height: media.width * 0.07,
                    ),
                    Dropdown(
                      title: "Your Area",
                      placeholder: "Select your zone",
                      ValueList: const ["Area 1", "Area 2"],
                      didChange: (sObj) {},
                    ),
                    SizedBox(
                      height: media.width * 0.07,
                    ),
                    RoundButton(
                        title: "Submit",
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LogInView()));
                        })
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
