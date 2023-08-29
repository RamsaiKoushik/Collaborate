import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

// this class is used only to store group profile pics,profile pics
class StorageMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImageToStorage(String childName, Uint8List file,
      bool isGroup, bool newGroup, String groupId) async {
    Reference ref =
        _storage.ref().child(childName).child(_auth.currentUser!.uid);

    if (isGroup) {
      // if it is a group profile pic, it's path will be different
      String id;
      if (newGroup) {
        //if new pic add an identification, else store in the same location
        id = const Uuid().v1();
      } else {
        id = groupId;
      }
      ref = ref.child(id);
    }
    UploadTask uploadTask = ref.putData(file);

    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}

//used Uint8List format because dart:io doesn't support file 
