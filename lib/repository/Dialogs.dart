import 'package:flutter/material.dart';

class Dialogs {
  static Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  key: key,
                  backgroundColor: Color(0xffffffff),
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0),
                  ),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Center(
                        child: Column(children: [
                          Opacity(
                            child: Image.asset(
                              'assets/loader.gif',
                              colorBlendMode: BlendMode.multiply,
                            ),
                            opacity: 1,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Please Wait...",
                            style: TextStyle(
                                color: Colors.black.withOpacity(0.7),
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w700,
                                fontSize: 18.0),
                          )
                        ]),
                      ),
                    )
                  ]));
        });
  }
}
