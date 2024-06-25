import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/config/string/String.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/config/theme/app_theme.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/widgets/app_bar.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/widgets/snack_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/ssh/SSH.dart';
import '../../providers/connection_providers.dart';


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
  late SSH ssh;
  initTextControllers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ipController.text = ref.read(ipProvider);
    usernameController.text = ref.read(usernameProvider);
    passwordController.text = ref.read(passwordProvider);
    portController.text = ref.read(portProvider).toString();
    rigsController.text = ref.read(rigsProvider).toString();
  }


  updateProviders() {
    ref.read(ipProvider.notifier).state = ipController.text;
    ref.read(usernameProvider.notifier).state = usernameController.text;
    ref.read(passwordProvider.notifier).state = passwordController.text;
    ref.read(portProvider.notifier).state = int.parse(portController.text);
    ref.read(rigsProvider.notifier).state = int.parse(rigsController.text);
    setRigs(int.parse(rigsController.text), ref);
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
    double height = MediaQuery.of(context).size.height;
    bool isConnectedToLg = ref.watch(connectedProvider);
    double paddingValue = width * 0.2;
    return SafeArea(
      child: Scaffold(
        appBar: const CustomAppBar(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
               /* ShowConnection(status: isConnectedToLg),*/
                customInput(ipController, "IP Address"),
                customInput(usernameController, "Username"),
                customInput(passwordController, "Password"),
                customInput(portController, "Port"),
                customInput(rigsController, "Rigs"),
                /*customInput(chatUserNameController, "Enter your name"),*/
                Padding(
                  padding:  EdgeInsets.only(left: paddingValue, right: paddingValue, top: 10, bottom: 10),
                  child: SizedBox(
                    height: 48,
                    width: width,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ref.read(connectedProvider) ? Colors.redAccent : Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      onPressed: () {
                        updateProviders();
                        if (!isConnectedToLg) _connectToLG();
                      },
                      child: const Text(
                        Strings.connectToLg,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }


  Future<void> _connectToLG() async {
    bool? result = await ssh.connectToLG(context);
    ref.read(connectedProvider.notifier).state = result!;
    if(ref.read(connectedProvider)){
      ssh.ChatResponseBalloon("Lleida",LatLng(0, 0), "Hey there, I am Lleida, your travel assistant. How can I help you today?");
      ssh.execute();
    }
  }

  Widget customInput(TextEditingController controller, String labelText) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double paddingValue = width * 0.2;
    return Padding(
      padding:  EdgeInsets.only(left: paddingValue, right: paddingValue, top: 10, bottom: 10),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: Colors.white), // Text color
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
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        ),
      ),
    );
  }

  Future<void> relaunchLg() async {
    SSHSession? session = await SSH(ref: ref).relaunchLG(context);
    if (session != null) {
      print(session.stdout);
    }else{
      print('Session is null');
    }
  }

  rebootLG(context) async {
    try {
      for (var i = 1; i <= ref.read(rigsProvider); i++) {
        await ref.read(sshClientProvider)?.run(
            'sshpass -p ${ref.read(passwordProvider)} ssh -t lg$i "echo ${ref.read(passwordProvider)} | sudo -S reboot');
      }
    } catch (error) {
      SnackBarWidget().showSnackBar(context: context, message: error.toString(), color: Colors.red);
    }
  }

  Future<void> shutdownLg() async {
    SSHSession? session = await SSH(ref: ref).shutdownLG(context);
    if (session != null) {
      print(session.stdout);
    }else{
      print('Session is null');
    }
  }

  Future<void> setRefresh() async {
    SSHSession? session = await SSH(ref: ref).setRefresh(context);
    if (session != null) {
      print(session.stdout);
    }else{
      print('Session is null');
    }
  }

  Future<void> resetRefresh() async {
    SSHSession? session = await SSH(ref: ref).resetRefresh(context);
    if (session != null) {
      print(session.stdout);
    }else{
      print('Session is null');
    }
  }

  Future<void> cleanSlaves() async {
    SSHSession? session = await SSH(ref: ref).cleanSlaves(context);
    if (session != null) {
      print(session.stdout);
    }else{
      print('Session is null');
    }
  }

  Future<void> cleanKml() async{
    SSHSession? session = await SSH(ref: ref).cleanKML(context);
    if (session != null) {
      print(session.stdout);
    }else{
      print('Session is null');
    }
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
            foregroundColor: isShutdown ? Colors.white : (isPrimary ? Colors.white : Colors.black),
            backgroundColor: isShutdown ? Colors.red : (isPrimary ? Colors.blue : Colors.white),
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