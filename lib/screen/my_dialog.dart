/*
 * forca-absensi
 * my_dialog.dart
 * Created by Cong Fandi on 27/5/2020
 * Copyright © 2020 PT Sinergi Informatika Semen Indonesia. All rights reserved.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hexcolor/hexcolor.dart';

enum Status { SUCCESS, ERROR, WARNING, DELETE }


forcaText(String title,
    {Color? color,
      double? fontSize,
      FontWeight? fontWeight,
      TextOverflow? overflow,
      TextAlign? align}) {
  return Text(
    title == "" ? title : "",
    style: TextStyle(
      fontFamily: "Title",
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    ),
    overflow: overflow,
    textAlign: align,
  );
}

forcaButton(Text title, ValueChanged onPressed(),
    {color, height, width, margin, padding, radius}) {
  return Container(
    width: width,
    height: height,
    margin: margin,
    padding: padding,
    child: RaisedButton(
      color: color == null ? Colors.blue : color,
      onPressed: () => onPressed(),
      child: title,
      shape: RoundedRectangleBorder (borderRadius: BorderRadius.circular(radius == null ? 0 : radius)),
    ),
  );

}

class MyDialog {
  final context;
  final String title;
  final String description;
  final Status status;

  MyDialog(this.context, this.title, this.description, this.status);



  build(ValueChanged ok(), {ValueChanged cancel()?}) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          // return object of type Dialog
//          return AlertDialog(
          return new AlertDialog(
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10.0),
            ),
            content: Container(
              padding: EdgeInsets.all(6.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if(status == Status.SUCCESS)
                  Center(child: Image.asset('assets/images/checked.png')),
                  if(status == Status.DELETE)
                    Center(child: Image.asset('assets/images/delete.png')),
                  SizedBox(height: 10,),
                  Center(
                    child: forcaText(title == "" ? title : "", fontSize: 20.0, fontWeight: FontWeight.bold, color: status == Status.WARNING ? HexColor("DF302C") : Colors.black ),
                  ),

                  Padding(padding: EdgeInsets.only(top: 16.0)),
                  forcaText(description =="" ? description : "", align: TextAlign.center),
                  Padding(padding: EdgeInsets.only(top: 16.0)),
                  cancel == null
                      ? _singleButton(ok)
                      : _doubleButton(ok, cancel),
                ],
              ),
            ),
          );
        });
  }

  _singleButton(ValueChanged ok()) {
    return Container(
      width: 120,
      child: forcaButton(forcaText("Ok", color: Colors.white), () => ok(),
          color: status == Status.ERROR
              ? Colors.red
              : status == Status.WARNING ? HexColor("DF302C") : HexColor("2F5496")),
    );
  }

  _doubleButton(ValueChanged ok(), ValueChanged cancel()) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          child: forcaButton(
              forcaText("Cancel", color: Colors.white), () => cancel(),
              color: Colors.red),
        ),
        Container(
          child: forcaButton(forcaText("Ok", color: Colors.white), () => ok()),
        ),
      ],
    );
  }
}

class AppLoading {
  final BuildContext context;

  AppLoading(this.context);

  show() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
            onWillPop: () async => false,
            child: Center(
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(24.0))),
                    padding: EdgeInsets.all(30.0),
                    child:  SizedBox(
                      width: 50,
                      height: 50,
                      child: SpinKitThreeInOut(
                        color: HexColor("2F5496"),
                        size: 28,
                      ),
                    ),)),
          );
        });
  }

  showWithText(String text, {bool? dismiss, VoidCallback? onBack}) {
    showDialog(
        context: context,
        barrierDismissible: dismiss ?? false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async {
                onBack?.call();
                return onBack != null;
              },
              child: Material(
                type: MaterialType.transparency,
                child: Center(
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(24.0))),
                        padding: EdgeInsets.all(30.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(
                              width: 50,
                              height: 50,
                              child: SpinKitThreeInOut(
                                color: HexColor("2F5496"),
                                size: 28,
                              ),
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            forcaText(text, fontSize: 17.0, color: Colors.blue)
                          ],
                        ))),
              ));
        });
  }
}
