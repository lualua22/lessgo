class ApiUser {
  const ApiUser({
    required this.id,
    required this.name,
    required this.school,
    required this.grade,
    required this.apiKey,
    this.phone = '',
    this.email = '',
    this.avatar = '',
    this.cash = 0,
    this.equippedBadge,
    this.ownedBadges = const [],
    this.isPremium = false,
    this.age,
    this.region = '',
    this.bio = '',
    this.profileVisibility = 'friends',
  });

  final String id;
  final String name;
  final String school;
  final String grade;
  final String apiKey;
  final String phone;
  final String email;
  final String avatar;
  final int cash;
  final String? equippedBadge;
  final List<String> ownedBadges;
  final bool isPremium;
  final int? age;
  final String region;
  final String bio;
  final String profileVisibility;

  factory ApiUser.fromJson(Map<String, dynamic> json) => ApiUser(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    school: json['school'] as String? ?? '',
    grade: json['grade'] as String? ?? '',
    apiKey: json['apiKey'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    email: json['email'] as String? ?? '',
    avatar: json['avatar'] as String? ?? '',
    cash: (json['cash'] as num?)?.toInt() ?? 0,
    equippedBadge: json['equippedBadge'] as String?,
    ownedBadges:
        (json['ownedBadges'] as List?)?.whereType<String>().toList() ??
        const [],
    isPremium: json['isPremium'] as bool? ?? false,
    age: (json['age'] as num?)?.toInt(),
    region: json['region'] as String? ?? '',
    bio: json['bio'] as String? ?? '',
    profileVisibility: json['profileVisibility'] as String? ?? 'friends',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'school': school,
    'grade': grade,
    'apiKey': apiKey,
    'phone': phone,
    'email': email,
    'avatar': avatar,
    'cash': cash,
    'equippedBadge': equippedBadge,
    'ownedBadges': ownedBadges,
    'isPremium': isPremium,
    'age': age,
    'region': region,
    'bio': bio,
    'profileVisibility': profileVisibility,
  };
}

class UserResult {
  const UserResult({
    required this.id,
    required this.name,
    required this.avatar,
    required this.school,
    required this.grade,
    this.age,
    this.region = '',
    this.bio = '',
  });
  final String id;
  final String name;
  final String avatar;
  final String school;
  final String grade;
  final int? age;
  final String region;
  final String bio;
  factory UserResult.fromJson(Map<String, dynamic> json) => UserResult(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    avatar: json['avatar'] as String? ?? '',
    school: json['school'] as String? ?? '',
    grade: json['grade'] as String? ?? '',
    age: (json['age'] as num?)?.toInt(),
    region: json['region'] as String? ?? '',
    bio: json['bio'] as String? ?? '',
  );
}

class FriendRequest {
  const FriendRequest({
    required this.id,
    required this.name,
    required this.school,
    this.avatar = '',
  });
  final String id;
  final String name;
  final String school;
  final String avatar;
  factory FriendRequest.fromJson(Map<String, dynamic> json) => FriendRequest(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    school: json['school'] as String? ?? '',
    avatar: json['avatar'] as String? ?? '',
  );
}

class AppLimit {
  const AppLimit({
    required this.name,
    required this.icon,
    required this.minutes,
  });
  final String name;
  final String icon;
  final int minutes;

  factory AppLimit.fromJson(Map<String, dynamic> json) => AppLimit(
    name: json['name'] as String? ?? '',
    icon: json['icon'] as String? ?? '',
    minutes: (json['minutes'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'icon': icon,
    'minutes': minutes,
  };
}

class Verification {
  const Verification({
    required this.date,
    required this.usedMinutes,
    required this.apps,
  });
  final String date;
  final int usedMinutes;
  final List<AppLimit> apps;

  factory Verification.fromJson(Map<String, dynamic> json) => Verification(
    date: json['date'] as String? ?? '',
    usedMinutes: (json['usedMinutes'] as num?)?.toInt() ?? 0,
    apps:
        (json['apps'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(AppLimit.fromJson)
            .toList() ??
        const [],
  );
}

class Participant {
  const Participant({
    required this.userId,
    required this.name,
    required this.isCreator,
    this.usedMinutes,
  });
  final String userId;
  final String name;
  final bool isCreator;
  final int? usedMinutes;

  factory Participant.fromJson(Map<String, dynamic> json) => Participant(
    userId: json['userId'] as String? ?? '',
    name: json['name'] as String? ?? '',
    isCreator: json['isCreator'] as bool? ?? false,
    usedMinutes: (json['usedMinutes'] as num?)?.toInt(),
  );
}

class Challenge {
  const Challenge({
    required this.id,
    required this.title,
    required this.goalMinutes,
    required this.periodDays,
    required this.mode,
    required this.participants,
    required this.appLimits,
    required this.shareCode,
    this.creatorId = '',
    this.creatorName = '',
    this.startDate,
    this.endDate,
    this.stakeType,
    this.donationAmount = 0,
    this.donationPeriod = 'week',
    this.pendingEdit,
    this.memo,
  });

  final String id;
  final String title;
  final int goalMinutes;
  final int periodDays;
  final String mode;
  final List<Participant> participants;
  final List<AppLimit> appLimits;
  final String shareCode;
  final String creatorId;
  final String creatorName;
  final String? startDate;
  final String? endDate;
  final String? stakeType;
  final int donationAmount;
  final String donationPeriod;
  final PendingEdit? pendingEdit;
  final String? memo;

  factory Challenge.fromJson(Map<String, dynamic> json) => Challenge(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '제목 없는 챌린지',
    goalMinutes: parseInt(json['goalMinutes']),
    periodDays: parseInt(json['periodDays']),
    mode: json['mode'] as String? ?? 'solo',
    shareCode: json['shareCode'] as String? ?? '',
    creatorId: json['creatorId'] as String? ?? '',
    creatorName: json['creatorName'] as String? ?? '',
    startDate: json['startDate'] as String?,
    endDate: json['endDate'] as String?,
    stakeType: json['stakeType'] as String?,
    donationAmount: parseInt(json['donationAmount']),
    donationPeriod: json['donationPeriod'] as String? ?? 'week',
    pendingEdit: json['pendingEdit'] is Map<String, dynamic>
        ? PendingEdit.fromJson(json['pendingEdit'] as Map<String, dynamic>)
        : null,
    memo: json['memo'] as String?,
    participants:
        (json['participants'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(Participant.fromJson)
            .toList() ??
        const [],
    appLimits:
        (json['appLimits'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(AppLimit.fromJson)
            .toList() ??
        const [],
  );
}

int parseInt(dynamic value, [int fallback = 0]) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

class PendingEdit {
  const PendingEdit({required this.proposedByName, required this.approvedBy});
  final String proposedByName;
  final List<String> approvedBy;

  factory PendingEdit.fromJson(Map<String, dynamic> json) => PendingEdit(
    proposedByName: json['proposedByName'] as String? ?? '',
    approvedBy:
        (json['approvedBy'] as List?)?.whereType<String>().toList() ?? const [],
  );
}
