import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logo_n_spinner/logo_n_spinner.dart';
import 'package:signgoogle/utils/SmartransColor.dart';

class PopupLoading extends StatelessWidget {
  const PopupLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LogoandSpinner(
        imageAssets: 'images/loadingsmartrans.png',
        reverse: false,
        arcColor: primaryColor,
        spinSpeed: Duration(milliseconds: 500),
      ),
    );
  }
}
