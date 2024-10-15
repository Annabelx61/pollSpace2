import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

class ApplicationState extends ChangeNotifier {

  // Method to check if the user has voted
  bool hasVoted(String pollId) {
    return _votedPolls.containsKey(pollId);
  }

  // Method to record a user's vote
  void setVoted(String pollId, String optionId) {
    _votedPolls[pollId] = optionId;
    notifyListeners();
    _saveVoteToFirestore(pollId, optionId);
  }

  ApplicationState() {
    init();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  final Map<String, String> _votedPolls = {};

  Future<void> init() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
    }

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
        _loadUserVotes(user.uid); // load previous votes
      } else {
        _loggedIn = false;
        _votedPolls.clear(); // Clear local vote cache when logged out
      }
      notifyListeners();
    });
  }

  // loads previous user voting history from firebase
  Future<void> _loadUserVotes(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('votes')
        .get();

    for (var doc in snapshot.docs) {
      _votedPolls[doc.id] = doc.data()['optionId'] as String;
    }
    notifyListeners();
  }

  // Method to saves a user's vote in the firebase
  Future<void> _saveVoteToFirestore(String pollId, String optionId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('votes')
          .doc(pollId)
          .set({
        'optionId': optionId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  Future<DocumentReference> addMessageToGuestBook(String message) {
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    return FirebaseFirestore.instance
        .collection('guestbook')
        .add(<String, dynamic>{
      'text': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'name': FirebaseAuth.instance.currentUser!.displayName,
      'userId': FirebaseAuth.instance.currentUser!.uid,
    });
  }
}
