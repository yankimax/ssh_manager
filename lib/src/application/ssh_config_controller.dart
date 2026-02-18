import 'package:flutter/foundation.dart';

import '../data/services/ssh_config_service.dart';
import '../data/services/ssh_connection_service.dart';
import '../domain/models/ssh_config_file.dart';

class SshConfigController extends ChangeNotifier {
  SshConfigController({
    required SshConfigService configService,
    required SshConnectionService connectionService,
  }) : _configService = configService,
       _connectionService = connectionService;

  final SshConfigService _configService;
  final SshConnectionService _connectionService;

  SshConfigFile _config = SshConfigFile.empty();
  bool _isLoading = true;
  bool _isSaving = false;

  SshConfigFile get config => _config;
  List<SshHostEntry> get hosts => _config.hosts;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String get configPath => _configService.defaultConfigPath();

  Future<ControllerMessage?> load() async {
    _isLoading = true;
    notifyListeners();

    try {
      _config = await _configService.load();
      return null;
    } catch (error) {
      return ControllerMessage.loadError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ControllerMessage?> addHost(SshHostEntry host) async {
    final hosts = [..._config.hosts, host];
    _config = _config.copyWith(hosts: hosts);
    notifyListeners();
    return _saveInternal();
  }

  Future<ControllerMessage?> updateHost(int index, SshHostEntry host) async {
    final hosts = [..._config.hosts];
    hosts[index] = host;
    _config = _config.copyWith(hosts: hosts);
    notifyListeners();
    return _saveInternal();
  }

  Future<ControllerMessage?> deleteHost(int index) async {
    final hosts = [..._config.hosts]..removeAt(index);
    _config = _config.copyWith(hosts: hosts);
    notifyListeners();
    return _saveInternal();
  }

  Future<ControllerMessage?> reorderHosts(int oldIndex, int newIndex) async {
    final hosts = [..._config.hosts];
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final moved = hosts.removeAt(oldIndex);
    hosts.insert(newIndex, moved);
    _config = _config.copyWith(hosts: hosts);
    notifyListeners();
    return _saveInternal();
  }

  Future<ControllerMessage?> connectToHost(SshHostEntry host) async {
    try {
      final result = await _connectionService.connect(host);
      if (result == ConnectResult.ok) {
        return ControllerMessage.connectStarted(host.primaryAlias);
      }
      if (result == ConnectResult.missingAlias) {
        return ControllerMessage.missingAlias();
      }
      return ControllerMessage.unsupportedPlatform();
    } catch (error) {
      return ControllerMessage.connectFailed(error);
    }
  }

  Future<ControllerMessage?> _saveInternal() async {
    _isSaving = true;
    notifyListeners();

    try {
      await _configService.save(_config);
      return ControllerMessage.saved(configPath);
    } catch (error) {
      return ControllerMessage.saveError(error);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}

enum ControllerMessageType {
  saved,
  loadError,
  saveError,
  connectStarted,
  missingAlias,
  unsupportedPlatform,
  connectFailed,
}

class ControllerMessage {
  const ControllerMessage({
    required this.type,
    this.path,
    this.alias,
    this.error,
  });

  final ControllerMessageType type;
  final String? path;
  final String? alias;
  final Object? error;

  factory ControllerMessage.saved(String path) {
    return ControllerMessage(type: ControllerMessageType.saved, path: path);
  }

  factory ControllerMessage.loadError(Object error) {
    return ControllerMessage(
      type: ControllerMessageType.loadError,
      error: error,
    );
  }

  factory ControllerMessage.saveError(Object error) {
    return ControllerMessage(
      type: ControllerMessageType.saveError,
      error: error,
    );
  }

  factory ControllerMessage.connectStarted(String alias) {
    return ControllerMessage(
      type: ControllerMessageType.connectStarted,
      alias: alias,
    );
  }

  factory ControllerMessage.missingAlias() {
    return const ControllerMessage(type: ControllerMessageType.missingAlias);
  }

  factory ControllerMessage.unsupportedPlatform() {
    return const ControllerMessage(
      type: ControllerMessageType.unsupportedPlatform,
    );
  }

  factory ControllerMessage.connectFailed(Object error) {
    return ControllerMessage(
      type: ControllerMessageType.connectFailed,
      error: error,
    );
  }
}
