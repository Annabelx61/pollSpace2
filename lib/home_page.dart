import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'src/authentication.dart';
import 'dart:async';

class PollPage extends StatefulWidget {
  @override
  _PollPageState createState() => _PollPageState();
}

class _PollPageState extends State<PollPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Tracks whether a user is logged in
  User? user;

  @override
  void initState() {
    super.initState();

    _auth.authStateChanges().listen((currentUser) {
      setState(() {
        user = currentUser;
      });
    });
  }

  // Handle casting a vote for a poll option
  Future<void> _castVote(String pollId, String optionId) async {
    if (user == null) return; 

    // Check if the user has already voted for this poll
    final userVoteRef = _firestore.collection('polls').doc(pollId).collection('userVotes').doc(user!.uid);
    final userVoteSnapshot = await userVoteRef.get();

    if (userVoteSnapshot.exists) {
      // prevent further voting
      return;
    }

    final optionRef = _firestore.collection('polls').doc(pollId).collection('option').doc(optionId);
    final optionSnapshot = await optionRef.get();
    final currentVotes = optionSnapshot.data()?['votes'] ?? 0;

    // Update the option vote count
    await optionRef.update({'votes': currentVotes + 1});

    // Record that the user has voted for this poll
    await userVoteRef.set({
      'pollId': pollId,
      'optionId': optionId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('spacePoll 🗳'),
      ),
      body: Consumer<ApplicationState>(
        builder: (context, appState, _) {
          return Column(
            children: [
              AuthFunc(
                loggedIn: appState.loggedIn,
                signOut: () {
                  FirebaseAuth.instance.signOut();
                },
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('polls').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final polls = snapshot.data?.docs ?? [];

                    return ListView.builder(
                      itemCount: polls.length,
                      itemBuilder: (context, index) {
                        final poll = polls[index];
                        final pollId = poll.id;
                        final question = poll['question'];

                        return Card(
                          margin: const EdgeInsets.all(10),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(question, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 10),
                                StreamBuilder<QuerySnapshot>(
                                  stream: _firestore.collection('polls').doc(pollId).collection('option').snapshots(),
                                  builder: (context, optionSnapshot) {
                                    if (!optionSnapshot.hasData) {
                                      return const CircularProgressIndicator();
                                    }

                                    final options = optionSnapshot.data?.docs ?? [];
                                    int totalVotes = options.fold(0, (sum, option) => sum + ((option['votes'] ?? 0)) as int);

                                    return Column(
                                      children: [
                                        ...options.map((option) {
                                          final optionId = option.id;
                                          final optionText = option['title'];
                                          final votes = option['votes'] ?? 0;

                                          return ListTile(
                                            title: Text(optionText),
                                            subtitle: Text('Votes: $votes'),
                                            trailing: user != null
                                                ? ElevatedButton(
                                                    onPressed: () async {
                                                      // Check if the user has already voted before allowing them to vote
                                                      await _castVote(pollId, optionId);
                                                    },
                                                    child: const Text('Vote'),
                                                  )
                                                : null,
                                          );
                                        }),
                                        const SizedBox(height: 10),
                                        Text('Total Votes: $totalVotes', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
