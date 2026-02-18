import '../models/ssh_config_file.dart';

class SshConfigParser {
  static SshConfigFile parse(String text) {
    final globalOptions = <String, String>{};
    final hosts = <SshHostEntry>[];

    List<String>? aliases;
    Map<String, String>? options;

    for (final originalLine in text.split('\n')) {
      final line = originalLine.trim();
      if (line.isEmpty || line.startsWith('#')) {
        continue;
      }

      final parts = line.split(RegExp(r'\s+'));
      if (parts.isEmpty) {
        continue;
      }

      final key = parts.first;
      final value = parts.skip(1).join(' ').trim();
      if (value.isEmpty) {
        continue;
      }

      if (key.toLowerCase() == 'host') {
        if (aliases != null && options != null) {
          hosts.add(SshHostEntry(aliases: aliases, options: options));
        }

        aliases = value
            .split(RegExp(r'\s+'))
            .where((segment) => segment.trim().isNotEmpty)
            .toList();
        options = <String, String>{};
        continue;
      }

      if (aliases == null || options == null) {
        globalOptions[key] = value;
      } else {
        options[key] = value;
      }
    }

    if (aliases != null && options != null) {
      hosts.add(SshHostEntry(aliases: aliases, options: options));
    }

    return SshConfigFile(globalOptions: globalOptions, hosts: hosts);
  }
}
