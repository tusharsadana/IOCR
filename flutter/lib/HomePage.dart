import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:map_view/map_view.dart';
import 'package:geocoder/geocoder.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

const API_KEY = "AIzaSyCbZclAa-Qx3yPfwfuksOAduipOBELFu3o";

class HomePage extends StatefulWidget {
  final FirebaseStorage storage;
  HomePage({this.storage});

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File _image;
  FirebaseDatabase database;
  MapView mapView = new MapView();
  Marker marker = new Marker(
    "1",
    "Entered Location",
    27.9614424,
    76.4002208,
    draggable: true, //Allows the user to move the marker.
  );
  double latitude, longitude;
  var results;
  bool isSuccessful = false;
  bool isStarted = false;
  var uid;
  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _detailsController = new TextEditingController();

  Future<List<Address>> _getResults(double lat, double long) async {
    var result = await Geocoder.local.findAddressesFromCoordinates(new Coordinates(lat, long));
    return result;
  }

  @override
  void initState() {
    super.initState();
    MapView.setApiKey(API_KEY);
    database = FirebaseDatabase(app: widget.storage.app);
    database.reference().child('locations').onChildChanged.listen((event){
      var results;
      if(event.snapshot.value.containsKey('seen')){
        _getResults(event.snapshot.value['lat'], event.snapshot.value['lon']).then((addressList){
          setState(() {
            results = addressList.first;
          });
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
             return AlertDialog(
               title: (results != null) ? Text('Missing person found at ${results.addressLine}!') : Text('Getting Location'),
               content: Column(
                 children: <Widget>[
                   Expanded(
                     child: SingleChildScrollView(
                       child: Column(
                         children: [
                           Image.network('${event.snapshot.value['download']}'),
                           Padding(padding: EdgeInsets.only(top: 10.0)),
                           Image.network('${event.snapshot.value['download_cctv']}')
                         ],
                       ),
                     ),
                   )
                 ],
               ),
             );
          }
        );
      }
    });
  }

  void getImage() async{
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
      uid = DateTime.now().millisecondsSinceEpoch;
      _image = _image.renameSync('${_image.parent.path}/$uid.jpeg');
      print(_image.path);
    });
  }

  Future<Null> _uploadData() async {
    setState(() {
      isStarted = true;
    });
    final StorageReference ref = widget.storage.ref().child('${uid.toString()}.jpeg');
    ref.putFile(_image).events.listen((event){
      if(event.type == StorageTaskEventType.success){
        setState(() {
          isSuccessful = true;
          widget.storage.ref().child('${uid.toString()}.jpeg').getDownloadURL().then((downloadUrl){
            database = FirebaseDatabase(app: widget.storage.app);
            database.reference().child('locations').child(uid.toString()).set({
              "download" : downloadUrl,
              "found" : 0,
              "lat" : latitude,
              "lon" : longitude,
              "name" : _nameController.text,
              "details" : _detailsController.text
            });
          });
          Timer(Duration(seconds: 5), () => isSuccessful = null);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'I.O.C.R',
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.blue,
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: Text(
                        'File a FIR Report',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 30.0
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: Container(
                        height: 50.0,
                        width: 300.0,
                        child: RaisedButton(
                          onPressed: (){
                            mapView.onMapReady.listen((_) {
                              mapView.setMarkers([marker]);
                            });
                            mapView.show(
                                new MapOptions(
                                    mapViewType: MapViewType.normal,
                                    showUserLocation: true,
                                    initialCameraPosition: new CameraPosition(
                                        new Location(27.9614424, 76.4002208), 14.0),
                                    title: "Recently Visited"));
                            mapView.onAnnotationDrag.listen((markerMap) {
                              var marker = markerMap.keys.first;
                              var location = markerMap[marker]; // The updated position of the marker.
                              setState(() {
                                latitude = location.latitude;
                                longitude = location.longitude;
                                _getResults(latitude, longitude).then((result){
                                  setState(() {
                                    results = result.first;
                                  });
                                });
                              });
                            });
                          },
                          child: Center(
                            child: Text(
                              'Enter Reported Location',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0
                              ),
                            ),
                          ),
                          color: Colors.black,
                        ),
                      ),
                    ),
                    (results != null) ? Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'Reported Location:',
                            style: TextStyle(
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w900
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                            child: Container(
                              child: Text(
                                '${results.addressLine}',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ) : Container(),
                    FractionalTranslation(
                      translation: Offset(-1.2, 0.0),
                      child: Padding(
                        padding: EdgeInsets.only(top: 30.0),
                        child: Text(
                          'Enter Name:',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Container(
                          height: 70.0,
                          width: 300.0,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FractionalTranslation(
                              translation: Offset(0.0, -0.3),
                              child: TextField(
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Name',
                                    hintStyle: TextStyle(
                                        color: Colors.black38,
                                        fontSize: 20.0
                                    )
                                ),
                                style: TextStyle(
                                    fontSize: 40.0,
                                    color: Colors.black
                                ),
                                controller: _nameController,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    FractionalTranslation(
                      translation: Offset(-1.2, 0.0),
                      child: Padding(
                        padding: EdgeInsets.only(top: 30.0),
                        child: Text(
                          'Enter Details:',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Container(
                          height: 70.0,
                          width: 300.0,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FractionalTranslation(
                              translation: Offset(0.0, -0.3),
                              child: TextField(
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Details',
                                    hintStyle: TextStyle(
                                        color: Colors.black38,
                                        fontSize: 20.0
                                    )
                                ),
                                style: TextStyle(
                                    fontSize: 40.0,
                                    color: Colors.black
                                ),
                                controller: _detailsController,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 40.0),
                      child: Container(
                        height: 50.0,
                        width: 300.0,
                        child: RaisedButton(
                          color: Colors.black,
                          onPressed: getImage,
                          child: Center(
                            child: Text(
                              'Upload missing person photo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    (isStarted) ? Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Container(
                        height: 50.0,
                        width: 300.0,
                        child: (!isSuccessful) ? Text(
                          'Uploading.....',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w700,
                            fontSize: 15.0
                          ),
                        ) : Text(
                          'Upload Successful',
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w700,
                              fontSize: 15.0
                          ),
                        ),
                      ),
                    ) :
                    Padding(
                      padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                      child: Container(
                        height: 50.0,
                        width: 200.0,
                        child: RaisedButton(
                          color: Colors.red,
                          onPressed: (results != null && _image != null) ? _uploadData : null,
                          child: Center(
                            child: Text(
                              'Submit an FIR Report',
                              style: TextStyle(
                                fontSize: 15.0
                              ),
                            ),
                          ),
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
  }
}

