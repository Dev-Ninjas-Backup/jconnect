
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class MessagesController extends GetxController {
  var selectedTab = 'All Chats'.obs;

  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[
    {
      "name": "Reva Sky",
      "avatar": "assets/reva_sky.png",
      "time": "5m ago",
      "content": "I've just sent you a new track for review 👽",
      "unread": true,
    },
    {
      "name": "DJ NovaX",
      "avatar": "assets/dj_novax.png",
      "time": "15m ago",
      "content": "Got your track! I'll post it tomorrow as discussed...",
      "activeDeal": true,
    },
    {
      "name": "Luna Beats",
      "avatar": "assets/luna_beats.png",
      "time": "1h ago",
      "content": "Hey! Can we discuss your promo rates?",
      "archived": true,
    },
    {
      "name": "MelloTune",
      "avatar": "assets/mellotune.png",
      "time": "3h ago",
      "content": "Once payment clears, I'll drop the reaction video.",
      "archived": true,
    },
    {
      "name": "DJ Static",
      "avatar": "assets/dj_static.png",
      "time": "Yesterday",
      "content": "Glad you liked the review, bro! Let's collab again...",
      "completedDeal": true,
      "unread": true,
    },
    {
      "name": "DJ Aero",
      "avatar": "assets/dj_aero.png",
      "time": "Sep 12",
      "content": "All good! Let's plan next month's promo.",
    },
  ].obs;
}