import 'package:flutter/material.dart';

import '../../application/ssh_config_controller.dart';
import '../../domain/models/ssh_config_file.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/empty_state.dart';
import '../widgets/host_editor_dialog.dart';

class SshConfigPage extends StatefulWidget {
  const SshConfigPage({super.key, required this.controller});

  final SshConfigController controller;

  @override
  State<SshConfigPage> createState() => _SshConfigPageState();
}

class _SshConfigPageState extends State<SshConfigPage> {
  SshConfigController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.load().then(_showControllerMessage);
  }

  @override
  void didUpdateWidget(covariant SshConfigPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      widget.controller.load().then(_showControllerMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(t.appTitle),
            actions: [
              TextButton.icon(
                onPressed: (_controller.isLoading || _controller.isSaving)
                    ? null
                    : _addHost,
                icon: const Icon(Icons.add),
                label: Text(t.addNew),
              ),
              IconButton(
                tooltip: t.refresh,
                onPressed: (_controller.isLoading || _controller.isSaving)
                    ? null
                    : _reload,
                icon: const Icon(Icons.refresh),
              ),
              if (_controller.isSaving)
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
            ],
          ),
          body: _controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _controller.hosts.isEmpty
              ? const EmptyState()
              : ReorderableListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  itemCount: _controller.hosts.length,
                  onReorder: _controller.isSaving ? (_, _) {} : _onReorder,
                  itemBuilder: (context, index) {
                    final host = _controller.hosts[index];
                    final subtitle = [
                      if (host.hostName.isNotEmpty)
                        'HostName: ${host.hostName}',
                      if (host.user.isNotEmpty) 'User: ${host.user}',
                      if (host.port.isNotEmpty) 'Port: ${host.port}',
                    ].join(' · ');

                    return Card(
                      key: ValueKey('${host.primaryAlias}-$index'),
                      child: ListTile(
                        title: Text(host.primaryAlias),
                        subtitle: subtitle.isEmpty ? null : Text(subtitle),
                        onTap: () => _editHost(index, host),
                        trailing: Wrap(
                          spacing: 4,
                          children: [
                            IconButton(
                              tooltip: t.connect,
                              onPressed: () => _connect(host),
                              icon: const Icon(Icons.link),
                            ),
                            IconButton(
                              tooltip: t.edit,
                              onPressed: () => _editHost(index, host),
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              tooltip: t.remove,
                              onPressed: () => _deleteHost(index, host),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Future<void> _reload() async {
    final message = await _controller.load();
    _showControllerMessage(message);
  }

  Future<void> _addHost() async {
    final result = await showDialog<SshHostEntry>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const HostEditorDialog(),
    );

    if (!mounted || result == null) {
      return;
    }

    final message = await _controller.addHost(result);
    _showControllerMessage(message);
  }

  Future<void> _editHost(int index, SshHostEntry existing) async {
    final result = await showDialog<SshHostEntry>(
      context: context,
      barrierDismissible: false,
      builder: (_) => HostEditorDialog(initial: existing),
    );

    if (!mounted || result == null) {
      return;
    }

    final message = await _controller.updateHost(index, result);
    _showControllerMessage(message);
  }

  Future<void> _deleteHost(int index, SshHostEntry host) async {
    final t = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.deleteTitle),
        content: Text(t.deleteBody(host.primaryAlias)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.remove),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) {
      return;
    }

    final message = await _controller.deleteHost(index);
    _showControllerMessage(message);
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    final message = await _controller.reorderHosts(oldIndex, newIndex);
    _showControllerMessage(message);
  }

  Future<void> _connect(SshHostEntry host) async {
    final message = await _controller.connectToHost(host);
    _showControllerMessage(message);
  }

  void _showControllerMessage(ControllerMessage? message) {
    if (!mounted || message == null) {
      return;
    }

    final t = AppLocalizations.of(context);
    late final String text;

    switch (message.type) {
      case ControllerMessageType.saved:
        text = t.configSaved(message.path ?? _controller.configPath);
      case ControllerMessageType.loadError:
        text = t.loadError(message.error ?? 'unknown');
      case ControllerMessageType.saveError:
        text = t.saveError(message.error ?? 'unknown');
      case ControllerMessageType.connectStarted:
        text = t.connectStarted(message.alias ?? '');
      case ControllerMessageType.missingAlias:
        text = t.missingAliasToConnect;
      case ControllerMessageType.unsupportedPlatform:
        text = t.unsupportedPlatform;
      case ControllerMessageType.connectFailed:
        text = t.connectFailed(message.error ?? 'unknown');
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}
