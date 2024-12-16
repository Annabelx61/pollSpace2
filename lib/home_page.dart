// https://pub.dev/packages/flutter_polls
// -> The base for the code



import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polls/flutter_polls.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'src/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:async';

class Polls extends StatefulWidget {
  const Polls({super.key});

  @override
  State<Polls> createState() => _PollsState();
}

class _PollsState extends State<Polls> {
  // This list can be replaced with data from Firestore
  final List<Map<String, dynamic>> polls = [
    {
      'id': 1,
      'pollTitle': 'Which season is the best?',
      'pollEnds': DateTime(2025, 11, 21),
      'pollOptions': [
        {
          'id': 1,
          'title': 'Winter',
          'votes': 0,
        },
        {
          'id': 2,
          'title': 'Autumn',
          'votes': 0,
        },
        {
          'id': 3,
          'title': 'Summer',
          'votes': 0,
        },
        {
          'id': 4,
          'title': 'Fall',
          'votes': 0,
        },
      ],
    }
  ];

  @override
  void initState() {
    super.initState();
    _loadVotesFromFirestore();
  }

  // Fetch the votes from Firestore
  Future<void> _loadVotesFromFirestore() async {
    for (var poll in polls) {
      final pollId = poll['id'].toString();
      final pollOptions = poll['pollOptions'];

      for (var option in pollOptions) {
        final optionId = option['id'];

        bool success = false;
        int retries = 3;

        while (retries > 0 && !success) {
          try {
            final voteSnapshot = await FirebaseFirestore.instance
                .collection('polls')
                .doc(pollId)
                .collection('pollOptions')
                .doc(optionId.toString())
                .get();

            if (voteSnapshot.exists) {
              setState(() {
                option['votes'] = voteSnapshot['votes'] ?? 0;  // Fetch and update the vote count
              });
              success = true;
            } else {
              print('No vote data found for option $optionId');
              success = true;  // Exit if no data is found
            }
          } catch (e) {
            print('Error fetching vote data: $e');
            retries--;

            if (retries > 0) {
              print('Retrying... Attempts left: $retries');
              await Future.delayed(Duration(seconds: 2));  // Delay before retrying
            } else {
              print('Failed to fetch vote data after retries');
            }
          }
        }
      }
    }
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
                child: ListView.builder(
                  itemCount: polls.length,
                  itemBuilder: (context, index) {
                    final poll = polls[index];
                    final pollId = poll['id'].toString();

                    // Check if the user has voted on this poll
                    final hasVoted = appState.hasVoted(pollId);
                    final userVotedOptionId = hasVoted ? appState.votedPolls[pollId] : null;

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FlutterPolls(
                        pollId: pollId,
                        pollTitle: Text(
                          poll['pollTitle'],
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        pollEnded: DateTime.now().isAfter(poll['pollEnds']),
                        votesTextStyle: const TextStyle(color: Colors.grey),
                        hasVoted: hasVoted,
                        userVotedOptionId: userVotedOptionId,
                        onVoted: (PollOption pollOption, int newTotalVotes) async {
                          if (!appState.loggedIn) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please sign in to vote.'))
                            );
                            return false;
                          }

                          if (!hasVoted) {
                            // Increment the vote count for the selected option locally
                            setState(() {
                              pollOption.votes += 1;
                            });

                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              // Save the user's vote to Firestore
                              final userVotesRef = FirebaseFirestore.instance
                                  .collection('votes')
                                  .doc(user.uid)
                                  .collection('userVotes')
                                  .doc(pollId);

                              await userVotesRef.set({
                                'pollId': pollId,
                                'optionId': pollOption.id,
                              });

                              // Update Firestore with the new vote count for the selected option
                              final pollOptionRef = FirebaseFirestore.instance
                                  .collection('polls')
                                  .doc(pollId)
                                  .collection('pollOptions')
                                  .doc(pollOption.id.toString());

                              await pollOptionRef.update({
                                'votes': pollOption.votes,
                              });
                            }

                            appState.setVoted(pollId, pollOption.id.toString());
                          }

                          return true;
                        },

                        pollOptions: List<PollOption>.from(
                          poll['pollOptions'].map(
                            (option) => PollOption(
                              id: option['id'].toString(),
                              title: Text(option['title']),
                              votes: option['votes'],
                            ),
                          ),
                        ),
                        metaWidget: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.poll, color: Colors.grey),
                            Text(
                              '${poll['pollOptions']?.fold<int>(0, (sum, option) => sum + option['votes'] as int)} votes',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
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
