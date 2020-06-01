// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';

// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:uuid/uuid.dart';

// class HompePage extends StatefulWidget {
//   static final routeName = "home-page";
//   @override
//   _HompePageState createState() => _HompePageState();
// }

// class _HompePageState extends State<HompePage> {
//   LatLng myLocation = LatLng(6.5244, 3.3792);
//   Completer<GoogleMapController> _controller = Completer();
//   final _scaffoldKey = GlobalKey<ScaffoldState>();
//   TextEditingController _fromLocationController = TextEditingController();
//   TextEditingController _toLocationController = TextEditingController();
//   BitmapDescriptor _start;
//   BitmapDescriptor _end;
//   PlaceDetail _startPlaceDetail = new PlaceDetail();
//   PlaceDetail _endPlaceDetail = new PlaceDetail();
//   Set<Polyline> _polylines = {};
//   List<LatLng> polylineCoordinates = [];
//   PolylinePoints polylinePoints = PolylinePoints();
//   bool _hasGottenCordinates = false;
//   bool _isAutoSuggestedDone = false;
//   String _dispatchStartAddress = "";
//   String _dispatchEndAddress = "";

//   Set<Marker> _markers = {};
//   LatLngBounds bound;
//   var uuid = Uuid();
//   String _mapStyle;
//   var sessionToken;
//   int _selectedIdnex = -1;
//   @override
//   void initState() {
//     BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5),
//             'assets/images/start.png')
//         .then((onValue) {
//       _start = onValue;
//     });

//     BitmapDescriptor.fromAssetImage(
//             ImageConfiguration(devicePixelRatio: 2.5), 'assets/images/end.png')
//         .then((onValue) {
//       _end = onValue;
//     });

//     rootBundle.loadString('assets/images/map_style.txt').then((string) {
//       _mapStyle = string;
//     });
//     super.initState();
//   }

//   void _getLatLngBounds(LatLng from, LatLng to) {
//     if (from.latitude > to.latitude && from.longitude > to.longitude) {
//       bound = LatLngBounds(southwest: to, northeast: from);
//     } else if (from.longitude > to.longitude) {
//       bound = LatLngBounds(
//           southwest: LatLng(from.latitude, to.longitude),
//           northeast: LatLng(to.latitude, from.longitude));
//     } else if (from.latitude > to.latitude) {
//       bound = LatLngBounds(
//           southwest: LatLng(to.latitude, from.longitude),
//           northeast: LatLng(from.latitude, to.longitude));
//     } else {
//       bound = LatLngBounds(southwest: from, northeast: to);
//     }
//   }

//   void check(CameraUpdate u, GoogleMapController c) async {
//     c.animateCamera(u);
//     LatLngBounds l1 = await c.getVisibleRegion();
//     LatLngBounds l2 = await c.getVisibleRegion();
//     print(l1.toString());
//     print(l2.toString());
//     if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90)
//       check(u, c);
//   }

//   void _clearCordinate() {
//     setState(() {
//       _fromLocationController.clear();
//       _toLocationController.clear();
//       _hasGottenCordinates = false;
//       _polylines = {};
//       _markers.clear();
//     });
//   }

//   setPolylines() async {
//     polylineCoordinates.clear();
//     _polylines.clear();
//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//         Constant.apiKey,
//         PointLatLng(_startPlaceDetail.lat, _startPlaceDetail.lng),
//         PointLatLng(_endPlaceDetail.lat, _endPlaceDetail.lng),
//         travelMode: TravelMode.driving,
//         wayPoints: []);
//     if (result.points.isNotEmpty) {
//       result.points.forEach((PointLatLng point) {
//         polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//       });
//     }
//     setState(() {
//       Polyline polyline = Polyline(
//           polylineId: PolylineId('poly'),
//           color: Constant.primaryColorDark,
//           width: 4,
//           points: polylineCoordinates);
//       _polylines.add(polyline);
//       _hasGottenCordinates = true;
//     });
//   }

//   void _moveCamera() async {
//     if (_markers.length > 0) {
//       setState(() {
//         _markers.clear();
//       });
//     }
//     if (_toLocationController.text != "" &&
//         _fromLocationController.text != "") {
//       _getLatLngBounds(LatLng(_startPlaceDetail.lat, _startPlaceDetail.lng),
//           LatLng(_endPlaceDetail.lat, _endPlaceDetail.lng));
//       GoogleMapController controller = await _controller.future;
//       CameraUpdate u2 = CameraUpdate.newLatLngBounds(bound, 50);
//       controller.animateCamera(u2).then((void v) {
//         check(u2, controller);
//       });
//     }

//     setState(() {
//       if (_fromLocationController.text != "" && _startPlaceDetail != null) {
//         _markers.add(
//           Marker(
//             markerId: MarkerId(_startPlaceDetail.placeId),
//             position: LatLng(_startPlaceDetail.lat, _startPlaceDetail.lng),
//             icon: _start,
//             infoWindow: InfoWindow(
//               title: "pick up",
//               snippet: _dispatchStartAddress,
//             ),
//           ),
//         );
//       }

//       if (_toLocationController.text != "" && _endPlaceDetail != null) {
//         _markers.add(
//           Marker(
//             markerId: MarkerId(_endPlaceDetail.placeId),
//             position: LatLng(_endPlaceDetail.lat, _endPlaceDetail.lng),
//             icon: _end,
//             infoWindow: InfoWindow(
//               title: "destination",
//               snippet: _dispatchEndAddress,
//             ),
//           ),
//         );
//       }
//     });

//     if (_toLocationController.text != "" &&
//         _endPlaceDetail != null &&
//         _fromLocationController.text != "" &&
//         _startPlaceDetail != null) {
//       await setPolylines();
//     }
//   }

//   _buildAutoSuggestion({
//     @required GoogleMapProvider googleMapProvider,
//     @required String label,
//     @required String imagePath,
//     @required TextEditingController cntroller,
//     @required TextStyle labelTextSTyle,
//     @required PlaceDetail placeDetail,
//     @required bool isTo,
//   }) {
//     return TypeAheadField(
//       direction: AxisDirection.up,
//       debounceDuration: Duration(milliseconds: 500),
//       textFieldConfiguration: TextFieldConfiguration(
//         controller: cntroller,
//         //  autofocus: true,
//         style: AppTextStyles.labelTextStyle,
//         decoration: InputDecoration(
//             prefixIcon: Image.asset(
//               imagePath,
//               scale: 2.5,
//             ),
//             suffixIcon: IconButton(
//                 icon: Icon(
//                   Icons.close,
//                   color: Colors.grey,
//                   size: 15,
//                 ),
//                 onPressed: () {
//                   cntroller.clear();
//                 }),
//             labelText: label,
//             labelStyle: labelTextSTyle),
//       ),
//       suggestionsCallback: (pattern) async {
//         if (sessionToken == null) {
//           sessionToken = uuid.v4();
//         }
//         if (pattern.length > 1)
//           return await googleMapProvider.getSuggestions(pattern, sessionToken);
//         return null;
//       },
//       itemBuilder: (context, suggetion) {
//         return Card(
//           child: ListTile(
//             title: Text(
//               suggetion.description,
//               style: AppTextStyles.labelTextStyle,
//             ),
//           ),
//         );
//       },
//       onSuggestionSelected: (suggetion) async {
//         cntroller.text = suggetion.description;
//         placeDetail = await googleMapProvider.getPlaceDetail(
//             suggetion.placeId, sessionToken);
//         isTo
//             ? _dispatchEndAddress = suggetion.description
//             : _dispatchStartAddress = suggetion.description;
//         isTo ? _endPlaceDetail = placeDetail : _startPlaceDetail = placeDetail;
//         _moveCamera();
//         sessionToken = null;
//       },
//     );
//   }

//   _buildSelectLocation(Size appSize, GoogleMapProvider googleMapProvider) {
//     return Container(
//       color: Constant.primaryColorLight,
//       width: appSize.width,
//       child: Column(
//         children: <Widget>[
//           _buildAutoSuggestion(
//               cntroller: _fromLocationController,
//               googleMapProvider: googleMapProvider,
//               label: "From",
//               imagePath: "assets/images/start.png",
//               labelTextSTyle: AppTextStyles.greenlabelTextStyle,
//               placeDetail: _startPlaceDetail,
//               isTo: false),
//           _buildAutoSuggestion(
//               cntroller: _toLocationController,
//               googleMapProvider: googleMapProvider,
//               label: "To",
//               imagePath: "assets/images/end.png",
//               labelTextSTyle: AppTextStyles.redlabelTextStyle,
//               placeDetail: _endPlaceDetail,
//               isTo: true),
//           SizedBox(
//             height: appSize.height * 0.03,
//           ),
//           _hasGottenCordinates
//               ? AppSmallButtonWudget(
//                   buttonText: "PROCEED",
//                   function: () {
//                     setState(() {
//                       _isAutoSuggestedDone = true;
//                     });
//                   },
//                 )
//               : Text("")
//         ],
//       ),
//     );
//   }

//   _buildDeliveryOptions(int index, String image, String dispatchType) {
//     final dispatchProvider =
//         Provider.of<DispatchProvider>(context, listen: false);
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _selectedIdnex = index;
//         });
//         currentDispatch = dispatchProvider.createDispatch(
//             dispatchType, _dispatchStartAddress, _dispatchEndAddress);
//         _buildBottomSheetConfirmation(currentDispatch, image);
//         //show Dispatch Confirmation pop Up
//       },
//       child: Container(
//         alignment: Alignment.center,
//         child: Column(
//           children: <Widget>[
//             Image.asset(
//               image,
//               scale: 12,
//             ),
//             Text(
//               dispatchType,
//               style: AppTextStyles.labelTextStyle,
//             )
//           ],
//         ),
//         width: _selectedIdnex == index ? 150.0 : 145.0,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20.0),
//           color: const Color(0xffffffff),
//           border: _selectedIdnex == index
//               ? Border.all(width: 2.0, color: Constant.primaryColorDark)
//               : Border.all(width: 0.5, color: Colors.grey),
//         ),
//       ),
//     );
//   }

//   _buildSelectDispatchType() {
//     return Column(
//       children: <Widget>[
//         Container(
//             alignment: Alignment.center,
//             color: Colors.transparent,
//             height: 125,
//             child: ListView(
//               scrollDirection: Axis.horizontal,
//               children: <Widget>[
//                 Padding(
//                     padding: const EdgeInsets.all(5.0),
//                     child: _buildDeliveryOptions(0, "assets/images/economy.png",
//                         Constant.dispatchTypeEconomy)),
//                 Padding(
//                     padding: const EdgeInsets.all(5.0),
//                     child: _buildDeliveryOptions(1, "assets/images/express.png",
//                         Constant.dispatchTypeExpress)),
//                 Padding(
//                     padding: const EdgeInsets.all(5.0),
//                     child: _buildDeliveryOptions(2, "assets/images/premiun.png",
//                         Constant.dispatchTypePremiun)),
//               ],
//             )),
//         SizedBox(
//           height: 5,
//         ),
//         AppSmallButtonWudget(
//           buttonText: "GO BACK",
//           function: () {
//             setState(() {
//               _isAutoSuggestedDone = false;
//               _selectedIdnex = -1;
//             });
//           },
//         )
//       ],
//     );
//   }

//   _buildListTileDialogue(String title, String subTitle) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Text(
//           title,
//           style: AppTextStyles.smallgreyTextStyle,
//         ),
//         Text(
//           subTitle,
//           style: AppTextStyles.labelTextStyle,
//         ),
//       ],
//     );
//   }

//   _buildDispatchConfirmationAlert(Dispatch dispatch, String image) {
//     showDialog(
//         context: context,
//         builder: (ctx) => AlertDialog(
//               content: Container(
//                 child: ListView(
//                   children: <Widget>[
//                     Image.asset(
//                       image,
//                     ),
//                     _buildListTileDialogue("Pick Up", dispatch.pickUpLocation),
//                     Divider(),
//                     _buildListTileDialogue(
//                         "Delivery Location", dispatch.dispatchDestination),
//                     Divider(),
//                     _buildListTileDialogue("Total Distance", "50 KM"),
//                     Divider(),
//                     _buildListTileDialogue("Estimated Time", "1hr"),
//                     Divider(),
//                     _buildListTileDialogue("Base Delivery Fee", "N 1000"),
//                     Divider(),
//                     _buildListTileDialogue("Total Delivery Fee", "N 5000"),
//                   ],
//                 ),
//               ),
//               actions: <Widget>[
//                 FlatButton(
//                     color: Colors.white,
//                     child: Text(
//                       "CANCEL",
//                     ),
//                     onPressed: () {
//                       Navigator.of(ctx).pop();
//                     }),
//                 FlatButton(
//                   child: Text("OK"),
//                   onPressed: () async {
//                     Navigator.of(context).pop();
//                     Navigator.of(context).pushNamed(RecipientPage.routeName);
//                   },
//                   color: Constant.primaryColorDark,
//                 ),
//               ],
//             ));
//   }

//   _buildBottomSheetConfirmation(Dispatch dispatch, String image) async {
//     final appSize = Constant.getAppSize(context);
//     return showModalBottomSheet(
//         isScrollControlled: true,
//         backgroundColor: Colors.transparent,
//         context: context,
//         builder: (context) {
//           return StatefulBuilder(
//             builder: (context, setState) {
//               return Container(
//                 height: appSize.height * 0.90,
//                 decoration: new BoxDecoration(
//                     color: Color(0xffffffff),
//                     borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(38.0),
//                         topRight: Radius.circular(38.0))),
//                 child: Padding(
//                   padding: const EdgeInsets.all(35.0),
//                   child: ListView(
//                     children: <Widget>[
//                       Container(
//                         height: 125,
//                         width: 125,
//                         child: Image.asset(
//                           image,
//                         ),
//                       ),
//                       _buildListTileDialogue(
//                           "Pick Up", dispatch.pickUpLocation),
//                       Divider(),
//                       _buildListTileDialogue(
//                           "Delivery Location", dispatch.dispatchDestination),
//                       Divider(),
//                       _buildListTileDialogue("Total Distance", "50 KM"),
//                       Divider(),
//                       _buildListTileDialogue("Estimated Time", "1hr"),
//                       Divider(),
//                       _buildListTileDialogue("Base Delivery Fee", "N 1000"),
//                       Divider(),
//                       _buildListTileDialogue("Total Delivery Fee", "N 5000"),
//                       SizedBox(
//                         height: appSize.height * 0.02,
//                       ),
//                       AppSmallButtonWudget(
//                         function: () {
//                           Navigator.of(context).pop();
//                           Navigator.of(context)
//                               .pushNamed(RecipientPage.routeName);
//                         },
//                         buttonText: "PROCEED",
//                       )
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final appSize = Constant.getAppSize(context);
//     final googleMapProvider =
//         Provider.of<GoogleMapProvider>(context, listen: false);
//     return SafeArea(
//       child: Scaffold(
//         key: _scaffoldKey,
//         drawer: AppDrawer(),
//         body: Stack(
//           children: <Widget>[
//             Container(
//               height: appSize.height,
//               width: appSize.width,
//             ),
//             Container(
//               width: appSize.width,
//               height: appSize.height * 0.68,
//               child: GoogleMap(
//                 mapType: MapType.normal,
//                 zoomGesturesEnabled: true,
//                 markers: _markers,
//                 polylines: _polylines,
//                 initialCameraPosition:
//                     CameraPosition(target: myLocation, zoom: 15),
//                 onMapCreated: (GoogleMapController controller) {
//                   controller.setMapStyle(_mapStyle);
//                   _controller.complete(controller);
//                 },
//               ),
//             ),
//             Positioned(
//               top: 15.0,
//               left: 10.0,
//               child: CircleAvatar(
//                 backgroundColor: Colors.white,
//                 child: IconButton(
//                     icon: Icon(
//                       Icons.menu,
//                       color: Constant.primaryColorDark,
//                     ),
//                     onPressed: () {
//                       _scaffoldKey.currentState.openDrawer();
//                     }),
//               ),
//             ),
//             Positioned(
//                 bottom: 8,
//                 left: 0,
//                 right: 0,
//                 child: Padding(
//                   padding: const EdgeInsets.all(0.0),
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),

//                     child: _isAutoSuggestedDone
//                         ? _buildSelectDispatchType()
//                         : _buildSelectLocation(appSize, googleMapProvider),
//                     // child:
//                     // )
//                     // //
//                   ),
//                 ))
//           ],
//         ),
//       ),
//     );
//   }
// }
