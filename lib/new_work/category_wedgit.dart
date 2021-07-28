import 'package:flutter/material.dart';
import 'package:mealup/model/top_restaurants_model.dart';

class Category extends StatefulWidget {
  @override
  _CategoryState createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  // List _topListData = [
  //   new Food('images/12014.png', 'Dinner', false),
  //   new Food('images/12015.png', 'Lanch', true),
  //   new Food('images/12016.png', 'Breakfast', false),
  //   new Food('images/12017.png', 'Dessert', false),
  // ];

  List<TopRestaurantsListData> _topListData = [];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: _topListData.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(right: 0, top: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 50),
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        image: DecorationImage(
                          image: ExactAssetImage(
                            '${_topListData[index].image}',
                          ),
                          fit: BoxFit.contain,
                        ),
                        borderRadius: BorderRadius.circular(16)),
                    height: 85,
                    width: 70,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    '${_topListData[index].vendorType}', // tyoe
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Colors.black,
                        fontSize: 15),
                  ),
                ],
              ),
            );
          }),
    );
  }
}

class Food {
  String image, type;
  bool isPressed;
  Food(this.image, this.type, this.isPressed);
}
