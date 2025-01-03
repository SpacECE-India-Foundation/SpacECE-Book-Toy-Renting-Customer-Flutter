import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:laundrymart/features/constants/color.dart';
import 'package:laundrymart/features/constants/hive_contants.dart';
import 'package:laundrymart/features/constants/misc_providers.dart';
import 'package:laundrymart/features/misc/misc_global_variables.dart';
import 'package:laundrymart/features/onBoarding/on_boarding_slider.dart';
import 'package:laundrymart/features/order/widget/button_with_icon_righ.dart';
import 'package:laundrymart/features/order/widget/journey_dot.dart';
import 'package:laundrymart/features/widgets/misc_widgets.dart';
import 'package:laundrymart/features/widgets/screen_wrapper.dart';
import 'package:laundrymart/features/widgets/text_button.dart';
import 'package:laundrymart/utils/entensions.dart';
import 'package:laundrymart/utils/routes.dart';

// ignore: must_be_immutable
class OnBoardingScreen extends ConsumerWidget {
  OnBoardingScreen({super.key});
  bool shouldAnimate = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(onBoardingSliderIndexProvider);
    final imgPageController =
        ref.watch(onBoardingSliderControllerProvider('image'));
    shouldAnimate = true;
    return ScreenWrapper(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: EdgeInsets.only(top: 20.h, left: 20.w, right: 20.w),
        child: Stack(
          children: [
            ListView(
              padding: EdgeInsets.zero,
              children: [
                AppSpacerH(50.h),
                Image.asset(
                  "assets/images/png/logo.png",
                  height: 90.h,
                  width: 80.h,
                ),
                AppSpacerH(70.h),
                AnimatedScale(
                  duration: transissionDuration,
                  scale: shouldAnimate ? 1 : 0,
                  child: const OnBoadringImageSlider(),
                ),
                AppSpacerH(20.h),
                SizedBox(
                  width: 335.w,
                  height: 6.h,
                  child: CustomJourneyDot(activeIndex: index, count: 3),
                ),
                AppSpacerH(20.h),
                const OnBoadringTextSlider(),
                AppSpacerH(20.h),
                AppTextButton(
                  title: 'Let`s Get Started',
                  onTap: () {
                    if (index < 2) {
                      ref
                          .watch(onBoardingSliderIndexProvider.notifier)
                          .update((state) {
                        imgPageController.animateToPage(
                          state + 1,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                        );
                        return state + 1;
                      });
                    } else {
                      final Box appSettingsBox =
                          Hive.box(AppHSC.appSettingsBox);
                      appSettingsBox.put(AppHSC.hasSeenSplashScreen, true);
                      context.nav.pushNamedAndRemoveUntil(
                        Routes.bottomnavScreen,
                        (route) => false,
                      );
                    }
                  },
                )
              ],
            ),
            if (index < 2)
              Positioned(
                right: 0,
                top: 0,
                child: AppRightIconTextButton(
                  icon: Icons.arrow_right,
                  title: 'Skip',
                  height: 30.h,
                  width: 65.w,
                  onTap: () {
                    final Box appSettingsBox = Hive.box(AppHSC.appSettingsBox);
                    appSettingsBox.put(AppHSC.hasSeenSplashScreen, true);
                    context.nav.pushNamedAndRemoveUntil(
                      Routes.bottomnavScreen,
                      (route) => false,
                    );
                  },
                ),
              )
          ],
        ),
      ),
    );
  }
}

final List<ObSliderData> slideData = [
  ObSliderData(
    image: 'assets/images/png/splash1.png',
    text: 'Discover Engaging Activities',
  ),
  ObSliderData(
    image: 'assets/images/png/splash2.png',
    text: 'Stay Organized with Our Schedule',
  ),
  ObSliderData(
    image: 'assets/images/png/splash3.png',
    text: 'Making Home Learning Fun and Easy!',
  ),
];

class ObSliderData {
  String image;
  String text;
  ObSliderData({
    required this.image,
    required this.text,
  });
}
