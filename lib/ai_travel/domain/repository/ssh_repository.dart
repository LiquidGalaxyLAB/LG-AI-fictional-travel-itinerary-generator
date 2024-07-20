import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Not in Use : Might be used in future
abstract class SSHRepository {
  Future<void> connectToLG(BuildContext context, SSHSession session);
  Future<void> execute(BuildContext context, SSHSession session);
  Future<void> disconnectLG(BuildContext context, SSHSession session);
  Future<void> shutdownLG(BuildContext context, SSHSession session);
  Future<void> relaunchLG(BuildContext context, SSHSession session);
  Future<void> restartLG(BuildContext context, SSHSession session);
  Future<void> cleanKml(BuildContext context, SSHSession session);
  Future<void> cleanSlaves(BuildContext context, SSHSession session);
  Future<void> cleanLogos(BuildContext context, SSHSession session);
  Future<void> rebootLG(BuildContext context, SSHSession session);
  Future<void> setRefresh(BuildContext context, SSHSession session);
  Future<void> resetRefresh(BuildContext context, SSHSession session);
}