import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  CameraPosition CurrentLocation = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 18.4746,
  );
  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  @override
  void dispose() {
    super.dispose();
    subscription!.cancel();
  }

  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gps"),
        centerTitle: true,
      ),
      body: locationData == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              onTap: (argument) {
                markers.add(Marker(
                    markerId: MarkerId("new$count"), position: argument));
                count++;
                setState(() {});
              },
              markers: markers,
              mapType: MapType.hybrid,
              initialCameraPosition: CurrentLocation,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
    );
  }

  StreamSubscription<LocationData>? subscription;
  LocationData? locationData;
  Location location = Location();
  PermissionStatus? permissionStatus;
  bool isServiceEnable = false;

  Future<bool> isServiceEnabled() async {
    isServiceEnable = await location.serviceEnabled();
    if (!isServiceEnable) {
      isServiceEnable = await location.requestService();
    }
    return isServiceEnable;
  }

  void getCurrentLocation() async {
    bool permission = await ispermitionGranted();
    if (!permission) return;
    bool service = await isServiceEnabled();
    if (!service) return;
    locationData = await location.getLocation();
    subscription = location.onLocationChanged.listen((event) {
      locationData = event;
      markers.add(Marker(
          markerId: MarkerId("My Location"),
          position: LatLng(event.latitude!, event.longitude!)));
      UpdateMylocation();
      setState(() {});
      print("lat :${locationData!.latitude} long : ${locationData!.longitude}");
    });
    location.changeSettings(accuracy: LocationAccuracy.high);
    setState(() {});
    CurrentLocation = CameraPosition(
      target: LatLng(locationData!.latitude!, locationData!.longitude!),
      zoom: 18.4746,
    );
  }

  Future<bool> ispermitionGranted() async {
    permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      return permissionStatus == PermissionStatus.granted;
    }
    return permissionStatus == PermissionStatus.granted;
  }

  Future<void> UpdateMylocation() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            zoom: 18,
            target:
                LatLng(locationData!.latitude!, locationData!.longitude!))));
  }
}
