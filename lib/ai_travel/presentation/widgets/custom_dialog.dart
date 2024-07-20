import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/config/string/String.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/config/theme/app_theme.dart';


class CustomDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final String imgSrc;
  final bool isErrorDialogue;
  final String errorTitle;

  const CustomDialog({
    required this.onConfirm,
    required this.onCancel,
    this.imgSrc = 'assets/images/thinking.png',
    this.isErrorDialogue = false,
    this.errorTitle = 'Parsing Error',
  });

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
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.4,
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Container(
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.black, // Replace with AppColors.onBackgroundColor
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  width: 120,
                  height: 120,
                  child: imgSrc.endsWith('.svg')
                      ? SvgPicture.asset(
                    imgSrc,
                    fit: BoxFit.fill,
                    height: 120,
                    width: 120,
                  )
                      : Image.asset(
                    imgSrc,
                    fit: BoxFit.fill,
                    height: 120,
                    width: 120,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  isErrorDialogue ? errorTitle : 'Are you sure?', // Replace with Strings.areYouSure
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(height: 24),
            if (!isErrorDialogue)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CustomButton(onConfirm: onCancel, isDanger: true, btnTitle: "Cancel"),
                  SizedBox(height: 8),
                  CustomButton(onConfirm: onConfirm),
                ],
              )
            else
              CustomButton(onConfirm: onConfirm, btnTitle: "Hmm, Okay"),
          ],
        ),
      ),
    );
  }
}




class CustomButton extends StatelessWidget {
  final bool isDanger;
  final String btnTitle;
  final VoidCallback onConfirm;

  const CustomButton({
    Key? key,
    required this.onConfirm,
    this.isDanger = false,
    this.btnTitle = 'Confirm',
  }) : super(key: key);

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
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Adjusted padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          btnTitle,
          style: TextStyle(
            color: isDanger ? Colors.redAccent : Colors.blue,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
