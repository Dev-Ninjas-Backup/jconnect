import 'package:flutter/material.dart';
import 'package:jconnect/features/user_profile/followers_followings/model/follower_following_model.dart';

class UserTile extends StatelessWidget {
  final FollowModel user;
  const UserTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        user.fullName,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        user.email,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
