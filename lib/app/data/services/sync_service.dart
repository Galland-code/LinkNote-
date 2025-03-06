import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../providers/api_provider.dart';
import '../repositories/note_repository.dart';
import '../services/database_service.dart';

class SyncService extends GetxService {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final NoteRepository _noteRepository = Get.find<NoteRepository>();

  // 其他依赖...

  final RxBool isSyncing = false.obs;
  final RxString syncStatus = ''.obs;

  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    // 监听网络连接变化
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen(_handleConnectivityChange);
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }

  // 网络状态变化处理
  void _handleConnectivityChange(ConnectivityResult result) {
    if (result != ConnectivityResult.none) {
      // 检测到网络恢复，执行同步
      syncData();
    }
  }

  // 同步数据
  Future<void> syncData() async {
    if (isSyncing.value) return;

    try {
      isSyncing.value = true;
      syncStatus.value = '正在同步...';

      // 1. 同步笔记
      await _syncNotes();

      // 2. 同步问题答题记录
      await _syncQuizAttempts();

      // 3. 同步成就
      await _syncAchievements();

      syncStatus.value = '同步完成';
      isSyncing.value = false;
    } catch (e) {
      syncStatus.value = '同步失败: $e';
      isSyncing.value = false;
    }
  }

  // 同步笔记
  Future<void> _syncNotes() async {
    // 获取本地修改的笔记
    final localNotes = _databaseService.getModifiedNotes();

    for (var note in localNotes) {
      try {
        if (note.isNewLocally) {
          // 创建新笔记
          await _apiProvider.post('/notes', data: note.toJson());
        } else if (note.isModifiedLocally) {
          // 更新笔记
          await _apiProvider.put('/notes/${note.id}', data: note.toJson());
        } else if (note.isDeletedLocally) {
          // 删除笔记
          await _apiProvider.delete('/notes/${note.id}');
        }

        // 更新本地同步状态
        await _databaseService.updateSyncStatus(note.id, true);
      } catch (e) {
        print('同步笔记错误: $e');
        // 继续同步其他笔记
      }
    }

    // 获取服务器上的最新数据
    await _noteRepository.getNotesFromApi();
  }

// 其他同步方法...
}