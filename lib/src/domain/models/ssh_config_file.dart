class SshConfigFile {
  SshConfigFile({required this.globalOptions, required this.hosts});

  final Map<String, String> globalOptions;
  final List<SshHostEntry> hosts;

  factory SshConfigFile.empty() => SshConfigFile(globalOptions: {}, hosts: []);

  SshConfigFile copyWith({
    Map<String, String>? globalOptions,
    List<SshHostEntry>? hosts,
  }) {
    return SshConfigFile(
      globalOptions: globalOptions ?? this.globalOptions,
      hosts: hosts ?? this.hosts,
    );
  }

  String toText() {
    final buffer = StringBuffer();

    for (final entry in globalOptions.entries) {
      buffer.writeln('${entry.key} ${entry.value}');
    }

    if (globalOptions.isNotEmpty && hosts.isNotEmpty) {
      buffer.writeln();
    }

    for (var i = 0; i < hosts.length; i++) {
      final host = hosts[i];
      buffer.writeln('Host ${host.aliases.join(' ')}');
      for (final option in host.options.entries) {
        buffer.writeln('  ${option.key} ${option.value}');
      }
      if (i != hosts.length - 1) {
        buffer.writeln();
      }
    }

    return buffer.toString();
  }
}

class SshHostEntry {
  SshHostEntry({required this.aliases, required this.options});

  final List<String> aliases;
  final Map<String, String> options;

  String get primaryAlias => aliases.isEmpty ? '' : aliases.first;

  String get hostName => _option('HostName');

  String get user => _option('User');

  String get port => _option('Port');

  String get identityFile => _option('IdentityFile');

  String get proxyJump => _option('ProxyJump');

  String get forwardAgent => _option('ForwardAgent');

  Map<String, String> get extraOptions {
    const standard = {
      'HostName',
      'User',
      'Port',
      'IdentityFile',
      'ProxyJump',
      'ForwardAgent',
    };

    return Map.fromEntries(
      options.entries.where((entry) => !standard.contains(entry.key)),
    );
  }

  String _option(String key) {
    for (final entry in options.entries) {
      if (entry.key.toLowerCase() == key.toLowerCase()) {
        return entry.value;
      }
    }
    return '';
  }
}
