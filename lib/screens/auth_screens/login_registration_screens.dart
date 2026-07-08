import 'package:flutter/material.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:uruvia/welcome/data_sync.dart';
import 'package:uruvia/widgets/custom_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/colors.dart';
import 'registration_page.dart';

class LoginRegistrationScreens extends StatelessWidget {
  const LoginRegistrationScreens({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                SizedBox(
                  child: Column(
                    children: [
                      Image.asset("assets/img/logo.png", height: 80, width: 80),
                      SizedBox(height: 16.0,),
                      interText(text: "Uruvia", colors: Colors.black, fontWeight: FontWeight.bold, size: 30.0),
                      SizedBox(height: 10.0,),
                      googleSansText(text: "Your business command centre", colors: Colors.black, fontWeight: FontWeight.normal, size: 16.0, textAlign: TextAlign.center),
                      SizedBox(height: 10.0,),
                    ],
                  ),
                ),
                FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    height: 200.0,
                    width: 200.0,
                    child: Image.asset("assets/img/3d-assets.png"),

                  ),
                ),
                Spacer(),
                FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () => slideRightWidget(newPage: DataSyncPage(), context: context,),
                          style: ButtonStyle(
                            fixedSize: WidgetStateProperty.all(Size(MediaQuery.of(context).size.width, 44.0)),
                            backgroundColor: WidgetStateProperty.all(ConstantColor.blueBackground),
                            shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
                          ),
                          child: interText(text: "Log in", colors: Colors.white, fontWeight: FontWeight.w700, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                        ),
                        SizedBox(height: 5.0,),
                        ElevatedButton(
                          onPressed: () => slideRightWidget(newPage: const RegistrationPage(), context: context,),
                          style: ButtonStyle(
                            fixedSize: WidgetStateProperty.all(Size(MediaQuery.of(context).size.width, 44.0)),
                            backgroundColor: WidgetStateProperty.all(ConstantColor.lightBackground),
                            shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0), side: BorderSide(color: ConstantColor.lightBackground, width: 2.0,),)),
                          ),
                          child: interText(text: "Sign up for free", colors: ConstantColor.blueBackground, fontWeight: FontWeight.w700, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                        ),
                        SizedBox(height: 24.0,),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: FittedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 1.0,
                                  width: MediaQuery.of(context).size.width / 5.0,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: ConstantColor.paragraphTextSecondary, width: 1.0),
                                  ),
                                ),
                                SizedBox(width: 12.0,),
                                interText(text: "OR CONTINUE WITH", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.w600, size: 11.0, textAlign: TextAlign.center, softWrap: true),
                                SizedBox(width: 12.0,),
                                Container(
                                  height: 1.0,
                                  width: MediaQuery.of(context).size.width / 5.0,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: ConstantColor.paragraphTextSecondary, width: 1.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 48.0,
                              width: 48.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100.0),
                                color: ConstantColor.lightBackground,
                                border: Border.all(color: ConstantColor.paragraphTextSecondary, width: 1.0),
                              ),
                              child: Center(
                                child: SvgPicture.asset("assets/svg/fingerprint.svg"),
                              ),
                            ),
                            SizedBox(width: 15.0,),
                            Container(
                              height: 48.0,
                              width: 48.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100.0),
                                color: ConstantColor.lightBackground,
                                border: Border.all(color: ConstantColor.paragraphTextSecondary, width: 1.0),
                              ),
                              child: Center(
                                child: SvgPicture.asset("assets/svg/passkey.svg"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
