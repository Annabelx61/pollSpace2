import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      if (currentUser == null) {
        // Reset polls on sign-out
        _resetPollVotes();
      }
    });
  }

  // Reset poll votes
  Future<void> _resetPollVotes() async {
    final polls = await _firestore.collection('polls').get();
    for (var poll in polls.docs) {
      final options = await poll.reference.collection('option').get();
      for (var option in options.docs) {
        await option.reference.update({'votes': 0});
      }
    }
  }

  // Handle voting
  Future<void> _castVote(String pollId, String optionId) async {
    final optionRef = _firestore.collection('polls').doc(pollId).collection('option').doc(optionId);
    final optionSnapshot = await optionRef.get();
    final currentVotes = optionSnapshot.data()?['votes'] ?? 0;

    await optionRef.update({'votes': currentVotes + 1});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Polls'),
        actions: [
          user != null
              ? IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () async {
                    await _auth.signOut();
                  },
                )
              : Container(),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('polls').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final polls = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: polls.length,
            itemBuilder: (context, index) {
              final poll = polls[index];
              final pollId = poll.id;
              final question = poll['question'];

              return Card(
                margin: EdgeInsets.all(10),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(question, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      StreamBuilder<QuerySnapshot>(
                        stream: _firestore.collection('polls').doc(pollId).collection('option').snapshots(),
                        builder: (context, optionSnapshot) {
                          if (!optionSnapshot.hasData) {
                            return CircularProgressIndicator();
                          }

                          final options = optionSnapshot.data?.docs ?? [];
                          int totalVotes = options.fold(0, (sum, option) => sum + ((option['votes'] ?? 0))as int);

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
                                          onPressed: () => _castVote(pollId, optionId),
                                          child: Text('Vote'),
                                        )
                                      : null,
                                );
                              }).toList(),
                              SizedBox(height: 10),
                              Text('Total Votes: $totalVotes', style: TextStyle(fontWeight: FontWeight.bold)),
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
    );
  }
}

