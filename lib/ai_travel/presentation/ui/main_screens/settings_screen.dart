import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/config/string/String.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/config/theme/app_theme.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/widgets/app_bar.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/widgets/snack_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/ssh/SSH.dart';
import '../../providers/connection_providers.dart';
import '../../widgets/custom_dialog.dart';

class ConnectionScreen extends ConsumerStatefulWidget {
  const ConnectionScreen({super.key});

  @override
  _ConnectionScreenState createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends ConsumerState<ConnectionScreen> {
  TextEditingController ipController = TextEditingController(text: '');
  TextEditingController usernameController = TextEditingController(text: '');
  TextEditingController passwordController = TextEditingController(text: '');
  TextEditingController portController = TextEditingController(text: '');
  TextEditingController rigsController = TextEditingController(text: '');
  TextEditingController groqApiController = TextEditingController(text: '');

  late SSH ssh;

  initTextControllers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? groqApiKey = prefs.getString(Strings.groqApiKeys);
    ref.read(ipProvider.notifier).state = prefs.getString(Strings.ipAddress) ?? '';
    ref.read(usernameProvider.notifier).state = prefs.getString(Strings.userName) ?? '';
    ref.read(passwordProvider.notifier).state = prefs.getString(Strings.password) ?? '';
    ref.read(portProvider.notifier).state = prefs.getInt(Strings.port) ?? 0;
    ref.read(rigsProvider.notifier).state = prefs.getInt(Strings.noOfRigs) ?? 0;
    ipController.text = ref.read(ipProvider);
    usernameController.text = ref.read(usernameProvider);
    passwordController.text = ref.read(passwordProvider);
    portController.text = ref.read(portProvider).toString();
    rigsController.text = ref.read(rigsProvider).toString();
    groqApiController.text = groqApiKey ?? '';
  }

  updateProviders() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ref.read(ipProvider.notifier).state = ipController.text;
    ref.read(usernameProvider.notifier).state = usernameController.text;
    ref.read(passwordProvider.notifier).state = passwordController.text;
    ref.read(portProvider.notifier).state = int.parse(portController.text);
    ref.read(rigsProvider.notifier).state = int.parse(rigsController.text);
    setRigs(int.parse(rigsController.text), ref);
    await prefs.setString(Strings.ipAddress, ipController.text);
    await prefs.setString(Strings.userName, usernameController.text);
    await prefs.setString(Strings.password, passwordController.text);
    await prefs.setInt(Strings.port, int.parse(portController.text));
    await prefs.setInt(Strings.noOfRigs, int.parse(rigsController.text));
  }

  updateApiKeyProviders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ref.read(groqApiProvider.notifier).state = groqApiController.text;
    await prefs.setString(Strings.groqApiKeys, groqApiController.text);
  }

  @override
  void initState() {
    super.initState();
    initTextControllers();
    ssh = SSH(ref: ref);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isConnectedToLg = ref.watch(connectedProvider);
    bool isGroqApiAdded = ref.watch(groqApiProvider).isNotEmpty;
    double paddingValue = width * 0.2;
    var watchGroqApi = ref.watch(groqApiProvider);
    print("Groq Api Keyx: $watchGroqApi");

    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Scaffold(
          appBar: CustomAppBar(
            shouldShowSettingsIcon: false,
            isSettingsPage: true, // Set this to true for the settings page
          ),
          body: TabBarView(
            children: [
              // Connection Settings Tab
              AnimationLimiter(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: AnimationConfiguration.toStaggeredList(
                        duration: const Duration(milliseconds: 500),
                        // Adjust as needed
                        childAnimationBuilder: (widget) => SlideAnimation(
                          horizontalOffset: -50, // Adjust as needed
                          child: FadeInAnimation(child: widget),
                        ),
                        children: [
                          // ShowConnection(status: isConnectedToLg),
                          customInput(ipController, "IP Address"),
                          customInput(usernameController, "Username"),
                          customInput(passwordController, "Password",
                              isPassword: true),
                          customInput(portController, "Port", isNumber: true),
                          customInput(rigsController, "Rigs", isNumber: true),
                          // customInput(chatUserNameController, "Enter your name"),
                          Padding(
                            padding: EdgeInsets.only(
                              left: paddingValue,
                              right: paddingValue,
                              top: 10,
                              bottom: 10,
                            ),
                            child: SizedBox(
                              height: 48,
                              width: width,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ref.read(connectedProvider)
                                      ? Colors.redAccent
                                      : Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                                onPressed: () {
                                  updateProviders();
                                  if (!isConnectedToLg) {
                                    _connectToLG();
                                  } else {
                                    buildShowDialog(context, () {
                                      _disconnectToLg();
                                    }, "Are you sure you want to disconnect?");
                                  }
                                },
                                child: Text(
                                  isConnectedToLg
                                      ? Strings.disconnect
                                      : Strings.connectToLg,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // API Settings Tab
              AnimationLimiter(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 500),
                      // Adjust as needed
                      childAnimationBuilder: (widget) => SlideAnimation(
                        horizontalOffset: -50, // Adjust as needed
                        child: FadeInAnimation(child: widget),
                      ),
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.2),
                              child: Text(
                                "Enter Your Groq Api Key",
                              ),
                            ),
                          ],
                        ),
                        customInput(groqApiController, "Groq Api",
                            isPassword: true),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.2),
                          child: Row(
                            children: [
                              // Additional widgets can be added here if needed
                            ],
                          ),
                        ),
                        StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            // Add a listener to the TextEditingController to rebuild the widget when the text changes
                            groqApiController.addListener(() {
                              setState(
                                  () {}); // Triggers rebuild to show/hide the remove button
                            });

                            return Padding(
                              padding: EdgeInsets.only(
                                left: paddingValue,
                                right: paddingValue,
                                top: 10,
                                bottom: 10,
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 48,
                                    width: width,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                      ),
                                      onPressed: () {
                                        if (groqApiController.text.isEmpty) {
                                          SnackBarWidget().showSnackBar(
                                            context: context,
                                            message: "Key Cannot be empty",
                                            color: Colors.redAccent,
                                            duration: 3,
                                          );
                                          return;
                                        } else {
                                          buildShowDialog(context, () {
                                            print(
                                                "Add key ${ref.read(groqApiProvider).isEmpty}");
                                            updateApiKeyProviders();
                                            SnackBarWidget().showSnackBar(
                                              context: context,
                                              message:
                                                  "Keys Updated Successfully",
                                              duration: 2,
                                            );
                                          }, "Update Keys?");
                                        }
                                      },
                                      child: Text(
                                        Strings.addKeys,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10), // Space between buttons
                                  if (groqApiController.text.isNotEmpty) ...[
                                    SizedBox(
                                      height: 48,
                                      width: width,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                          ),
                                        ),
                                        onPressed: () {
                                          buildShowDialog(context, () async {
                                            groqApiController.clear(); // Clear the controller
                                            SnackBarWidget().showSnackBar(
                                              context: context,
                                              message:
                                                  "Keys Removed Successfully",
                                              duration: 2,
                                            );
                                          }, "Remove Keys?");
                                        },
                                        child: Text(
                                          "Remove the keys",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> buildShowDialog(
      BuildContext context, VoidCallback onConfirm, String dialogTitle) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          onConfirm: () {
            onConfirm();
            Navigator.pop(context);
          },
          onCancel: () {
            Navigator.pop(context);
          },
          isErrorDialogue: false,
          errorTitle: Strings.doDisconnect,
          dialogTitle: dialogTitle,
        );
      },
    );
  }

  Future<void> _connectToLG() async {
    bool? result = await ssh.connectToLG(context);
    ref.read(connectedProvider.notifier).state = result!;
    if (ref.read(connectedProvider)) {
      ssh.chatResponseBalloon("Ready for some imaginations to explore?",
          LatLng(41.6177, 0.6200), "Welcome!", "Lleida Spain");
      ssh.execute();
      SSH(ref: ref).showSplashLogo();
    }
  }

  Future<void> _disconnectToLg() async {
    bool? result = await ssh.disconnect(context);
    ref.read(connectedProvider.notifier).state = result!;
  }

  Widget customInput(TextEditingController controller, String labelText,
      {bool isPassword = false, bool isNumber = false}) {
    bool _obscureText =
        true; // This should be maintained within the StatefulBuilder

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.2,
              vertical: 10),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword ? _obscureText : false,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            inputFormatters:
                isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
            style: TextStyle(color: Colors.white),
            // Text color
            decoration: InputDecoration(
              labelText: labelText,
              labelStyle: TextStyle(color: Colors.white),
              filled: true,
              fillColor: Color(0xFF2D2F3A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: const BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: const BorderSide(color: Colors.white),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    ipController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    portController.dispose();
    rigsController.dispose();

    super.dispose();
  }
}

class ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final bool isShutdown;
  final VoidCallback onPressed;

  const ControlButton({
    required this.icon,
    required this.label,
    this.isPrimary = false,
    required this.onPressed,
    this.isShutdown = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final buttonWidth = screenWidth * 0.2;
    final buttonHeight = screenHeight * 0.1;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: buttonHeight,
        width: buttonWidth,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 24),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            foregroundColor: isShutdown
                ? Colors.white
                : (isPrimary ? Colors.white : Colors.black),
            backgroundColor: isShutdown
                ? Colors.red
                : (isPrimary ? Colors.blue : Colors.white),
            textStyle: const TextStyle(fontSize: 16),
            padding: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
    );
  }
}
