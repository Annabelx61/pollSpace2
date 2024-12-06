// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// // help from https://www.youtube.com/watch?v=tCN395wN3pY 

// class ProfilePicture extends StatefulWidget {
//   const ProfilePicture({super.key});

//   @override
//   State<ProfilePicture> createState() => _ProfilePictureState();
// }

// class _ProfilePictureState extends State<ProfilePicture> {
//   get get => null;
  
//   get pickedImage => null;

//   // Uint8List? pickedImage;

//   @override
//   void initState() {
//     super.initState();
//     // getProfilePicture();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 100,
//       width: 100,
//       decoration: BoxDecoration(
//         color: Colors.grey[400],
//         shape: BoxShape.circle,
//         //comment here
//         image: pickedImage != null
//           ? DecorationImage(
//             fit: BoxFit.cover,
//             image: Image.memory(
//               pickedImage!,
//               fit: BoxFit.cover,
//             ).image,
//           )
//         : null,
//              //comment here
//       ),
//            //comment here
//       child: const Center(
//         child: 
        
//         Icon(
//           Icons.person_rounded,
//           color: Colors.black38,
//           size: 35),
//         ),
//              //comment here
//     );
//   }
//        //comment here
//   Future<void> onProfileTapped() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? image = await picker.pickImage(source: ImageSource.gallery);
//     if (image == null) return;
//        //comment here
//       final storageRef = FirebaseStorage.instance.ref();
      
//         get;

//      //comment here
//     // final imageRef = storageRef.child("user_1.jpg");
//     // 'user_1'needs to be whatever the user id is
//     // final imageBytes = await image.readAsBytes();
//     // await imageRef.putData(imageBytes);

//     // setState(() => pickedImage = imageBytes);
//   }

//   Future<void> getProfilePicture() async {
//     final storageRef = FirebaseStorage.instance.ref();
//     final imageRef = storageRef.child('user_1.jpg');

//     // try {
//     //   final imageBytes = await imageRef.getData();
//     //   if (imageBytes == null) return;
//     //   setState(() => pickedImage = imageBytes);
//     // } catch (e) {
//     //   print('Profile picture could not be found');
//     // }
//   }
//        //comment here

// }
// }