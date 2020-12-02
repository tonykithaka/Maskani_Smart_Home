import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maskanismarthome/animation_engine/fadeInAnimation.dart';
import 'package:maskanismarthome/animation_engine/sizeAnimation.dart';
import 'package:maskanismarthome/animation_engine/slideUpAnimation.dart';
import 'package:maskanismarthome/models/scenes.dart';
import 'package:maskanismarthome/models/users.dart';
import 'package:maskanismarthome/repository/Dialogs.dart';
import 'package:maskanismarthome/repository/UserRepo.dart';
import 'package:maskanismarthome/repository/scenes/Scenes.dart';
import 'package:maskanismarthome/style/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweetalert/sweetalert.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  CarouselController buttonCarouselController = CarouselController();
  final createUserFormKey = new GlobalKey<FormState>();
  final loginUserFormKey = new GlobalKey<FormState>();

  //  Style Variables
  int delayAmount = 0;
  var buttonLabel = 'Sign Up';
  var buttonMethod;

  Color defaultColor1 = Colors.black;
  Color defaultColor2 = Colors.grey;

  var fullNameController = TextEditingController();
  var emailController = TextEditingController();
  var phoneNumberController = TextEditingController();
  var passwordController = TextEditingController();
  var passwordRepeatController = TextEditingController();

  var loginEmailAddressController = TextEditingController();
  var loginPasswordController = TextEditingController();

  String full_name;
  String email_address;
  String phone_number;
  String password;
  String repeatPassword;
  String final_message;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  var userClass = new Users();
  var scenesClass = new Scenes();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.buttonLabel = 'Sign Up';
    this.buttonMethod;
    this.final_message = "please wait...";
  }

  //  Change signup/login button/title
  validateCurrentPage(int index, BuildContext context) {
    print(index);
    if (index == 0) {
      setState(() {
        print(index);
        this.defaultColor1 = Colors.black;
        this.defaultColor2 = Colors.grey;
        this.buttonLabel = 'Sign Up';
        this.buttonMethod = validateProcessRegistrationForm(context);
      });
    } else {
      setState(() {
        print(index);
        this.defaultColor1 = Colors.grey;
        this.defaultColor2 = Colors.black;
        this.buttonLabel = 'Login';
        this.buttonMethod = validateProcessLoginForm(context);
      });
    }
  }

  // Validate and process sign up form
  validateProcessRegistrationForm(BuildContext context) async {
    if (emailController.text.isEmpty) {
      print('No validation');
    } else {
      print('Validating login form...');
      if (createUserFormKey.currentState.validate()) {
        print("Validation successfull");
        createUserFormKey.currentState.save();
        full_name = fullNameController.text;
        email_address = emailController.text;
        phone_number = phoneNumberController.text;
        password = passwordController.text;

        SignUpUser(context, full_name, email_address, phone_number, password);
      }
    }
  }

  SignUpUser(BuildContext context, String fullName, String email,
      String phoneNumber, String password) async {
    final SharedPreferences prefs = await _prefs;
    try {
      Dialogs.showLoadingDialog(context, _keyLoader); //invoking login
      SignUpData signupData =
          await userClass.SignUp(fullName, email, phoneNumber, password);

      if (signupData.success == 1) {
        LoginData loginData = await userClass.SignIn(email, password);
        if (loginData.success == 1) {
          prefs.setString("token", loginData.token);
          print(loginData.data.fullName);
          prefs.setString("full_name", loginData.data.fullName);
          prefs.setString("user_id", loginData.data.userId);
          Navigator.of(_keyLoader.currentContext, rootNavigator: true)
              .pop(); //close the dialoge
          Navigator.pushReplacementNamed(context, "/home");
        }
      } else {
        this.final_message = signupData.message;
      }
    } catch (error) {
      print(error);
    }
  }

  //  Validate and process login form
  validateProcessLoginForm(BuildContext context) {
    if (loginEmailAddressController.text.isEmpty &&
        loginPasswordController.text.isEmpty) {
    } else {
      print('Validating login form...');
      if (loginUserFormKey.currentState.validate()) {
        print("Validation successfull");
        loginUserFormKey.currentState.save();
        var email = loginEmailAddressController.text;
        var password = loginPasswordController.text;
        SignInUser(context, email, password);
      } else {
        print("Validation failed");
      }
    }
  }

  SignInUser(BuildContext context, String email, String password) async {
    final SharedPreferences prefs = await _prefs;
    try {
      Dialogs.showLoadingDialog(context, _keyLoader); //invoking login
      LoginData loginData = await userClass.SignIn(email, password);

      if (loginData.success == 1) {
        prefs.setString("token", loginData.token);
        print(loginData.data.fullName);
        prefs.setString("full_name", loginData.data.fullName);
        prefs.setString("user_id", loginData.data.userId);
        ScenesData scenesData =
            await scenesClass.FetchUserScenes(loginData.data.userId);
        if (scenesData.success == 1) {
          //close the dialoge

          Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
          Navigator.pushReplacementNamed(context, "/home");

          //close the dialoge
        } else {
          Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
          SweetAlert.show(context,
              subtitle: loginData.message, style: SweetAlertStyle.error);
        }
      } else {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        SweetAlert.show(context,
            subtitle: loginData.message, style: SweetAlertStyle.error);
      }
    } catch (error) {
      print(error);
    }
  }

  //Sign Up

  Widget _ReqistrationForm() {
    return Form(
      key: createUserFormKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage(
                  "assets/text_background.png",
                ),
              ),
            ),
            child: TextFormField(
              controller: fullNameController,
              keyboardType: TextInputType.text,
              validator: (value) => (value.isEmpty) || value == ""
                  ? "Enter your full name"
                  : null,
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  fontSize: 15.0),
              decoration: InputDecoration(
                  enabledBorder: const UnderlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.transparent, width: 1.0),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  contentPadding: EdgeInsets.only(
                      top: 15.0, bottom: 15.0, left: 50.0, right: 50.0),
                  hintText: 'Full Name',
                  hintStyle: TextStyle(
                      letterSpacing: 0,
                      fontSize: 14.0,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600),
                  prefixIcon: const Icon(
                    Icons.person,
                    color: Color(0xFF222222),
                    size: 20.0,
                  ),
                  prefixIconConstraints: BoxConstraints(
                    minWidth: 30,
                    minHeight: 25,
                  ),
                  // fillColor: Color(0xffEFEFEF),
                  border: new UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.white,
                          width: 1.0,
                          style: BorderStyle.none)),
                  filled: true),
            ),
          ),
          Container(
            height: SizeConfig.blockSizeVertical * 2,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage(
                  "assets/text_background.png",
                ),
              ),
            ),
            child: TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (val) => val.length == 0 || val == ""
                  ? "Enter your email address"
                  : null,
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  fontSize: 15.0),
              decoration: InputDecoration(
                  enabledBorder: const UnderlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.transparent, width: 1.0),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  contentPadding: EdgeInsets.all(15.0),
                  hintText: 'Email Address',
                  hintStyle: TextStyle(
                      letterSpacing: 0,
                      fontFamily: 'Montserrat',
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600),
                  prefixIcon: const Icon(
                    Icons.mail,
                    color: Color(0xFF222222),
                    size: 15.0,
                  ),
                  prefixIconConstraints: BoxConstraints(
                    minWidth: 30,
                    minHeight: 25,
                  ),
                  fillColor: Color(0xffEFEFEF),
                  filled: true),
            ),
          ),
          Container(
            height: SizeConfig.blockSizeVertical * 2,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage(
                  "assets/text_background.png",
                ),
              ),
            ),
            child: TextFormField(
              controller: phoneNumberController,
              keyboardType: TextInputType.phone,
              validator: (val) => val.length == 0 || val == ""
                  ? "Enter your phone number"
                  : null,
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  fontSize: 15.0),
              decoration: InputDecoration(
                  enabledBorder: const UnderlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.transparent, width: 1.0),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  contentPadding: EdgeInsets.all(15.0),
                  hintText: 'Phone Number',
                  hintStyle: TextStyle(
                      letterSpacing: 0,
                      fontFamily: 'Montserrat',
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600),
                  prefixIcon: const Icon(
                    Icons.phone,
                    color: Color(0xFF222222),
                    size: 15.0,
                  ),
                  prefixIconConstraints: BoxConstraints(
                    minWidth: 30,
                    minHeight: 25,
                  ),
                  fillColor: Color(0xffEFEFEF),
                  filled: true),
            ),
          ),
          Container(
            height: SizeConfig.blockSizeVertical * 2,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage(
                  "assets/text_background.png",
                ),
              ),
            ),
            child: TextFormField(
              controller: passwordController,
              obscureText: true,
              keyboardType: TextInputType.text,
              validator: (val) =>
                  val.length == 0 || val == "" ? "Enter your password" : null,
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  fontSize: 15.0),
              decoration: InputDecoration(
                  enabledBorder: const UnderlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.transparent, width: 1.0),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  contentPadding: EdgeInsets.all(15.0),
                  hintText: 'Password',
                  hintStyle: TextStyle(
                      letterSpacing: 0,
                      fontFamily: 'Montserrat',
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600),
                  prefixIcon: const Icon(
                    Icons.lock,
                    color: Color(0xFF222222),
                    size: 15.0,
                  ),
                  prefixIconConstraints: BoxConstraints(
                    minWidth: 30,
                    minHeight: 25,
                  ),
                  fillColor: Color(0xffEFEFEF),
                  filled: true),
            ),
          ),
          Container(
            height: SizeConfig.blockSizeVertical * 2,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage(
                  "assets/text_background.png",
                ),
              ),
            ),
            child: TextFormField(
              controller: passwordRepeatController,
              obscureText: true,
              keyboardType: TextInputType.text,
              validator: (val) =>
                  val.length == 0 || val == "" ? "Repeat your password" : null,
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  fontSize: 15.0),
              decoration: InputDecoration(
                  enabledBorder: const UnderlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.transparent, width: 1.0),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  contentPadding: EdgeInsets.all(15.0),
                  hintText: 'Repeat Password',
                  hintStyle: TextStyle(
                      letterSpacing: 0,
                      fontFamily: 'Montserrat',
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600),
                  prefixIcon: const Icon(
                    Icons.lock,
                    color: Color(0xFF222222),
                    size: 15.0,
                  ),
                  prefixIconConstraints: BoxConstraints(
                    minWidth: 30,
                    minHeight: 25,
                  ),
                  fillColor: Color(0xffEFEFEF),
                  filled: true),
            ),
          ),
        ],
      ),
    );
  }

  //Sign up form

  Widget _LoginForm() {
    bool checkedValue = false;
    return Form(
        key: loginUserFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 50,
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage(
                    "assets/text_background.png",
                  ),
                ),
              ),
              child: TextFormField(
                controller: loginEmailAddressController,
                validator: (val) => val.length == 0 || val == ""
                    ? "Enter your email address"
                    : null,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 15.0),
                decoration: InputDecoration(
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: const BorderSide(
                          color: Colors.transparent, width: 1.0),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    contentPadding: EdgeInsets.all(15.0),
                    hintText: 'Email Address',
                    hintStyle: TextStyle(
                        letterSpacing: 0,
                        fontFamily: 'Montserrat',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600),
                    prefixIcon: const Icon(
                      Icons.email,
                      color: Color(0xFF222222),
                      size: 15.0,
                    ),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: 30,
                      minHeight: 25,
                    ),
                    fillColor: Colors.transparent,
                    filled: true),
              ),
            ),
            Container(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage(
                    "assets/text_background.png",
                  ),
                ),
              ),
              child: TextFormField(
                controller: loginPasswordController,
                validator: (val) =>
                    val.length == 0 || val == "" ? "Enter your password" : null,
                obscureText: true,
                keyboardType: TextInputType.text,
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 15.0),
                decoration: InputDecoration(
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: const BorderSide(
                          color: Colors.transparent, width: 1.0),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    contentPadding: EdgeInsets.all(15.0),
                    hintText: 'Password',
                    hintStyle: TextStyle(
                        letterSpacing: 0,
                        fontFamily: 'Montserrat',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600),
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Color(0xFF222222),
                      size: 15.0,
                    ),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: 30,
                      minHeight: 25,
                    ),
                    fillColor: Colors.transparent,
                    filled: true),
              ),
            ),
            SizedBox(
              height: 15.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 20.0,
                      width: 20.0,
                      child: Checkbox(
                        value: checkedValue,
                        onChanged: (newValue) {
                          setState(() {
                            checkedValue = newValue;
                          });
                        },
                        // controlAffinity:
                        //     ListTileControlAffinity.leading, //  <-- leading Checkbox
                      ),
                    ),
                    SizedBox(
                      width: 5.0,
                    ),
                    Text(
                      'Stay signed in',
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14.0,
                          fontWeight: FontWeight.w700),
                    )
                  ],
                ),
                InkWell(
                  onTap: () {
                    print('forgot password');
                  },
                  child: Container(
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14.0,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                )
              ],
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: Color(0xFFF8F7F8),
        body: Stack(
          children: <Widget>[
            Container(
                child: SizeAnimation(
              Image(
                height: MediaQuery.of(context).size.height,
                alignment: Alignment.bottomCenter,
                fit: BoxFit.fitWidth,
                image: AssetImage('assets/Welcome_Background@2x.png'),
              ),
            )),
            Container(
                height: SizeConfig.blockSizeVertical * 14.0,
                margin:
                    EdgeInsets.only(top: SizeConfig.blockSizeVertical * 18.0),
                child: SlideUpAnimation(
                  child: SizeAnimation(Image.asset(
                    'assets/Logo@2x.png',
                    alignment: Alignment.topCenter,
                  )),
                  delay: delayAmount,
                )),
            Container(
                width: double.maxFinite,
                alignment: Alignment.center,
                child: SlideUpAnimation(
                  child: FadeOut(
                    child: SlideUpAnimation(
                      delay: delayAmount,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            height: SizeConfig.blockSizeVertical * 5.0,
                          ),
                          Text(
                            'Hey there!',
                            style: TextStyle(
                                fontFamily: 'TitilliumWeb',
                                fontSize: 30.0,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF222222)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    delay: delayAmount + 1500,
                  ),
                  delay: delayAmount + 2500,
                )),
            SlideLeftAnimation(
              delay: delayAmount + 4000,
              child: FadeIn(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  alignment: Alignment.bottomCenter,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(
                            right: SizeConfig.blockSizeHorizontal * 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              InkWell(
                                child: Padding(
                                  child: Text(
                                    "Sign Up",
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w600,
                                        color: defaultColor1,
                                        letterSpacing: 0),
                                  ),
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, bottom: 5),
                                ),
                                onTap: () =>
                                    buttonCarouselController.previousPage(
                                        duration: Duration(milliseconds: 500),
                                        curve: Curves.decelerate),
                              ),
                              Container(
                                height: 15.0,
                                width: 1.5,
                                color: Colors.grey,
                                margin: EdgeInsets.only(
                                    left: 10.0, right: 10.0, bottom: 5),
                              ),
                              InkWell(
                                child: Padding(
                                  child: Text(
                                    "Login  ",
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w600,
                                        color: defaultColor2,
                                        letterSpacing: 0),
                                  ),
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, bottom: 5),
                                ),
                                onTap: () => buttonCarouselController.nextPage(
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.decelerate),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 10.0,
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              left: SizeConfig.blockSizeHorizontal * 8,
                              right: SizeConfig.blockSizeHorizontal * 8,
                              bottom: SizeConfig.blockSizeVertical * 2),
                          constraints: BoxConstraints(
                              minHeight: SizeConfig.blockSizeVertical * 20,
                              minWidth: double.infinity),
                          padding: EdgeInsets.only(top: 10.0),
                          decoration: BoxDecoration(
                            color: Color(0xffEFEFEF),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                            gradient: LinearGradient(
                                colors: [Color(0xFFFFFFFF), Color(0xFFd9d9d9)],
                                stops: [0.0, 1.0],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Container(
                                child: CarouselSlider(
                                  carouselController: buttonCarouselController,
                                  items: [_ReqistrationForm(), _LoginForm()]
                                      .map((i) {
                                    return Builder(
                                      builder: (BuildContext context) {
                                        return SingleChildScrollView(
                                          child: Container(
                                              constraints: BoxConstraints(
                                                  minHeight: SizeConfig
                                                          .blockSizeVertical *
                                                      20,
                                                  minWidth: double.infinity),
                                              padding: EdgeInsets.all(20.0),
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 5.0),
                                              child: i),
                                        );
                                      },
                                    );
                                  }).toList(),
                                  options: CarouselOptions(
                                      height: SizeConfig.blockSizeVertical * 45,
                                      viewportFraction: 1,
                                      enableInfiniteScroll: false,
                                      initialPage: 0,
                                      onPageChanged: (index, reason) {
                                        this.validateCurrentPage(
                                            index, context);
                                      }),
                                ),
                              ),
                              Container(
                                width: double.maxFinite,
                                alignment: Alignment.bottomRight,
                                child: InkWell(
                                  onTap: () {
                                    if (this.buttonLabel == 'Sign Up') {
                                      this.validateProcessRegistrationForm(
                                          context);
                                    } else {
                                      this.validateProcessLoginForm(context);
                                    }
                                  },
                                  child: FractionallySizedBox(
                                    widthFactor: 0.5,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10.0),
                                          bottomRight: Radius.circular(10.0)),
                                      child: Container(
                                        padding: EdgeInsets.all(20.0),
                                        color: Color(0xFF222222),
                                        alignment: Alignment.center,
                                        child: Text(buttonLabel.toUpperCase(),
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontFamily: 'Montserrat',
                                                letterSpacing: 1.0,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500)),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                delay: delayAmount + 4000,
              ),
            )
          ],
        ),
      ),
    );
  }
}
