import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/ssh/SSH.dart';
import '../../providers/connection_providers.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/snack_bar.dart';
import '../settings_screen.dart';

class LiquidGalaxyManagement extends ConsumerStatefulWidget {
  const LiquidGalaxyManagement({Key? key}) : super(key: key);

  @override
  _LiquidGalaxyManagementState createState() => _LiquidGalaxyManagementState();
}

class _LiquidGalaxyManagementState extends ConsumerState<LiquidGalaxyManagement> {

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
                Padding(
                  padding: EdgeInsets.only(
                    left: paddingValue,
                    right: paddingValue,
                    top: 20,
                    bottom: 10,
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        alignment: Alignment.center,
                        height: height * 0.07,
                        width: width,
                        child: const Text(
                          textAlign: TextAlign.center,
                          'Liquid Galaxy Management',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          color: const Color(0xFF1E1E2C),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  ControlButton(
                                    icon: Icons.cleaning_services,
                                    label: 'Clean Slaves',
                                    onPressed: () {
                                      cleanSlaves();
                                    },
                                  ),
                                  ControlButton(
                                    icon: Icons.image,
                                    label: 'Show Logo',
                                    onPressed: () {},
                                  ),
                                  ControlButton(
                                    icon: Icons.cleaning_services,
                                    label: 'Clean KML',
                                    onPressed: () {
                                      cleanKml();
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(width: 20),
                              Column(
                                children: [
                                  ControlButton(
                                    icon: Icons.refresh,
                                    label: 'Set Refresh',
                                    isPrimary: true,
                                    onPressed: () {
                                      setRefresh();
                                    },
                                  ),
                                  ControlButton(
                                    icon: Icons.refresh,
                                    label: 'Reset Refr..',
                                    isPrimary: true,
                                    onPressed: () {
                                      resetRefresh();
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(width: 20),
                              Column(
                                children: [
                                  ControlButton(
                                    icon: Icons.play_arrow,
                                    label: 'Relaunch LG',
                                    onPressed: () {
                                      relaunchLg();
                                    },
                                  ),
                                  ControlButton(
                                    icon: Icons.replay,
                                    label: 'Reboot LG',
                                    onPressed: () {
                                      rebootLG(context);
                                    },
                                  ),
                                  ControlButton(
                                    icon: Icons.power_settings_new,
                                    label: 'Shutdown LG',
                                    onPressed: () {
                                      shutdownLg();
                                    },
                                    isShutdown: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> relaunchLg() async {
    SSHSession? session = await SSH(ref: ref).relaunchLG();
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
}
