import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';

Future<void> main() async{
  final FirebaseApp app = await FirebaseApp.configure(
      name: 'db2',
      options: FirebaseOptions(
        googleAppID: '1:114544769499:android:0fa7582c140c4fac',
        apiKey: 'AIzaSyDO-LbSclMsSsPrfrgG9rrPcmhj4DB6hhQ',
        databaseURL: 'https://hackathonniit.firebaseio.com/',
        gcmSenderID: '114544769499',
        projectID: 'hackathonniit'
      ),
  );
  final FirebaseStorage storage = FirebaseStorage(
    app: app,
    storageBucket: 'gs://hackathonniit.appspot.com'
  );
  runApp(new MaterialApp(
    home: LoginPage(storage: storage),
    debugShowCheckedModeBanner: false,
    routes: <String, WidgetBuilder>{
      '/HomePage': (BuildContext context) => new HomePage(storage: storage),
    },
  ));
}

class LoginPage extends StatefulWidget {
  final FirebaseStorage storage;
  LoginPage({this.storage});

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.blue,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 100.0),
                      child: Text(
                        'I.O.C.R',
                        style: TextStyle(
                            fontSize: 50.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                        ),
                      ),
                    ),
                    FractionalTranslation(
                      translation: Offset(-0.43, 0.0),
                      child: Padding(
                        padding: EdgeInsets.only(top: 80.0),
                        child: Text(
                          'Enter Police man name:',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 15.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Container(
                          height: 70.0,
                          width: 300.0,
                          color: Colors.white,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: FractionalTranslation(
                                translation: Offset(0.0, -0.3),
                                child: TextField(
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Name*',
                                    hintStyle: TextStyle(
                                      color: Colors.black38,
                                      fontSize: 20.0
                                    )
                                  ),
                                  style: TextStyle(
                                      fontSize: 40.0,
                                      color: Colors.black
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    FractionalTranslation(
                      translation: Offset(-1.3, 0.0),
                      child: Padding(
                        padding: EdgeInsets.only(top: 40.0),
                        child: Text(
                          'Enter PIS ID:',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 15.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Container(
                          height: 70.0,
                          width: 300.0,
                          color: Colors.white,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: FractionalTranslation(
                              translation: Offset(0.0, -0.3),
                              child: TextField(
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'PIS ID*',
                                    hintStyle: TextStyle(
                                        color: Colors.black38,
                                        fontSize: 20.0
                                    )
                                ),
                                style: TextStyle(
                                    fontSize: 40.0,
                                    color: Colors.black
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 60.0),
                      child: Container(
                        height: 60.0,
                        width: 200.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: RaisedButton(
                            color: Colors.red,
                            onPressed: (){
                              Navigator.of(context).pushNamedAndRemoveUntil('/HomePage', (Route<dynamic> route) => false);
                            },
                            child: Center(
                              child: Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 30.0,
                                  color: Colors.white
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}
