import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../domain/models/ssh_config_file.dart';

class SshConnectionService {
  const SshConnectionService();

  Future<ConnectResult> connect(SshHostEntry host) async {
    final alias = host.primaryAlias;
    if (alias.isEmpty) {
      return ConnectResult.missingAlias;
    }

    if (kIsWeb) {
      return ConnectResult.unsupportedPlatform;
    }

    if (Platform.isLinux) {
      await Process.start('x-terminal-emulator', ['-e', 'ssh', alias]);
      return ConnectResult.ok;
    }

    if (Platform.isMacOS) {
      final script = 'tell application "Terminal" to do script "ssh $alias"';
      await Process.start('osascript', ['-e', script]);
      return ConnectResult.ok;
    }

    if (Platform.isWindows) {
      await Process.start('cmd', ['/c', 'start', 'cmd', '/k', 'ssh $alias']);
      return ConnectResult.ok;
    }

    return ConnectResult.unsupportedPlatform;
  }
}

enum ConnectResult { ok, missingAlias, unsupportedPlatform }
