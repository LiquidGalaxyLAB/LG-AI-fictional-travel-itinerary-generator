import '../../../data/model/SubPoiInfoModal.dart';

abstract class MapRepository{
  Future<SubPoiInfoModal?> getSubPoiPlaceInfo(String query);
}
