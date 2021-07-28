import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mealup/model/cartmodel.dart';
import 'package:mealup/network_api/Retro_Api.dart';
import 'package:mealup/network_api/api_client.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/database_helper.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/preference_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'bottom_navigation/dashboard_screen.dart';
import 'intro/intro_screen1.dart';

final dbHelper = DatabaseHelper.instance;

class SplashScreen extends StatefulWidget {
  final CartModel model;

  const SplashScreen({Key key, this.model}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  ProgressDialog progressDialog;

  @override
  void initState() {
    Timer(
      Duration(seconds: 5),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PreferenceUtils.isIntroDone("isIntroDone")
              ? DashboardScreen(0)
              : IntroScreen1(),
        ),
      ),
    );
    _queryFirst(context, widget.model);
    Constants.checkNetwork().whenComplete(() => callAppSettingData());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage('images/ic_background_image.png'),
          fit: BoxFit.cover,
        )),
        alignment: Alignment.center,
        child: Hero(
          tag: 'App_logo',
          child: Image.asset('images/ic_logo.png'),
        ),
      ),
      backgroundColor: Color(Constants.colorTheme),
    );
  }

  callAppSettingData() {
    RestClient(RetroApi().dioData()).setting().then((response) {
      progressDialog.hide();
      print(response.success);
      print('businessAvailability' +
          response.data.businessAvailability.toString());

      if (response.success) {
        if (response.data.currencySymbol != null) {
          SharedPreferenceUtil.putString(
              Constants.appSettingCurrencySymbol, response.data.currencySymbol);
        } else {
          SharedPreferenceUtil.putString(
              Constants.appSettingCurrencySymbol, '\$');
        }
        if (response.data.currency != null) {
          SharedPreferenceUtil.putString(
              Constants.appSettingCurrency, response.data.currency);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingCurrency, 'USD');
        }
        if (response.data.aboutUs != null) {
          SharedPreferenceUtil.putString(
              Constants.appSettingAboutUs, response.data.aboutUs);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingAboutUs, '');
        }
        if (response.data.aboutUs != null) {
          SharedPreferenceUtil.putString(
              Constants.appSettingAboutUs, response.data.aboutUs);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingAboutUs, '');
        }

        if (response.data.termsAndCondition != null) {
          SharedPreferenceUtil.putString(
              Constants.appSettingTerm, response.data.termsAndCondition);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingTerm, '');
        }

        if (response.data.help != null) {
          SharedPreferenceUtil.putString(
              Constants.appSettingHelp, response.data.help);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingHelp, '');
        }

        if (response.data.privacyPolicy != null) {
          SharedPreferenceUtil.putString(
              Constants.appSettingPrivacyPolicy, response.data.privacyPolicy);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingPrivacyPolicy, '');
        }

        if (response.data.companyDetails != null) {
          SharedPreferenceUtil.putString(
              Constants.appAboutCompany, response.data.companyDetails);
        } else {
          SharedPreferenceUtil.putString(Constants.appAboutCompany, '');
        }
        if (response.data.driverAutoRefrese != null) {
          SharedPreferenceUtil.putInt(Constants.appSettingDriverAutoRefresh,
              response.data.driverAutoRefrese);
        } else {
          SharedPreferenceUtil.putInt(Constants.appSettingDriverAutoRefresh, 0);
        }

        if (response.data.isPickup != null) {
          SharedPreferenceUtil.putInt(
              Constants.appSettingIsPickup, response.data.isPickup);
        } else {
          SharedPreferenceUtil.putInt(Constants.appSettingIsPickup, 0);
        }

        if (response.data.customerAppId != null) {
          SharedPreferenceUtil.putString(
              Constants.appSettingCustomerAppId, response.data.customerAppId);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingCustomerAppId, '');
        }

        if (response.data.androidCustomerVersion != null) {
          SharedPreferenceUtil.putString(
              Constants.appSettingAndroidCustomerVersion,
              response.data.androidCustomerVersion);
        } else {
          SharedPreferenceUtil.putString(
              Constants.appSettingAndroidCustomerVersion, '');
        }

        SharedPreferenceUtil.putInt(Constants.appSettingBusinessAvailability,
            response.data.businessAvailability);

        if (SharedPreferenceUtil.getInt(
                Constants.appSettingBusinessAvailability) ==
            0) {
          SharedPreferenceUtil.putString(
              Constants.appSettingBusinessMessage, response.data.message);
        }

        if (SharedPreferenceUtil.getString(Constants.appPushOneSingleToken)
            .isEmpty) {
          getOneSingleToken(SharedPreferenceUtil.getString(
              Constants.appSettingCustomerAppId));
        }
      } else {
        Constants.toastMessage('Error while get app setting data.');
      }
    }).catchError((Object obj) {
      progressDialog.hide();
      switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response;
          var msg = res.statusMessage;
          var responsecode = res.statusCode;
          if (responsecode == 401) {
            Constants.toastMessage(responsecode.toString());
            print(responsecode);
            print(res.statusMessage);
          } else if (responsecode == 422) {
            print("code:$responsecode");
            print("msg:$msg");
            Constants.toastMessage(responsecode.toString());
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

  getOneSingleToken(String appId) async {
    // String push_token = '';
    String userId = '';
    // OneSignal.shared.setRequiresUserPrivacyConsent(_requireConsent);

    /*var settings = {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.promptBeforeOpeningPushUrl: true
    };*/
    OneSignal.shared.consentGranted(true);
    await OneSignal.shared.setAppId(appId);
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    await OneSignal.shared
        .promptUserForPushNotificationPermission(fallbackToSettings: true);
    OneSignal.shared.promptLocationPermission();
    // OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);
    var status = await OneSignal.shared.getDeviceState();
    // var pushtoken = await status.subscriptionStatus.pushToken;
    userId = status.userId;
    print("pushtoken1:$userId");
    // print("pushtoken123456:$pushtoken");
    // push_token = pushtoken-;

    if (SharedPreferenceUtil.getString(Constants.appPushOneSingleToken)
        .isEmpty) {
      //getOneSingleToken(SharedPreferenceUtil.getString(Constants.appSettingCustomerAppId));
    } else {
      SharedPreferenceUtil.putString(Constants.appPushOneSingleToken, userId);
    }
  }
}

void _queryFirst(BuildContext context, CartModel model) async {
  final allRows = await dbHelper.queryAllRows();
  print('query all rows:');
  allRows.forEach((row) => print(row));
  for (int i = 0; i < allRows.length; i++) {
    model.addProduct(Product(
      id: allRows[i]['pro_id'],
      restaurantsName: allRows[i]['restName'],
      title: allRows[i]['pro_name'],
      imgUrl: allRows[i]['pro_image'],
      price: double.parse(allRows[i]['pro_price']),
      qty: allRows[i]['pro_qty'],
      restaurantsId: allRows[i]['restId'],
      restaurantImage: allRows[i]['restImage'],
      foodCustomization: allRows[i]['pro_customization'],
      isRepeatCustomization: allRows[i]['isRepeatCustomization'],
      tempPrice: double.parse(allRows[i]['itemTempPrice'].toString()),
      itemQty: allRows[i]['itemQty'],
      isCustomization: allRows[i]['isCustomization'],
    ));
  }
}
