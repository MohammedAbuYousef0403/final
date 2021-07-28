import 'package:flutter/material.dart';
import 'package:mealup/model/AllCuisinesModel.dart';
import 'package:mealup/model/nearByRestaurantsModel.dart';

class NearRestunant extends StatefulWidget {
  @override
  State createState() {
    return _NearRestunantState();
  }
}

class _NearRestunantState extends State<NearRestunant> {
  // List<NearByRestaurantListData> _allCuisineListData = [];
  List<AllCuisineData> _allCuisineListData = [];

  
  
  // List _allCuisineListData = [
  //   new Restunant(
  //     'images/ic_pizza.jpg',
  //     'Noah’s Bagels',
  //     'Lunch',
  //     'America',
  //     '4',
  //     '97%',
  //     '10 mile',
  //     '10 ',
  //   ),
  //   new Restunant(
  //     'images/ic_pizza.jpg',
  //     'Chicken Lollipop',
  //     'Snacks',
  //     'America',
  //     '5',
  //     '97%',
  //     '10 mile',
  //     '10 ',
  //   ),
  //   new Restunant(
  //     'images/ic_pizza.jpg',
  //     'Chicken Lollipop',
  //     'Snacks',
  //     'America',
  //     '5',
  //     '97%',
  //     '10 mile',
  //     '10 ',
  //   ),
  //   new Restunant(
  //     'images/ic_pizza.jpg',
  //     'Chicken Lollipop',
  //     'Snacks',
  //     'America',
  //     '5',
  //     '97%',
  //     '10 mile',
  //     '10 ',
  //   ),
  //   new Restunant(
  //     'images/ic_pizza.jpg',
  //     'Chicken Lollipop',
  //     'Snacks',
  //     'America',
  //     '5',
  //     '97%',
  //     '10 mile',
  //     '10 ',
  //   ),
  // ];

  @override
  Widget build(BuildContext context) {
    print('.........................................');
    print(_allCuisineListData);
    // SizeConfig().init(context);
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,






      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
        ListView.builder(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            itemCount: _allCuisineListData.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              return Column(
                children: <Widget>[
                  Align(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.grey.withOpacity(0.1)),
                      height: 300,
                      // width: SizeConfig.safeBlockHorizontal * 68,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12)),
                              height: 200,
                              width: 330,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    '${_allCuisineListData[index].image}',
                                    fit: BoxFit.cover,
                                  ))),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            child: Row(
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Text(
                                      '${_allCuisineListData[index].name}',
                                      style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.2,
                                          fontSize: 20),
                                    ),
                                    SizedBox(
                                      height: 1,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          '${_allCuisineListData[index].status}', // type
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Poppins',
                                              color: Colors.grey,
                                              fontSize: 17),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          '${_allCuisineListData[index].status}', // contry
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Poppins',
                                              color: Colors.grey,
                                              fontSize: 17),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          '\$ ${_allCuisineListData[index].updatedAt} ', //price
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            color: Colors.grey,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                      ],
                                    ) 
                                  ],
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                ),
                              ],
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  )
                ],
              );
            }),
      ]),






    );
 
  }
}

class Restunant {
  String image, name, type, contry, discount, rating, distance, price;
  Restunant(this.image, this.name, this.type, this.contry, this.discount,
      this.rating, this.distance, this.price);
}
