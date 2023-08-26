import 'package:cloud_firestore/cloud_firestore.dart';

// await FirebaseFirestore.instance.collection('groups').add({
//       'category': selectedCategory,
//       'skills': skillsList,
//       'isHidden': isHidden,
//       'description': description,
//       'profilePicUrl': profilePicUrl,
//       'createdBy': user.uid,
//     });

class Group {
  final String groupId;
  final String groupName;
  final String category;
  final List skillsList;
  final bool isHidden;
  final String description;
  final String uid;
  final String username;
  final DateTime dateCreated;
  final String profilePic;
  final List groupMembers;

  const Group(
      {required this.groupId,
      required this.groupName,
      required this.category,
      required this.skillsList,
      required this.isHidden,
      required this.description,
      required this.uid,
      required this.username,
      required this.dateCreated,
      required this.profilePic,
      required this.groupMembers});

  static Group fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Group(
      groupId: snapshot["groupId"],
      description: snapshot["description"],
      groupName: snapshot["groupName"],
      category: snapshot["category"],
      skillsList: snapshot["skillsList"],
      isHidden: snapshot["isHidden"],
      uid: snapshot["uid"],
      username: snapshot["username"],
      dateCreated: snapshot["dateCreated"],
      profilePic: snapshot["profilePic"],
      groupMembers: snapshot["groupMembers"],
    );
  }

  Map<String, dynamic> toJson() => {
        "groupId": groupId,
        "description": description,
        "groupName": groupName,
        "category": category,
        "skillsList": skillsList,
        "isHidden": isHidden,
        "uid": uid,
        "username": username,
        "dateCreated": dateCreated,
        'profilePic': profilePic,
        "groupMembers": groupMembers
      };
}