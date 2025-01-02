import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:laundrymart/features/constants/color.dart';
import 'package:laundrymart/features/constants/text_style.dart';
import 'package:laundrymart/features/widgets/misc_widgets.dart';
import 'package:laundrymart/features/widgets/screen_wrapper.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenWrapper(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 104.h,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
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
                  AppSpacerH(50.h),
                  Text(
                    "Notifications",
                    style: AppTextStyle(context).bodyTextH1,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const MessageTextWidget(
                    msg: 'No Notifications Found',
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
              ),
            ),
          )
        ],
      ),
    );
  }
}
