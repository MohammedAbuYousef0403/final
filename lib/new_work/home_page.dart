import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mealup/componants/custom_appbar.dart';
import 'package:mealup/model/AllCuisinesModel.dart';
import 'package:mealup/model/exploreRestaurantsListModel.dart';
import 'package:mealup/model/nearByRestaurantsModel.dart';
import 'package:mealup/model/nonvegRestaurantsModel.dart';
import 'package:mealup/model/top_restaurants_model.dart';
import 'package:mealup/model/vegRestaurantsModel.dart';
import 'package:mealup/network_api/Retro_Api.dart';
import 'package:mealup/network_api/api_client.dart';
import 'package:mealup/new_work/category_wedgit.dart';
import 'package:mealup/new_work/restanant.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/offer_screen.dart';
import 'package:mealup/screens/restaurants_details_screen.dart';
import 'package:mealup/screens/search_screen.dart';
import 'package:mealup/screens/set_location_screen.dart';
import 'package:mealup/screens/single_cuisine_details_screen.dart';
import 'package:mealup/screens/wallet/wallet_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rating_bar/rating_bar.dart';

class HomeScreen1 extends StatefulWidget {
  @override
  _HomeScreen1State createState() => _HomeScreen1State();
}

class _HomeScreen1State extends State<HomeScreen1> {
  List<AllCuisineData> _allCuisineListData = [];
  List<NearByRestaurantListData> _nearbyListData = [];
  List<VegRestaurantListData> _vegListData = [];
  List<TopRestaurantsListData> _topListData = [];
  List<NonVegRestaurantListData> _nonvegListData = [];
  List<ExploreRestaurantsListData> _exploreResListData = [];
  List<String> restaurantsFood = [];
  List<String> vegRestaurantsFood = [];
  List<String> nonVegRestaurantsFood = [];
  List<String> topRestaurantsFood = [];
  List<String> exploreRestaurantsFood = [];

  LatLng _center;
  bool _isSyncing = false;
  Position currentLocation;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  bool isBusinessAvailable = false;

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    if (SharedPreferenceUtil.getInt(Constants.appSettingBusinessAvailability) ==
        1) {
      getUserLocation();

      Constants.checkNetwork().whenComplete(() => callAllCuisine());
      Constants.checkNetwork().whenComplete(() => callVegRestaurants());
      Constants.checkNetwork().whenComplete(() => callTopRestaurants());
      Constants.checkNetwork().whenComplete(() => callNonVegRestaurants());
      Constants.checkNetwork().whenComplete(() => callExploreRestaurants());
    } else {
      Constants.toastMessage('This is a testing app');
    }
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  var aspectRatio = 0.0;

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  getOneSingleToken(String appId) async {
    String userId = '';
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
    // print("pushtoken1:$userId");
    SharedPreferenceUtil.putString(Constants.appPushOneSingleToken, userId);
    /* if (SharedPreferenceUtil.getString(Constants.appPushOneSingleToken).isEmpty) {
      getOneSingleToken(SharedPreferenceUtil.getString(Constants.appSettingCustomerAppId));
    }*/
  }

  getUserLocation() async {
    currentLocation = await locateUser();
    if (mounted)
      setState(() {
        _center = LatLng(currentLocation.latitude, currentLocation.longitude);
      });
    SharedPreferenceUtil.putString('selectedLat', _center.latitude.toString());
    SharedPreferenceUtil.putString('selectedLng', _center.longitude.toString());
    Constants.checkNetwork().whenComplete(() => callNearByRestaurants());
    print('center $_center');
    print('selectedLat ${_center.latitude}');
    print('selectedLng ${_center.longitude}');
  }

  @override
  void initState() {
    super.initState();
    SharedPreferenceUtil.getInt(Constants.appSettingBusinessAvailability) == 1
        ? isBusinessAvailable = false
        : isBusinessAvailable = true;
    if (SharedPreferenceUtil.getString(Constants.appPushOneSingleToken)
        .isEmpty) {
      getOneSingleToken(
          SharedPreferenceUtil.getString(Constants.appSettingCustomerAppId));
    }

    if (SharedPreferenceUtil.getInt(Constants.appSettingBusinessAvailability) ==
        1) {
      getUserLocation();

      Constants.checkNetwork().whenComplete(() => callAllCuisine());

      Constants.checkNetwork().whenComplete(() => callVegRestaurants());
      Constants.checkNetwork().whenComplete(() => callTopRestaurants());
      Constants.checkNetwork().whenComplete(() => callNonVegRestaurants());
      Constants.checkNetwork().whenComplete(() => callExploreRestaurants());
    } else {
      Constants.toastMessage('This is a testing app');
    }
  }

  @override
  Widget build(BuildContext context) {
    dynamic screenWidth = MediaQuery.of(context).size.width;
    dynamic screenHeight = MediaQuery.of(context).size.height;

    ScreenUtil.init(
        BoxConstraints(maxWidth: screenWidth, maxHeight: screenHeight),
        designSize: Size(360, 690),
        orientation: Orientation.portrait);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 25),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: 30,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'How can we serve\nyou today?',
                      style:
                          TextStyle(fontSize: 29, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 55,
                    ),
                    Image(
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        image: AssetImage('images/Group.png'))
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                TextField(
                  onTap: () => {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => SearchScreen()))
                  },
                  controller: searchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(left: 10, right: 10),
                    suffixIcon: IconButton(
                      onPressed: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    SearchScreen()))
                      },
                      icon: SvgPicture.asset(
                        'images/search.svg',
                        width: 20,
                        height: 20,
                        color: Color(Constants.colorGray),
                      ),
                    ),
                    hintText: 'Search for a restaraunt',
                    // Languages.of(context).labelSearchRestOrCoupon,
                    hintStyle: TextStyle(
                      fontSize: 14,
                      fontFamily: Constants.appFont,
                      color: Color(Constants.colorGray),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(10.0),
                      ),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Color(0xFFeeeeee),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Category(),
                SizedBox(
                  height: 15,
                ),
                Text(
                  'Lunch Restaraunts Near You',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                ),
                NearRestunant(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  callAllCuisine() {
    _allCuisineListData.clear();
    if (mounted)
      setState(() {
        _isSyncing = true;
      });

    RestClient(RetroApi().dioData()).allCuisine().then((response) {
      // print(response.success);
      if (response.success) {
        if (mounted)
          setState(() {
            _isSyncing = false;
            if (0 < response.data.length) {
              _allCuisineListData.addAll(response.data);
            } else {
              _allCuisineListData.clear();
            }
          });
      } else {
        Constants.toastMessage(Languages.of(context).labelNoData);
      }
    }).catchError((Object obj) {
      if (mounted)
        setState(() {
          _isSyncing = false;
        });
      switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response;
          var msg = res.statusMessage;
          var responsecode = res.statusCode;
          if (responsecode == 401) {
            Constants.toastMessage('$responsecode');
            // print(responsecode);
            // print(res.statusMessage);
          } else if (responsecode == 422) {
            // print("code:$responsecode");
            // print("msg:$msg");
            Constants.toastMessage('$responsecode');
          } else if (responsecode == 500) {
            // print("code:$responsecode");
            // print("msg:$msg");
            Constants.toastMessage(
                Languages.of(context).labelInternalServerError);
          }
          break;
        default:
      }
    });
  }

  callNearByRestaurants() {
    _nearbyListData.clear();
    Map<String, String> body = {
      'lat': SharedPreferenceUtil.getString('selectedLat'),
      'lang': SharedPreferenceUtil.getString('selectedLng'),
    };
    RestClient(RetroApi().dioData()).nearBy(body).then((response) {
      // print(response.success);
      if (response.success) {
        if (mounted)
          setState(() {
            if (0 < response.data.length) {
              _nearbyListData.addAll(response.data);
            } else {
              _nearbyListData.clear();
            }
          });
      } else {
        Constants.toastMessage(Languages.of(context).labelNoData);
      }
    }).catchError((Object obj) {
      if (mounted)
        setState(() {
          _isSyncing = false;
        });
      switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response;
          var msg = res.statusMessage;
          var responsecode = res.statusCode;
          if (responsecode == 401) {
            Constants.toastMessage('$responsecode');
            // print(responsecode);
            // print(res.statusMessage);
          } else if (responsecode == 422) {
            // print("code:$responsecode");
            // print("msg:$msg");
            Constants.toastMessage('$responsecode');
          } else if (responsecode == 500) {
            // print("code:$responsecode");
            // print("msg:$msg");
          }
          break;
        default:
      }
    });
  }

  callTopRestaurants() {
    _topListData.clear();
    Map<String, String> body = {
      'lat': SharedPreferenceUtil.getString('selectedLat'),
      'lang': SharedPreferenceUtil.getString('selectedLng'),
    };
    RestClient(RetroApi().dioData()).topRest(body).then((response) {
      // print(response.success);

      if (response.success) {
        if (mounted)
          setState(() {
            if (0 < response.data.length) {
              _topListData.addAll(response.data);
            } else {
              _topListData.clear();
            }
          });
      } else {
        Constants.toastMessage(Languages.of(context).labelNoData);
      }
    }).catchError((Object obj) {
      if (mounted)
        setState(() {
          _isSyncing = false;
        });
      // print(obj.toString());
      Constants.toastMessage(obj.toString());
      switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response;
          var msg = res.statusMessage;
          var responsecode = res.statusCode;
          if (responsecode == 401) {
            Constants.toastMessage('$responsecode');
            // print(responsecode);
            // print(res.statusMessage);
          } else if (responsecode == 422) {
            // print("code:$responsecode");
            // print("msg:$msg");
            Constants.toastMessage('$responsecode');
          } else if (responsecode == 500) {
            // print("code:$responsecode");
            // print("msg:$msg");
            Constants.toastMessage(
                Languages.of(context).labelInternalServerError);
          }
          break;
        default:
      }
    });
  }

  callVegRestaurants() {
    _vegListData.clear();
    print(SharedPreferenceUtil.getString('selectedLat'));
    print(SharedPreferenceUtil.getString('selectedLng'));
    Map<String, String> body = {
      'lat': SharedPreferenceUtil.getString('selectedLat'),
      'lang': SharedPreferenceUtil.getString('selectedLng'),
    };
    RestClient(RetroApi().dioData()).vegRest(body).then((response) {
      // print(response.success);

      if (response.success) {
        if (mounted)
          setState(() {
            if (0 < response.data.length) {
              _vegListData.addAll(response.data);
            } else {
              _vegListData.clear();
            }
          });
      } else {
        Constants.toastMessage(Languages.of(context).labelNoData);
      }
    }).catchError((Object obj) {
      if (mounted)
        setState(() {
          _isSyncing = false;
        });
      // print(obj.toString());
      Constants.toastMessage(obj.toString());
      switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response;
          var msg = res.statusMessage;
          var responsecode = res.statusCode;
          if (responsecode == 401) {
            Constants.toastMessage('$responsecode');
            // print(responsecode);
            // print(res.statusMessage);
          } else if (responsecode == 422) {
            // print("code:$responsecode");
            // print("msg:$msg");
            Constants.toastMessage('$responsecode');
          } else if (responsecode == 500) {
            // print("code:$responsecode");
            // print("msg:$msg");
            Constants.toastMessage(
                Languages.of(context).labelInternalServerError);
          }
          break;
        default:
      }
    });
  }

  callNonVegRestaurants() {
    _nonvegListData.clear();
    Map<String, String> body = {
      'lat': SharedPreferenceUtil.getString('selectedLat'),
      'lang': SharedPreferenceUtil.getString('selectedLng'),
    };
    RestClient(RetroApi().dioData()).nonvegRest(body).then((response) {
      // print(response.success);

      if (response.success) {
        if (mounted)
          setState(() {
            if (0 < response.data.length) {
              _nonvegListData.addAll(response.data);
            } else {
              _nonvegListData.clear();
            }
          });
      } else {
        Constants.toastMessage(Languages.of(context).labelNoData);
      }
    }).catchError((Object obj) {
      if (mounted)
        setState(() {
          _isSyncing = false;
        });
      switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response;
          var msg = res.statusMessage;
          var responsecode = res.statusCode;
          if (responsecode == 401) {
            Constants.toastMessage('$responsecode');
            // print(responsecode);
            // print(res.statusMessage);
          } else if (responsecode == 422) {
            // print("code:$responsecode");
            // print("msg:$msg");
            Constants.toastMessage('$responsecode');
          } else if (responsecode == 500) {
            // print("code:$responsecode");
            // print("msg:$msg");
            Constants.toastMessage(
                Languages.of(context).labelInternalServerError);
          }
          break;
        default:
      }
    });
  }

  callExploreRestaurants() {
    _exploreResListData.clear();
    Map<String, String> body = {
      'lat': SharedPreferenceUtil.getString('selectedLat'),
      'lang': SharedPreferenceUtil.getString('selectedLng'),
    };
    RestClient(RetroApi().dioData()).exploreRest(body).then((response) {
      // print(response.success);
      if (mounted)
        setState(() {
          _isSyncing = false;
        });
      if (response.success) {
        if (mounted)
          setState(() {
            if (0 < response.data.length) {
              _exploreResListData.addAll(response.data);
            } else {
              _exploreResListData.clear();
            }
          });
      } else {
        Constants.toastMessage(Languages.of(context).labelNoData);
      }
    }).catchError((Object obj) {
      // print(obj.toString());
      Constants.toastMessage(obj.toString());
      if (mounted)
        setState(() {
          _isSyncing = false;
        });
      switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response;
          var msg = res.statusMessage;
          var responsecode = res.statusCode;
          if (responsecode == 401) {
            Constants.toastMessage('$responsecode');
            // print(responsecode);
            // print(res.statusMessage);
          } else if (responsecode == 422) {
            // print("code:$responsecode");
            // print("msg:$msg");
            Constants.toastMessage('$responsecode');
          } else if (responsecode == 500) {
            // print("code:$responsecode");
            // print("msg:$msg");
            Constants.toastMessage(
                Languages.of(context).labelInternalServerError);
          }
          break;
        default:
      }
    });
  }

  void callAddRemoveFavorite(int vegRestId) {
    if (mounted)
      setState(() {
        _isSyncing = true;
      });
    Map<String, String> body = {
      'id': vegRestId.toString(),
    };
    RestClient(RetroApi().dioData()).favorite(body).then((response) {
      if (mounted)
        setState(() {
          _isSyncing = false;
        });
      // print(response.success);
      if (response.success) {
        Constants.toastMessage(response.data);
        Constants.checkNetwork().whenComplete(() => callVegRestaurants());
        Constants.checkNetwork().whenComplete(() => callNearByRestaurants());
        Constants.checkNetwork().whenComplete(() => callTopRestaurants());
        Constants.checkNetwork().whenComplete(() => callNonVegRestaurants());
        Constants.checkNetwork().whenComplete(() => callExploreRestaurants());
        if (mounted) setState(() {});
      } else {
        Constants.toastMessage(Languages.of(context).labelErrorWhileUpdate);
      }
    }).catchError((Object obj) {
      if (mounted)
        setState(() {
          _isSyncing = false;
        });
      switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response;
          var msg = res.statusMessage;
          var responsecode = res.statusCode;
          if (responsecode == 401) {
            Constants.toastMessage(responsecode.toString());
            // print(responsecode);
            // print(res.statusMessage);
          } else if (responsecode == 422) {
            // print("code:$responsecode");
            // print("msg:$msg");
            Constants.toastMessage(responsecode.toString());
          } else if (responsecode == 500) {
            // print("code:$responsecode");
            // print("msg:$msg");
            Constants.toastMessage(
                Languages.of(context).labelInternalServerError);
          }
          break;
        default:
      }
    });
  }

  String getRestaurantsFood(int index) {
    restaurantsFood.clear();
    if (_nearbyListData.isNotEmpty) {
      for (int j = 0; j < _nearbyListData[index].cuisine.length; j++) {
        restaurantsFood.add(_nearbyListData[index].cuisine[j].name);
      }
    }
    // print(restaurantsFood.toString());

    return restaurantsFood.join(" , ");
  }

  String getVegRestaurantsFood(int index) {
    vegRestaurantsFood.clear();
    if (_vegListData.isNotEmpty) {
      for (int j = 0; j < _vegListData[index].cuisine.length; j++) {
        vegRestaurantsFood.add(_vegListData[index].cuisine[j].name);
      }
    }
    // print(vegRestaurantsFood.toString());

    return vegRestaurantsFood.join(" , ");
  }

  String getNonVegRestaurantsFood(int index) {
    nonVegRestaurantsFood.clear();
    if (_nonvegListData.isNotEmpty) {
      for (int j = 0; j < _nonvegListData[index].cuisine.length; j++) {
        nonVegRestaurantsFood.add(_nonvegListData[index].cuisine[j].name);
      }
    }
    // print(nonVegRestaurantsFood.toString());

    return nonVegRestaurantsFood.join(" , ");
  }

  String getTopRestaurantsFood(int index) {
    topRestaurantsFood.clear();
    if (_topListData.isNotEmpty) {
      for (int j = 0; j < _topListData[index].cuisine.length; j++) {
        topRestaurantsFood.add(_topListData[index].cuisine[j].name);
      }
    }
    print(topRestaurantsFood.toString());

    return topRestaurantsFood.join(" , ");
  }

  String getExploreRestaurantsFood(int index) {
    exploreRestaurantsFood.clear();
    if (_exploreResListData.isNotEmpty) {
      for (int j = 0; j < _exploreResListData[index].cuisine.length; j++) {
        exploreRestaurantsFood.add(_exploreResListData[index].cuisine[j].name);
      }
    }
    // print(exploreRestaurantsFood.toString());

    return exploreRestaurantsFood.join(" , ");
  }
}
