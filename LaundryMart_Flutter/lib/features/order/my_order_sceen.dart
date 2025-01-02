import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:laundrymart/features/constants/color.dart';
import 'package:laundrymart/features/constants/hive_contants.dart';
import 'package:laundrymart/features/constants/text_style.dart';
import 'package:laundrymart/features/core/home_screen.dart';
import 'package:laundrymart/features/order/widget/filter_dialougue.dart';
import 'package:laundrymart/features/payment/logic/order_providers.dart';
import 'package:laundrymart/features/payment/model/all_order_model/order.dart';
import 'package:laundrymart/features/payment/shipping_payment.dart';
import 'package:laundrymart/features/widgets/misc_widgets.dart';
import 'package:laundrymart/features/widgets/screen_wrapper.dart';
import 'package:laundrymart/features/widgets/text_button.dart';
import 'package:laundrymart/generated/l10n.dart';
import 'package:laundrymart/utils/context_less_nav.dart';
import 'package:laundrymart/utils/routes.dart';

class MyOrderScreen extends ConsumerStatefulWidget {
  const MyOrderScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends ConsumerState<MyOrderScreen> {
  bool ischeked = false;
  bool ischeked1 = false;
  bool ischeked2 = false;
  @override
  Widget build(BuildContext context) {
    ref.watch(allOrdersProvider);
    return ValueListenableBuilder(
        valueListenable: Hive.box(AppHSC.authBox).listenable(),
        builder: (BuildContext context, Box authBox, Widget? child) {
          return ScreenWrapper(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 104.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor ==
                            AppColor.black
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
                      children: [
                        AppSpacerH(44.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 30.w,
                            ),
                            Expanded(
                              child: Center(
                                child: Text(S.of(context).myorder,
                                    style: AppTextStyle(context).bodyTextH1),
                              ),
                            ),
                            if (authBox.get('token') != null)
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return const FilterDialog();
                                    },
                                  );
                                },
                                child: const HomeTopContainer(
                                  icon: "assets/svgs/sort_icon.svg",
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (authBox.get('token') != null) ...[
                  Expanded(
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: ref.watch(allOrdersProvider).map(
                              initial: (_) => const SizedBox(),
                              loading: (_) => const LoadingWidget(),
                              loaded: (_) {
                                if (_.data.data!.orders!.isEmpty) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const MessageTextWidget(
                                        msg: 'No Order Found',
                                      ),
                                      AppSpacerH(20.h),
                                      SizedBox(
                                        height: 154.h,
                                        width: 154.w,
                                        child: Image.asset(
                                          'assets/images/png/hibernation.png',
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    ],
                                  );
                                } else {
                                  return ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: _.data.data!.orders!.length + 1,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      if (index < _.data.data!.orders!.length) {
                                        final Order data =
                                            _.data.data!.orders![index];
                                        return OrderTile(
                                          order: data,
                                        );
                                      } else {
                                        // Add the desired padding widget after the last index
                                        return const Padding(
                                          padding:
                                              EdgeInsets.only(bottom: 140.0),
                                          child:
                                              SizedBox(), // Placeholder widget
                                        );
                                      }
                                    },
                                  );
                                }
                              },
                              error: (_) => ErrorTextWidget(error: _.error),
                            )),
                  )
                ] else ...[
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.h),
                        child: const NotSignedInwidget(),
                      ),
                    ),
                  )
                ]
              ],
            ),
          );
        });
  }
}

class OrderTile extends StatelessWidget {
  const OrderTile({
    super.key,
    required this.order,
  });
  final Order order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: Padding(
        padding: EdgeInsets.only(top: 8.h),
        child: GestureDetector(
          onTap: () {
            context.nav.pushNamed(Routes.orderDetailsScreen, arguments: order);
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), color: AppColor.white),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.h),
              child: Column(
                children: [
                  AppSpacerH(21.h),
                  SummaryContainer(
                    type: S.of(context).ordrid,
                    amount: "#${order.orderCode}",
                    style2: AppTextStyle(context).bodyTextSmal.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColor.gray,
                        ),
                    style: AppTextStyle(context).bodyTextSmal.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColor.black,
                        ),
                  ),
                  AppSpacerH(8.h),
                  SummaryContainer(
                    type: S.of(context).dlvryat,
                    amount: order.deliveryDate!,
                    style2: AppTextStyle(context).bodyTextSmal.copyWith(
                          color: AppColor.gray,
                        ),
                    style: AppTextStyle(context).bodyTextSmal.copyWith(
                          color: AppColor.black,
                        ),
                  ),
                  AppSpacerH(8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        S.of(context).status,
                        style: AppTextStyle(context).bodyTextSmal.copyWith(
                              color: AppColor.gray,
                            ),
                      ),
                      StatusContainer(
                        color: getOrderStatusColor(),
                        status: order.orderStatus!,
                      )
                    ],
                  ),
                  AppSpacerH(14.h),
                  Row(
                    children: List.generate(
                      800 ~/ 10,
                      (index) => Expanded(
                        child: Container(
                          color: index % 2 == 0
                              ? Colors.transparent
                              : AppColor.gray,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  AppSpacerH(12.h),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColor.blue,
                        size: 14,
                      ),
                      AppSpacerW(6.45.w),
                      Expanded(
                        child: Text(
                          processAddess(),
                          style: AppTextStyle(context)
                              .bodyTextExtraSmall
                              .copyWith(color: AppColor.black),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  AppSpacerH(21.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String processAddess() {
    String address = '';
    if (order.address!.flatNo != null) {
      address = '$address Flat: ${order.address!.flatNo}, ';
    }
    if (order.address!.houseNo != null) {
      address = '$address House: ${order.address!.houseNo}, ';
    }
    if (order.address!.roadNo != null) {
      address = '$address Road:${order.address!.roadNo}, ';
    }
    if (order.address!.block != null) {
      address = '$address Block:${order.address!.block}, ';
    }
    if (order.address!.addressLine != null) {
      address = '$address${order.address!.addressLine}, ';
    }
    if (order.address!.addressLine2 != null) {
      address = '$address${order.address!.addressLine2}, ';
    }
    if (order.address!.postCode != null) {
      address = '$address${order.address!.postCode}';
    }

    return address;
  }

  Color getOrderStatusColor() {
    if (order.orderStatus!.toLowerCase() == 'pending') {
      return AppColor.gray;
    } else if (order.orderStatus!.replaceAll(' ', '').toLowerCase() ==
        'processing'.toLowerCase()) {
      return AppColor.blue;
    } else if (order.orderStatus!.replaceAll(' ', '').toLowerCase() ==
        'cancelled'.toLowerCase()) {
      return AppColor.red;
    } else {
      return AppColor.green;
    }
  }
}

class NotSignedInwidget extends ConsumerWidget {
  const NotSignedInwidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/png/not_found.png'),
        Text(
          S.of(context).yourntsignedin,
          style: AppTextStyle(context).bodyText.copyWith(
                fontWeight: FontWeight.w500,
              ),
          textAlign: TextAlign.center,
        ),
        AppSpacerH(35.h),
        AppTextButton(
          title: S.of(context).login,
          buttonColor: AppColor.blue,
          onTap: () {
            context.nav.pushNamed(Routes.loginScreen);
          },
        )
      ],
    );
  }
}

class StatusContainer extends StatefulWidget {
  const StatusContainer({
    super.key,
    required this.color,
    required this.status,
  });
  final Color color;
  final String status;

  @override
  State<StatusContainer> createState() => _StatusContainerState();
}

class _StatusContainerState extends State<StatusContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: widget.color,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 4.h,
          vertical: 2.h,
        ),
        child: Text(
          widget.status,
          style: AppTextStyle(context)
              .bodyTextExtraSmall
              .copyWith(color: AppColor.white),
        ),
      ),
    );
  }
}
