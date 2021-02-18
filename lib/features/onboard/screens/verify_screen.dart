import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_segment/flutter_segment.dart';
import 'package:fusecash/constants/variables.dart';
import 'package:fusecash/generated/i18n.dart';
import 'package:fusecash/models/app_state.dart';
import 'package:fusecash/widgets/main_scaffold.dart';
import 'package:fusecash/widgets/primary_button.dart';
import 'package:fusecash/redux/viewsmodels/onboard.dart';
import 'package:fusecash/widgets/snackbars.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';

class VerifyScreen extends StatefulWidget {
  final String verificationId;
  VerifyScreen({this.verificationId});
  @override
  _VerifyScreenState createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  String autoCode = "";
  TextEditingController codeController = TextEditingController(text: '');

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Segment.screen(screenName: '/verify-phone-number-screen');
    return StoreConnector<AppState, OnboardViewModel>(
      distinct: true,
      converter: OnboardViewModel.fromStore,
      onInitialBuild: (viewModel) {
        if (viewModel.credentials != null && viewModel.verificationId != null) {
          autoCode = viewModel.credentials.smsCode ?? "";
          viewModel.verify(autoCode);
        }
      },
      onWillChange: (previousViewModel, newViewModel) {
        if (previousViewModel.verifyErrorMessage !=
            newViewModel.verifyErrorMessage) {
          showErrorSnack(
              title: I18n.of(context).oops,
              message: newViewModel.verifyErrorMessage,
              duration: Duration(seconds: 3),
              context: context,
              margin: EdgeInsets.only(top: 8, right: 8, left: 8, bottom: 120));
          Future.delayed(Duration(seconds: Variables.INTERVAL_SECONDS), () {
            newViewModel.resetErrors();
          });
        }
      },
      builder: (_, viewModel) {
        return MainScaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          withPadding: true,
          title: I18n.of(context).sign_up,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                  left: 20.0, right: 20.0, bottom: 20.0, top: 10.0),
              child: Column(
                children: <Widget>[
                  Text(
                      I18n.of(context).we_just_sent +
                          "${viewModel.phoneNumber}" +
                          "\n",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      )),
                  Text(I18n.of(context).enter_verification_code,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      )),
                  Padding(
                    padding: EdgeInsets.only(left: 0.0, top: 10.0, right: 0.0),
                    child: Container(
                      width: 280,
                      child: Theme(
                        data: ThemeData(
                          hintColor: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        child: PinInputTextField(
                          pinLength: 6,
                          decoration: UnderlineDecoration(
                            colorBuilder: FixedColorListBuilder(
                              List<Color>.filled(
                                6,
                                Color(0xFFDDDDDD),
                              ),
                            ),
                          ),
                          controller: codeController,
                          autoFocus: true,
                          textInputAction: TextInputAction.go,
                          onSubmit: (pin) {},
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
          footer: Container(
            child: Column(
              children: <Widget>[
                SizedBox(height: 10.0),
                Center(
                  child: PrimaryButton(
                    label: I18n.of(context).next_button,
                    labelFontWeight: FontWeight.normal,
                    fontSize: 16,
                    preload: viewModel.isVerifyRequest,
                    onPressed: () {
                      viewModel.verify(codeController.text);
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      I18n.of(context).didnt_get_message,
                      style: TextStyle(fontSize: 12),
                    ),
                    FlatButton(
                      padding: EdgeInsets.only(right: 10),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        I18n.of(context).resend_code,
                        style: TextStyle(color: Colors.blue, fontSize: 12),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
