import 'package:flutter/material.dart';

import 'constants.dart';

class RoundedCornerAppButton extends StatelessWidget {
  RoundedCornerAppButton({@required this.btnLabel, @required this.onPressed});
  final btnLabel;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Color(Constants.colorTheme),
        onPrimary: Colors.white,
        shape:   RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0),),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            0.0, 15.0, 0, 15.0),
        child: Text(
          btnLabel,
          style: TextStyle(
              fontFamily: Constants.appFont,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontSize: 16.0),
        ),
      ),
      onPressed: onPressed,

    );
  }
}