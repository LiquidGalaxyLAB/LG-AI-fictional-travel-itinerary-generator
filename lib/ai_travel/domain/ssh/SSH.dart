
import 'dart:io';
import 'dart:math';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/config/string/String.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/kml/KmlMaker.dart';
import '../../core/kml/LookAt.dart';
import '../../core/kml/NamePlaceBallon.dart';
import '../../core/utils/Images.dart';
import '../../core/utils/constants.dart';
import '../../data/service/mapService.dart';
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
      ref.read(sshClientProvider.notifier).state = SSHClient(
        socket,
        username: ref.read(usernameProvider),
        onPasswordRequest: () => ref.read(passwordProvider),
      );
      ref.read(connectedProvider.notifier).state = true;
      return true;
    } catch (e) {
      ref
          .read(connectedProvider.notifier)
          .state = false;
      print('Failed to connect: $e');
      customWidgets.showSnackBar(context: context, message: e.toString(), color: Colors.red);
      return false;
    }
  }

  Future<SSHSession?> motionControls (double updownflag, double rightleftflag, double zoomflag, double tiltflag, double bearingflag) async {
    _client = ref.read(sshClientProvider);
    LookAt flyto = LookAt(rightleftflag, updownflag, zoomflag.toString(),
        tiltflag.toString(), bearingflag.toString());
    try {
      final session = await _client?.execute(
          'echo "flytoview=${flyto.generateLinearString()}" > /tmp/query.txt');
      return session;
    } catch (e) {
      print('Could not connect to host LG');
      return Future.error(e);
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

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  buildOrbit(String content) async {
    try {
      String localPath = await _localPath;
      String filePath = '$localPath/Orbit.kml';
      File localFile = File(filePath);
      await localFile.writeAsString(content);
      print('File written to $filePath');

      final client = ref.read(sshClientProvider);
      if (client == null) {
        throw Exception('SSH client is not initialized');
      }
      final sftp = await client.sftp();
      if (sftp == null) {
        throw Exception('Failed to initialize SFTP client');
      }

      final file = await sftp.open(
        filePath,
        mode: SftpFileOpenMode.truncate | SftpFileOpenMode.write,
      );

      await file.write(File('/var/www/html/Orbit.kml').openRead().cast()).done;
      print('done');

      print('File uploaded successfully to /var/www/html/Orbit.kml');

      // Execute command on the remote server
      var result = await client.execute(
        "echo '\nhttp://lg1:81/Orbit.kml' >> /var/www/html/kmls.txt",
      );
      return result;
    } catch (e) {
      print('Error occurred: $e');
      return Future.error(e);
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
      await connectionRetry(context);
      await cleanBalloon(context);
    }
  }

  showSplashLogo() async{
    await ref.read(sshClientProvider)?.execute(
        "echo '${KMLMakers.screenOverlayImage(ImageConst.splashOnline3, Const.splashAspectRatio)}' > /var/www/html/kml/slave_${ref.read(leftmostRigProvider)}.kml");
  }




  Future<String> getBase64Image(String placeName) async{
    var base64 = await loadNearbyPlacesImages(apiKey: "", textQuery: placeName);
    print("base64 $base64");
    return base64;
    /*try{

    }catch(e){
      print("$e this is error of image");
      return 'https://raw.githubusercontent.com/Rohit-554/LaserSlidesFlutter/master/explore.png';
    }*/
  }

  /// Beaware : this is just for testing
/*  String base64Stringtest(){
    final base64 = """
    /9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBAQFBAYFBQYJBgUGCQsIBgYICwwKCgsKCgwQDAwMDAwMEAwODxAPDgwTExQUExMcGxsbHB8fHx8fHx8fHx//2wBDAQcHBw0MDRgQEBgaFREVGh8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx//wgARCAIVAyADAREAAhEBAxEB/8QAGwABAAEFAQAAAAAAAAAAAAAAAAUBAgYHCAT/xAAUAQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIQAxAAAAHagAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALDn8ijoElwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAeM5kLDexmgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABh5GGwioAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP/EABwQAAIDAAMBAAAAAAAAAAAAAAIEAQMFBmCwAP/aAAgBAQABBQL0sDIQDX3W37k9BxSzJ0BfR7A7UVqZDIl9xGg6sjsOpxlJ+xPhidVkRER6WH//xAAUEQEAAAAAAAAAAAAAAAAAAADA/9oACAEDAQE/AVFn/8QAFBEBAAAAAAAAAAAAAAAAAAAAwP/aAAgBAgEBPwFRZ//EACgQAAIBAgIJBQAAAAAAAAAAAAECAwAhEXEEMTJBQlFggbAQEkNhwf/aAAgBAQAGPwLyWBdrKoxPamwcpo/BGOX3QeCUqRu3HMVHpAGBNnXkw19QzxLtSRso7jCirWYWI9AX+Vy65WH51EZgTDMdpluDmKDzymcDgw9o73NACwGoeSx//8QAIBABAAEDBAMBAAAAAAAAAAAAAREAITFRYGGREKGwsf/aAAgBAQABPyH6WCiSD6AlqGjqPQ0MYlaVNks54sDXoScAbh9iQ7j9oMJKrIlk8DQkOdYHd+4sdF0clYvyNKj2S79l7o+wUBgDB9LH/9oADAMBAAIAAwAAABCSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSQCSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSCCSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSACSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSST//EABQRAQAAAAAAAAAAAAAAAAAAAMD/2gAIAQMBAT8QUWf/xAAUEQEAAAAAAAAAAAAAAAAAAADA/9oACAECAQE/EFFn/8QAIRABAAIBAwQDAAAAAAAAAAAAAREhADFBYRBRYLBxgaH/2gAIAQEAAT8Q9lhKLKdFE+gyi0Z7KaI1s0aGB+wBCGVNTvWDWImVKIWKmzh8hV2EwpP3zD3asCcjkTpzbGw2cSD58ivCY0HdA8BO+BbgQOGQAF3IThp1GgBABoB7LH//2Q==
    """;
    return base64;
  }*/

  Future<void> chatResponseBalloon(String data, LatLng coordinates, String placeName, String textQuery) async {
    final _client = ref.read(sshClientProvider);
    String openLogoKML = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <Document>
    <name>About Data</name>
    <ScreenOverlay>
      <description><![CDATA[
        <div style="font-size:40px; text-align: center;">
          <div style="font-weight: bold; margin-bottom: 30px;">$placeName</div>
          <div style="width: 100%; text-align: center;">
            <img src="data:image/jpeg;base64,${await getBase64Image(textQuery)}" alt="Placeholder Image" style="width: 100%; height: auto; border-radius: 30px;"/>
          </div>
          <div style="margin-top: 20px;">$data</div>
        </div>
      ]]></description>
      <overlayXY x="0" y="0" xunits="fraction" yunits="fraction"/>
      <screenXY x="0.0" y="0.0" xunits="fraction" yunits="fraction"/>
      <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
      <size x="0" y="0" xunits="fraction" yunits="fraction"/>
      <gx:balloonVisibility>1</gx:balloonVisibility>
    </ScreenOverlay>
  </Document>
</kml>''';
    try {
      String escapedKML = openLogoKML.replaceAll("'", "'\\''");
      await _client?.execute("echo '$escapedKML' > /var/www/html/kml/slave_${ref.read(rightmostRigProvider)}.kml");
    } catch (e) {
      return Future.error('Failed to execute SSH command: $e');
    }
  }

  ///Connection Retry
  connectionRetry(context, {int i = 0}) async {
    ref.read(sshClientProvider)?.close();
    SSHSocket socket;
    try {
      socket = await SSHSocket.connect(
          ref.read(ipProvider), ref.read(portProvider),
          timeout: const Duration(seconds: 5));
    } catch (error) {
      ref.read(connectedProvider.notifier).state = false;
      return false;
    }
    ref.read(sshClientProvider.notifier).state = SSHClient(
      socket,
      username: ref.read(usernameProvider)!,
      onPasswordRequest: () => ref.read(passwordProvider)!,
    );
    return true;
  }

  /// For restarting the rigs using SSH
   relaunchLG(context) async {
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
    } catch (error) {
      customWidgets.showSnackBar(context: context, message: error.toString(), color: Colors.red);
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
    ref.read(sshClientProvider.notifier).state = null;
    if (snackBar) {
      customWidgets.showSnackBar(context: context, message: Strings.disconnectCompleted, color: Colors.green);
    }
    ref.read(connectedProvider.notifier).state = false;
  }

  /// For cleaning the KML files
  cleanKML(context) async {
    try {
      await stopOrbit(context);
      await ref.read(sshClientProvider)?.run('echo "" > /tmp/query.txt');
      await ref.read(sshClientProvider)?.run("echo '' > /var/www/html/kml/slave_${ref.read(rightmostRigProvider)}.txt");
    } catch (error) {
      await connectionRetry(context);
      await cleanKML(context);
      customWidgets.showSnackBar(context: context, message: error.toString(), color: Colors.red);
    }
  }

  /// For cleaning the slaves
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

  /// For stopping the orbit
  stopOrbit(context) async {
    try {
      await ref.read(sshClientProvider)?.run('echo "exittour=true" > /tmp/query.txt');
    } catch (error) {
      stopOrbit(context);
    }
  }

  /// For restarting the LG rigs
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

  /// For flying to a location
  flyTo(context, double latitude, double longitude, double zoom, double tilt,
      double bearing) async {
    try {
      Future.delayed(Duration.zero).then((x) async {
        ref.read(lastGMapPositionProvider.notifier).state = CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: zoom,
          tilt: tilt,
          bearing: bearing,
        );
      });
      await ref.read(sshClientProvider)?.run(
          'echo "flytoview=${KMLMakers.lookAtLinear(latitude, longitude, zoom, tilt, bearing)}" > /tmp/query.txt');
    } catch (error) {
      try {
        await connectionRetry(context);
        await flyTo(context, latitude, longitude, zoom, tilt, bearing);
      } catch (e) {}
    }
  }

  static String orbitAround(
      LatLng latLng, {
        double zoom = 17,
      }) {
    print('orbitAround');
    int heading = 0;
    String tags = "";
    double altitude = 156543.03392 * cos(latLng.latitude * pi / 180) / pow(2.0, zoom) * 1000;

    for (var i = 0; i <= 36; i++) {
      heading += 10;
      tags += """
      <gx:FlyTo>
        <gx:duration>1.2</gx:duration>
        <gx:flyToMode>smooth</gx:flyToMode>
        <LookAt>
          <longitude>${latLng.longitude}</longitude>
          <latitude>${latLng.latitude}</latitude>
          <heading>$heading</heading>
          <tilt>60</tilt>
          <range>2000</range>
          <gx:fovy>60</gx:fovy>
          <altitude>3341.7995674</altitude>
          <gx:altitudeMode>absolute</gx:altitudeMode>
        </LookAt>
      </gx:FlyTo>""";
    }

    return """<?xml version="1.0" encoding="UTF-8"?>
    <kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">  
      <gx:Tour>
        <name>Orbit</name>
        <gx:Playlist>$tags</gx:Playlist>
      </gx:Tour>
    </kml>""";
  }

  /// For Flying to a instant
  flyToInstant(context, double latitude, double longitude, double zoom,
      double tilt, double bearing) async {
    try {
      ref.read(lastGMapPositionProvider.notifier).state = CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: zoom,
        tilt: tilt,
        bearing: bearing,
      );
      await ref.read(sshClientProvider)?.run(
          'echo "flytoview=${KMLMakers.lookAtLinearInstant(latitude, longitude, zoom, tilt, bearing)}" > /tmp/query.txt');
    } catch (error) {
      customWidgets.showSnackBar(context: context, message: error.toString(), color: Colors.red);
    }
  }

  /// For flying to an orbit
  flyToOrbit(context, double latitude, double longitude, double zoom,
      double tilt, double bearing) async {
    try {
      await ref.read(sshClientProvider)?.run(
          'echo "flytoview=${KMLMakers.orbitLookAtLinear(latitude, longitude, zoom, tilt, bearing)}" > /tmp/query.txt');
    } catch (error) {
      await connectionRetry(context);
      await flyToOrbit(context, latitude, longitude, zoom, tilt, bearing);
    }
  }

  /// For starting any orbit
  startOrbit(context) async {
    try {
      await ref.read(sshClientProvider)?.run('echo "playtour=Orbit" > /tmp/query.txt');
    } catch (error) {
      await SSH(ref: ref).connectionRetry(context);
      await startOrbit(context);
    }
  }
}