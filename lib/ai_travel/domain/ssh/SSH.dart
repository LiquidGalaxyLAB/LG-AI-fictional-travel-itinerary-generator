
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/kml/NamePlaceBallon.dart';
import '../../presentation/providers/connection_providers.dart';
import '../../presentation/widgets/snack_bar.dart';

class SSH {
  final WidgetRef ref;
  SSH({required this.ref});
  SSHClient? _client;
  final SnackBarWidget customWidgets = SnackBarWidget();


  /// For connection with the rigs using SSH
  Future<bool?> connectToLG(BuildContext context) async {
    try {
      final socket = await SSHSocket.connect(
          ref.read(ipProvider), ref.read(portProvider),
          timeout: const Duration(seconds: 5));
      ref
          .read(sshClientProvider.notifier)
          .state = SSHClient(
        socket,
        username: ref.read(usernameProvider),
        onPasswordRequest: () => ref.read(passwordProvider),
      );
      ref
          .read(connectedProvider.notifier)
          .state = true;
      return true;
    } catch (e) {
      ref
          .read(connectedProvider.notifier)
          .state = false;
      print('Failed to connect: $e');
      customWidgets.showSnackBar(
          context: context, message: e.toString(), color: Colors.red);
      return false;
    }
  }

  /// For shutting down the rigs using SSH
   shutdownLG(context) async {
    try {
      for (var i = 1; i <= ref.read(rigsProvider); i++) {
        await ref.read(sshClientProvider)?.run(
            'sshpass -p ${ref.read(passwordProvider)} ssh -t lg$i "echo ${ref.read(passwordProvider)} | sudo -S poweroff"');
      }
    } catch (error) {
      customWidgets.showSnackBar(
          context: context, message: error.toString(), color: Colors.red);
    }
  }

  Future<String> renderInSlave(context, int slaveNo, String kml) async {
    try {
      await ref
          .read(sshClientProvider)
          ?.run("echo '$kml' > /var/www/html/kml/slave_$slaveNo.kml");
      return kml;
    } catch (error) {
      customWidgets.showSnackBar(
          context: context, message: error.toString(), color: Colors.red);
      return BalloonMakers.blankBalloon();
    }
  }
  cleanBalloon(context) async {
    try {
      String blank = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <Document>
  </Document>
</kml>''';
      await ref.read(sshClientProvider)?.run(
          "echo '${BalloonMakers
              .blankBalloon()}' > /var/www/html/kml/slave_${ref.read(
              leftmostRigProvider)}.kml");
    } catch (error) {
      // await connectionRetry(context);
      await cleanBalloon(context);
    }
  }
  Future ChatResponseBalloon(String data) async {
    int rigs = 4;
    _client = ref.read(sshClientProvider);
    rigs = ref.read(rightmostRigProvider);
    String openLogoKML =
    '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<Document>
 <name>About Data</name>
 <Style id="about_style">
   <BalloonStyle>
     <textColor>ffffffff</textColor>
     <text>
        <h2>$data</h2>
       
        
     </text>
     <bgColor>ff15151a</bgColor>
   </BalloonStyle>
 </Style>
 <Placemark id="ab">
   <description>
   </description>
   <LookAt>
     <longitude>0</longitude>
     <latitude>0</latitude>
    
   </LookAt>
   <styleUrl>#about_style</styleUrl>
   <gx:balloonVisibility>1</gx:balloonVisibility>
   <Point>
     <coordinates>0,0,0</coordinates>
   </Point>
 </Placemark>
</Document>
</kml>''';
    try {
      await _client?.execute("echo '$openLogoKML' > /var/www/html/kml/slave_2.kml");
    } catch (e) {
      return Future.error(e);
    }
  }

  /// For restarting the rigs using SSH
   relaunchLG() async {
    try {
      _client = ref.read(sshClientProvider);
      for (var i = 1; i <= ref.read(rigsProvider); i++) {
        String cmd = """RELAUNCH_CMD="\\
          if [ -f /etc/init/lxdm.conf ]; then
            export SERVICE=lxdm
          elif [ -f /etc/init/lightdm.conf ]; then
            export SERVICE=lightdm
          else
            exit 1
          fi
          if  [[ \\\$(service \\\$SERVICE status) =~ 'stop' ]]; then
            echo ${ref.read(passwordProvider)} | sudo -S service \\\${SERVICE} start
          else
            echo ${ref.read(passwordProvider)} | sudo -S service \\\${SERVICE} restart
          fi
          " && sshpass -p ${ref.read(
            passwordProvider)} ssh -x -t lg@lg$i "\$RELAUNCH_CMD\"""";
        await ref.read(sshClientProvider)?.execute(
            '"/home/${ref.read(usernameProvider)}/bin/lg-relaunch" > /home/${ref
                .read(usernameProvider)}/log.txt');
        await ref.read(sshClientProvider)?.execute(cmd);
      }

      /*if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }
      final session = await _client!.execute('lg-relaunch');
      return session;*/
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }

  resetRefresh(context) async {
    try {
      for (var i = 2; i <= ref.read(rigsProvider); i++) {
        String search =
            '<href>##LG_PHPIFACE##kml\\/slave_$i.kml<\\/href><refreshMode>onInterval<\\/refreshMode><refreshInterval>2<\\/refreshInterval>';
        String replace = '<href>##LG_PHPIFACE##kml\\/slave_$i.kml<\\/href>';

        await ref.read(sshClientProvider)?.run(
            'sshpass -p ${ref.read(passwordProvider)} ssh -t lg$i \'echo ${ref.read(passwordProvider)} | sudo -S sed -i "s/$search/$replace/" ~/earth/kml/slave/myplaces.kml\'');
      }
    } catch (error) {
      SnackBarWidget().showSnackBar(context: context, message: error.toString(), color: Colors.red);
    }
  }

  /// This is for locating a place via SSH
  Future<SSHSession?> search(String place) async {
    try {
      _client = ref.read(sshClientProvider);
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }
      final session =
      await _client!.execute('echo "search=$place" >/tmp/query.txt');
      return session;
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }

  /// This is for initial visualization after connecting
  Future<SSHSession?> execute() async {
    try {
      _client = ref.read(sshClientProvider);
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }
      final session =
      await _client!.execute('echo "search=Lleida" >/tmp/query.txt');
      return session;
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }

  /// For disconnecting from the lg rigs
  disconnect(context, {bool snackBar = true}) async {
    ref.read(sshClientProvider)?.close();
    ref
        .read(sshClientProvider.notifier)
        .state = null;
    if (snackBar) {
      /* showSnackBar(
          context: context,
          message: translate('settings.disconnection_completed'));*/
    }
    ref.read(connectedProvider.notifier).state = false;
  }

  cleanKML(context) async {
    try {
      await stopOrbit(context);
      await ref.read(sshClientProvider)?.run('echo "" > /tmp/query.txt');
      await ref.read(sshClientProvider)?.run("echo '' > /var/www/html/kml/slave_2.txt");
    } catch (error) {

      await cleanKML(context);
      // showSnackBar(
      //     context: context, message: error.toString(), color: Colors.red);
    }
  }

  cleanSlaves(context) async {
    String blank = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <Document>
  </Document>
</kml>''';
    try {
      for (var i = 2; i <= ref.read(rigsProvider); i++) {
        await ref
            .read(sshClientProvider)
            ?.run("echo '$blank' > /var/www/html/kml/slave_$i.kml");
      }
    } catch (error) {
      await cleanSlaves(context);
    }
  }

  stopOrbit(context) async {
    try {
      await ref.read(sshClientProvider)?.run('echo "exittour=true" > /tmp/query.txt');
    } catch (error) {

      stopOrbit(context);
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
  /// For refreshing the visualization
  setRefresh(context) async {
    _client = ref.read(sshClientProvider);
    try {
      for (var i = 2; i <= ref.read(rigsProvider); i++) {
        String search = '<href>##LG_PHPIFACE##kml\\/slave_$i.kml<\\/href>';
        String replace =
            '<href>##LG_PHPIFACE##kml\\/slave_$i.kml<\\/href><refreshMode>onInterval<\\/refreshMode><refreshInterval>2<\\/refreshInterval>';

        await ref.read(sshClientProvider)?.run(
            'sshpass -p ${ref.read(passwordProvider)} ssh -t lg$i \'echo ${ref
                .read(
                passwordProvider)} | sudo -S sed -i "s/$replace/$search/" ~/earth/kml/slave/myplaces.kml\'');
        await ref.read(sshClientProvider)?.run(
            'sshpass -p ${ref.read(passwordProvider)} ssh -t lg$i \'echo ${ref
                .read(
                passwordProvider)} | sudo -S sed -i "s/$search/$replace/" ~/earth/kml/slave/myplaces.kml\'');
      }
    } catch (error) {
      customWidgets.showSnackBar(context: context, message: "Error: $error", color: Colors.red);
    }
  }

}