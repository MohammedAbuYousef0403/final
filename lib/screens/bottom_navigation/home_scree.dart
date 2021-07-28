import 'dart:async';

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
import 'package:mealup/model/cuisine_vendor_details_model.dart';
import 'package:mealup/model/exploreRestaurantsListModel.dart';
import 'package:mealup/model/nearByRestaurantsModel.dart';
import 'package:mealup/model/nonvegRestaurantsModel.dart';
import 'package:mealup/model/top_restaurants_model.dart';
import 'package:mealup/model/vegRestaurantsModel.dart';
import 'package:mealup/network_api/Retro_Api.dart';
import 'package:mealup/network_api/api_client.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
// import 'package:mealup/screens/bottom_navigation/stream_products.dart';
import 'package:mealup/screens/offer_screen.dart';
import 'package:mealup/screens/set_location_screen.dart';
import 'package:mealup/screens/single_cuisine_details_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rating_bar/rating_bar.dart';
import 'package:shimmer/shimmer.dart';

import '../auth/login_screen.dart';
import '../restaurants_details_screen.dart';
import '../search_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<CuisineVendorDetailsListData> products = [];

  final StreamController<List<CuisineVendorDetailsListData>>
      _productsController =
      StreamController<List<CuisineVendorDetailsListData>>.broadcast();
  final StreamController<int> _categoryController =
      StreamController<int>.broadcast();

  Stream<List<CuisineVendorDetailsListData>> get productsStream =>
      _productsController.stream;

  StreamSink<int> get fetchProducts => _categoryController.sink;
  Stream<int> get getProductsForCategoriescategory =>
      _categoryController.stream;

  RetroApi apiService;

  int categoryID = 0;

  // StreamProductsBloc _exploreResListData = _exploreResListData();

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
  List<CuisineVendorDetailsListData> _listCuisineVendorRestaurants = [];
  LatLng _center;
  bool _isSyncing = false;
  Position currentLocation;
  List listImages = [
    new Restunant('images/ic_pizza.jpg'),
    new Restunant('images/ic_pizza.jpg'),
    new Restunant('images/ic_pizza.jpg'),
    new Restunant('images/ic_pizza.jpg'),
  ];

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

  // List<Tab> _tabs(List<AllCuisinesModel> categoryModel) {
  //   List<Tab> tabs = [];
  //   for (AllCuisinesModel category in categoryModel) {
  //     tabs.add(Tab(
  //       // text: category,
  //     ));
  //   }
  //   return tabs;
  // }

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
    Constants.checkNetwork().whenComplete(() =>
        getCallSingleCuisineDetails(_allCuisineListData[currentIndex].id));
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
      Constants.checkNetwork().whenComplete(() => getCallSingleCuisineDetails(
          int.parse(_allCuisineListData[currentIndex].id.toString())));
    } else {
      Constants.toastMessage('This is a testing app');
    }
  }

  void getCallSingleCuisineDetails(cuisineId) {
    _listCuisineVendorRestaurants.clear();

    setState(() {
      _isSyncing = true;
    });

    RestClient(RetroApi().dioData())
        .cuisineVendor(
      cuisineId,
    )
        .then((response) {
      setState(() {
        _isSyncing = false;
        _listCuisineVendorRestaurants.addAll(response.data);
      });
    }).catchError((Object obj) {
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
            print(responsecode);
            print(res.statusMessage);
          } else if (responsecode == 422) {
            print("code:$responsecode");
            print("msg:$msg");
            Constants.toastMessage('$responsecode');
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

  int currentIndex = 0;
  Function onTap(int index) {
    Constants.checkNetwork().whenComplete(() => getCallSingleCuisineDetails(
        int.parse(_allCuisineListData[currentIndex].id.toString())));
    setState(() {
      currentIndex = index;
    });
    print(currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    var _controlller = TabController(
      initialIndex: currentIndex,
      length: _allCuisineListData.length,
      vsync: this,
    );

    List<Tab> _tabs(List<AllCuisineData> categoryModel) {
      List<Tab> tabs = [];
      for (AllCuisineData category in categoryModel) {
        tabs.add(new Tab(
          text: '${category.name}',
          iconMargin: EdgeInsets.only(bottom: 20.0),
          icon: CachedNetworkImage(
            // height: 60,
            width: 60,
            imageUrl: category.image,
            fit: BoxFit.fitHeight,
            placeholder: (context, url) =>
                SpinKitFadingCircle(color: Color(Constants.colorTheme)),
            errorWidget: (context, url, error) => Container(
              width: 50,
              height: 50,
              child: Image.asset('images/noimage.png'),
            ),
          ),
          //     SizedBox(
          //       height: 10,
          //     ),
          //     SizedBox(
          //       child: Text(
          //         '${category.name}', // tyoe
          //         style: TextStyle(
          //             fontWeight: FontWeight.bold,
          //             fontFamily: 'Poppins',
          //             color: Colors.black,
          //             fontSize: 15),
          //       ),
          //     ),
          //   ],
          // )
          //     Column(
          //   children: [
          //     Expanded(
          //                   child: CachedNetworkImage(
          //         height: 60,
          //         width: 60,
          //         imageUrl: category.image,
          //         // fit: BoxFit.fill,
          //         placeholder: (context, url) =>
          //             SpinKitFadingCircle(color: Color(Constants.colorTheme)),
          //         errorWidget: (context, url, error) => Container(
          //           child: Center(child: Image.asset('images/noimage.png')),
          //         ),
          //       ),
          //     ),
          //     SizedBox(
          //       height: 2,
          //     ),
          //     Text(category.name),
          //   ],
          // )
        ));
      }
      return tabs;
    }

    dynamic screenWidth = MediaQuery.of(context).size.width;
    dynamic screenHeight = MediaQuery.of(context).size.height;

    ScreenUtil.init(
        BoxConstraints(maxWidth: screenWidth, maxHeight: screenHeight),
        designSize: Size(360, 690),
        orientation: Orientation.portrait);
    return SafeArea(
      child: Scaffold(
        body: ModalProgressHUD(
          progressIndicator: Padding(
            padding: const EdgeInsets.only(top: 30, right: 20, left: 20),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300],
              highlightColor: Colors.grey[100],
              // enabled: _enabled,
              child: ListView.builder(
                itemBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Container(
                      //   width: 48.0,
                      //   height: 240,
                      //   color: Colors.white,
                      // ),
                      // const Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: 8.0),
                      // ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Container(
                                  width: double.infinity,
                                  height: 200,
                                  color: Colors.white,
                                ),
                              ),
                              width: double.infinity,
                              height: 300,
                              color: Colors.white,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 2.0),
                            ),
                            Container(
                              width: double.infinity,
                              height: 16,
                              color: Colors.white,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 2.0),
                            ),
                            Container(
                              width: 40.0,
                              height: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                itemCount: 6,
              ),
            ),
          ),
          inAsyncCall: _isSyncing,
          child: SmartRefresher(
            enablePullDown: true,
            header: MaterialClassicHeader(
              backgroundColor: Color(Constants.colorTheme),
              color: Colors.white,
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: Container(
              decoration: BoxDecoration(
                  color: Color(Constants.colorScreenbackGround),
                  image: DecorationImage(
                    image: AssetImage('images/ic_background_image.png'),
                    fit: BoxFit.cover,
                  )),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
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
                            style: TextStyle(
                                fontSize: 29, fontWeight: FontWeight.bold),
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
                                  builder: (BuildContext context) =>
                                      SearchScreen()))
                        },
                        // controller: searchController,
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
                      // SizedBox(
                      //   height: 25,
                      // ),
                      // // Category(),
                      // SizedBox(
                      //   height: 15,
                      // ),
                      // ListView.builder(
                      //     physics: ClampingScrollPhysics(),
                      //     shrinkWrap: true,
                      //     scrollDirection: Axis.hore,
                      //     itemCount: _listCuisineVendorRestaurants.length,
                      //     itemBuilder:
                      //         (BuildContext context, int index) =>Align(
                      //   child: Container(
                      //     decoration: BoxDecoration(
                      //         borderRadius: BorderRadius.circular(16),
                      //         color: Colors.grey.withOpacity(0.1)),
                      //     height: 300,
                      //     // width: SizeConfig.safeBlockHorizontal * 68,
                      //     child: Column(
                      //       children: [
                      //         SizedBox(
                      //           height: 15,
                      //         ),
                      //         Container(
                      //             decoration: BoxDecoration(
                      //                 borderRadius: BorderRadius.circular(12)),
                      //             height: 200,
                      //             width: 330,
                      //             child: ClipRRect(
                      //                 borderRadius: BorderRadius.circular(12),
                      //                 child: Image.asset(
                      //                   '${listImages[index]}',
                      //                   fit: BoxFit.cover,
                      //                 ))),
                      //         Padding(
                      //           padding: EdgeInsets.symmetric(
                      //               vertical: 10, horizontal: 20),
                      //           child: Row(
                      //             children: <Widget>[
                      //               Column(
                      //                 children: <Widget>[

                      //                   SizedBox(
                      //                     height: 1,
                      //                   ),
                      //                   Row(
                      //                     children: <Widget>[

                      //                       SizedBox(
                      //                         width: 10,
                      //                       ),

                      //                       SizedBox(
                      //                         width: 10,
                      //                       ),

                      //                       SizedBox(
                      //                         width: 15,
                      //                       ),
                      //                     ],
                      //                   )
                      //                 ],
                      //                 crossAxisAlignment:
                      //                     CrossAxisAlignment.start,
                      //                 mainAxisAlignment:
                      //                     MainAxisAlignment.center,
                      //               ),
                      //             ],
                      //             mainAxisAlignment:
                      //                 MainAxisAlignment.spaceBetween,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // )),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: SizedBox(
                          child: Text(
                            'New Offers',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 25),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                            physics: ClampingScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: _listCuisineVendorRestaurants.length,
                            itemBuilder: (BuildContext context, int index) =>
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.white.withOpacity(0.1)),
                                  height: 300,
                                  // width: SizeConfig.safeBlockHorizontal * 68,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            height: 200,
                                            width: 330,
                                            child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Image.asset(
                                                  '${listImages[index].image}',
                                                  fit: BoxFit.cover,
                                                ))),
                                      ),
                                    ],
                                  ),
                                )),
                      ),
                      SizedBox(height: 25,),
                      Container(
                        child: Text('Please, Choose a section:'),
                      ),
                      SizedBox(
                        height: 150,

//////////////////////////////////////////////////
                        child:

                            // ListView.builder(
                            //   itemCount: _allCuisineListData.length,
                            //             scrollDirection: Axis.horizontal,
                            //             itemBuilder: (context, index) {
                            //               return

                            TabBar(
                          indicatorColor: Color(0XFF117182),
                          // indicatorWeight: 5,
                          controller: _controlller,
                          tabs: List<Widget>.generate(
                              _allCuisineListData.length, (int index) {
                            return new Tab(
                              icon: CachedNetworkImage(
                                height: 30,
                                width: 30,
                                imageUrl: _allCuisineListData[index].image,
                                fit: BoxFit.fitHeight,
                                placeholder: (context, url) =>
                                    SpinKitFadingCircle(
                                        color: Color(Constants.colorTheme)),
                                errorWidget: (context, url, error) => Container(
                                  // width: 50,
                                  // height: 50,
                                  child: Image.asset('images/noimage.png'),
                                ),
                              ),
                              text: '${_allCuisineListData[index].name}',
                            );
                          }),
                          // _tabs(_allCuisineListData),
                          //       tabs: [
                          //         for (AllCuisineData category in _allCuisineListData) {
                          //           Tab(text: 'sd',)
                          // }
                          //       ],

                          isScrollable: true,
                          onTap: onTap,
                          // (index) {
                          //   _currentIndex =currentIndex;
                          //   print(_currentIndex);
                          //   // setState(() {
                          //   //   _currentIndex =currentIndex;
                          //   // });
                          //   // _productsController.add(List(5));
                          //   // print("Selected Index: " +
                          //   //    currentIndex.toString());

                          //   // _exploreResListDat/a..add(this.productsCategories[index].id!);
                          // },
                        ),
                        //             }
                        // )

                        // StreamBuilder(
                        //   // stream: ,
                        //   builder: (context, snapshot) {
                        //     return ListView.builder(
                        //             physics: BouncingScrollPhysics(),
                        //             itemCount: _allCuisineListData.length,
                        //             scrollDirection: Axis.horizontal,
                        //             itemBuilder: (context, index) {
                        //               print(
                        //                   'hi: ${_allCuisineListData[index].toString()}');
                        //               return GestureDetector(
                        //                 onTap: () {},
                        //                 child: Padding(
                        //                   padding: EdgeInsets.only(
                        //                       right: 0, top: 10),
                        //                   child: Column(
                        //                     mainAxisAlignment:
                        //                         MainAxisAlignment.start,
                        //                     children: <Widget>[
                        //                       ClipRRect(
                        //                         borderRadius:
                        //                             BorderRadius.circular(15.0),
                        //                         child: CachedNetworkImage(
                        //                           height: 80,
                        //                           width: 80,
                        //                           imageUrl:
                        //                               _allCuisineListData[index]
                        //                                   .image,
                        //                           fit: BoxFit.fill,
                        //                           placeholder: (context, url) =>
                        //                               SpinKitFadingCircle(
                        //                                   color: Color(Constants
                        //                                       .colorTheme)),
                        //                           errorWidget:
                        //                               (context, url, error) =>
                        //                                   Container(
                        //                             child: Center(
                        //                                 child: Image.asset(
                        //                                     'images/noimage.png')),
                        //                           ),
                        //                         ),
                        //                       ),
                        //                       SizedBox(
                        //                         height: 5,
                        //                       ),
                        //                       Text(
                        //                         '${_allCuisineListData[index].name}', // tyoe
                        //                         style: TextStyle(
                        //                             fontWeight: FontWeight.bold,
                        //                             fontFamily: 'Poppins',
                        //                             color: Colors.black,
                        //                             fontSize: 15),
                        //                       ),
                        //                     ],
                        //                   ),
                        //                 ),
                        //               );
                        //             });
                        //   },
                        // ),

////////////////////////////////////////////////////////
                      ),
                      // Text('wef'),
                      // StreamBuilder(),
                      SizedBox(
                        height: 30,
                      ),
                      Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 10),
                          child:
                              _listCuisineVendorRestaurants.length == 0 ||
                                      _listCuisineVendorRestaurants.length ==
                                          null
                                  ? !_isSyncing
                                      ? Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Image(
                                                width:
                                                    ScreenUtil().setWidth(150),
                                                height:
                                                    ScreenUtil().setHeight(180),
                                                image: AssetImage(
                                                    'images/ic_no_rest.png'),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: ScreenUtil()
                                                        .setHeight(10)),
                                                child: Text(
                                                  Languages.of(context)
                                                      .labelNoData,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize:
                                                        ScreenUtil().setSp(18),
                                                    fontFamily:
                                                        Constants.appFontBold,
                                                    color: Color(
                                                        Constants.colorTheme),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      : Container()
                                  : ListView.builder(
                                      physics: ClampingScrollPhysics(),
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      itemCount:
                                          _listCuisineVendorRestaurants.length,
                                      itemBuilder:
                                          (BuildContext context, int index) =>
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    Transitions(
                                                      transitionType:
                                                          TransitionType.fade,
                                                      curve: Curves.bounceInOut,
                                                      reverseCurve: Curves
                                                          .fastLinearToSlowEaseIn,
                                                      widget:
                                                          RestaurantsDetailsScreen(
                                                        restaurantId:
                                                            _listCuisineVendorRestaurants[
                                                                    index]
                                                                .id,
                                                        isFav: null,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Card(
                                                  margin: EdgeInsets.only(
                                                      bottom: 20),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15.0),
                                                        child:
                                                            CachedNetworkImage(
                                                          height: ScreenUtil()
                                                              .setHeight(100),
                                                          width: ScreenUtil()
                                                              .setWidth(100),
                                                          imageUrl:
                                                              _listCuisineVendorRestaurants[
                                                                      index]
                                                                  .image,
                                                          fit: BoxFit.fill,
                                                          placeholder: (context,
                                                                  url) =>
                                                              SpinKitFadingCircle(
                                                                  color: Color(
                                                                      Constants
                                                                          .colorTheme)),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Container(
                                                            child: Center(
                                                                child: Image.asset(
                                                                    'images/noimage.png')),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 5,
                                                        child: Container(
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Container(
                                                                child: Column(
                                                                  children: [
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .only(
                                                                        left:
                                                                            10,
                                                                        right:
                                                                            10,
                                                                      ),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Text(
                                                                            _listCuisineVendorRestaurants[index].name,
                                                                            style:
                                                                                TextStyle(fontFamily: Constants.appFontBold, fontSize: ScreenUtil().setSp(16.0)),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      alignment:
                                                                          Alignment
                                                                              .topLeft,
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(left: 10),
                                                                        child:
                                                                            Text(
                                                                          getExploreRestaurantsFood(
                                                                              index),
                                                                          style: TextStyle(
                                                                              fontFamily: Constants.appFont,
                                                                              color: Color(Constants.colorGray),
                                                                              fontSize: ScreenUtil().setSp(12.0)),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: EdgeInsets.only(
                                                                    top: ScreenUtil()
                                                                        .setHeight(
                                                                            10)),
                                                                child:
                                                                    Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .topLeft,
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            10,
                                                                        right:
                                                                            10),
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Container(
                                                                              child: Row(
                                                                                children: [
                                                                                  RatingBar.readOnly(
                                                                                    initialRating: _listCuisineVendorRestaurants[index].rate.toDouble(),
                                                                                    size: ScreenUtil().setWidth(15.0),
                                                                                    isHalfAllowed: true,
                                                                                    halfFilledColor: Color(0xFFffc107),
                                                                                    halfFilledIcon: Icons.star_half,
                                                                                    filledIcon: Icons.star,
                                                                                    emptyIcon: Icons.star_border,
                                                                                    emptyColor: Color(Constants.colorGray),
                                                                                    filledColor: Color(0xFFffc107),
                                                                                  ),
                                                                                  Text(
                                                                                    '(${_listCuisineVendorRestaurants[index].review})',
                                                                                    style: TextStyle(
                                                                                      fontSize: ScreenUtil().setSp(12.0),
                                                                                      fontFamily: Constants.appFont,
                                                                                      color: Color(0xFF132229),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Container(
                                                                              margin: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
                                                                              child: (() {
                                                                                if (_listCuisineVendorRestaurants[index].vendorType == 'veg') {
                                                                                  return Row(
                                                                                    children: [
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.only(right: 2),
                                                                                        child: SvgPicture.asset(
                                                                                          'images/ic_veg.svg',
                                                                                          height: ScreenUtil().setHeight(10.0),
                                                                                          width: ScreenUtil().setHeight(10.0),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  );
                                                                                } else if (_listCuisineVendorRestaurants[index].vendorType == 'non_veg') {
                                                                                  return Row(
                                                                                    children: [
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.only(right: 2),
                                                                                        child: SvgPicture.asset(
                                                                                          'images/ic_non_veg.svg',
                                                                                          height: ScreenUtil().setHeight(10.0),
                                                                                          width: ScreenUtil().setHeight(10.0),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  );
                                                                                } else if (_listCuisineVendorRestaurants[index].vendorType == 'all') {
                                                                                  return Row(
                                                                                    children: [
                                                                                      Padding(
                                                                                        padding: EdgeInsets.only(right: ScreenUtil().setWidth(5)),
                                                                                        child: SvgPicture.asset(
                                                                                          'images/ic_veg.svg',
                                                                                          height: ScreenUtil().setHeight(10.0),
                                                                                          width: ScreenUtil().setHeight(10.0),
                                                                                        ),
                                                                                      ),
                                                                                      SvgPicture.asset(
                                                                                        'images/ic_non_veg.svg',
                                                                                        height: ScreenUtil().setHeight(10.0),
                                                                                        width: ScreenUtil().setHeight(10.0),
                                                                                      )
                                                                                    ],
                                                                                  );
                                                                                }
                                                                              }()),
                                                                            )
                                                                          ],
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )))
                    ],
                  ),
                ),
              ),
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

class Restunant {
  String image;
  Restunant(
    this.image,
  );
}
