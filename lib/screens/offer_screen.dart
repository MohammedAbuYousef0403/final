import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mealup/model/promocode_model.dart';
import 'package:mealup/network_api/Retro_Api.dart';
import 'package:mealup/network_api/api_client.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:progress_dialog/progress_dialog.dart';

class OfferScreen extends StatefulWidget {
  final double orderAmount;
  final int restaurantId;

  const OfferScreen({Key key, this.orderAmount, this.restaurantId})
      : super(key: key);

  @override
  _OfferScreenState createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {
  ProgressDialog progressDialog;

  List<PromoCodeListData> _listPromoCode = [];
  List<PromoCodeListData> _searchListPromoCode = [];
  TextEditingController _searchController = new TextEditingController();

  @override
  void initState() {
    super.initState();

    Constants.checkNetwork()
        .whenComplete(() => callGetPromocodeListData(widget.restaurantId));
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

    dynamic screenWidth = MediaQuery.of(context).size.width;
    dynamic screenHeight = MediaQuery.of(context).size.height;

    ScreenUtil.init(
        BoxConstraints(
            maxWidth: screenWidth,
            maxHeight: screenHeight),
        designSize: Size(360, 690),
        orientation: Orientation.portrait);

    return SafeArea(
        child: Scaffold(
      appBar: ApplicationToolbar(
        appbarTitle: Languages.of(context).labelFoodOfferCoupons,
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return ConstrainedBox(
            constraints:
                BoxConstraints(minHeight: viewportConstraints.maxHeight),
            child: Container(
              color: Color(0xfff6f6f6),
              child: Column(
                children: <Widget>[
                  Container(
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: ScreenUtil().setWidth(20),
                          right: ScreenUtil().setWidth(20),
                          top: ScreenUtil().setHeight(10)),
                      child: TextField(
                        controller: _searchController,
                        onChanged: onSearchTextChanged,
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.only(left: ScreenUtil().setWidth(10)),
                          suffixIcon: IconButton(
                            onPressed: () => {},
                            icon: SvgPicture.asset(
                              'images/search.svg',
                              width: ScreenUtil().setWidth(20),
                              height: ScreenUtil().setHeight(20),
                              color: Color(Constants.colorGray),
                            ),
                          ),
                          hintText:
                              Languages.of(context).labelSearchRestOrCoupon,
                          hintStyle: TextStyle(
                            fontSize: ScreenUtil().setSp(14),
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
                    ),
                  ),
                  Expanded(
                    flex: 10,
                    child: _listPromoCode.length != 0
                        ? GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.85,
                            padding: EdgeInsets.all(10),
                            children: _searchListPromoCode.length != 0 ||
                                    _searchController.text.isNotEmpty
                                ? List.generate(_searchListPromoCode.length,
                                    (index) {
                                    return Container(
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                                child: CachedNetworkImage(
                                                  height: ScreenUtil()
                                                      .setHeight(70),
                                                  width:
                                                      ScreenUtil().setWidth(70),
                                                  imageUrl:
                                                      _searchListPromoCode[
                                                              index]
                                                          .image,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      SpinKitFadingCircle(
                                                          color: Color(Constants
                                                              .colorTheme)),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Container(
                                                    child: Center(
                                                        child: Image.asset('images/noimage.png')),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: ScreenUtil()
                                                      .setHeight(12)),
                                              child: Text(
                                                _searchListPromoCode[index]
                                                    .name,
                                                style: TextStyle(
                                                    fontFamily:
                                                        Constants.appFont,
                                                    fontSize:
                                                        ScreenUtil().setSp(14)),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: ScreenUtil()
                                                      .setHeight(12)),
                                              child: Text(
                                                _searchListPromoCode[index]
                                                    .promoCode,
                                                style: TextStyle(
                                                  fontFamily:
                                                      Constants.appFont,
                                                  fontSize:
                                                      ScreenUtil().setSp(18),
                                                  letterSpacing: 4,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              _searchListPromoCode[index]
                                                  .displayText,
                                              style: TextStyle(
                                                  fontFamily:
                                                      Constants.appFont,
                                                  fontSize:
                                                      ScreenUtil().setSp(12),
                                                  color: Color(
                                                      Constants.colorTheme)),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: ScreenUtil()
                                                      .setHeight(12)),
                                              child: Text(
                                                '${Languages.of(context).labelValidUpTo} ${_searchListPromoCode[index].startEndDate.substring(_searchListPromoCode[index].startEndDate.indexOf(" - ") + 1)}',
                                                style: TextStyle(
                                                    color: Color(
                                                        Constants.colorGray),
                                                    fontFamily:
                                                        Constants.appFont,
                                                    fontSize:
                                                        ScreenUtil().setSp(12)),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  })
                                : List.generate(_listPromoCode.length, (index) {
                                    return Container(
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                                child: CachedNetworkImage(
                                                  height: ScreenUtil()
                                                      .setHeight(70),
                                                  width:
                                                      ScreenUtil().setWidth(70),
                                                  imageUrl:
                                                      _listPromoCode[index]
                                                          .image,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      SpinKitFadingCircle(
                                                          color: Color(Constants
                                                              .colorTheme)),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Container(
                                                    child: Center(
                                                        child: Image.asset('images/noimage.png')),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: ScreenUtil()
                                                      .setHeight(12)),
                                              child: Text(
                                                _listPromoCode[index].name,
                                                style: TextStyle(
                                                    fontFamily:
                                                        Constants.appFont,
                                                    fontSize:
                                                        ScreenUtil().setSp(14)),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: ScreenUtil()
                                                      .setHeight(12)),
                                              child: Text(
                                                _listPromoCode[index].promoCode,
                                                style: TextStyle(
                                                  fontFamily:
                                                      Constants.appFont,
                                                  fontSize:
                                                      ScreenUtil().setSp(18),
                                                  letterSpacing: 4,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              _listPromoCode[index].displayText,
                                              style: TextStyle(
                                                  fontFamily:
                                                      Constants.appFont,
                                                  fontSize:
                                                      ScreenUtil().setSp(12),
                                                  color: Color(
                                                      Constants.colorTheme)),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: ScreenUtil()
                                                      .setHeight(12)),
                                              child: Text(
                                                '${Languages.of(context).labelValidUpTo} ${_listPromoCode[index].startEndDate.substring(_listPromoCode[index].startEndDate.indexOf(" - ") + 1)}',
                                                style: TextStyle(
                                                    color: Color(
                                                        Constants.colorGray),
                                                    fontFamily:
                                                        Constants.appFont,
                                                    fontSize:
                                                        ScreenUtil().setSp(12)),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                          )
                        : Container(
                            width: ScreenUtil().screenWidth,
                            height: ScreenUtil().screenHeight,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image(
                                  width: ScreenUtil().setWidth(150),
                                  height: ScreenUtil().setHeight(180),
                                  image: AssetImage('images/ic_no_offer.png'),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: ScreenUtil().setHeight(10)),
                                  child: Text(
                                    Languages.of(context).labelNoOffer,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(18),
                                      fontFamily: Constants.appFontBold,
                                      color: Color(Constants.colorTheme),
                                    ),
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
    ));
  }

  callGetPromocodeListData(int restaurantId) {
    progressDialog.show();

    RestClient(RetroApi().dioData())
        .promoCode(
      restaurantId,
    )
        .then((response) {
      print(response.success);
      progressDialog.hide();
      if (response.success) {
        setState(() {
          _listPromoCode.addAll(response.data);
        });
      } else {
        Constants.toastMessage('Error while remove address');
      }
    }).catchError((Object obj) {
      progressDialog.hide();
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

  void calculateDiscount(String discountType, int discount, int flatDiscount,
      int isFlat, double orderAmount) {
    double tempDisc = 0;
    if (discountType == 'percentage') {
      tempDisc = orderAmount * discount / 100;
      print('Temp Discount $tempDisc');
      if (isFlat == 1) {
        tempDisc = tempDisc + flatDiscount;
        print('after flat disc add $tempDisc');
      }

      print('Grand Total = ${orderAmount - tempDisc}');
    } else {
      tempDisc = tempDisc + discount;

      if (isFlat == 1) {
        tempDisc = tempDisc + flatDiscount;
      }
   print('Grand Total = ${orderAmount - tempDisc}');
    }

    Navigator.pop(context);
  }

  onSearchTextChanged(String text) async {
    _searchListPromoCode.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    for (int i = 0; i < _listPromoCode.length; i++) {
      var item = _listPromoCode[i];

      if (item.name.toLowerCase().contains(text.toLowerCase())) {
        _searchListPromoCode.add(item);
        _searchListPromoCode.toSet();
      }
    }

    setState(() {});
  }
}