import 'package:common/services/notification_service.dart';

import '../authentication_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Register extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(
                    "Sign Up",
                    style: _theme.textTheme.headline6!.copyWith(
                      fontSize: 30.0,
                    ),
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
                SignupForm(),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?"),
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("Log in"))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignupForm extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  SignupForm({
    Key? key,
  }) : super(key: key);

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  late String phoneNumber;

  bool loginPassObscureText = true;
  bool signupConfirmPassObscureText = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  controller: firstNameController,
                  decoration: InputDecoration(
                    labelText: "First name",
                  ),
                  textInputAction: TextInputAction.next,
                ),
              ),
              SizedBox(width: 15.0),
              Expanded(
                child: TextFormField(
                  controller: lastNameController,
                  decoration: InputDecoration(
                    labelText: "Last name",
                  ),
                  textInputAction: TextInputAction.next,
                ),
              )
            ],
          ),
          const SizedBox(
            height: 20.0,
          ),
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
            inputDecoration: InputDecoration(
                labelText: "Phone number",
                border: Theme.of(context).inputDecorationTheme.border),
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
          const SizedBox(
            height: 20.0,
          ),
          TextFormField(
            obscureText: loginPassObscureText,
            controller: passwordController,
            decoration: InputDecoration(
              labelText: "Password",
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () {
                    loginPassObscureText = !loginPassObscureText;
                    setState(() {});
                  },
                  icon: Icon(!loginPassObscureText
                      ? Icons.visibility
                      : Icons.visibility_off),
                ),
              ),
            ),
            textInputAction: TextInputAction.next,
            validator: (s) => passwordValidator(s, context),
          ),
          SizedBox(
            height: 20.0,
          ),
          TextFormField(
            controller: confirmPasswordController,
            obscureText: signupConfirmPassObscureText,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
                labelText: 'Confirm password',
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    onPressed: () {
                      signupConfirmPassObscureText =
                          !signupConfirmPassObscureText;
                      setState(() {});
                    },
                    icon: Icon(!signupConfirmPassObscureText
                        ? Icons.visibility
                        : Icons.visibility_off),
                  ),
                )),
            validator: (s) =>
                confirmPasswordValidator(s, context, passwordController),
          ),
          const SizedBox(height: 20.0),
          Text(
            "By clicking \"Sign Up\" you agree to our terms and conditions as well as our pricacy policy",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          Consumer(builder: (context, ref, child) {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: 45.0,
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    ref.read(authenticationProvider).signup(
                        firstName: firstNameController.text,
                        lastName: lastNameController.text,
                        phoneNumber: phoneNumber,
                        password: passwordController.text,
                        fcmToken:
                            ref.read(notificationProvider).token ?? "asd");
                  }
                  // Navigator.of(context).push(
                  //     MaterialPageRoute(builder: (_) => OtpVerification()));
                },
                child: Text(
                  "SIGN UP",
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                ),
              ),
            );
          })
        ],
      ),
    );
  }

  String? passwordValidator(s, context) {
    if (s == null || s.trim().isEmpty) {
      return "* Field required";
    }
    if (s.length < 6) {
      return 'Password must be at least characters';
    }
    return null;
  }

  String? confirmPasswordValidator(s, context, passwordController) {
    if (s.trim().isEmpty) {
      return "Field required";
    }
    if (s.trim() != passwordController.text) {
      return "Password does not match";
    }
    return null;
  }
}
