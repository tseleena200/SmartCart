import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  final TextEditingController txtOTP = TextEditingController();
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
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text(
                "Verification Code",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                "Please enter the 6-digit code sent to\n${widget.phone}",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: TColor.secondaryText),
              ),
              const SizedBox(height: 32),

              // OTP Input Box
              SizedBox(
                width: media.width * 0.6,
                child: TextField(
                  controller: txtOTP,
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 28, letterSpacing: 10),
                  decoration: InputDecoration(
                    counterText: "",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    hintText: "- - - - - -",
                    hintStyle: const TextStyle(letterSpacing: 10, fontSize: 28),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Resend
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
                  _canResend ? "Resend Code" : "Resend in $_resendCountdown s",
                  style: TextStyle(
                    color: _canResend ? TColor.primary : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Continue Button
              ElevatedButton(
                onPressed: () {
                  final otp = txtOTP.text.trim();

                  if (otp.length != 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter the 6-digit OTP"),
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
                    isLogin: widget.firstName.isEmpty,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primary,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
