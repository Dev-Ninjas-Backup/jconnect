import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ArtistsController extends GetxController {
  var searchTextController = TextEditingController();
  final RxInt selectArtistsItemIndex = 0.obs;
  final RxList<String> artistItem = [
    'All Artists',
    'Featured Artists',
    'Rising Stars',
    'Top Rated',
    'Most Active',
  ].obs;
}
