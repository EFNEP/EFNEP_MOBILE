class Poll {
  final String id;
  final String title;
  final List<PollOption> options;
  final int voteCount;
  final DateTime created;
  final List votes;

  Poll({
    required this.id,
    required this.title,
    required this.options,
    required this.voteCount,
    required this.created,
    required this.votes,
  });
}

class PollOption {
  final String option;
  final int voteCount;

  PollOption({required this.option, required this.voteCount});

  
}
