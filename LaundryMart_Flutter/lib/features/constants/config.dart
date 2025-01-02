import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppConfig {
  AppConfig._();

  //Base Url For APP
  static const String baseUrl = 'https://laundrymart.razinsoft.com/api';
  static const LatLng defaultLocation = LatLng(23.768496, 90.356780);
  static const CameraPosition defaultCameraLocation = CameraPosition(
    target: defaultLocation,
    zoom: 13.4746,
  );

  //Google Map API Key
  static const String googleMapKey = 'AIzaSyAxmOiAM26lJAXIvoHrWBXt2ogyUascpqs';

  //Stripe Keys For App - Replace With Yours
  static const String secretKey = 'sk_test_AC8LYQ8cVN0RNGdhZ7G02zWe00lYKYw7LR';
  static const String publicKey = 'pk_test_2Iu9vNpu2ROjYOb9KHDBa3Hb00KSavaClK';

  //One Signal
  static const String oneSignalAppID =
      '96fa9ec8-39bc-4395-9f3b-2c30fd9fdc3e'; // One Signal App ID

  static const String appName =
      'Laundry'; //Only For Showing Inside App. Doesn't Change Launher App Name

  //Contact US Config
  static const String ctAboutCompany =
      'RazinSoft, Dhaka, 1216'; //Company name And Address
  static const String ctWhatsApp =
      '+88017xxxxxxxx'; // whats app Number with Country Code
  static const String ctPhone = '+88017xxxxxxxx'; // Contact Phone Number
  static const String ctMail = 'example@gmail.com';
  static const String mobile = '+8801714231625';
  static const String email = 'razinsoftltd@gmail.com';
  static const String aboutUs =
      'Looking for best software development company in online. We build amazing Web & eCommerce solution, Custom software for Accounts,ui/ux design,mobile app development HRM & more.';
  // Contact Mail
}
