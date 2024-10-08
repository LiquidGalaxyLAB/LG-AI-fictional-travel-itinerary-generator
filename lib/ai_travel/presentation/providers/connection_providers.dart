import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/config/string/String.dart';

import '../../core/kml/NamePlaceBallon.dart';

StateProvider<SSHClient?> sshClientProvider = StateProvider(
      (ref) => null,
);

StateProvider<String> ipProvider = StateProvider((ref) => ''); //192.168.201.3
StateProvider<String> usernameProvider = StateProvider((ref) => ''); //lg
StateProvider<String> passwordProvider = StateProvider((ref) => ''); //lg
StateProvider<int> portProvider = StateProvider((ref) => 22);
StateProvider<int> rigsProvider = StateProvider((ref) => 3);
StateProvider<String> groqApiProvider = StateProvider((ref) => '');
StateProvider<bool> connectedProvider = StateProvider((ref) => false);
StateProvider<int> leftmostRigProvider = StateProvider((ref) => 3);
StateProvider<int> rightmostRigProvider = StateProvider((ref) => 2);
/*StateProvider<String> lastBalloonProvider = StateProvider((ref) => BalloonMakers.blankBalloon());*/
StateProvider<bool> isLoadingProvider = StateProvider((ref) => false);
StateProvider<String> currentAiModelSelected = StateProvider((ref) => gemma7b);
StateProvider<List<String>> groqAiModelsListProvider = StateProvider((ref) => []);
StateProvider<bool> isSpeaking = StateProvider((ref) => false);
StateProvider<bool> isVoiceStopped = StateProvider((ref) => false);
StateProvider<bool> isNewChat = StateProvider((ref) => false);
StateProvider<String> lastBalloonProvider = StateProvider((ref) => BalloonMakers.blankBalloon());
StateProvider<CameraPosition?> lastGMapPositionProvider =
StateProvider((ref) => null);
StateProvider<bool> isConnectedToLGProvider = StateProvider((ref) => false);
StateProvider<bool> isOrbitPlaying = StateProvider((ref) => false);

setRigs(int rig, WidgetRef ref) {
  ref.read(rigsProvider.notifier).state = rig;
  ref.read(leftmostRigProvider.notifier).state = (rig) ~/ 2 + 2;
  ref.read(rightmostRigProvider.notifier).state = (rig) ~/ 2 + 1;
}