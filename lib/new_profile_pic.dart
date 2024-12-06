import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';             
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as path;    


class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File? _imageFile;
  String? _downloadURL;
  
  // at 7 min in video to look back below
  Future<void> _pickImage() async{
    final pickedFile = await ImagePicker()
    .pickImage(source: ImageSource.gallery, imageQuality: 80);
    setState((){
      _imageFile = File(pickedFile!.path);
    });
  }

    Future<void> _uploadImage() async{
    if(_imageFile == null)return;
    final fileName = path.basename(_imageFile!.path);
    final storageRef = FirebaseStorage.instance.ref().child('uploads/$fileName');
    await storageRef.putFile(_imageFile!);
    final url = await storageRef.getDownloadURL();
    setState(()
    {
      _downloadURL = url;
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Upload Image"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _imageFile != null ? Image.file(_imageFile!,
              height: 250,
              width: 250,
              )
              // ignore: sized_box_for_whitespace
              : Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: const Center(
                  child: Icon(Icons.image),
                  )
              ),

              const SizedBox(height: 20),
              ElevatedButton(onPressed: _pickImage, child: Text("Pick Image"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _uploadImage, child: const Text("Upload Image"),
              ),
              const SizedBox(height: 20),
              _downloadURL != null ? Image.network(_downloadURL!, height: 250, width: 250,) 
              : const SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}