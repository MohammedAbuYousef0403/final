import 'package:country_code_picker/country_code_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mealup/network_api/Retro_Api.dart';
import 'package:mealup/network_api/api_client.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/auth/login_screen.dart';
import 'package:mealup/screens/otp_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_lable_widget.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/card_password_textfield.dart';
import 'package:mealup/utils/card_textfield.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/hero_image_app_logo.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/localization/locale_constant.dart';
import 'package:mealup/utils/rounded_corner_app_button.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateNewAccount extends StatefulWidget {
  @override
  _CreateNewAccountState createState() => _CreateNewAccountState();
}

class Item {
  const Item(this.name, this.icon);

  final String name;
  final Icon icon;
}

class _CreateNewAccountState extends State<CreateNewAccount> {
  bool _passwordVisible = true;
  bool _confirmpasswordVisible = true;

  Item selectedUser;
  List<Item> users = <Item>[
    const Item(
        'Android',
        Icon(
          Icons.android,
          color: const Color(0xFF167F67),
        )),
    const Item(
        'Flutter',
        Icon(
          Icons.flag,
          color: const Color(0xFF167F67),
        )),
    const Item(
        'ReactNative',
        Icon(
          Icons.format_indent_decrease,
          color: const Color(0xFF167F67),
        )),
    const Item(
        'iOS',
        Icon(
          Icons.mobile_screen_share,
          color: const Color(0xFF167F67),
        )),
  ];

  final _textFullName = TextEditingController();
  final _textEmail = TextEditingController();
  final _textPassword = TextEditingController();
  final _textConfPassword = TextEditingController();
  final _textContactNo = TextEditingController();
  final _formKey = new GlobalKey<FormState>();
  String strCountryCode = '+968';
  ProgressDialog progressDialog;
  String strLanguage = '';

  List<String> _listLanguages = [];

  int radioIndex;

  void changeIndex(int index) {
    setState(() {
      radioIndex = index;
    });
  }

  Widget getChecked() {
    return Container(
      width: 25,
      height: 25,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: SvgPicture.asset(
          'images/ic_check.svg',
          width: 15,
          height: 15,
        ),
      ),
      decoration: myBoxDecorationChecked(false, Color(Constants.colorTheme)),
    );
  }

  Widget getunChecked() {
    return Container(
      width: 25,
      height: 25,
      decoration: myBoxDecorationChecked(true, Colors.white),
    );
  }

  BoxDecoration myBoxDecorationChecked(bool isBorder, Color color) {
    return BoxDecoration(
      color: color,
      border: isBorder ? Border.all(width: 1.0) : null,
      borderRadius: BorderRadius.all(
          Radius.circular(8.0) //                 <--- border radius here
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    getLanguageList();
  }

  @override
  Widget build(BuildContext context) {
    // print(context);
    progressDialog = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      isDismissible: false,
    );

    progressDialog.style(
      message: Languages.of(context).labelPleaseWait,
      borderRadius: 5.0,
      backgroundColor: Colors.white,
      progressWidget: SpinKitFadingCircle(color: Color(Constants.colorTheme)),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      progressTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          fontFamily: Constants.appFont),
      messageTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          fontFamily: Constants.appFont),
    );

    dynamic screenWidth = MediaQuery.of(context).size.width;
    dynamic screenHeight = MediaQuery.of(context).size.height;

    ScreenUtil.init(
        BoxConstraints(maxWidth: screenWidth, maxHeight: screenHeight),
        designSize: Size(360, 690),
        orientation: Orientation.portrait);

    return SafeArea(
      child: Scaffold(
        appBar: ApplicationToolbar(
            appbarTitle: Languages.of(context).labelCreateNewAccount),
        backgroundColor: Color(0xFFFAFAFA),
        body: SingleChildScrollView(
          child: Column(
            children: [
              HeroImage(),
              SizedBox(
                height: ScreenUtil().setHeight(10),
              ),
              Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage('images/ic_background_image.png'),
                  fit: BoxFit.cover,
                )),
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(ScreenUtil().setWidth(30),
                      ScreenUtil().setHeight(30), ScreenUtil().setWidth(30), 0),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        AppLableWidget(
                          title: Languages.of(context).labelFullName,
                        ),
                        CardTextFieldWidget(
                          focus: (v) {
                            FocusScope.of(context).nextFocus();
                          },
                          textInputAction: TextInputAction.next,
                          hintText:
                              Languages.of(context).labelEnterYourFullName,
                          textInputType: TextInputType.text,
                          textEditingController: _textFullName,
                          validator: kvalidateFullName,
                        ),
                        AppLableWidget(
                          title: Languages.of(context).labelEmail,
                        ),
                        CardTextFieldWidget(
                          focus: (v) {
                            FocusScope.of(context).nextFocus();
                          },
                          textInputAction: TextInputAction.next,
                          hintText: Languages.of(context).labelEnterYourEmailID,
                          textInputType: TextInputType.emailAddress,
                          textEditingController: _textEmail,
                          validator: kvalidateEmail,
                        ),
                        AppLableWidget(
                          title: Languages.of(context).labelContactNumber,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                elevation: 5.0,
                                child: Container(
                                  height: ScreenUtil().setHeight(50),
                                  child: CountryCodePicker(
                                    onChanged: (c) {
                                      setState(() {
                                        strCountryCode = c.dialCode;
                                      });
                                    },
                                    // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                    initialSelection: 'OM',
                                    favorite: ['+968', 'OM'],
                                    hideMainText: true,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                elevation: 5.0,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: ScreenUtil().setWidth(15),
                                    right: ScreenUtil().setWidth(15),
                                  ),
                                  child: IntrinsicHeight(
                                    child: Row(
                                      children: [
                                        Text(strCountryCode),
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              15,
                                              ScreenUtil().setHeight(10),
                                              ScreenUtil().setWidth(10),
                                              ScreenUtil().setHeight(10)),
                                          child: VerticalDivider(
                                            color: Colors.black54,
                                            width: ScreenUtil().setWidth(5),
                                            thickness: 1.0,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: TextFormField(
                                            textInputAction:
                                                TextInputAction.next,
                                            controller: _textContactNo,
                                            validator: kvalidateCotactNum,
                                            keyboardType: TextInputType.number,
                                            onFieldSubmitted: (v) {
                                              FocusScope.of(context)
                                                  .nextFocus();
                                            },
                                            decoration: InputDecoration(
                                                errorStyle: TextStyle(
                                                    fontFamily:
                                                        Constants.appFontBold,
                                                    color: Colors.red),
                                                hintText: '000 000 000',
                                                hintStyle: TextStyle(
                                                    color: Color(
                                                        Constants.colorHint)),
                                                border: InputBorder.none),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        AppLableWidget(
                          title: Languages.of(context).labelPassword,
                        ),
                        CardPasswordTextFieldWidget(
                            textEditingController: _textPassword,
                            validator: kvalidatePassword,
                            hintText:
                                Languages.of(context).labelEnterYourPassword,
                            isPasswordVisible: _passwordVisible),
                        AppLableWidget(
                          title: Languages.of(context).labelConfirmPassword,
                        ),
                        CardPasswordTextFieldWidget(
                            textEditingController: _textConfPassword,
                            validator: validateConfPassword,
                            hintText:
                                Languages.of(context).labelReEnterPassword,
                            isPasswordVisible: _confirmpasswordVisible),
                        AppLableWidget(
                          title: Languages.of(context).labelLanguage,
                        ),
                        ListView.builder(
                            physics: ClampingScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: _listLanguages.length,
                            itemBuilder: (BuildContext context, int index) =>
                                InkWell(
                                  onTap: () {
                                    changeIndex(index);
                                    String languageCode = '';
                                    if (index == 0) {
                                      languageCode = 'en';
                                    } else if (index == 1) {
                                      languageCode = 'ar';
                                    } else {
                                      languageCode = 'ar';
                                    }
                                    changeLanguage(context, languageCode);
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: ScreenUtil().setWidth(20),
                                        bottom: ScreenUtil().setHeight(10),
                                        top: ScreenUtil().setHeight(10)),
                                    child: Row(
                                      children: [
                                        radioIndex == index
                                            ? getChecked()
                                            : getunChecked(),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            left: ScreenUtil().setWidth(10),
                                            right: ScreenUtil().setWidth(10),
                                          ),
                                          child: Text(
                                            _listLanguages[index],
                                            style: TextStyle(
                                                fontFamily: Constants.appFont,
                                                fontWeight: FontWeight.w900,
                                                fontSize:
                                                    ScreenUtil().setSp(14)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                        SizedBox(
                          height: ScreenUtil().setHeight(20),
                        ),
                        Padding(
                          padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
                          child: RoundedCornerAppButton(
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                if (radioIndex == 0) {
                                  strLanguage = 'english';
                                } else if (radioIndex == 1) {
                                  strLanguage = 'spanish';
                                } else {
                                  strLanguage = 'arabic';
                                }
                                print('selected Language' + strLanguage);
                                callRegisterAPI(strLanguage);
                              } else {
                                setState(() {
                                  // validation error
                                  //_autoValidate = true;
                                });
                              }
                            },
                            btnLabel:
                                Languages.of(context).labelCreateNewAccount,
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(10),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                Languages.of(context).labelAlreadyHaveAccount,
                                style: TextStyle(fontFamily: Constants.appFont),
                              ),
                              Text(
                                Languages.of(context).labelLogin,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: Constants.appFont),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(30),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String kvalidatePassword(String value) {
    Pattern pattern = r'^(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
    RegExp regex = new RegExp(pattern);
    if (value.length == 0) {
      return Languages.of(context).labelPasswordRequired;
    } else if (!regex.hasMatch(value))
      return Languages.of(context).labelPasswordValidation;
    else
      return null;
  }

  String kvalidateFullName(String value) {
    if (value.length == 0) {
      return Languages.of(context).labelFullNameRequired;
    } else
      return null;
  }

  String kvalidateCotactNum(String value) {
    if (value.length == 0) {
      return Languages.of(context).labelContactNumberRequired;
    } else if (value.length > 10) {
      return Languages.of(context).labelContactNumberNotValid;
    } else
      return null;
  }

  String kvalidateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (value.length == 0) {
      return Languages.of(context).labelEmailRequired;
    } else if (!regex.hasMatch(value))
      return Languages.of(context).labelEnterValidEmail;
    else
      return null;
  }

  String validateConfPassword(String value) {
    Pattern pattern = r'^(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
    RegExp regex = new RegExp(pattern);
    if (value.length == 0) {
      return Languages.of(context).labelPasswordRequired;
    } else if (_textPassword.text != _textConfPassword.text)
      return Languages.of(context).labelPasswordConfPassNotMatch;
    else if (!regex.hasMatch(value))
      return Languages.of(context).labelPasswordValidation;
    else
      return null;
  }

  void callRegisterAPI(String strLanguage) {
    progressDialog.show();

    Map<String, String> body = {
      'name': _textFullName.text,
      'email_id': _textEmail.text,
      'password': _textConfPassword.text,
      'phone': _textContactNo.text,
      'phone_code': strCountryCode,
      'language': strLanguage,
    };
    RestClient(RetroApi().dioData())
        // .register1('dev test', 'devtest@gmail.com', 'devtest@123', '+919876543210')
        .register(body)
        .then((response) {
      progressDialog.hide();
      print(response.success);

      if (response.success) {
        Constants.toastMessage(response.msg);
        SharedPreferenceUtil.putInt(
            Constants.registrationOTP, response.data.otp);
        SharedPreferenceUtil.putString(
            Constants.registrationEmail, response.data.emailId);
        SharedPreferenceUtil.putString(
            Constants.registrationPhone, response.data.phone);
        SharedPreferenceUtil.putString(
            Constants.registrationUserId, response.data.id.toString());

        if (response.data.isVerified == 0) {
          Navigator.of(context).pushReplacement(
            Transitions(
              transitionType: TransitionType.slideUp,
              curve: Curves.bounceInOut,
              reverseCurve: Curves.fastLinearToSlowEaseIn,
              widget: OTPScreen(
                isFromRegistration: true,
              ),
            ),
          );
        } else {
          Navigator.of(context).pushReplacement(
            Transitions(
              transitionType: TransitionType.fade,
              curve: Curves.bounceInOut,
              reverseCurve: Curves.fastLinearToSlowEaseIn,
              widget: LoginScreen(),
            ),
          );
        }
      } else {
        Constants.toastMessage(response.msg);
      }
    }).catchError((Object obj) {
      progressDialog.hide();
      switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response;
          var msg = res.statusMessage;
          var responsecode = res.statusCode;
          if (responsecode == 401) {
            Constants.toastMessage(Languages.of(context).labelInvalidData);
            print(responsecode);
            print(res.statusMessage);
          } else if (responsecode == 422) {
            print("code:$responsecode");
            print("msg:$msg");
            Constants.toastMessage(
                Languages.of(context).labelEmailIdAlreadyTaken);
          } else if (responsecode == 500) {
            print("code:$responsecode");
            print("msg:$msg");
            Constants.toastMessage(
                Languages.of(context).labelInternalServerError);
          }
          break;
        default:
      }
    });
  }

  Future<void> getLanguageList() async {
    _listLanguages.clear();
    _listLanguages.add('English');
    _listLanguages.add('Spanish');
    _listLanguages.add('Arabic');

    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String languageCode = _prefs.getString(prefSelectedLanguageCode);

    setState(() {
      if (languageCode == 'en') {
        radioIndex = 0;
      } else if (languageCode == 'ar') {
        radioIndex = 1;
      } else {
        radioIndex = 1;
      }
    });
  }
}
