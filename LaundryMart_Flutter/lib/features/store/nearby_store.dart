import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:laundrymart/features/address/logic/addresss_providers.dart';
import 'package:laundrymart/features/address/model/address_list_model/address.dart'
    as addres;
import 'package:laundrymart/features/constants/color.dart';
import 'package:laundrymart/features/constants/config.dart';
import 'package:laundrymart/features/constants/hive_contants.dart';
import 'package:laundrymart/features/constants/text_style.dart';
import 'package:laundrymart/features/core/logic/core_providers.dart';
import 'package:laundrymart/features/core/model/all_stores_model/store.dart';
import 'package:laundrymart/features/widgets/misc_widgets.dart';
import 'package:laundrymart/features/widgets/screen_wrapper.dart';
import 'package:laundrymart/generated/l10n.dart';
import 'package:laundrymart/utils/context_less_nav.dart';
import 'package:laundrymart/utils/routes.dart';

class NearbyStoreScreen extends ConsumerStatefulWidget {
  const NearbyStoreScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NearbyStoreSScreenState();
}

class _NearbyStoreSScreenState extends ConsumerState<NearbyStoreScreen> {
  LatLng? currentLocation;
  bool isLoading = false;
  final Box locationBox = Hive.box(AppHSC.locationBox);

  final Set<Polyline> _polylines = {};
  late CustomInfoWindowController _customInfoWindowController;
  late final TextEditingController _controller = TextEditingController();
  bool flag = true;
  List<Store> stores = [];
  BitmapDescriptor? storeImg;
  var image;
  @override
  void initState() {
    super.initState();
    _customInfoWindowController = CustomInfoWindowController();
    _controller.addListener(() {
      if (_controller.text.isEmpty) {
        ref.watch(allStoresProvider).maybeWhen(
            orElse: () {},
            loaded: (data) {
              stores.clear();
              stores.addAll(data.data!.stores!);
              setState(() {});
            });
      }
    });
  }

  getCustomIcon() async {
    final ByteData data =
        await rootBundle.load('assets/images/png/storePoint.png');
    final Uint8List bytes = data.buffer.asUint8List();
    setState(() {
      image = bytes;
    });
  }

  Marker customWidow(Store store) {
    return Marker(
      markerId: MarkerId(store.id.toString()),
      onTap: () async {
        _customInfoWindowController.addInfoWindow!(
          DecoratedBox(
            decoration: const BoxDecoration(color: AppColor.white),
            child: Padding(
              padding: EdgeInsets.all(10.0.r),
              child: Column(
                children: [
                  Text(
                    store.name!,
                    style: AppTextStyle(context).bodyText.copyWith(
                          color: AppColor.black,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  AppSpacerH(6.h),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_sharp,
                        color: AppColor.yellow,
                        size: 20,
                      ),
                      AppSpacerW(4.w),
                      Text(
                        "Nurjahan Road, Mohammadpur",
                        style:
                            AppTextStyle(context).bodyTextExtraSmall.copyWith(
                                  color: AppColor.black,
                                ),
                      ),
                    ],
                  ),
                  AppSpacerH(6.h),
                  InkWell(
                    onTap: () {
                      context.nav.pushNamed(
                        Routes.storedetailsScreen,
                        arguments: {'storeindex': 0, "store": store},
                      );
                    },
                    child: Row(
                      children: [
                        Row(
                          children: [
                            Text(
                              store.distance.toString(),
                              style: AppTextStyle(context)
                                  .bodyTextExtraSmall
                                  .copyWith(color: AppColor.gray),
                            ),
                            SizedBox(
                              height: 14.h,
                              child: const VerticalDivider(
                                color: AppColor.offWhite,
                                thickness: 1,
                              ),
                            ),
                            Row(
                              children: [
                                SvgPicture.asset("assets/svgs/rating_icon.svg"),
                                AppSpacerW(5.45.w),
                                Text(
                                  store.rating.toString(),
                                  style: AppTextStyle(context)
                                      .bodyTextExtraSmall
                                      .copyWith(color: AppColor.black),
                                ),
                                AppSpacerW(5.45.w),
                                Text(
                                  "(${store.totalRating})",
                                  style: AppTextStyle(context)
                                      .bodyTextExtraSmall
                                      .copyWith(color: AppColor.gray),
                                )
                              ],
                            )
                          ],
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_forward_ios, size: 16.r)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          LatLng(
            double.parse(store.latitude!),
            double.parse(store.longitude!),
          ),
        );
      },
      position: LatLng(
        double.parse(store.latitude!),
        double.parse(store.longitude!),
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueRed,
      ),
    );
  }

  late Set<Marker> markersList = {
    Marker(
      markerId: const MarkerId('current_Postion'),
      infoWindow: const InfoWindow(
          title: 'Current Position', snippet: "Hello this is for test"),
      position: AppConfig.defaultLocation,
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueBlue,
      ),
    ),
  };

  bool ismap = true;
  void _onMapCreated(GoogleMapController? controller) {
    _customInfoWindowController.googleMapController = controller;
  }

  @override
  void dispose() {
    _customInfoWindowController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSearch = ref.watch(searchStoreProvider);
    return ScreenWrapper(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        children: [
          // Store List
          ListView(
            padding: EdgeInsets.zero,
            children: [
              if (ismap) ...[
                AppSpacerH(134.h),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.h),
                    child: ref.watch(allStoresProvider).map(
                        initial: (_) {
                          return const LoadingWidget();
                        },
                        loading: (_) {
                          return const LoadingWidget();
                        },
                        loaded: (_) {
                          if (flag) {
                            stores.clear();
                            stores.addAll(_.data.data!.stores!);
                            flag = false;
                          }
                          return isLoading
                              ? const LoadingWidget()
                              : stores.isEmpty
                                  ? const Center(
                                      child: Text("No search found"),
                                    )
                                  : ListView.builder(
                                      padding: EdgeInsets.zero,
                                      physics: const BouncingScrollPhysics(),
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      itemCount: stores.length,
                                      itemBuilder: (context, index) {
                                        markersList.add(
                                          customWidow(stores[index]),
                                        );
                                        return isSearch
                                            ? const LoadingWidget()
                                            : NearByStoreContainer(
                                                loc: stores[index].address !=
                                                        null
                                                    ? stores[index]
                                                        .address!
                                                        .addressName!
                                                    : "",
                                                ontap: () {
                                                  context.nav.pushNamed(
                                                    Routes.storedetailsScreen,
                                                    arguments: {
                                                      'storeindex': 0,
                                                      "store": stores[index]
                                                    },
                                                  );
                                                },
                                                store: stores[index],
                                              );
                                      },
                                    );
                        },
                        error: (_) => ErrorTextWidget(error: _.error)),
                  ),
                ),
                AppSpacerH(120.h)
              ] else ...[
                AppSpacerH(124.h),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 510.h,
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: AppConfig.defaultCameraLocation,
                        compassEnabled: true,
                        myLocationButtonEnabled: true,
                        zoomGesturesEnabled: true,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: true,
                        markers: markersList,
                        mapType: MapType.normal,
                        // ignore: prefer_collection_literals
                        gestureRecognizers: Set()
                          ..add(Factory<EagerGestureRecognizer>(
                              () => EagerGestureRecognizer())),
                        onMapCreated: _onMapCreated,
                        onTap: (position) {
                          _customInfoWindowController.hideInfoWindow!();
                        },
                        onCameraMove: (position) {
                          _customInfoWindowController.onCameraMove!();
                        },
                        polylines: _polylines,
                      ),
                      CustomInfoWindow(
                        controller: _customInfoWindowController,
                        height: 90.h,
                        width: 230.w,
                        offset: 50,
                      ),
                      Positioned(
                        right: 12.h,
                        bottom: 12.h,
                        child: FloationgContainer(
                          icon: "assets/svgs/menu_icon.svg",
                          ontap: () async {
                            setState(() {
                              ismap = true;
                            });
                          },
                        ),
                      )
                    ],
                  ),
                ),
                AppSpacerH(16.h),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.h),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 102.h,
                      child: ref.watch(allStoresProvider).map(
                          initial: (_) {
                            return const LoadingWidget();
                          },
                          loading: (_) {
                            return const LoadingWidget();
                          },
                          loaded: (_) {
                            return ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: _.data.data!.stores!.length,
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return Padding(
                                    padding: EdgeInsets.only(
                                        left: index == 0 ? 0 : 12.h),
                                    child: NearByStoreContainer(
                                        width: 340.w,
                                        loc: stores[index].address != null
                                            ? stores[index]
                                                .address!
                                                .addressName!
                                            : "",
                                        ontap: () {
                                          context.nav.pushNamed(
                                            Routes.storedetailsScreen,
                                            arguments: {
                                              'storeindex': 0,
                                              "store":
                                                  _.data.data!.stores![index]
                                            },
                                          );
                                        },
                                        store: _.data.data!.stores![index]));
                              },
                            );
                          },
                          error: (_) => ErrorTextWidget(error: _.error)),
                    ))
              ]
            ],
          ),
          Positioned(
            child: NearByStoreAppbar(
              controller: _controller,
              ontap: () {
                if (_controller.text.isNotEmpty) {
                  setState(() {
                    isLoading = true;
                  });
                  ref
                      .watch(searchStoreProvider.notifier)
                      .searchStore(query: _controller.text)
                      .then((store) {
                    stores.clear();
                    stores.addAll(store.data!.stores!);
                    setState(() {
                      isLoading = false;
                    });
                  });
                }
              },
            ),
          ),
          // floating button for visible shops in maps
          if (ismap)
            Positioned(
              right: 12.w,
              bottom: 80.h,
              child: FloationgContainer(
                icon: "assets/svgs/map_icon.svg",
                ontap: () {
                  setState(() {
                    ismap = false;
                  });
                },
              ),
            )
        ],
      ),
    );
  }
}

class NearByStoreContainer extends StatelessWidget {
  const NearByStoreContainer({
    super.key,
    this.ontap,
    this.width,
    this.height,
    this.margin,
    this.imagewidth,
    this.imageheight,
    required this.loc,
    required this.store,
  });
  final Function()? ontap;
  final double? width;
  final double? height;
  final double? margin;
  final double? imagewidth;
  final double? imageheight;
  final String loc;
  final Store store;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        margin: EdgeInsets.only(top: margin ?? 8.h),
        width: width ?? MediaQuery.of(context).size.width,
        height: height ?? 96.h,
        decoration: BoxDecoration(
            color: AppColor.white, borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.h),
          child: Column(
            children: [
              AppSpacerH(12.h),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      store.logo.toString(),
                      fit: BoxFit.cover,
                      width: imagewidth ?? 72.w,
                      height: imageheight ?? 72.h,
                    ),
                  ),
                  AppSpacerW(8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              store.name ?? "",
                              style: AppTextStyle(context).bodyText.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.black,
                                  ),
                            ),
                            Container(
                              width: 32.w,
                              height: 16.h,
                              decoration: BoxDecoration(
                                color: store.owner!.isActive == 1
                                    ? AppColor.green
                                    : AppColor.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(
                                  store.owner!.isActive == 1 ? "Open" : "Close",
                                  style: AppTextStyle(context)
                                      .bodyTextExtraSmall
                                      .copyWith(
                                        color: AppColor.white,
                                        fontSize: 10.sp,
                                      ),
                                ),
                              ),
                            )
                          ],
                        ),
                        AppSpacerH(6.h),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_sharp,
                              color: AppColor.blue,
                              size: 20,
                            ),
                            AppSpacerW(4.w),
                            Expanded(
                              child: Text(
                                loc,
                                style: AppTextStyle(context)
                                    .bodyTextExtraSmall
                                    .copyWith(color: AppColor.black),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        AppSpacerH(6.h),
                        Row(
                          children: [
                            Text(
                              store.distance.toString(),
                              style: AppTextStyle(context)
                                  .bodyTextExtraSmall
                                  .copyWith(color: AppColor.gray),
                            ),
                            SizedBox(
                              height: 14.h,
                              child: const VerticalDivider(
                                color: AppColor.gray,
                                thickness: 1,
                              ),
                            ),
                            Row(
                              children: [
                                SvgPicture.asset("assets/svgs/rating_icon.svg"),
                                AppSpacerW(5.45.w),
                                Text(
                                  store.rating.toString(),
                                  style: AppTextStyle(context)
                                      .bodyTextExtraSmall
                                      .copyWith(
                                        color: AppColor.black,
                                      ),
                                ),
                                AppSpacerW(5.45.w),
                                Text(
                                  "(${store.totalRating})",
                                  style: AppTextStyle(context)
                                      .bodyTextExtraSmall
                                      .copyWith(
                                        color: AppColor.gray,
                                      ),
                                )
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FloationgContainer extends StatelessWidget {
  const FloationgContainer({
    super.key,
    required this.icon,
    this.ontap,
  });
  final String icon;
  final Function()? ontap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        width: 48.w,
        height: 48.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColor.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColor.blue.withOpacity(0.25),
              offset: const Offset(0, 0),
              blurRadius: 32,
            )
          ],
          color: AppColor.blue,
        ),
        child: Center(
          child: SvgPicture.asset(icon),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class NearByStoreAppbar extends ConsumerStatefulWidget {
  const NearByStoreAppbar({
    super.key,
    this.ontap,
    required TextEditingController controller,
  }) : _controller = controller;
  final Function()? ontap;
  final TextEditingController _controller;

  @override
  ConsumerState<NearByStoreAppbar> createState() => _NearByStoreAppbarState();
}

class _NearByStoreAppbarState extends ConsumerState<NearByStoreAppbar> {
  addres.Address? address;

  String processAddess(addres.Address address) {
    String addres = '';

    if (address.houseNo != null) {
      addres = '$addres${address.houseNo}, ';
    }
    if (address.roadNo != null) {
      addres = '$addres${address.roadNo}, ';
    }
    if (address.block != null) {
      addres = '$addres${address.block}, ';
    }
    if (address.addressLine != null) {
      addres = '$addres${address.addressLine}, ';
    }
    if (address.addressLine2 != null) {
      addres = '$addres${address.addressLine2}, ';
    }
    if (address.area != null) {
      addres = '$addres${address.area}, ';
    }
    if (address.postCode != null) {
      addres = '$addres${address.postCode}';
    }
    return addres;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(addresListProvider).maybeWhen(
        orElse: () {},
        loaded: (_) {
          for (var element in _.data!.addresses!) {
            if (element.isDefault == 1) {
              setState(() {
                address = element;
              });
            }
          }
        });
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 134.h,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor == AppColor.black
            ? AppColor.black
            : AppColor.white,
        border: const Border(
          bottom: BorderSide(
            color: AppColor.offWhite,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppSpacerH(34.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 280.w,
                  height: 44.h,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColor.gray.withOpacity(0.5),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: widget._controller,
                          style: AppTextStyle(context).bodyTextSmal,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: S.of(context).searchstore,
                            hintStyle: AppTextStyle(context)
                                .bodyTextSmal
                                .copyWith(color: AppColor.gray),
                            contentPadding: EdgeInsets.only(
                              left: Hive.box(AppHSC.appSettingsBox)
                                          .get(AppHSC.appLocal)
                                          .toString() ==
                                      "ar"
                                  ? 0.w
                                  : 15.w,
                              right: Hive.box(AppHSC.appSettingsBox)
                                          .get(AppHSC.appLocal)
                                          .toString() ==
                                      "ar"
                                  ? 15.w
                                  : 0.w,
                              bottom: 8.w,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          widget.ontap?.call();
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: Hive.box(AppHSC.appSettingsBox)
                                        .get(AppHSC.appLocal)
                                        .toString() ==
                                    "ar"
                                ? 0.w
                                : 15.w,
                            left: Hive.box(AppHSC.appSettingsBox)
                                        .get(AppHSC.appLocal)
                                        .toString() ==
                                    "ar"
                                ? 15.w
                                : 0.w,
                          ),
                          child: SvgPicture.asset(
                            "assets/svgs/search_icon.svg",
                            fit: BoxFit.cover,
                            color: AppColor.gray,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppSpacerH(12.h),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        address != null
                            ? const Icon(
                                Icons.location_on,
                                color: AppColor.blue,
                                size: 14,
                              )
                            : const SizedBox(),
                        AppSpacerW(6.45.w),
                        Expanded(
                          child: Text(
                            address != null ? processAddess(address!) : "",
                            style: AppTextStyle(context).bodyTextExtraSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
