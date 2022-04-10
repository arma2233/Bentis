import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:untitled/%20services/auth.dart';
import 'package:untitled/screens/authenticate/register.dart';
import 'package:untitled/screens/home/home.dart';
import 'package:untitled/shared/Loading.dart';
import 'package:untitled/shared/constants.dart';
// For Overrided MaterialPageRout to tCustomPageRoute. To stop animation
class CustomPageRoute extends MaterialPageRoute {
  CustomPageRoute({builder}) : super(builder: builder);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);
}
//----------------------------------------------------------------------

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);


  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  final _formKeyOTP = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String phoneNumber = 'numeris';
  final TextEditingController otpController = new TextEditingController();

  var isLoading = false;
  var isResend = false;
  var isLoginScreen = false;
  var isOTPScreen = true;
  var verificationCode = '';

  bool _isButtonLoading = false;
  bool wrongNumber = true;
  bool showError = false;

  @override
  void initState() {
    if (_auth.currentUser != null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => Home(),
        ),
            (route) => false,
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isOTPScreen ? returnOTPScreen() : returnLoginScreen();
  }

  Widget returnLoginScreen() {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Container(
                    padding: EdgeInsets.all(30),
                    width: double.infinity,
                    height: MediaQuery
                        .of(context)
                        .size
                        .height,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FadeInDown(
                          delay: Duration(milliseconds: 150),
                          child: Image(
                            image: AssetImage("assets/images/B_2.png"),
                            fit: BoxFit.cover,
                            width: 200,
                          ),
                        ),

                        SizedBox(height: 15,),
                        FadeInDown(
                          delay: Duration(milliseconds: 300),
                          child: Text('LOGIN',
                            style: TextStyle(fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Colors.grey.shade900),),
                        ),
                        FadeInDown(
                          delay: Duration(milliseconds: 450),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 20),
                            child: Text('Login to your account',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey.shade700),),
                          ),
                        ),
                        SizedBox(height: 25,),
                        FadeInDown(
                            delay: Duration(milliseconds: 600),
                            child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.grey.shade200, width: 2),
                                ),
                                child: Stack(
                                  children: [
                                    InternationalPhoneNumberInput(
                                      onInputChanged: (PhoneNumber number) {
                                        setState(() {
                                          phoneNumber = number.phoneNumber!;
                                        });
                                      },
                                      onInputValidated: (bool value) {
                                        if (value) {
                                          setState(() {
                                            wrongNumber = false;
                                            print('Phone number: $phoneNumber');
                                          });
                                        }
                                        else {
                                          setState(() {
                                            wrongNumber = true;
                                            phoneNumber = '';
                                          });
                                        }
                                        print(value);
                                      },
                                      selectorConfig: SelectorConfig(
                                        selectorType: PhoneInputSelectorType
                                            .BOTTOM_SHEET,
                                      ),

                                      initialValue: PhoneNumber(isoCode: 'LT'),
                                      ignoreBlank: false,
                                      autoValidateMode: AutovalidateMode
                                          .disabled,
                                      validator: (val) {
                                        if (wrongNumber) {
                                          setState(() {
                                            showError = true;
                                          });
                                        } else {
                                          setState(() {
                                            showError = false;
                                          });
                                        }
                                        return null;
                                      },

                                      selectorTextStyle: TextStyle(color: Colors
                                          .black),
                                      textFieldController: TextEditingController(),
                                      formatInput: false,
                                      maxLength: 9,
                                      keyboardType:
                                      TextInputType.numberWithOptions(
                                          signed: true, decimal: true),
                                      cursorColor: Colors.black,
                                      inputDecoration: InputDecoration(
                                        contentPadding: EdgeInsets.only(
                                            bottom: 15, left: 0),
                                        border: InputBorder.none,
                                        hintText: 'Phone Number',
                                        hintStyle: TextStyle(
                                            color: Colors.black.withOpacity(
                                                0.5),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                    Positioned(
                                      left: 90,
                                      top: 8,
                                      bottom: 8,
                                      child: Container(
                                        height: 40,
                                        width: 1,
                                        color: Colors.black.withOpacity(0.13),
                                      ),
                                    ),
                                  ],
                                )
                            )
                        ),
                        SizedBox(height: 3,),
                        Column(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                (wrongNumber && showError)
                                    ? 'Number is invalid'
                                    : '',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Colors.red, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15,),
                        FadeInDown(
                          delay: Duration(milliseconds: 750),
                          child: MaterialButton(
                            onPressed: () {
                              if (wrongNumber) {
                                setState(() {
                                  showError = true;
                                });
                                return;
                              }

                              setState(() {
                                _isButtonLoading = true;
                              });

                              Future.delayed(Duration(milliseconds: 1500), () {
                                setState(() {
                                  _isButtonLoading = false;
                                  isOTPScreen = true;
                                  isLoginScreen = false;
                                });
                              });
                            },
                            color: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 30),
                            child: _isButtonLoading ? Container(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                                color: Colors.black,
                                strokeWidth: 2,
                              ),
                            ) :
                            Text("Login", style: TextStyle(
                                color: Colors.white, fontSize: 16.0),),
                          ),
                        ),
                        SizedBox(height: 15,),
                        FadeInDown(
                          delay: Duration(milliseconds: 900),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Don\'t have an account?',
                                style: TextStyle(color: Colors.grey.shade700),),
                              SizedBox(width: 5,),
                              InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => Register()));
                                },
                                child: Text('Register', style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400),),
                              )
                            ],
                          ),
                        )
                      ],
                    )
                )
            )
        )
    );
  }

  Widget returnOTPScreen() {
    return Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKeyOTP,
            child: Container(
              padding: EdgeInsets.all(30),
              width: double.infinity,
              height: MediaQuery
                  .of(context)
                  .size
                  .height,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network('https://ouch-cdn2.icons8.com/n9XQxiCMz0_zpnfg9oldMbtSsG7X6NwZi_kLccbLOKw/rs:fit:392:392/czM6Ly9pY29uczgu/b3VjaC1wcm9kLmFz/c2V0cy9zdmcvNDMv/MGE2N2YwYzMtMjQw/NC00MTFjLWE2MTct/ZDk5MTNiY2IzNGY0/LnN2Zw.png', fit: BoxFit.cover, width: 280, ),
                    SizedBox(height: 50,),
                    FadeInDown(
                      delay: Duration(milliseconds: 150),
                      child: Text('VERIFICATION',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.grey.shade900),),
                    ),
                    FadeInDown(
                      delay: Duration(milliseconds: 300),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20),
                        child: Text('Enter the code sent to: $phoneNumber',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),),
                      ),
                    ),
                    SizedBox(height: 20,),
                    /// Cia bus langeliai kur irasomas OTP kodas.
                    SizedBox(height: 20,),
                    FadeInDown(
                      delay: Duration(milliseconds: 450),
                      child: MaterialButton(
                        onPressed: () {
                          setState(() {
                            _isButtonLoading = true;
                          });

                          Future.delayed(Duration(milliseconds: 1500), () {
                            setState(() {
                              _isButtonLoading = false;
                            });
                          });
                        },
                        color: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: 15, horizontal: 30),
                        child: _isButtonLoading ? Container(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.white,
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        ) :
                        Text("Verify", style: TextStyle(
                            color: Colors.white, fontSize: 16.0),),
                      ),
                    ),
                  ]
              )
            )
          )
        )
    );
  }
}
