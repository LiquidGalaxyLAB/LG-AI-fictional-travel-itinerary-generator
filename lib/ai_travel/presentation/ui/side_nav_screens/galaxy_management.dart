import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/widgets/custom_dialog.dart';

import '../../../domain/ssh/SSH.dart';
import '../../providers/connection_providers.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/snack_bar.dart';
import '../main_screens/settings_screen.dart';

class LiquidGalaxyManagement extends ConsumerStatefulWidget {
  const LiquidGalaxyManagement({super.key});

  @override
  _LiquidGalaxyManagementState createState() => _LiquidGalaxyManagementState();
}

class _LiquidGalaxyManagementState
    extends ConsumerState<LiquidGalaxyManagement> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    bool isConnectedToLg = ref.watch(connectedProvider);

    return SafeArea(
      child: Scaffold(
        appBar: const CustomAppBar(),
        body: Container(
          padding: const EdgeInsets.all(16.0),
          height: height, // Constrain height to screen height
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
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: const Color(0xFF1E1E2C),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            ControlButton(
                              icon: Icons.cleaning_services,
                              label: 'Clean Slaves',
                              onPressed: () {
                                cleanSlaves();
                              },
                            ),
                            Spacer(),
                            ControlButton(
                              icon: Icons.image,
                              label: 'Show Logo',
                              onPressed: () {},
                            ),
                            Spacer(),
                            ControlButton(
                              icon: Icons.cleaning_services,
                              label: 'Clean KML',
                              onPressed: () {
                                setRefresh();
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ControlButton(
                              icon: Icons.refresh,
                              label: 'Set Refresh',
                              isPrimary: true,
                              onPressed: () {
                                setRefresh();
                              },
                            ),
                            const SizedBox(height: 20),
                            ControlButton(
                              icon: Icons.refresh,
                              label: 'Reset Refresh',
                              isPrimary: true,
                              onPressed: () {
                                resetRefresh();
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          children: [
                            ControlButton(
                              icon: Icons.play_arrow,
                              label: 'Relaunch LG',
                              onPressed: () {
                                buildShowDialog(context, () {relaunchLg();});
                              },
                            ),
                            Spacer(),
                            ControlButton(
                              icon: Icons.replay,
                              label: 'Reboot LG',
                              onPressed: () {
                                buildShowDialog(context, () {rebootLG(context);});
                              },
                            ),
                            Spacer(),
                            ControlButton(
                              icon: Icons.power_settings_new,
                              label: 'Shutdown LG',
                              onPressed: () {
                                buildShowDialog(context, () {shutdownLg();});
                              },
                              isShutdown: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> buildShowDialog(BuildContext context, VoidCallback onConfirm) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(onConfirm: () {
          onConfirm();
          Navigator.pop(context);
        }, onCancel: () {
          Navigator.pop(context);
        });
      },
    );
  }

  Future<void> relaunchLg() async {
    await SSH(ref: ref).relaunchLG();
  }

  rebootLG(context) async {
    try {
      for (var i = 1; i <= ref.read(rigsProvider); i++) {
        await ref.read(sshClientProvider)?.run(
            'sshpass -p ${ref.read(passwordProvider)} ssh -t lg$i "echo ${ref.read(passwordProvider)} | sudo -S reboot');
      }
    } catch (error) {
      SnackBarWidget().showSnackBar(
          context: context, message: error.toString(), color: Colors.red);
    }
  }

  Future<void> shutdownLg() async {
    await SSH(ref: ref).shutdownLG(context);
  }

  Future<void> setRefresh() async {
    await SSH(ref: ref).setRefresh(context);
  }

  Future<void> resetRefresh() async {
    await SSH(ref: ref).resetRefresh(context);
  }

  Future<void> cleanSlaves() async {
    await SSH(ref: ref).cleanSlaves(context);
  }

  Future<void> cleanKml() async {
    await SSH(ref: ref).cleanKML(context);
    await SSH(ref: ref).cleanBalloon(context);
    await SSH(ref: ref).cleanSlaves(context);
    await SSH(ref: ref).setRefresh(context);
  }
}
