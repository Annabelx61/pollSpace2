import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

class ApplicationState extends ChangeNotifier {

  Map<String, String> votedPolls = {};

  // Method to check if the user has voted
  bool hasVoted(String pollId) {
    return votedPolls.containsKey(pollId);
  }

  void clearVoteStatus() {
    _votedPolls.clear();  
    notifyListeners();
  }

  // Method to record a user's vote
  void setVoted(String pollId, String optionId) {
    votedPolls[pollId] = optionId;
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
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('votes')
          .doc(userId)
          .collection('userVotes')
          .get();

      // Update local votedPolls map
      for (var doc in snapshot.docs) {
        votedPolls[doc['pollId']] = doc['optionId'];
      }

      notifyListeners();
    } catch (e) {
      print('Error loading votes: $e');
    }
  } // load everyone's vote

  // Save the user's vote to Firestore
  void _saveVoteToFirestore(String pollId, String optionId) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('votes')
          .doc(user.uid)
          .collection('userVotes')
          .doc(pollId)
          .set({
        'pollId': pollId,
        'optionId': optionId,
      });
    }
  }

  void setLoggedIn(bool value) {
    _loggedIn = value;
    notifyListeners();
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

