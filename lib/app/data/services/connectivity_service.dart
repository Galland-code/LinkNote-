import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

/// 网络连接状态服务，监控设备网络状态变化
class ConnectivityService extends GetxService {
  // 观察变量 - 网络状态
  final RxBool isConnected = false.obs;

  // 连接类型
  final Rx<ConnectivityResult> connectionType = ConnectivityResult.none.obs;

  // 连接实例
  final Connectivity _connectivity = Connectivity();

  // 连接状态流订阅
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    // 初始化连接监听
    _initConnectivity();
    // 订阅连接变化
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }

  // 初始化网络状态
  Future<void> _initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      result = ConnectivityResult.none;
    }
    return _updateConnectionStatus(result);
  }

  // 更新连接状态
  void _updateConnectionStatus(ConnectivityResult result) {
    connectionType.value = result;
    isConnected.value = result != ConnectivityResult.none;
  }
}
