/// Business rules and persisted data model for the gem economy.
library;

class RewardRules {
  RewardRules._();
  static const pointsPerGem = 20;
  static const freePlaysPerDay = 3;
  static const extraRoundCost = 1;

  /// Maximum points one scoring event may carry (guards against bad input).
  static const maxPointsPerEvent = 50;

  static int gemsForScore(int score) => score <= 0 ? 0 : score ~/ pointsPerGem;
}

enum EntryType { free, gem }

enum RoundStatus { active, completed, abandoned }

enum TxType { earned, spent }

String localDateKey(DateTime t) {
  final l = t.toLocal();
  return '${l.year.toString().padLeft(4, '0')}-${l.month.toString().padLeft(2, '0')}-${l.day.toString().padLeft(2, '0')}';
}

class DailyGameStats {
  DailyGameStats({
    required this.gameId,
    required this.localDate,
    this.freePlaysUsed = 0,
    this.paidPlaysUsed = 0,
    this.totalScore = 0,
    this.totalRoundsCompleted = 0,
  });

  final String gameId;
  final String localDate;
  int freePlaysUsed;
  int paidPlaysUsed;
  int totalScore;
  int totalRoundsCompleted;

  Map<String, dynamic> toJson() => {
    'gameId': gameId,
    'localDate': localDate,
    'free': freePlaysUsed,
    'paid': paidPlaysUsed,
    'score': totalScore,
    'done': totalRoundsCompleted,
  };

  factory DailyGameStats.fromJson(Map<String, dynamic> j) => DailyGameStats(
    gameId: j['gameId'] as String,
    localDate: j['localDate'] as String,
    freePlaysUsed: j['free'] as int? ?? 0,
    paidPlaysUsed: j['paid'] as int? ?? 0,
    totalScore: j['score'] as int? ?? 0,
    totalRoundsCompleted: j['done'] as int? ?? 0,
  );
}

class GameRound {
  GameRound({
    required this.roundId,
    required this.playerId,
    required this.gameId,
    required this.startedAt,
    required this.entryType,
    required this.localDate,
    this.completedAt,
    this.score = 0,
    this.gemsEarned = 0,
    this.status = RoundStatus.active,
    Set<String>? processedEvents,
  }) : processedEvents = processedEvents ?? <String>{};

  final String roundId;
  final String playerId;
  final String gameId;
  final DateTime startedAt;
  final EntryType entryType;
  final String localDate;
  DateTime? completedAt;
  int score;
  int gemsEarned;
  RoundStatus status;

  /// Score event ids already applied — makes awardScore idempotent.
  final Set<String> processedEvents;

  int get finalScore => score;

  Map<String, dynamic> toJson() => {
    'roundId': roundId,
    'playerId': playerId,
    'gameId': gameId,
    'startedAt': startedAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'entryType': entryType.name,
    'localDate': localDate,
    'score': score,
    'gems': gemsEarned,
    'status': status.name,
    if (status == RoundStatus.active) 'events': processedEvents.toList(),
  };

  factory GameRound.fromJson(Map<String, dynamic> j) => GameRound(
    roundId: j['roundId'] as String,
    playerId: j['playerId'] as String,
    gameId: j['gameId'] as String,
    startedAt: DateTime.parse(j['startedAt'] as String),
    completedAt: j['completedAt'] == null ? null : DateTime.parse(j['completedAt'] as String),
    entryType: EntryType.values.byName(j['entryType'] as String),
    localDate: j['localDate'] as String,
    score: j['score'] as int? ?? 0,
    gemsEarned: j['gems'] as int? ?? 0,
    status: RoundStatus.values.byName(j['status'] as String),
    processedEvents: ((j['events'] as List?) ?? const []).cast<String>().toSet(),
  );
}

class RewardTransaction {
  RewardTransaction({
    required this.transactionId,
    required this.roundId,
    required this.type,
    required this.amount,
    required this.reason,
    required this.createdAt,
  });

  final String transactionId;
  final String roundId;
  final TxType type;
  final int amount;
  final String reason;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': transactionId,
    'roundId': roundId,
    'type': type.name,
    'amount': amount,
    'reason': reason,
    'at': createdAt.toIso8601String(),
  };

  factory RewardTransaction.fromJson(Map<String, dynamic> j) => RewardTransaction(
    transactionId: j['id'] as String,
    roundId: j['roundId'] as String,
    type: TxType.values.byName(j['type'] as String),
    amount: j['amount'] as int,
    reason: j['reason'] as String,
    createdAt: DateTime.parse(j['at'] as String),
  );
}

/// The whole persisted reward state. Saved as one document so every
/// operation is written atomically.
class RewardState {
  RewardState({
    required this.playerId,
    this.gemBalance = 0,
    DateTime? updatedAt,
    this.lastSeenDate,
    Map<String, DailyGameStats>? daily,
    Map<String, GameRound>? rounds,
    List<RewardTransaction>? transactions,
    Map<String, String>? startRequests,
    this.seq = 0,
  }) : updatedAt = updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
       daily = daily ?? {},
       rounds = rounds ?? {},
       transactions = transactions ?? [],
       startRequests = startRequests ?? {};

  final String playerId;
  int gemBalance;
  DateTime updatedAt;

  /// Latest local date ever observed; the clock may not move behind it.
  String? lastSeenDate;

  /// Keyed by `localDate|gameId`.
  final Map<String, DailyGameStats> daily;
  final Map<String, GameRound> rounds;
  final List<RewardTransaction> transactions;

  /// Start request id -> round id, so a repeated Start request is idempotent.
  final Map<String, String> startRequests;

  /// Monotonic counter for unique ids.
  int seq;

  Map<String, dynamic> toJson() => {
    'v': 1,
    'playerId': playerId,
    'gemBalance': gemBalance,
    'updatedAt': updatedAt.toIso8601String(),
    'lastSeenDate': lastSeenDate,
    'daily': daily.values.map((d) => d.toJson()).toList(),
    'rounds': rounds.values.map((r) => r.toJson()).toList(),
    'tx': transactions.map((t) => t.toJson()).toList(),
    'req': startRequests,
    'seq': seq,
  };

  factory RewardState.fromJson(Map<String, dynamic> j) {
    final daily = <String, DailyGameStats>{};
    for (final d in (j['daily'] as List? ?? const [])) {
      final s = DailyGameStats.fromJson((d as Map).cast<String, dynamic>());
      daily['${s.localDate}|${s.gameId}'] = s;
    }
    final rounds = <String, GameRound>{};
    for (final r in (j['rounds'] as List? ?? const [])) {
      final g = GameRound.fromJson((r as Map).cast<String, dynamic>());
      rounds[g.roundId] = g;
    }
    return RewardState(
      playerId: j['playerId'] as String? ?? 'local-player',
      gemBalance: j['gemBalance'] as int? ?? 0,
      updatedAt: DateTime.tryParse(j['updatedAt'] as String? ?? ''),
      lastSeenDate: j['lastSeenDate'] as String?,
      daily: daily,
      rounds: rounds,
      transactions: [
        for (final t in (j['tx'] as List? ?? const [])) RewardTransaction.fromJson((t as Map).cast<String, dynamic>()),
      ],
      startRequests: Map<String, String>.from((j['req'] as Map?) ?? const {}),
      seq: j['seq'] as int? ?? 0,
    );
  }
}
