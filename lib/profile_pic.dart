import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  Future<void> onProfileTapped() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child("user_1.jpg");
  }


}