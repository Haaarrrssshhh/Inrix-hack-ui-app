import 'dart:convert';
// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inrix_hack/models/places.dart';

double wp1_lat = 37.770581; //sourceLocation.latitude;
double wp1_long = -122.442550; //sourceLocation.longitude;
double wp2_lat = 37.765297; //destination.latitude;
double wp2_long = -122.442527; //destination.longitude;

class LocationInput extends StatefulWidget {
  const LocationInput({super.key});

  @override
  State<LocationInput> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;
  var _isGettingLocation = false;
  String key = "AIzaSyBL-l_GznfYxn-khcJhUiUnptZ8wMUskjI";

  // final Completer<GoogleMapController> _controller = Completer();

  LatLng sourceLocation = LatLng(wp1_lat, wp1_long);
  LatLng destination = LatLng(wp2_lat, wp2_long);

  String get locationImage {
    if (_pickedLocation == null) {
      return '';
    }
    final lat = _pickedLocation!.latitude;
    final lng = _pickedLocation!.longitude;
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng=&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$lng&key=$key';
  }

  void _getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isGettingLocation = true;
    });

    locationData = await location.getLocation();
    final lat = locationData.latitude;
    final lng = locationData.longitude;

    if (lat == null || lng == null) {
      return;
    }

    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$key');
    final response = await http.get(url);
    final resData = json.decode(response.body);
    final address = resData['results'][0]['formatted_address'];

    setState(() {
      _pickedLocation = PlaceLocation(
        latitude: lat,
        longitude: lng,
        address: address,
      );
      _isGettingLocation = false;
    });
  }

  List<List<LatLng>> polyCoordinates = [];
  List<bool> shortes = [];
  void ployPoint() async {
    //print("wp_1: $wp1_lat,$wp1_long");
    //print("wp_2: $wp2_lat,$wp2_long");
    final url = Uri.http("172.20.195.111:9000", 'inrix/getroute');
    //print("Sending...........");
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(
        {"wp_1": "$wp1_lat,$wp1_long", "wp_2": "$wp2_lat,$wp2_long"},
      ),
    );
    print("-----Done-----------");
    //print(response.body);
    Map result = jsonDecode(response.body);
    List rs = result['data']['result']['trip']['routes'];
    print(rs.length);
    for (int i = 0; i < rs.length; i++) {
      List<LatLng> temp = [];
      rs[i]['shortest'] == true ? shortes.add(true) : shortes.add(false);
      rs[i]['points']['coordinates'].forEach((element) => {
            //print(element['lat']);
            // (PointLatLng point) =>
            temp.add(LatLng(element['lat'], element['lng']))
          });
      polyCoordinates.add(temp);
    }
    print(shortes);

    //print(polyCoordinates);
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("getting Location");
    //_getCurrentLocation();
    //ployPoint();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: GoogleMap(
              myLocationEnabled: true,
              initialCameraPosition:
                  CameraPosition(target: sourceLocation, zoom: 14.5),
              markers: {
                Marker(
                  markerId: MarkerId("Source"),
                  position: sourceLocation,
                ),
                Marker(
                  markerId: MarkerId("Destination"),
                  position: destination,
                ),
              },
              polylines: {
                for (int i = 0; i < polyCoordinates.length; i++)
                  Polyline(
                    polylineId: PolylineId("Polyline$i"),
                    points: polyCoordinates[i],
                    color: shortes[i] == true
                        ? Color.fromARGB(255, 49, 158, 35)
                        : Color.fromARGB(255, 15, 82, 121),
                    width: 4,
                  )
              },
            ),
          ),
          Container(
            child: const TextField(
              decoration: InputDecoration(
                labelText: 'Source',
                prefixIcon: Icon(Icons.home),
              ),
            ),
          ),
          Container(
            child: const TextField(
              decoration: InputDecoration(
                labelText: 'Destination',
                prefixIcon: Icon(Icons.location_city),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 20),
            child: ElevatedButton(
              onPressed: ployPoint,
              child: const Text("Get Route"),
            ),
          ),
        ],
      ),
    );
  }
}
