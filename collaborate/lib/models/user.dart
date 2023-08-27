import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String profilePic;
  final String username;
  final String rollNumber;
  final String about;
  final List followers;
  final List following;
  final List learnSkills;
  final List experienceSkills;

  User(
      {required this.username,
      required this.uid,
      required this.profilePic,
      required this.email,
      required this.rollNumber,
      required this.about,
      required this.followers,
      required this.following,
      required this.learnSkills,
      required this.experienceSkills});

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
        username: snapshot["username"],
        uid: snapshot["uid"],
        email: snapshot["email"],
        rollNumber: snapshot["rollNumber"],
        profilePic: snapshot["profilePic"],
        about: snapshot["about"],
        followers: snapshot["followers"],
        following: snapshot["following"],
        learnSkills: snapshot["learnSkills"],
        experienceSkills: snapshot['experienceSkills']);
  }

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "email": email,
        "rollNumber": rollNumber,
        "profilePic": profilePic,
        "about": about,
        "followers": followers,
        "following": following,
        "learnSkills": learnSkills,
        "experienceSkills": experienceSkills
      };
}
