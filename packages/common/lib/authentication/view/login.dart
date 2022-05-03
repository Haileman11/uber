import 'package:common/authentication/authentication_controller.dart';
import 'package:common/authentication/view/register.dart';
import 'package:common/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: _theme.scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        elevation: 0.0,
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => Register(),
                ),
              );
            },
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child:
                  Text("Sign Up", style: Theme.of(context).textTheme.headline6),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(
                    "Log In",
                    style: _theme.textTheme.headline6!.copyWith(
                      fontSize: 30.0,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                LoginForm()
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  LoginForm({Key? key}) : super(key: key);
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  late String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InternationalPhoneNumberInput(
            keyboardAction: TextInputAction.next,
            onInputChanged: (PhoneNumber number) {},
            initialValue: PhoneNumber(isoCode: 'ET'),
            onInputValidated: (bool value) {
              print(value);
            },
            selectorConfig: const SelectorConfig(
              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
            ),
            ignoreBlank: false,
            // inputDecoration: InputDecoration(
            //     labelText: AppLocalizations.of(context)
            //         .translate('hint_mobile_no')),
            textFieldController: phoneController,
            autoValidateMode: AutovalidateMode.onUserInteraction,
            selectorTextStyle: Theme.of(context).textTheme.bodyText1,
            keyboardType: const TextInputType.numberWithOptions(
                signed: true, decimal: true),
            onSaved: (PhoneNumber number) {
              phoneNumber = number.toString();
            },
            // errorMessage: AppLocalizations.of(context)
            //     .translate('error_enter_valid_phone_no'),
          ),
          SizedBox(
            height: 20.0,
          ),
          TextFormField(
            controller: passwordController,
            decoration: InputDecoration(
              labelText: "Password",
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Text(
            "Forgot password?",
          ),
          SizedBox(
            height: 25.0,
          ),
          Consumer(builder: (context, ref, child) {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: 45.0,
              child: ElevatedButton(
                onPressed: () {
                  // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=>));
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    ref.read(authenticationProvider).login(
                          phoneNumber: phoneNumber,
                          password: passwordController.text,
                          fcmToken:
                              ref.read(notificationProvider).token ?? "asd",
                        );
                  }
                  //   {
                  //   "username": "newuser",
                  //   "password": "Password@123",
                  // }
                },
                child: Text(
                  "LOG IN",
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                ),
              ),
            );
          })
        ],
      ),
    );
  }
}
