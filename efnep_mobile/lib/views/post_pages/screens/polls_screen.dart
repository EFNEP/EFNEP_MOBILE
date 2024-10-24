import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:efnep_mobile/provider/language_provider.dart';
import 'package:efnep_mobile/services/analytics.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import '../../../constants/colors.dart';
import '../../../views/post_pages/screens/poll_comment_screen.dart';
import '../../../models/polls/db_provider.dart';
import '../../../models/polls/fetch_polls_provider.dart';

class PollsScreen extends StatefulWidget {
  final User? user;

  const PollsScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<PollsScreen> createState() => _PollsScreenState();
}

class _PollsScreenState extends State<PollsScreen> {
  late LanguageProvider _languageProvider;
  bool _isFetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _languageProvider = Provider.of<LanguageProvider>(context); // Get the LanguageProvider instance
  }

  @override
  void initState() {
    analytics('Polls', 'PollsScreen');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<FetchPollsProvider>(builder: (context, polls, child) {
        if (_isFetched == false) {
          polls.fetchAllPolls();
          Future.delayed(const Duration(microseconds: 1), () {
            _isFetched = true;
          });
        }
        return SafeArea(
          child: polls.isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : polls.pollsList.isEmpty
                  ? LiquidPullToRefresh(
                      onRefresh: () async {
                        setState(() {
                          polls.fetchAllPolls();
                        });
                      },
                      child: Center(
                        child: Text(
                          _languageProvider.currentLanguage == Language.English
                              ? "No polls at the moment"
                              : "No hay encuestas por el momento",
                        ),
                      ),
                    )
                  : LiquidPullToRefresh(
                      onRefresh: () async {
                        setState(() {
                          polls.fetchAllPolls();
                        });
                      },
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 50),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    ...List.generate(polls.pollsList.length, (index) {
                                      final data = polls.pollsList[index];
                                      Map poll = data["poll"];
                                      Timestamp date = data["dateCreated"];
                                      List voters = poll["voters"];
                                      List<dynamic> options = poll["options"];
                                      int totalVotes = options.fold(0, (sum, option) => sum + (option["percent"] as int));

                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 10),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: greyLight),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 8),
                                            Text(
                                              _languageProvider.currentLanguage == Language.English
                                                  ? poll["question"] ?? "No question available"
                                                  : poll["S_question"] ?? "No question available",
                                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(DateFormat.yMEd().format(date.toDate())),
                                            const SizedBox(height: 8),
                                            ...List.generate(options.length, (index) {
                                              final dataOption = options[index];
                                              int votes = dataOption["percent"];
                                              double percent = totalVotes > 0 ? (votes / totalVotes) * 100 : 0;

                                              return Consumer<DbProvider>(builder: (context, vote, child) {
                                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                                  if (vote.message.isNotEmpty) {
                                                    Fluttertoast.showToast(msg: vote.message);
                                                    vote.clear();
                                                  }
                                                });
                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      if (voters.isEmpty) {
                                                        vote.votePoll(
                                                          pollId: data.id,
                                                          pollData: data,
                                                          previousTotalVotes: poll["total_votes"],
                                                          selectedOptions: dataOption["answer"],
                                                        );
                                                      } else {
                                                        final isExists = voters.firstWhere(
                                                          (element) => element["uid"] == widget.user!.uid,
                                                          orElse: () => null,
                                                        );
                                                        if (isExists == null) {
                                                          vote.votePoll(
                                                            pollId: data.id,
                                                            pollData: data,
                                                            previousTotalVotes: poll["total_votes"],
                                                            selectedOptions: dataOption["answer"],
                                                          );
                                                        } else {
                                                          Fluttertoast.showToast(msg: 'You have already voted for this Poll');
                                                        }
                                                      }
                                                    },
                                                    child: Container(
                                                      margin: const EdgeInsets.only(bottom: 5),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Stack(
                                                              children: [
                                                                LinearProgressIndicator(
                                                                  minHeight: 30,
                                                                  value: percent / 100,
                                                                  backgroundColor: notWhite,
                                                                ),
                                                                Container(
                                                                  alignment: Alignment.centerLeft,
                                                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                                                  height: 30,
                                                                  child: Text(
                                                                    _languageProvider.currentLanguage == Language.English
                                                                        ? dataOption["answer"] ?? "No answer available"
                                                                        : dataOption["S_answer"] ?? "No answer available",
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(width: 20),
                                                          Text("${percent.toStringAsFixed(2)}%"),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              });
                                            }),
                                            const SizedBox(height: 8),
                                            Text(
                                              _languageProvider.currentLanguage == Language.English
                                                  ? "Total votes: ${poll["total_votes"]}"
                                                  : "Total de votos: ${poll["total_votes"]}",
                                            ),
                                            const SizedBox(height: 8),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                InkWell(
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                                    child: Text(
                                                      _languageProvider.currentLanguage == Language.English
                                                          ? 'View all comments'
                                                          : 'Ver todos los comentarios',
                                                      style: const TextStyle(fontSize: 16, color: greyDark),
                                                    ),
                                                  ),
                                                  onTap: () => Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) => PollCommentsScreen(pollId: data.id),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
        );
      }),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (_, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: primaryColor,
            ),
          );
        } else if (snapshot.hasError) {
          debugPrint(snapshot.error.toString());
          return const Center(child: Text("Something went wrong!"));
        } else {
          final user = snapshot.data;
          return PollsScreen(user: user);
        }
      },
    );
  }
}
