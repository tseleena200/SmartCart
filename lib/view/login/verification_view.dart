import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onlinegroceries/common_widget/line_textfield.dart';
import '../../common/color_extension.dart';
import '../../controllers/auth_controller.dart';

class VerificationView extends StatefulWidget {
  final String verificationId;
  final String phone;
  final String firstName;
  final String lastName;
  final String dob;
  final String branch;
  final bool receivePromos;

  const VerificationView({
    super.key,
    required this.verificationId,
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.dob,
    required this.branch,
    required this.receivePromos,
  });

  @override
  State<VerificationView> createState() => _VerificationViewState();
}

class _VerificationViewState extends State<VerificationView> {
  TextEditingController txtOTP = TextEditingController();

  int _resendCountdown = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _resendCountdown = 30;
    _canResend = false;

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (_resendCountdown == 0) {
        setState(() => _canResend = true);
        return false;
      } else {
        setState(() => _resendCountdown--);
        return true;
      }
    });
  }

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: media.width * 0.1),
                    Text(
                      "Enter Your 6 - Digit Code",
                      style: TextStyle(
                        color: TColor.primaryText,
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 15),
                    LineTextField(
                      title: "Code",
                      placeholder: "- - - - - -",
                      controller: txtOTP,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: media.width * 0.3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _canResend
                              ? () {
                            AuthController.instance.sendOTP(
                              phoneNumber: widget.phone,
                              firstName: widget.firstName,
                              lastName: widget.lastName,
                              dob: widget.dob,
                              branch: widget.branch,
                              receivePromos: widget.receivePromos,
                            );
                            _startCountdown();
                          }
                              : null,
                          child: Text(
                            _canResend
                                ? "Resend Code"
                                : "Resend in $_resendCountdown s",
                            style: TextStyle(
                              color:
                              _canResend ? TColor.primary : Colors.grey,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () {
                            final otp = txtOTP.text.trim();

                            if (otp.length != 6) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                  Text("Please enter the 6-digit OTP"),
                                ),
                              );
                              return;
                            }

                            AuthController.instance.verifyAndRegisterOTP(
                              verificationId: widget.verificationId,
                              smsCode: otp,
                              phone: widget.phone,
                              firstName: widget.firstName,
                              lastName: widget.lastName,
                              dob: widget.dob,
                              branch: widget.branch,
                              receivePromos: widget.receivePromos,
                            );
                          },
                          child: Container(
                            width: 60,
                            height: 60,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: TColor.primary,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Image.asset(
                              "assets/img/next.png",
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ),
                      ],
                    )
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
