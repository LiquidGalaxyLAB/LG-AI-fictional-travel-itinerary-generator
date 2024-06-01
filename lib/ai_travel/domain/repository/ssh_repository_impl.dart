import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/domain/repository/ssh_repository.dart';
import 'package:riverpod/src/framework.dart';

class SSHRepositoryImpl implements SSHRepository {
  final SSHClient _client;

  SSHRepositoryImpl(this._client);

  @override
  Future<void> cleanKml(BuildContext context, SSHSession session) {
    // TODO: implement cleanKml
    throw UnimplementedError();
  }

  @override
  Future<void> cleanLogos(BuildContext context, SSHSession session) {
    // TODO: implement cleanLogos
    throw UnimplementedError();
  }

  @override
  Future<void> cleanSlaves(BuildContext context, SSHSession session) {
    // TODO: implement cleanSlaves
    throw UnimplementedError();
  }

  @override
  Future<void> connectToLG(BuildContext context, SSHSession session) {
    // TODO: implement connectToLG
    throw UnimplementedError();
  }

  @override
  Future<void> disconnectLG(BuildContext context, SSHSession session) {
    // TODO: implement disconnectLG
    throw UnimplementedError();
  }

  @override
  Future<void> execute(BuildContext context, SSHSession session) {
    // TODO: implement execute
    throw UnimplementedError();
  }

  @override
  Future<void> rebootLG(BuildContext context, SSHSession session) {
    // TODO: implement rebootLG
    throw UnimplementedError();
  }

  @override
  Future<void> relaunchLG(BuildContext context, SSHSession session) {
    // TODO: implement relaunchLG
    throw UnimplementedError();
  }

  @override
  Future<void> resetRefresh(BuildContext context, SSHSession session) {
    // TODO: implement resetRefresh
    throw UnimplementedError();
  }

  @override
  Future<void> restartLG(BuildContext context, SSHSession session) {
    // TODO: implement restartLG
    throw UnimplementedError();
  }

  @override
  Future<void> setRefresh(BuildContext context, SSHSession session) {
    // TODO: implement setRefresh
    throw UnimplementedError();
  }

  @override
  Future<void> shutdownLG(BuildContext context, SSHSession session) {
    // TODO: implement shutdownLG
    throw UnimplementedError();
  }


}
