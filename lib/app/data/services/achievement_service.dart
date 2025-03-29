import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_achievement.dart';
import '../models/community_challenge.dart';
import '../../modules/auth/controllers/userController.dart';

class AchievementService extends GetxService {
  final String baseUrl = 'http://82.157.18.189:8080/linknote/api';
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // 用户成就数据
  final Rx<UserAchievement?> userAchievement = Rx<UserAchievement?>(null);
  // 社区挑战列表
  final RxList<CommunityChallenge> communityChallenges =
      <CommunityChallenge>[].obs;

  // 成就定义
  final List<Map<String, dynamic>> achievementDefinitions = [
    {
      'id': 'first_question',
      'title': '初次问答',
      'description': '完成第一次问答',
      'iconPath': 'assets/icons/achievements/first_question.svg',
      'expReward': 10,
    },
    {
      'id': 'first_correct',
      'title': '初尝甜头',
      'description': '第一次答对问题',
      'iconPath': 'assets/icons/achievements/first_correct.svg',
      'expReward': 15,
    },
    {
      'id': 'first_challenge',
      'title': '挑战者',
      'description': '完成第一个挑战',
      'iconPath': 'assets/icons/achievements/first_challenge.svg',
      'expReward': 20,
    },
    {
      'id': 'streak_3',
      'title': '连击手',
      'description': '连续答对3个问题',
      'iconPath': 'assets/icons/achievements/streak_3.svg',
      'expReward': 30,
    },
    {
      'id': 'create_challenge',
      'title': '命题者',
      'description': '创建第一个挑战关卡',
      'iconPath': 'assets/icons/achievements/create_challenge.svg',
      'expReward': 50,
    },
    {
      'id': 'share_challenge',
      'title': '分享者',
      'description': '分享挑战到社区',
      'iconPath': 'assets/icons/achievements/share_challenge.svg',
      'expReward': 40,
    },
    {
      'id': 'complete_5_challenges',
      'title': '挑战大师',
      'description': '完成5个挑战',
      'iconPath': 'assets/icons/achievements/complete_5_challenges.svg',
      'expReward': 100,
    },
    {
      'id': 'reach_level_5',
      'title': '成长之路',
      'description': '达到5级',
      'iconPath': 'assets/icons/achievements/reach_level_5.svg',
      'expReward': 0,
    },
    {
      'id': 'reach_level_10',
      'title': '初级专家',
      'description': '达到10级',
      'iconPath': 'assets/icons/achievements/reach_level_10.svg',
      'expReward': 0,
    },
  ];

  // 称号定义
  final List<Map<String, dynamic>> titleDefinitions = [
    {'id': 'beginner', 'title': '初学者', 'requiredLevel': 1},
    {'id': 'knowledge_seeker', 'title': '求知者', 'requiredLevel': 3},
    {'id': 'smart_learner', 'title': '学习达人', 'requiredLevel': 5},
    {'id': 'knowledge_master', 'title': '知识大师', 'requiredLevel': 10},
    {
      'id': 'computer_network_expert',
      'title': '计算机网络专家',
      'requiredCategory': '计算机网络',
      'requiredCorrectCount': 50,
    },
    {
      'id': 'algorithm_genius',
      'title': '算法天才',
      'requiredCategory': '算法',
      'requiredCorrectCount': 50,
    },
  ];

  // 头像框定义
  final List<Map<String, dynamic>> frameDefinitions = [
    {
      'id': 'default',
      'name': '默认',
      'imageUrl': 'assets/frames/default.png',
      'requiredLevel': 1,
    },
    {
      'id': 'bronze',
      'name': '青铜',
      'imageUrl': 'assets/frames/bronze.png',
      'requiredLevel': 5,
    },
    {
      'id': 'silver',
      'name': '白银',
      'imageUrl': 'assets/frames/silver.png',
      'requiredLevel': 10,
    },
    {
      'id': 'gold',
      'name': '黄金',
      'imageUrl': 'assets/frames/gold.png',
      'requiredLevel': 15,
    },
    {
      'id': 'diamond',
      'name': '钻石',
      'imageUrl': 'assets/frames/diamond.png',
      'requiredLevel': 20,
    },
    {
      'id': 'computer_network',
      'name': '网络精英',
      'imageUrl': 'assets/frames/network.png',
      'requiredCategory': '计算机网络',
      'requiredCorrectCount': 100,
      'hasAnimation': true,
    },
  ];

  @override
  void onInit() {
    super.onInit();
    loadUserAchievement();
    loadCommunityChallenges();
  }

  // 加载用户成就数据
  Future<void> loadUserAchievement() async {
    try {
      isLoading.value = true;
      int userId = Get.find<UserController>().userId.value;

      // 尝试从缓存加载
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('user_achievement_$userId');

      if (cachedData != null) {
        userAchievement.value = UserAchievement.fromJson(
          jsonDecode(cachedData),
        );
      }

      // 尝试从API加载
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/achievements/user/$userId'),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          userAchievement.value = UserAchievement.fromJson(data);

          // 更新缓存
          await prefs.setString('user_achievement_$userId', jsonEncode(data));
        }
      } catch (e) {
        print('从API加载用户成就失败: $e');
        // 如果API失败但有缓存数据，保持使用缓存数据
        if (userAchievement.value == null) {
          // 如果没有数据，创建一个新的
          userAchievement.value = UserAchievement(
            userId: userId,
            updatedAt: DateTime.now(),
          );
        }
      }

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = '加载用户成就失败: $e';
    }
  }

  // 加载社区挑战
  Future<void> loadCommunityChallenges() async {
    try {
      isLoading.value = true;

      try {
        final response = await http.get(
          Uri.parse('$baseUrl/community-challenges'),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));

          if (data is List) {
            communityChallenges.value =
                data.map((item) => CommunityChallenge.fromJson(item)).toList();
          }
        }
      } catch (e) {
        print('从API加载社区挑战失败: $e');
        // 如果API失败，使用模拟数据
        communityChallenges.value = _getMockCommunityChallenges();
      }

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = '加载社区挑战失败: $e';
    }
  }

  // 更新用户成就（添加经验值）
  Future<void> addExperience(int exp, {String? category}) async {
    try {
      if (userAchievement.value == null) {
        await loadUserAchievement();
      }

      if (userAchievement.value == null) {
        throw Exception('用户成就数据不存在');
      }

      // 更新经验值和等级
      var updated = userAchievement.value!.addExperience(exp);

      // 如果有分类信息，更新分类进度
      if (category != null && category.isNotEmpty) {
        Map<String, int> updatedCategoryProgress = Map<String, int>.from(
          updated.categoryProgress,
        );

        updatedCategoryProgress[category] =
            (updatedCategoryProgress[category] ?? 0) + exp;

        updated = updated.copyWith(categoryProgress: updatedCategoryProgress);
      }

      // 检查是否可以解锁新称号和头像框
      updated = _checkForNewUnlocks(updated);

      // 更新本地数据
      userAchievement.value = updated;

      // 尝试保存到API
      try {
        await http.post(
          Uri.parse('$baseUrl/achievements/update'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(updated.toJson()),
        );
      } catch (e) {
        print('保存成就到API失败: $e');
      }

      // 更新本地缓存
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'user_achievement_${updated.userId}',
        jsonEncode(updated.toJson()),
      );
    } catch (e) {
      errorMessage.value = '更新用户成就失败: $e';
    }
  }

  // 检查新的称号和头像框解锁
  UserAchievement _checkForNewUnlocks(UserAchievement achievement) {
    List<String> newTitles = List.from(achievement.unlockedTitles);
    List<String> newFrames = List.from(achievement.unlockedFrames);

    // 检查称号解锁
    for (var title in titleDefinitions) {
      String titleId = title['id'];

      if (!newTitles.contains(titleId)) {
        // 检查等级要求
        if (title.containsKey('requiredLevel') &&
            achievement.level >= title['requiredLevel']) {
          newTitles.add(titleId);
        }

        // 检查分类要求
        if (title.containsKey('requiredCategory') &&
            title.containsKey('requiredCorrectCount')) {
          String category = title['requiredCategory'];
          int requiredCount = title['requiredCorrectCount'];

          if (achievement.categoryProgress.containsKey(category) &&
              achievement.categoryProgress[category]! >= requiredCount) {
            newTitles.add(titleId);
          }
        }
      }
    }

    // 检查头像框解锁
    for (var frame in frameDefinitions) {
      String frameId = frame['id'];

      if (!newFrames.contains(frameId)) {
        // 检查等级要求
        if (frame.containsKey('requiredLevel') &&
            achievement.level >= frame['requiredLevel']) {
          newFrames.add(frameId);
        }

        // 检查分类要求
        if (frame.containsKey('requiredCategory') &&
            frame.containsKey('requiredCorrectCount')) {
          String category = frame['requiredCategory'];
          int requiredCount = frame['requiredCorrectCount'];

          if (achievement.categoryProgress.containsKey(category) &&
              achievement.categoryProgress[category]! >= requiredCount) {
            newFrames.add(frameId);
          }
        }
      }
    }

    // 如果有新解锁，返回更新后的成就对象
    if (newTitles.length > achievement.unlockedTitles.length ||
        newFrames.length > achievement.unlockedFrames.length) {
      return achievement.copyWith(
        unlockedTitles: newTitles,
        unlockedFrames: newFrames,
      );
    }

    return achievement;
  }

  // 解锁成就
  Future<void> unlockAchievement(String achievementId) async {
    try {
      if (userAchievement.value == null) {
        await loadUserAchievement();
      }

      if (userAchievement.value == null) {
        throw Exception('用户成就数据不存在');
      }

      // 检查成就是否已解锁
      if (userAchievement.value!.unlockedAchievements.contains(achievementId)) {
        return; // 已解锁，跳过
      }

      // 查找成就定义
      final achievementDef = achievementDefinitions.firstWhere(
        (a) => a['id'] == achievementId,
        orElse: () => throw Exception('成就定义不存在'),
      );

      // 添加成就到已解锁列表
      List<String> updatedAchievements = List.from(
        userAchievement.value!.unlockedAchievements,
      );
      updatedAchievements.add(achievementId);

      // 更新用户成就
      var updated = userAchievement.value!.copyWith(
        unlockedAchievements: updatedAchievements,
      );

      // 如果有经验奖励，添加经验
      int expReward = achievementDef['expReward'] ?? 0;
      if (expReward > 0) {
        updated = updated.addExperience(expReward);
      }

      // 检查是否可以解锁新称号和头像框
      updated = _checkForNewUnlocks(updated);

      // 更新本地数据
      userAchievement.value = updated;

      // 尝试保存到API
      try {
        await http.post(
          Uri.parse('$baseUrl/achievements/unlock'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId': updated.userId,
            'achievementId': achievementId,
          }),
        );
      } catch (e) {
        print('保存成就解锁到API失败: $e');
      }

      // 更新本地缓存
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'user_achievement_${updated.userId}',
        jsonEncode(updated.toJson()),
      );

      // 显示成就解锁提示
      Get.snackbar(
        '成就解锁！',
        '恭喜解锁成就: ${achievementDef['title']}',
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      errorMessage.value = '解锁成就失败: $e';
    }
  }

  // 获取用户当前等级称号
  String getUserTitle() {
    if (userAchievement.value == null ||
        userAchievement.value!.currentTitle.isEmpty) {
      return '初学者';
    }
    return userAchievement.value!.currentTitle;
  }

  // 获取用户当前头像框
  String getUserFrame() {
    if (userAchievement.value == null ||
        userAchievement.value!.currentFrame.isEmpty) {
      return 'default';
    }
    return userAchievement.value!.currentFrame;
  }

  // 设置当前使用的称号
  Future<void> setUserTitle(String titleId) async {
    try {
      if (userAchievement.value == null) {
        await loadUserAchievement();
      }

      if (userAchievement.value == null) {
        throw Exception('用户成就数据不存在');
      }

      // 检查称号是否已解锁
      if (!userAchievement.value!.unlockedTitles.contains(titleId)) {
        throw Exception('该称号尚未解锁');
      }

      // 更新当前称号
      final updated = userAchievement.value!.copyWith(
        currentTitle: titleId,
        updatedAt: DateTime.now(),
      );

      // 更新本地数据
      userAchievement.value = updated;

      // 尝试保存到API
      try {
        await http.post(
          Uri.parse('$baseUrl/achievements/set-title'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'userId': updated.userId, 'titleId': titleId}),
        );
      } catch (e) {
        print('保存称号设置到API失败: $e');
      }

      // 更新本地缓存
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'user_achievement_${updated.userId}',
        jsonEncode(updated.toJson()),
      );
    } catch (e) {
      errorMessage.value = '设置称号失败: $e';
    }
  }

  // 设置当前使用的头像框
  Future<void> setUserFrame(String frameId) async {
    try {
      if (userAchievement.value == null) {
        await loadUserAchievement();
      }

      if (userAchievement.value == null) {
        throw Exception('用户成就数据不存在');
      }

      // 检查头像框是否已解锁
      if (!userAchievement.value!.unlockedFrames.contains(frameId)) {
        throw Exception('该头像框尚未解锁');
      }

      // 更新当前头像框
      final updated = userAchievement.value!.copyWith(
        currentFrame: frameId,
        updatedAt: DateTime.now(),
      );

      // 更新本地数据
      userAchievement.value = updated;

      // 尝试保存到API
      try {
        await http.post(
          Uri.parse('$baseUrl/achievements/set-frame'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'userId': updated.userId, 'frameId': frameId}),
        );
      } catch (e) {
        print('保存头像框设置到API失败: $e');
      }

      // 更新本地缓存
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'user_achievement_${updated.userId}',
        jsonEncode(updated.toJson()),
      );
    } catch (e) {
      errorMessage.value = '设置头像框失败: $e';
    }
  }

  // 答题完成，更新统计信息
  Future<void> updateQuestionStats(bool isCorrect, String category) async {
    try {
      if (userAchievement.value == null) {
        await loadUserAchievement();
      }

      if (userAchievement.value == null) {
        throw Exception('用户成就数据不存在');
      }

      int newTotalQuestions = userAchievement.value!.totalQuestions + 1;
      int newCorrectQuestions =
          isCorrect
              ? userAchievement.value!.correctQuestions + 1
              : userAchievement.value!.correctQuestions;

      // 更新分类进度
      Map<String, int> updatedCategoryProgress = Map<String, int>.from(
        userAchievement.value!.categoryProgress,
      );

      updatedCategoryProgress[category] =
          (updatedCategoryProgress[category] ?? 0) + (isCorrect ? 1 : 0);

      // 更新用户成就
      var updated = userAchievement.value!.copyWith(
        totalQuestions: newTotalQuestions,
        correctQuestions: newCorrectQuestions,
        categoryProgress: updatedCategoryProgress,
        updatedAt: DateTime.now(),
      );

      // 检查是否可以解锁新称号和头像框
      updated = _checkForNewUnlocks(updated);

      // 更新战力值
      updated = updated.copyWith(powerScore: updated.calculatePowerScore());

      // 更新本地数据
      userAchievement.value = updated;

      // 尝试保存到API
      try {
        await http.post(
          Uri.parse('$baseUrl/achievements/update-stats'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId': updated.userId,
            'isCorrect': isCorrect,
            'category': category,
          }),
        );
      } catch (e) {
        print('保存统计信息到API失败: $e');
      }

      // 更新本地缓存
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'user_achievement_${updated.userId}',
        jsonEncode(updated.toJson()),
      );
    } catch (e) {
      errorMessage.value = '更新统计信息失败: $e';
    }
  }

  // 发布挑战到社区
  Future<bool> publishChallengeToCommuity(CommunityChallenge challenge) async {
    try {
      isLoading.value = true;

      // 设置为已发布
      final publishedChallenge = challenge.copyWith(isPublished: true);

      // 尝试保存到API
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/community-challenges/create'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(publishedChallenge.toJson()),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          // 添加到本地列表
          communityChallenges.add(publishedChallenge);

          // 解锁"分享者"成就
          await unlockAchievement('share_challenge');

          isLoading.value = false;
          return true;
        } else {
          throw Exception('API返回错误: ${response.statusCode}');
        }
      } catch (e) {
        print('保存挑战到API失败: $e');
        // 模拟成功（离线模式）
        communityChallenges.add(publishedChallenge);
        await unlockAchievement('share_challenge');
        isLoading.value = false;
        return true;
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = '发布挑战失败: $e';
      return false;
    }
  }

  // 提交挑战完成记录
  Future<bool> submitChallengeCompletion(
    String challengeId,
    CompletionRecord record,
  ) async {
    try {
      isLoading.value = true;

      // 查找挑战
      final index = communityChallenges.indexWhere((c) => c.id == challengeId);
      if (index == -1) {
        throw Exception('挑战不存在');
      }

      // 更新挑战记录
      final challenge = communityChallenges[index];
      final updatedChallenge = challenge.addCompletionRecord(record);

      // 更新本地列表
      communityChallenges[index] = updatedChallenge;

      // 尝试保存到API
      try {
        await http.post(
          Uri.parse('$baseUrl/community-challenges/submit-completion'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'challengeId': challengeId,
            'record': record.toJson(),
          }),
        );
      } catch (e) {
        print('保存挑战完成记录到API失败: $e');
        // 继续处理，因为已经更新了本地数据
      }

      // 解锁"挑战者"成就
      await unlockAchievement('first_challenge');

      // 检查是否完成了5个挑战
      int completedChallenges =
          communityChallenges.where((c) {
            return c.completionRecords.any(
              (r) => r.userId == record.userId && r.isCompleted,
            );
          }).length;

      if (completedChallenges >= 5) {
        await unlockAchievement('complete_5_challenges');
      }

      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = '提交挑战完成记录失败: $e';
      return false;
    }
  }

  // 获取基于位置的排行榜
  Future<List<Map<String, dynamic>>> getLocationBasedLeaderboard(
    String locationTag,
  ) async {
    try {
      isLoading.value = true;

      try {
        final response = await http.get(
          Uri.parse('$baseUrl/leaderboard/location/$locationTag'),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          isLoading.value = false;
          return List<Map<String, dynamic>>.from(data);
        } else {
          throw Exception('API返回错误: ${response.statusCode}');
        }
      } catch (e) {
        print('从API加载排行榜失败: $e');
        // 返回模拟数据
        isLoading.value = false;
        return _getMockLeaderboardData(locationTag);
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = '获取排行榜失败: $e';
      return [];
    }
  }

  // 获取好友排行榜
  Future<List<Map<String, dynamic>>> getFriendsLeaderboard() async {
    try {
      isLoading.value = true;
      int userId = Get.find<UserController>().userId.value;

      try {
        final response = await http.get(
          Uri.parse('$baseUrl/leaderboard/friends/$userId'),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          isLoading.value = false;
          return List<Map<String, dynamic>>.from(data);
        } else {
          throw Exception('API返回错误: ${response.statusCode}');
        }
      } catch (e) {
        print('从API加载好友排行榜失败: $e');
        // 返回模拟数据
        isLoading.value = false;
        return _getMockFriendsLeaderboardData();
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = '获取好友排行榜失败: $e';
      return [];
    }
  }

  // 模拟社区挑战数据
  List<CommunityChallenge> _getMockCommunityChallenges() {
    return [
      CommunityChallenge(
        id: '1',
        creatorId: 101,
        creatorName: '网络大师',
        title: '计算机网络入门挑战',
        description: '测试你的计算机网络基础知识',
        category: '计算机网络',
        createdAt: DateTime.now().subtract(Duration(days: 5)),
        questions: [],
        difficultyLevel: 1,
        playCount: 48,
        passCount: 42,
        passRate: 0.875,
        isPublished: true,
      ),
      CommunityChallenge(
        id: '2',
        creatorId: 102,
        creatorName: '算法迷',
        title: '数据结构进阶',
        description: '挑战你的数据结构理解深度',
        category: '数据结构',
        createdAt: DateTime.now().subtract(Duration(days: 3)),
        questions: [],
        difficultyLevel: 3,
        playCount: 32,
        passCount: 12,
        passRate: 0.375,
        isPublished: true,
      ),
      CommunityChallenge(
        id: '3',
        creatorId: 103,
        creatorName: '系统大神',
        title: '操作系统高难度挑战',
        description: '只有真正的OS达人才能通过',
        category: '操作系统',
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        questions: [],
        difficultyLevel: 4,
        playCount: 25,
        passCount: 3,
        passRate: 0.12,
        isPublished: true,
      ),
    ];
  }

  // 模拟位置排行榜数据
  List<Map<String, dynamic>> _getMockLeaderboardData(String locationTag) {
    return [
      {
        'userId': 101,
        'username': '网络大师',
        'avatar': 'assets/avatars/1.png',
        'frame': 'gold',
        'level': 15,
        'powerScore': 320,
        'title': '知识大师',
        'completedChallenges': 12,
      },
      {
        'userId': 102,
        'username': '算法迷',
        'avatar': 'assets/avatars/2.png',
        'frame': 'silver',
        'level': 12,
        'powerScore': 285,
        'title': '学习达人',
        'completedChallenges': 9,
      },
      {
        'userId': 103,
        'username': '系统大神',
        'avatar': 'assets/avatars/3.png',
        'frame': 'diamond',
        'level': 18,
        'powerScore': 410,
        'title': '计算机网络专家',
        'completedChallenges': 15,
      },
    ];
  }

  // 模拟好友排行榜数据
  List<Map<String, dynamic>> _getMockFriendsLeaderboardData() {
    return [
      {
        'userId': 104,
        'username': '张三',
        'avatar': 'assets/avatars/4.png',
        'frame': 'bronze',
        'level': 8,
        'powerScore': 180,
        'title': '求知者',
        'completedChallenges': 5,
      },
      {
        'userId': 105,
        'username': '李四',
        'avatar': 'assets/avatars/5.png',
        'frame': 'default',
        'level': 5,
        'powerScore': 120,
        'title': '初学者',
        'completedChallenges': 3,
      },
      {
        'userId': 106,
        'username': '王五',
        'avatar': 'assets/avatars/6.png',
        'frame': 'silver',
        'level': 10,
        'powerScore': 220,
        'title': '学习达人',
        'completedChallenges': 7,
      },
    ];
  }
}
