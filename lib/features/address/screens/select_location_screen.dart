import 'package:hexacom_user/features/address/providers/location_provider.dart';
import 'package:hexacom_user/features/address/widgets/location_search_dialog_widget.dart';
import 'package:hexacom_user/features/address/widgets/location_permission_dialog_widget.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/main.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/common/widgets/web_app_bar_widget.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:provider/provider.dart';

class SelectLocationScreen extends StatefulWidget {
  final GoogleMapController? googleMapController;
  const SelectLocationScreen({super.key, this.googleMapController});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  GoogleMapController? _controller;
  final TextEditingController _locationController = TextEditingController();
  CameraPosition? _cameraPosition;
  late LatLng _initialPosition;

  @override
  void initState() {
    super.initState();

    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final LocationProvider locationProvider = Provider.of<LocationProvider>(context, listen: false);

    _initialPosition = LatLng(
      double.parse(splashProvider.configModel!.branches![0].latitude! ),
      double.parse(splashProvider.configModel!.branches![0].longitude!),
    );

    locationProvider.setPickData();
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }

  @override
  Widget build(BuildContext context) {

    _locationController.text = Provider.of<LocationProvider>(context).address ?? '';

    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context)? const PreferredSize(preferredSize: Size.fromHeight(90), child: WebAppBarWidget()) :  AppBar(
        backgroundColor: const Color(0xFF3A4756),
        elevation: 0,
        leading: const SizedBox.shrink(),
        centerTitle: true,
        title: Text(getTranslated('select_delivery_address', context), style: rubikMedium.copyWith(color: Colors.white)),
      ),
      body: Center(
        child: SizedBox(
          width: Dimensions.webScreenWidth,
          child: Consumer<LocationProvider>(
            builder: (context, locationProvider, child) => Stack(
              clipBehavior: Clip.none,
              children: [
                GoogleMap(
                  minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: _initialPosition,
                    zoom: 15,
                  ),
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                  indoorViewEnabled: true,
                  mapToolbarEnabled: true,
                  onCameraIdle: () {
                    locationProvider.updatePosition(_cameraPosition, false, null,false);
                  },
                  onCameraMove: ((position) => _cameraPosition = position),
                  // markers: Set<Marker>.of(locationProvider.markers),
                  onMapCreated: (GoogleMapController controller) {
                    Future.delayed(const Duration(milliseconds: 600)).then((value) {
                      _controller = controller;
                      _controller!.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
                          target:  locationProvider.pickPosition.longitude.toInt() == 0 &&  locationProvider.pickPosition.latitude.toInt() == 0 ? _initialPosition : LatLng(
                            locationProvider.pickPosition.latitude, locationProvider.pickPosition.longitude,
                          ), zoom: 17)));
                    });

                  },
                ),
                locationProvider.pickAddress != null
                    ? InkWell(
                  onTap: () => showDialog(context: context, builder: (context) => LocationSearchDialogWidget(mapController: _controller)),
                  child: Container(
                    width: MediaQuery.sizeOf(context).width,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: 18.0),
                    margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: 23.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12, offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Builder(
                        builder: (context) {
                          _locationController.text = locationProvider.pickAddress!;

                          return Row(children: [
                            Expanded(child: Text(
                              locationProvider.pickAddress ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                            )),

                            const Icon(Icons.search, size: 20),
                          ]);
                        }
                    ),
                  ),
                ) : const SizedBox.shrink(),
                Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () => _checkPermission((){
                          locationProvider.getCurrentLocation(context, false, mapController: _controller);
                        }, context),
                        child: Container(
                          width: 50,
                          height: 50,
                          margin: const EdgeInsets.only(right: Dimensions.paddingSizeLarge),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(context).cardColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.10),
                                blurRadius: 8, offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.my_location,
                            color: Color(0xFF3A4756),
                            size: 35,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                          child: CustomButtonWidget(
                            btnTxt: getTranslated('select_location', context),
                            backgroundColor: const Color(0xFF3A4756),
                            onTap: locationProvider.isLoading ? null : () {

                              if(locationProvider.pickAddress != null){
                                locationProvider.setAddress = locationProvider.pickAddress ?? '';
                              }

                              locationProvider.setPickedAddressLatLon(locationProvider.pickPosition.latitude.toString(), locationProvider.pickPosition.longitude.toString());

                              if(widget.googleMapController != null) {
                                widget.googleMapController!.setMapStyle('[]');
                                widget.googleMapController!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(
                                  locationProvider.pickPosition.latitude, locationProvider.pickPosition.longitude,
                                ), zoom: 16)));

                                if(ResponsiveHelper.isWeb()) {
                                  locationProvider.setLocationData(true);
                                }
                              }
                              Navigator.of(context).pop(false);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Center(
                    child: Icon(
                      Icons.location_on,
                      color: Color(0xFF3A4756),
                      size: 50,
                    )),
                locationProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _checkPermission(Function callback, BuildContext context) async {
    LocationPermission permission = await Geolocator.requestPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }else if(permission == LocationPermission.deniedForever) {
      showDialog(context: Get.context!, barrierDismissible: true, builder: (context) => const LocationPermissionDialogWidget());
    }else {
      callback();
    }
  }
}
