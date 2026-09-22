import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'core/models.dart';
import 'core/session.dart';
import 'theme/app_theme.dart';
import 'onboarding/onboarding_view.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({required this.session, super.key});
  final SessionStore session;

  @override
  Widget build(BuildContext context) => OnboardingView(
    onStart: () async {
      await session.completeOnboarding();
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => session.user == null
              ? SignupScreen(session: session)
              : HomeShell(session: session),
        ),
      );
    },
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.session, super.key});
  final SessionStore session;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phone = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() {
    phone.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (phone.text.isEmpty || password.text.isEmpty) {
      showMessage(context, '전화번호와 비밀번호를 입력해주세요.');
      return;
    }
    if (!await widget.session.login(phone.text.trim(), password.text) &&
        mounted) {
      showMessage(context, widget.session.error ?? '로그인에 실패했어요.');
    }
  }

  @override
  Widget build(BuildContext context) => AuthPage(
    title: '다시 만나요',
    subtitle: '오늘의 집중을 인증하고\n친구들과 함께 이어가요.',
    children: [
      TextField(
        controller: phone,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(labelText: '전화번호'),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: password,
        obscureText: true,
        decoration: const InputDecoration(labelText: '비밀번호'),
        onSubmitted: (_) => submit(),
      ),
      const SizedBox(height: 20),
      FilledButton(
        onPressed: widget.session.loading ? null : submit,
        child: Text(widget.session.loading ? '로그인 중...' : '로그인'),
      ),
      TextButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SignupScreen(session: widget.session),
          ),
        ),
        child: const Text('처음이라면 회원가입'),
      ),
    ],
  );
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({required this.session, super.key});
  final SessionStore session;
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final name = TextEditingController();
  final school = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();
  String grade = '중학교 1학년';

  @override
  void dispose() {
    name.dispose();
    school.dispose();
    phone.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if ([
      name,
      school,
      phone,
      password,
    ].any((controller) => controller.text.trim().isEmpty)) {
      showMessage(context, '모든 항목을 입력해주세요.');
      return;
    }
    final ok = await widget.session.signup(
      name: name.text.trim(),
      school: school.text.trim(),
      grade: grade,
      phone: phone.text.trim(),
      password: password.text,
    );
    if (!ok && mounted) {
      showMessage(context, widget.session.error ?? '가입하지 못했어요.');
    }
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => AuthPage(
    title: 'LessGo 시작하기',
    subtitle: '작은 목표부터 함께 만들어봐요.',
    children: [
      TextField(
        controller: name,
        decoration: const InputDecoration(labelText: '이름'),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: school,
        decoration: const InputDecoration(labelText: '학교'),
      ),
      const SizedBox(height: 10),
      DropdownButtonFormField<String>(
        initialValue: grade,
        decoration: const InputDecoration(labelText: '학년'),
        items:
            [
                  '중학교 1학년',
                  '중학교 2학년',
                  '중학교 3학년',
                  '고등학교 1학년',
                  '고등학교 2학년',
                  '고등학교 3학년',
                  '성인',
                ]
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
        onChanged: (value) => setState(() => grade = value!),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: phone,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(labelText: '전화번호'),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: password,
        obscureText: true,
        decoration: const InputDecoration(labelText: '비밀번호'),
      ),
      const SizedBox(height: 18),
      FilledButton(
        onPressed: widget.session.loading ? null : submit,
        child: Text(widget.session.loading ? '가입 중...' : '회원가입'),
      ),
    ],
  );
}

class AuthPage extends StatelessWidget {
  const AuthPage({
    required this.title,
    required this.subtitle,
    required this.children,
    super.key,
  });
  final String title;
  final String subtitle;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
        children: [
          const Text(
            'LessGo',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(subtitle),
          const SizedBox(height: 34),
          ...children,
        ],
      ),
    ),
  );
}

class HomeShell extends StatefulWidget {
  const HomeShell({required this.session, super.key});
  final SessionStore session;
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(session: widget.session),
      VerifyScreen(session: widget.session),
      ChallengesScreen(session: widget.session),
      FriendsScreen(session: widget.session),
      StatsScreen(session: widget.session),
      ProfileScreen(session: widget.session),
    ];
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined),
            selectedIcon: Icon(Icons.camera_alt),
            label: '인증',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag),
            label: '챌린지',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: '친구',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: '통계',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '마이',
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({required this.session, super.key});
  final SessionStore session;
  @override
  Widget build(BuildContext context) {
    final level = statusFor(session);
    final today = session.verifications
        .where((item) => item.date == dateKey(DateTime.now()))
        .firstOrNull;
    return AppPage(
      title: '안녕하세요, ${session.user!.name}님',
      subtitle: '오늘도 짧게 시작해볼까요?',
      children: [
        LevelCard(level: level),
        const SizedBox(height: 14),
        GradientCard(
          title: today == null ? '아직 인증 전이에요' : '${today.usedMinutes}분 사용했어요',
          subtitle: '오늘의 스크린타임',
        ),
        const SizedBox(height: 18),
        const SectionTitle(title: '오늘의 챌린지'),
        const SizedBox(height: 10),
        if (session.challenges.isEmpty)
          const EmptyCard(message: '참여 중인 챌린지가 없어요.')
        else
          ...session.challenges
              .take(3)
              .map(
                (challenge) =>
                    ChallengeTile(challenge: challenge, session: session),
              ),
      ],
    );
  }
}

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({required this.session, super.key});
  final SessionStore session;
  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final query = TextEditingController();
  final school = TextEditingController();
  String region = '';
  Future<List<UserResult>>? results;
  List<FriendRequest> requests = const [];
  List<UserResult> friends = const [];

  @override
  void initState() {
    super.initState();
    loadRequests();
  }

  @override
  void dispose() {
    query.dispose();
    school.dispose();
    super.dispose();
  }

  Future<void> loadRequests() async {
    requests = await widget.session.api.friendRequests(
      widget.session.user!.apiKey,
    );
    friends = await widget.session.api.friends(widget.session.user!.apiKey);
    if (mounted) setState(() {});
  }

  void search() {
    setState(
      () => results = widget.session.api.searchUsers(
        widget.session.user!.apiKey,
        query: query.text,
        region: region,
        school: school.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AppPage(
    title: '친구 찾기',
    subtitle: '함께하면 습관도 더 가벼워져요.',
    children: [
      TextField(
        controller: query,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => search(),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: '이름으로 검색',
          suffixIcon: IconButton(
            onPressed: search,
            icon: const Icon(Icons.arrow_forward),
          ),
        ),
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: school,
              decoration: const InputDecoration(labelText: '학교(선택)'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: region.isEmpty ? null : region,
              hint: const Text('지역'),
              items: const ['서울', '부산', '인천', '대구', '광주', '대전']
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: (value) {
                region = value ?? '';
                search();
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 18),
      if (requests.isNotEmpty) ...[
        const SectionTitle(title: '받은 친구 요청'),
        const SizedBox(height: 8),
        ...requests.map(
          (request) => Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(request.name),
              subtitle: Text(request.school),
              trailing: Wrap(
                children: [
                  IconButton(
                    onPressed: () async {
                      await widget.session.api.respondFriendRequest(
                        widget.session.user!.apiKey,
                        request.id,
                        true,
                      );
                      await loadRequests();
                    },
                    icon: const Icon(Icons.check, color: AppColors.blue),
                  ),
                  IconButton(
                    onPressed: () async {
                      await widget.session.api.respondFriendRequest(
                        widget.session.user!.apiKey,
                        request.id,
                        false,
                      );
                      await loadRequests();
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
      const SectionTitle(title: '추천 사용자'),
      const SizedBox(height: 8),
      if (results == null)
        const EmptyCard(message: '이름, 학교, 지역으로 친구를 찾아보세요.')
      else
        FutureBuilder<List<UserResult>>(
          future: results,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data!.isEmpty) {
              return const EmptyCard(message: '조건에 맞는 사용자가 없어요.');
            }
            return Column(
              children: snapshot.data!
                  .map(
                    (user) =>
                        UserResultCard(user: user, session: widget.session),
                  )
                  .toList(),
            );
          },
        ),
      if (friends.isNotEmpty) ...[
        const SizedBox(height: 20),
        const SectionTitle(title: '내 친구'),
        const SizedBox(height: 8),
        ...friends.map(
          (friend) => Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(friend.name),
              subtitle: Text(
                [
                  if (friend.region.isNotEmpty) friend.region,
                  if (friend.school.isNotEmpty) friend.school,
                ].join(' · '),
              ),
            ),
          ),
        ),
      ],
    ],
  );
}

class UserResultCard extends StatelessWidget {
  const UserResultCard({required this.user, required this.session, super.key});
  final UserResult user;
  final SessionStore session;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(user.name),
      subtitle: Text(
        [
          if (user.age != null) '${user.age}세',
          if (user.region.isNotEmpty) user.region,
          if (user.school.isNotEmpty) user.school,
        ].join(' · '),
      ),
      trailing: FilledButton(
        onPressed: () async {
          await session.api.sendFriendRequest(session.user!.apiKey, user.id);
          if (context.mounted) showMessage(context, '친구 요청을 보냈어요.');
        },
        child: const Text('요청'),
      ),
    ),
  );
}

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({required this.session, super.key});
  final SessionStore session;
  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final picker = ImagePicker();
  final images = <String>[];
  List<AppLimit> apps = const [];
  bool analyzing = false;
  bool analyzed = false;
  int? total;

  @override
  void initState() {
    super.initState();
    final challenge = widget.session.challenges
        .where((item) => item.mode == 'solo')
        .firstOrNull;
    apps =
        challenge?.appLimits ??
        [const AppLimit(name: '전체 사용 시간', icon: '', minutes: 0)];
  }

  Future<void> pickImages() async {
    final selected = await picker.pickMultiImage(imageQuality: 85);
    if (selected.isEmpty) return;
    final remaining = selected.take(10 - images.length);
    for (final file in remaining) {
      images.add(
        'data:image/jpeg;base64,${base64Encode(await file.readAsBytes())}',
      );
    }
    setState(() {});
  }

  Future<void> analyze() async {
    if (images.isEmpty) return;
    setState(() => analyzing = true);
    try {
      final result = await widget.session.api.analyzeScreenTime(
        widget.session.user!.apiKey,
        images,
        apps.map((app) => app.name).toList(),
      );
      final parsed = (result['apps'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AppLimit.fromJson)
          .toList();
      setState(() {
        apps = parsed.isEmpty ? apps : parsed;
        total =
            (result['totalMinutes'] as num?)?.toInt() ??
            apps.fold<int>(0, (sum, app) => sum + app.minutes);
        analyzed = result['isAuthentic'] == true;
      });
      if (!analyzed && mounted) showMessage(context, '스크린타임 캡처를 확인하지 못했어요.');
    } catch (_) {
      if (mounted) showMessage(context, '사진을 분석하지 못했어요.');
    } finally {
      if (mounted) setState(() => analyzing = false);
    }
  }

  Future<void> submit() async {
    if (!analyzed || total == null) return;
    try {
      await widget.session.api.submitVerification(
        widget.session.user!.apiKey,
        dateKey(DateTime.now()),
        total!,
        apps,
      );
      await widget.session.refreshData();
      if (mounted) showMessage(context, '오늘 인증이 완료됐어요!');
    } catch (_) {
      if (mounted) showMessage(context, '인증을 저장하지 못했어요.');
    }
  }

  @override
  Widget build(BuildContext context) => AppPage(
    title: '오늘의 인증',
    subtitle: '스크린타임 캡처를 올려 사용 시간을 확인해요.',
    children: [
      if (images.isNotEmpty)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: images
              .asMap()
              .entries
              .map(
                (entry) => Stack(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      color: Colors.black12,
                      child: const Icon(Icons.image),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        onPressed: () =>
                            setState(() => images.removeAt(entry.key)),
                        icon: const Icon(Icons.close, size: 16),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      OutlinedButton.icon(
        onPressed: images.length >= 10 ? null : pickImages,
        icon: const Icon(Icons.photo_library_outlined),
        label: Text('사진 추가하기 (${images.length}/10)'),
      ),
      const SizedBox(height: 10),
      FilledButton.icon(
        onPressed: analyzing ? null : analyze,
        icon: const Icon(Icons.auto_awesome),
        label: Text(analyzing ? 'AI 분석 중...' : '사진으로 분석하기'),
      ),
      if (analyzed) ...[
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            title: const Text('분석 결과'),
            subtitle: Text('총 ${total ?? 0}분'),
            trailing: FilledButton(
              onPressed: submit,
              child: const Text('인증 제출'),
            ),
          ),
        ),
        ...apps.map(
          (app) => ListTile(
            leading: const Icon(Icons.apps),
            title: Text(app.name),
            trailing: Text('${app.minutes}분'),
          ),
        ),
      ],
    ],
  );
}

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({required this.session, super.key});
  final SessionStore session;
  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  Future<void> create() async {
    final title = TextEditingController();
    final goal = TextEditingController(text: '180');
    final period = TextEditingController(text: '7');
    final memo = TextEditingController();
    final donation = TextEditingController(text: '100');
    String mode = 'solo';
    bool donationEnabled = false;
    String donationPeriod = 'week';
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('새 챌린지'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: mode,
                  decoration: const InputDecoration(labelText: '방식'),
                  items: const [
                    DropdownMenuItem(value: 'solo', child: Text('개인')),
                    DropdownMenuItem(value: 'group', child: Text('친구들과 함께')),
                  ],
                  onChanged: (value) => setDialogState(() => mode = value!),
                ),
                TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: '챌린지 이름'),
                ),
                TextField(
                  controller: goal,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '하루 목표 시간(분)'),
                ),
                TextField(
                  controller: period,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '기간(일)'),
                ),
                TextField(
                  controller: memo,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: '약속하기',
                    hintText: '예: 목표를 못 지키면 친구들에게 커피 사기',
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('기부금 약속 설정'),
                  subtitle: const Text('목표를 못 지킨 날 기부할 캐시를 정해요.'),
                  value: donationEnabled,
                  onChanged: (value) =>
                      setDialogState(() => donationEnabled = value),
                ),
                if (donationEnabled) ...[
                  TextField(
                    controller: donation,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '기부금(캐시)'),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: donationPeriod,
                    decoration: const InputDecoration(labelText: '기부금 계산 주기'),
                    items: const [
                      DropdownMenuItem(value: 'day', child: Text('실패한 날마다')),
                      DropdownMenuItem(value: 'week', child: Text('실패한 주마다')),
                    ],
                    onChanged: (value) =>
                        setDialogState(() => donationPeriod = value!),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () async {
                if (title.text.trim().isEmpty) return;
                try {
                  await widget.session.api.createChallenge(
                    widget.session.user!.apiKey,
                    {
                      'mode': mode,
                      'title': title.text.trim(),
                      'goalMinutes': int.tryParse(goal.text) ?? 180,
                      'periodDays': int.tryParse(period.text) ?? 7,
                      'maxParticipants': mode == 'group' ? 20 : null,
                      'openEnrollment': mode == 'group',
                      'stakeEnabled': donationEnabled,
                      'stakeType': donationEnabled ? 'donation' : null,
                      'donationAmount': donationEnabled
                          ? (int.tryParse(donation.text) ?? 0)
                          : 0,
                      'donationPeriod': donationPeriod,
                      'verifyByHour': 22,
                      'appLimits': [],
                      'photo': null,
                      'background': null,
                      'memo': memo.text.trim().isEmpty
                          ? null
                          : memo.text.trim(),
                    },
                  );
                  await widget.session.refreshData();
                  if (context.mounted) Navigator.pop(context);
                  setState(() {});
                } catch (_) {
                  if (context.mounted) showMessage(context, '챌린지를 만들지 못했어요.');
                }
              },
              child: const Text('만들기'),
            ),
          ],
        ),
      ),
    );
    title.dispose();
    goal.dispose();
    period.dispose();
    memo.dispose();
    donation.dispose();
  }

  Future<void> join() async {
    final code = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('초대 코드로 참여'),
        content: TextField(
          controller: code,
          decoration: const InputDecoration(labelText: '초대 코드'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await widget.session.api.joinChallenge(
                  widget.session.user!.apiKey,
                  code: code.text.trim(),
                );
                await widget.session.refreshData();
                if (context.mounted) Navigator.pop(context);
                setState(() {});
              } catch (_) {
                if (context.mounted) showMessage(context, '참여하지 못했어요.');
              }
            },
            child: const Text('참여'),
          ),
        ],
      ),
    );
    code.dispose();
  }

  @override
  Widget build(BuildContext context) => AppPage(
    title: '챌린지',
    subtitle: '함께 목표를 지켜보세요.',
    children: [
      Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: create,
              icon: const Icon(Icons.add),
              label: const Text('새로 만들기'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: join,
              icon: const Icon(Icons.group_add),
              label: const Text('참여하기'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 18),
      if (widget.session.challenges.isEmpty)
        const EmptyCard(message: '참여 중인 챌린지가 없어요.')
      else
        ...widget.session.challenges.map(
          (challenge) =>
              ChallengeTile(challenge: challenge, session: widget.session),
        ),
    ],
  );
}

class ChallengeTile extends StatelessWidget {
  const ChallengeTile({
    required this.challenge,
    required this.session,
    super.key,
  });
  final Challenge challenge;
  final SessionStore session;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const CircleAvatar(child: Icon(Icons.flag)),
      title: Text(
        challenge.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${challenge.goalMinutes}분 · ${challenge.periodDays}일 · ${challenge.participants.length}명',
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ChallengeDetailScreen(challenge: challenge, session: session),
        ),
      ),
    ),
  );
}

class ChallengeDetailScreen extends StatefulWidget {
  const ChallengeDetailScreen({
    required this.challenge,
    required this.session,
    super.key,
  });
  final Challenge challenge;
  final SessionStore session;
  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  late Challenge challenge;

  @override
  void initState() {
    super.initState();
    challenge = widget.challenge;
  }

  Future<void> edit() async {
    final title = TextEditingController(text: challenge.title);
    final goal = TextEditingController(text: '${challenge.goalMinutes}');
    final period = TextEditingController(text: '${challenge.periodDays}');
    final memo = TextEditingController(text: challenge.memo ?? '');
    final donation = TextEditingController(text: '${challenge.donationAmount}');
    bool donationEnabled = challenge.stakeType == 'donation';
    String donationPeriod = challenge.donationPeriod == 'day' ? 'day' : 'week';
    try {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('챌린지 수정'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: title,
                    decoration: const InputDecoration(labelText: '이름'),
                  ),
                  TextField(
                    controller: goal,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '하루 목표(분)'),
                  ),
                  TextField(
                    controller: period,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '기간(일)'),
                  ),
                  TextField(
                    controller: memo,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: '약속하기',
                      hintText: '어떤 약속을 할지 적어주세요',
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('기부금 약속 설정'),
                    value: donationEnabled,
                    onChanged: (value) =>
                        setDialogState(() => donationEnabled = value),
                  ),
                  if (donationEnabled) ...[
                    TextField(
                      controller: donation,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: '기부금(캐시)'),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: donationPeriod,
                      decoration: const InputDecoration(labelText: '기부금 계산 주기'),
                      items: const [
                        DropdownMenuItem(value: 'day', child: Text('실패한 날마다')),
                        DropdownMenuItem(value: 'week', child: Text('실패한 주마다')),
                      ],
                      onChanged: (value) =>
                          setDialogState(() => donationPeriod = value!),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              FilledButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    var updated = await widget.session.api.updateChallenge(
                      widget.session.user!.apiKey,
                      challenge.id,
                      {
                        'title': title.text.trim(),
                        'goalMinutes':
                            int.tryParse(goal.text) ?? challenge.goalMinutes,
                        'periodDays':
                            int.tryParse(period.text) ?? challenge.periodDays,
                        'appLimits': challenge.appLimits
                            .map((app) => app.toJson())
                            .toList(),
                        'stakeType': donationEnabled ? 'donation' : null,
                        'donationAmount': donationEnabled
                            ? (int.tryParse(donation.text) ?? 0)
                            : 0,
                        'donationPeriod': donationPeriod,
                        'verifyByHour': 22,
                        'memo': memo.text.trim().isEmpty
                            ? null
                            : memo.text.trim(),
                      },
                    );
                    if (updated.pendingEdit != null &&
                        challenge.participants.length <= 1) {
                      updated = await widget.session.api.approveChallengeEdit(
                        widget.session.user!.apiKey,
                        challenge.id,
                      );
                    }
                    if (!context.mounted) return;
                    setState(() => challenge = updated);
                    Navigator.pop(context);
                    await widget.session.refreshData();
                    if (!mounted) return;
                    if (updated.pendingEdit != null) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('수정 제안을 보냈어요. 모든 참여자의 동의가 필요해요.'),
                        ),
                      );
                    }
                  } catch (error) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('수정하지 못했어요: $error')),
                    );
                  }
                },
                child: const Text('저장'),
              ),
            ],
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        showMessage(context, '수정 화면을 열지 못했어요: $error');
      }
    }
  }

  Future<void> inviteParticipants() async {
    final messenger = ScaffoldMessenger.of(context);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('참여자 초대'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('아래 코드를 친구에게 보내면 챌린지에 참여할 수 있어요.'),
            const SizedBox(height: 16),
            SelectableText(
              challenge.shareCode,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: challenge.shareCode));
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
                messenger.showSnackBar(
                  const SnackBar(content: Text('초대 코드가 복사됐어요.')),
                );
              }
            },
            child: const Text('코드 복사'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(challenge.title),
      actions: [
        IconButton(
          onPressed: inviteParticipants,
          tooltip: '참여자 초대',
          icon: const Icon(Icons.person_add_alt_1),
        ),
        IconButton(
          onPressed: () => edit(),
          tooltip: '챌린지 수정',
          icon: const Icon(Icons.edit),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        GradientCard(
          title: '${challenge.goalMinutes}분',
          subtitle: '${challenge.periodDays}일 목표',
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.group_add_outlined),
            title: const Text('참여자 초대'),
            subtitle: Text('초대 코드 ${challenge.shareCode}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: inviteParticipants,
          ),
        ),
        const SizedBox(height: 16),
        if (challenge.stakeType == 'donation' && challenge.donationAmount > 0)
          Card(
            child: ListTile(
              leading: const Icon(Icons.volunteer_activism),
              title: Text('${challenge.donationAmount}캐시 기부 약속'),
              subtitle: Text(
                challenge.donationPeriod == 'day' ? '실패한 날마다' : '실패한 주마다',
              ),
            ),
          ),
        if (challenge.memo != null) ...[
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.handshake_outlined),
              title: const Text('약속 내용'),
              subtitle: Text(challenge.memo!),
            ),
          ),
        ],
        if (challenge.pendingEdit != null) ...[
          const SizedBox(height: 10),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '수정 제안 대기 중',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${challenge.pendingEdit!.proposedByName}님이 수정안을 제안했어요.',
                  ),
                  Text(
                    '동의 ${challenge.pendingEdit!.approvedBy.length}/${challenge.participants.length}명',
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            try {
                              final updated = await widget.session.api
                                  .approveChallengeEdit(
                                    widget.session.user!.apiKey,
                                    challenge.id,
                                  );
                              if (!mounted) return;
                              setState(() => challenge = updated);
                              await widget.session.refreshData();
                            } catch (_) {
                              if (!mounted) return;
                              messenger.showSnackBar(
                                const SnackBar(content: Text('동의 처리에 실패했어요.')),
                              );
                            }
                          },
                          child: const Text('동의하기'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            try {
                              final updated = await widget.session.api
                                  .rejectChallengeEdit(
                                    widget.session.user!.apiKey,
                                    challenge.id,
                                  );
                              if (!mounted) return;
                              setState(() => challenge = updated);
                              await widget.session.refreshData();
                            } catch (_) {
                              if (!mounted) return;
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('수정 제안을 취소하지 못했어요.'),
                                ),
                              );
                            }
                          },
                          child: const Text('취소'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        const Text(
          '참여자',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ...challenge.participants.map(
          (participant) => ListTile(
            leading: const Icon(Icons.person),
            title: Text(participant.name),
            trailing: Text(
              participant.usedMinutes == null
                  ? '-'
                  : '${participant.usedMinutes}분',
            ),
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: () async {
            try {
              await widget.session.api.deleteChallenge(
                widget.session.user!.apiKey,
                challenge.id,
              );
              await widget.session.refreshData();
              if (context.mounted) Navigator.pop(context);
            } catch (_) {
              if (context.mounted) showMessage(context, '챌린지를 삭제하지 못했어요.');
            }
          },
          icon: const Icon(Icons.delete_outline),
          label: const Text('챌린지 삭제'),
        ),
      ],
    ),
  );
}

class StatsScreen extends StatelessWidget {
  const StatsScreen({required this.session, super.key});
  final SessionStore session;
  @override
  Widget build(BuildContext context) {
    final records = session.verifications;
    final level = statusFor(session);
    final average = records.isEmpty
        ? 0
        : records.map((item) => item.usedMinutes).reduce((a, b) => a + b) ~/
              records.length;
    return AppPage(
      title: '통계',
      subtitle: '꾸준함이 보이면 동기도 따라와요.',
      children: [
        LevelCard(level: level),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: MetricCard(label: '평균 사용시간', value: '$average분'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: MetricCard(label: '인증 일수', value: '${records.length}일'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (records.isEmpty)
          const EmptyCard(message: '인증 기록이 쌓이면 통계를 보여드릴게요.')
        else
          ...records.reversed.map(
            (item) => ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(item.date),
              trailing: Text('${item.usedMinutes}분'),
            ),
          ),
      ],
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({required this.session, super.key});
  final SessionStore session;
  Future<void> changeAvatar(BuildContext context) async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file == null) return;
    try {
      final avatar =
          'data:image/jpeg;base64,${base64Encode(await file.readAsBytes())}';
      await session.saveUser(
        await session.api.updateAvatar(session.user!.apiKey, avatar),
      );
    } catch (_) {
      if (context.mounted) showMessage(context, '사진을 바꾸지 못했어요.');
    }
  }

  @override
  Widget build(BuildContext context) => AppPage(
    title: '마이페이지',
    subtitle: '${session.user!.school} · ${session.user!.grade}',
    children: [
      LevelCard(level: statusFor(session)),
      const SizedBox(height: 10),
      Card(
        child: ListTile(
          leading: GestureDetector(
            onTap: () => changeAvatar(context),
            child: CircleAvatar(
              backgroundImage: session.user!.avatar.startsWith('data:')
                  ? MemoryImage(
                      base64Decode(session.user!.avatar.split(',').last),
                    )
                  : null,
              child: session.user!.avatar.isEmpty
                  ? const Icon(Icons.person)
                  : null,
            ),
          ),
          title: Text(session.user!.name),
          subtitle: Text('캐시 ${session.user!.cash}개'),
        ),
      ),
      const SizedBox(height: 10),
      BadgeShop(session: session),
      const SizedBox(height: 10),
      ListTile(
        leading: const Icon(Icons.edit),
        title: const Text('프로필 수정'),
        onTap: () => showProfileEditor(context, session),
      ),
      ListTile(
        leading: const Icon(Icons.feedback_outlined),
        title: const Text('피드백 보내기'),
        onTap: () => showFeedback(context, session),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: () => showAccountDelete(context, session),
        icon: const Icon(Icons.delete_forever),
        label: const Text('계정 삭제'),
      ),
      TextButton(onPressed: session.logout, child: const Text('로그아웃')),
    ],
  );
}

class BadgeShop extends StatelessWidget {
  const BadgeShop({required this.session, super.key});
  final SessionStore session;
  static const badges = {
    'shop-star': ('⭐', '별', 50),
    'shop-crown': ('👑', '왕관', 150),
    'shop-diamond': ('💎', '다이아', 400),
  };
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('뱃지 상점', style: TextStyle(fontWeight: FontWeight.bold)),
          ...badges.entries.map((entry) {
            final owned = session.user!.ownedBadges.contains(entry.key);
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Text(
                entry.value.$1,
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(entry.value.$2),
              trailing: owned
                  ? const Text('보유 중')
                  : TextButton(
                      onPressed: session.user!.cash < entry.value.$3
                          ? null
                          : () async {
                              try {
                                await session.saveUser(
                                  await session.api.buyBadge(
                                    session.user!.apiKey,
                                    entry.key,
                                  ),
                                );
                              } catch (_) {
                                if (context.mounted) {
                                  showMessage(context, '구매하지 못했어요.');
                                }
                              }
                            },
                      child: Text('${entry.value.$3} 캐시'),
                    ),
            );
          }),
        ],
      ),
    ),
  );
}

Future<void> showAccountDelete(
  BuildContext context,
  SessionStore session,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('계정을 삭제할까요?'),
      content: const Text('계정과 인증 기록은 되돌릴 수 없어요.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('삭제'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  try {
    await session.deleteAccount();
  } catch (_) {
    if (context.mounted) showMessage(context, '탈퇴하지 못했어요.');
  }
}

Future<void> showProfileEditor(
  BuildContext context,
  SessionStore session,
) async {
  final name = TextEditingController(text: session.user!.name);
  final school = TextEditingController(text: session.user!.school);
  final grade = TextEditingController(text: session.user!.grade);
  final age = TextEditingController(text: session.user!.age?.toString() ?? '');
  final region = TextEditingController(text: session.user!.region);
  final bio = TextEditingController(text: session.user!.bio);
  String visibility = session.user!.profileVisibility;
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('프로필 수정'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: name,
            decoration: const InputDecoration(labelText: '이름'),
          ),
          TextField(
            controller: school,
            decoration: const InputDecoration(labelText: '학교'),
          ),
          TextField(
            controller: grade,
            decoration: const InputDecoration(labelText: '학년'),
          ),
          TextField(
            controller: age,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '나이 (선택)'),
          ),
          TextField(
            controller: region,
            decoration: const InputDecoration(
              labelText: '지역 (선택)',
              hintText: '서울, 부산처럼 넓은 지역',
            ),
          ),
          TextField(
            controller: bio,
            maxLines: 2,
            decoration: const InputDecoration(labelText: '자기소개 (선택)'),
          ),
          DropdownButtonFormField<String>(
            initialValue: visibility,
            decoration: const InputDecoration(labelText: '프로필 공개 범위'),
            items: const [
              DropdownMenuItem(value: 'public', child: Text('전체 공개')),
              DropdownMenuItem(value: 'friends', child: Text('친구만 공개')),
              DropdownMenuItem(value: 'private', child: Text('비공개')),
            ],
            onChanged: (value) => visibility = value ?? 'friends',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () async {
            try {
              await session.saveUser(
                await session.api.updateProfile(
                  session.user!.apiKey,
                  name.text,
                  school.text,
                  grade.text,
                  age: int.tryParse(age.text),
                  region: region.text,
                  bio: bio.text,
                  profileVisibility: visibility,
                ),
              );
              if (context.mounted) Navigator.pop(context);
            } catch (_) {
              if (context.mounted) showMessage(context, '저장하지 못했어요.');
            }
          },
          child: const Text('저장'),
        ),
      ],
    ),
  );
  name.dispose();
  school.dispose();
  grade.dispose();
  age.dispose();
  region.dispose();
  bio.dispose();
}

Future<void> showFeedback(BuildContext context, SessionStore session) async {
  final message = TextEditingController();
  String category = 'other';
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('피드백 보내기'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: category,
            items: const [
              DropdownMenuItem(value: 'design', child: Text('디자인')),
              DropdownMenuItem(value: 'function', child: Text('기능')),
              DropdownMenuItem(value: 'other', child: Text('기타')),
            ],
            onChanged: (value) => category = value!,
          ),
          TextField(
            controller: message,
            maxLines: 4,
            decoration: const InputDecoration(labelText: '내용'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () async {
            try {
              await session.api.submitFeedback(
                session.user!.apiKey,
                category,
                message.text,
              );
              if (context.mounted) Navigator.pop(context);
            } catch (_) {
              if (context.mounted) showMessage(context, '전송하지 못했어요.');
            }
          },
          child: const Text('보내기'),
        ),
      ],
    ),
  );
  message.dispose();
}

class AppPage extends StatelessWidget {
  const AppPage({
    required this.title,
    required this.subtitle,
    required this.children,
    super.key,
  });
  final String title;
  final String subtitle;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 5),
        Text(subtitle),
        const SizedBox(height: 24),
        ...children,
      ],
    ),
  );
}

class GradientCard extends StatelessWidget {
  const GradientCard({required this.title, required this.subtitle, super.key});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.blue, AppColors.deepBlue],
      ),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(subtitle, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class LevelStatus {
  const LevelStatus({
    required this.level,
    required this.name,
    required this.description,
    required this.score,
    required this.achievementRate,
    required this.streakDays,
  });

  final int level;
  final String name;
  final String description;
  final int score;
  final int achievementRate;
  final int streakDays;
}

LevelStatus statusFor(SessionStore session) {
  final now = DateTime.now();
  final cutoff = now.subtract(const Duration(days: 30));
  final recent = session.verifications.where((record) {
    final date = DateTime.tryParse(record.date);
    return date != null && !date.isBefore(cutoff) && !date.isAfter(now);
  }).toList();
  final challenge =
      session.challenges.where((item) => item.mode == 'solo').firstOrNull ??
      session.challenges.firstOrNull;
  final goal = challenge?.goalMinutes ?? 180;
  final successful = recent
      .where((record) => record.usedMinutes <= goal)
      .length;
  final achievementRate = recent.isEmpty
      ? 0
      : (successful * 100 ~/ recent.length);

  final dates = recent.map((record) => record.date).toSet();
  var streak = 0;
  var cursor = DateTime(now.year, now.month, now.day);
  while (dates.contains(dateKey(cursor))) {
    final record = recent.firstWhere((item) => item.date == dateKey(cursor));
    if (record.usedMinutes > goal) break;
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }

  final lastSeven = now.subtract(const Duration(days: 7));
  final hasRecentActivity = recent.any((record) {
    final date = DateTime.tryParse(record.date);
    return date != null && !date.isBefore(lastSeven);
  });
  var score = achievementRate;
  if (!hasRecentActivity) score -= 10;
  score += (streak * 2).clamp(0, 10);
  score += (session.challenges.length * 2).clamp(0, 5);
  score = score.clamp(0, 100);

  final level = score <= 20
      ? 1
      : score <= 40
      ? 2
      : score <= 60
      ? 3
      : score <= 80
      ? 4
      : 5;
  const names = ['새싹이', '탐색가', '빌더', '몰입가', '프리마스터'];
  const descriptions = [
    '새로운 스마트폰 사용 습관을 시작하는 단계',
    '나에게 맞는 사용 균형을 찾아가는 단계',
    '목표 실천을 통해 집중 루틴을 만들어가는 단계',
    '꾸준한 실천으로 몰입 시간을 안정적으로 확보하는 단계',
    '스마트폰 사용을 주도적으로 관리하며 건강한 루틴을 유지하는 단계',
  ];
  return LevelStatus(
    level: level,
    name: names[level - 1],
    description: descriptions[level - 1],
    score: score,
    achievementRate: achievementRate,
    streakDays: streak,
  );
}

class LevelCard extends StatelessWidget {
  const LevelCard({required this.level, super.key});
  final LevelStatus level;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  '${level.level}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level ${level.level} · ${level.name}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      level.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                '${level.score}점',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: level.score / 100),
          const SizedBox(height: 7),
          Text(
            '최근 달성률 ${level.achievementRate}% · 연속 성공 ${level.streakDays}일',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ),
  );
}

class MetricCard extends StatelessWidget {
  const MetricCard({required this.label, required this.value, super.key});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(label, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    ),
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({required this.title, super.key});
  final String title;
  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
  );
}

class EmptyCard extends StatelessWidget {
  const EmptyCard({required this.message, super.key});
  final String message;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Center(child: Text(message)),
    ),
  );
}

String dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
void showMessage(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
