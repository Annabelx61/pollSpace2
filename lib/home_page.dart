// https://pub.dev/packages/flutter_polls
// -> The base for the code

import 'package:flutter_application_1/polls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polls/flutter_polls.dart';

class Polls extends StatefulWidget {
  const Polls({super.key});

  @override
  State<Polls> createState() => _PollsState();
}

class _PollsState extends State<Polls> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('spacePoll 🗳'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(20),
        child: ListView.builder(
          itemCount: polls.length,
          itemBuilder: (BuildContext context, int index) {
            final Map<String, dynamic> poll = polls[index];

            final int days = DateTime(
              poll['end_date'].year,
              poll['end_date'].month,
              poll['end_date'].day,
            )
                .difference(DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                ))
                .inDays;

            // To check whether the user has voted
            bool hasVoted = poll['hasVoted'] ?? false; 

            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: FlutterPolls(
                pollId: poll['id'].toString(),
                hasVoted: hasVoted,
                userVotedOptionId: poll['userVotedOptionId'].toString(),
                onVoted: (PollOption pollOption, int newTotalVotes) async {
                  /// Simulate HTTP request
                  await Future.delayed(const Duration(seconds: 1));

                  /// If HTTP status is success, return true else false
                  return true;
                },

                // If the date for the voting is over 
                pollEnded: days < 0,
                pollTitle: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    poll['question'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                pollOptions: List<PollOption>.from(
                  // Each item is a map with the following keys: id, title, image and votes.
                  poll['options'].map(
                    (option) => PollOption(
                      id: option['id'].toString(),
                      title: Row(
                        children: [
                          Image.asset(
                            option['image'], // image in list from polls.dart
                            width: 80, // width of image
                            height: 80, // height of image
                            fit: BoxFit.cover, 
                          ),
                          const SizedBox(width: 8), // Space between image and text
                          Text(
                            option['title'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      votes: option['votes'],
                    ),
                  ),
                ),
                votedPercentageTextStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                metaWidget: Row(
                  children: [
                    const SizedBox(width: 15),
                    const Text(
                      '•',
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Text(
                      days < 0 ? "ended" : "ends in $days days",
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}