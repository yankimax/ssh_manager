import 'package:flutter/material.dart';

import '../../domain/models/ssh_config_file.dart';
import '../../l10n/app_localizations.dart';

class HostEditorDialog extends StatefulWidget {
  const HostEditorDialog({super.key, this.initial});

  final SshHostEntry? initial;

  @override
  State<HostEditorDialog> createState() => _HostEditorDialogState();
}

class _HostEditorDialogState extends State<HostEditorDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _hostController;
  late final TextEditingController _hostNameController;
  late final TextEditingController _userController;
  late final TextEditingController _portController;
  late final TextEditingController _identityFileController;
  late final TextEditingController _proxyJumpController;
  late final TextEditingController _forwardAgentController;
  late final TextEditingController _extraOptionsController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _hostController = TextEditingController(
      text: (initial?.aliases ?? []).join(' '),
    );
    _hostNameController = TextEditingController(text: initial?.hostName ?? '');
    _userController = TextEditingController(text: initial?.user ?? '');
    _portController = TextEditingController(text: initial?.port ?? '');
    _identityFileController = TextEditingController(
      text: initial?.identityFile ?? '',
    );
    _proxyJumpController = TextEditingController(
      text: initial?.proxyJump ?? '',
    );
    _forwardAgentController = TextEditingController(
      text: initial?.forwardAgent ?? '',
    );
    _extraOptionsController = TextEditingController(
      text:
          initial?.extraOptions.entries
              .map((entry) => '${entry.key} ${entry.value}')
              .join('\n') ??
          '',
    );
  }

  @override
  void dispose() {
    _hostController.dispose();
    _hostNameController.dispose();
    _userController.dispose();
    _portController.dispose();
    _identityFileController.dispose();
    _proxyJumpController.dispose();
    _forwardAgentController.dispose();
    _extraOptionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.initial == null ? t.newHost : t.editHost,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _hostController,
                    decoration: InputDecoration(
                      labelText: t.fieldHostAliases,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return t.validateAliasRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _hostNameController,
                    decoration: InputDecoration(
                      labelText: t.fieldHostName,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _userController,
                          decoration: InputDecoration(
                            labelText: t.fieldUser,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _portController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: t.fieldPort,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _identityFileController,
                    decoration: InputDecoration(
                      labelText: t.fieldIdentityFile,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _proxyJumpController,
                          decoration: InputDecoration(
                            labelText: t.fieldProxyJump,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _forwardAgentController,
                          decoration: InputDecoration(
                            labelText: t.fieldForwardAgent,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _extraOptionsController,
                    minLines: 4,
                    maxLines: 8,
                    decoration: InputDecoration(
                      labelText: t.fieldExtraOptions,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(t.cancel),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(onPressed: _save, child: Text(t.save)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final aliases = _hostController.text
        .split(RegExp(r'\s+'))
        .where((value) => value.trim().isNotEmpty)
        .toList();

    final extraOptions = <String, String>{};
    final lines = _extraOptionsController.text.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        continue;
      }

      final parts = trimmed.split(RegExp(r'\s+'));
      if (parts.length < 2) {
        continue;
      }

      final key = parts.first;
      final value = parts.skip(1).join(' ');
      extraOptions[key] = value;
    }

    final entry = SshHostEntry(
      aliases: aliases,
      options: {
        if (_hostNameController.text.trim().isNotEmpty)
          'HostName': _hostNameController.text.trim(),
        if (_userController.text.trim().isNotEmpty)
          'User': _userController.text.trim(),
        if (_portController.text.trim().isNotEmpty)
          'Port': _portController.text.trim(),
        if (_identityFileController.text.trim().isNotEmpty)
          'IdentityFile': _identityFileController.text.trim(),
        if (_proxyJumpController.text.trim().isNotEmpty)
          'ProxyJump': _proxyJumpController.text.trim(),
        if (_forwardAgentController.text.trim().isNotEmpty)
          'ForwardAgent': _forwardAgentController.text.trim(),
        ...extraOptions,
      },
    );

    Navigator.of(context).pop(entry);
  }
}
