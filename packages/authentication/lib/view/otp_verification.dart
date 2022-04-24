import 'package:authentication/authentication_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  final String phone;
  final resetData;
  final bool isReset;
  const VerificationScreen(this.phone,
      {Key? key, this.resetData, this.isReset = false})
      : super(key: key);
  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  var _formdata = <String, String>{};
  bool isLoading = false;
  final codeLength = 6;
  List<FocusNode> focusNodes = [];
  List<bool> isActive = [];
  List<TextEditingController> controllers = [];

  var endTime = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, DateTime.now().hour, DateTime.now().minute + 30)
      .millisecondsSinceEpoch;

  void verify() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      var code = '';
      _formdata.forEach((key, value) {
        code += value;
      });
      await ref
          .read(authenticationProvider)
          .confirmPhoneNumber(widget.phone, code, widget.isReset);
    }
  }

  void resend() async {
    await ref.read(authenticationProvider).resetPassword(widget.phone);
  }

  void updateFocusNodes() {
    for (var i = 0; i < codeLength; i++) {
      focusNodes[i].addListener(() {
        bool status;
        status = focusNodes[i].hasFocus;
        if (status == true) {
          setState(() {
            isActive[i] = true;
          });
        } else {
          setState(() {
            isActive[i] = false;
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < codeLength; i++) {
      focusNodes.add(FocusNode());
      isActive.add(false);
      controllers.add(TextEditingController());
    }
    updateFocusNodes();
  }

  @override
  Widget build(BuildContext context) {
    var boxDecoration = BoxDecoration(
      color: Theme.of(context).backgroundColor,
      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2))],
      // border: Border.all(color: Colors.transparent),
      // borderRadius: BorderRadius.all(Radius.circular(5)),
    );
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          // shadowColor: Colors.transparent,
          iconTheme: Theme.of(context).iconTheme,
          elevation: 0,
        ),
        body: Consumer(
          child: const CircularProgressIndicator.adaptive(),
          builder: (context, watch, child) {
            // if (ref.watch(authenticationProvider).isLoading) {
            //   return child;
            // }
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'We have sent verification code to ${widget.phone} ',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Enter code to verify phone number',
                          style: Theme.of(context).textTheme.headline6),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ...List.generate(
                                  codeLength,
                                  (index) => Expanded(
                                    child: Container(
                                      height: 80,
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: boxDecoration,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: TextFormField(
                                          controller: controllers[index],
                                          focusNode: focusNodes[index],
                                          onChanged: (term) {
                                            if (term.isEmpty) {
                                              index == 0
                                                  ? FocusScope.of(context)
                                                      .unfocus()
                                                  : FocusScope.of(context)
                                                      .requestFocus(focusNodes[
                                                          index - 1]);
                                            } else {
                                              index == codeLength - 1
                                                  ? FocusScope.of(context)
                                                      .unfocus()
                                                  : FocusScope.of(context)
                                                      .requestFocus(focusNodes[
                                                          index + 1]);
                                            }
                                          },
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.all(0)),
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(1)
                                          ],
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5,
                                          onSaved: (term) {
                                            _formdata.addEntries([
                                              MapEntry('$index', term ?? '')
                                            ]);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // CountdownTimer(
                            //   endTime: endTime,
                            //   widgetBuilder: (_, time) {
                            //     if (time == null) {
                            //       return Text(
                            //           "Code expired. Click resend to get a new code",
                            //           style:
                            //               Theme.of(context).textTheme.bodyText1);
                            //     }
                            //     return Text(
                            //       ' ${time.hours ?? '0'}:${time.min ?? '0'}:${time.sec ?? '0'}',
                            //       style: Theme.of(context).textTheme.bodyText2,
                            //       textAlign: TextAlign.center,
                            //     );
                            //   },
                            // ),
                            const SizedBox(height: 16.0),
                            SizedBox(
                              width: double.maxFinite,
                              height: 40,
                              child: ElevatedButton(
                                child: Text("Verify"),
                                onPressed: () {
                                  verify();
                                },
                              ),
                            ),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text("Did not receive?"),
                                  TextButton(
                                    onPressed: () => resend(),
                                    child: Text("Resend code"),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
