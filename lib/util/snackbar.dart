// For Dart 2.12.0 and above.
// This will enable the "non-nullable" language feature in this file.
// You can remove this comment if you like.
// ignore_for_file: null_safety_warnings
import 'package:flutter/material.dart';
import 'responsive_helper.dart';
import 'dimensions.dart';
import 'package:get/get.dart';
import 'styles.dart';

void show(BuildContext context, String message, {bool isError = true}) {
  Color backgroundColor = isError ? Colors.red : Theme.of(context).primaryColor;

  //  if (Get.context == null) {
  //   return;
  // }
  WidgetsBinding.instance!.addPostFrameCallback((_) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        dismissDirection: DismissDirection.horizontal,
        margin: EdgeInsets.only(
          right: ResponsiveHelper.isDesktop(Get.context)
              ? Get.context!.width * 0.7
              : Dimensions.PADDING_SIZE_SMALL,
          top: Dimensions.PADDING_SIZE_SMALL,
          bottom: Dimensions.PADDING_SIZE_SMALL,
          left: Dimensions.PADDING_SIZE_SMALL,
        ),
        content: Text(
          message,
          style: robotoMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL)),
      ),
    );
  });
}
