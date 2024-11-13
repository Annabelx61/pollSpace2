import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  const ProfilePicture({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          color: Colors.black38,
          size: 35),
        ),
    );
  }
  void onProfileTapped() {}
}