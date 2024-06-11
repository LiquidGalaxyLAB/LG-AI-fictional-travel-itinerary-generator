import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/config/string/String.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/config/theme/app_theme.dart';

class CustomDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final String imgSrc;
  CustomDialog({required this.onConfirm, required this.onCancel, this.imgSrc = 'assets/images/sad_emoji.svg'});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.2;
    double height = MediaQuery.of(context).size.height * 0.45;
    return Stack(
      children: <Widget>[
        Container(
          width: width,
          height: height,
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: AppColors.onBackgroundColor,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: Colors.white, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: 80,
                      height: 80,
                      child: SvgPicture.asset(
                        imgSrc,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16), // Added spacing
                    Text(Strings.areYouSure, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CustomButton(onConfirm: onCancel, isDanger: true, btnTitle: "Cancel"),
                  SizedBox(height: 8),
                  CustomButton(onConfirm: onConfirm),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}



class CustomButton extends StatelessWidget {
  final isDanger;
  final String btnTitle;
  const CustomButton({
    Key? key,
    required this.onConfirm,
    this.isDanger = false,
    this.btnTitle = 'Confirm',
  }) : super(key: key);

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onConfirm,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDanger ? Colors.redAccent : Colors.blue,
          ),
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child:  Text(
          btnTitle,
          style: TextStyle(
            color: isDanger ? Colors.redAccent : Colors.blue,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
