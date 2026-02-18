import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../domain/models/ssh_config_file.dart';
import '../../domain/parsers/ssh_config_parser.dart';

class SshConfigService {
  const SshConfigService();

  String defaultConfigPath() {
    if (kIsWeb) {
      return '.ssh/config';
    }

    final env = Platform.environment;
    final home = env['HOME'];
    if (home != null && home.isNotEmpty) {
      return '$home/.ssh/config';
    }

    final userProfile = env['USERPROFILE'];
    if (userProfile != null && userProfile.isNotEmpty) {
      return '$userProfile/.ssh/config';
    }

    return '.ssh/config';
  }

  Future<SshConfigFile> load() async {
    final file = File(defaultConfigPath());
    if (!await file.exists()) {
      return SshConfigFile.empty();
    }

    final content = await file.readAsString();
    return SshConfigParser.parse(content);
  }

  Future<void> save(SshConfigFile config) async {
    final file = File(defaultConfigPath());
    await file.parent.create(recursive: true);
    await file.writeAsString(config.toText());
  }
}
