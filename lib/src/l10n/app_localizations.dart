import 'package:flutter/material.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('ru')];

  static const delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    return localizations ?? const AppLocalizations(Locale('en'));
  }

  bool get isRu => locale.languageCode.toLowerCase() == 'ru';

  String get appTitle => isRu ? 'SSH Config Manager' : 'SSH Config Manager';
  String get addNew => isRu ? 'Добавить новый' : 'Add New';
  String get refresh => isRu ? 'Обновить' : 'Refresh';
  String get connect => isRu ? 'Подключиться' : 'Connect';
  String get edit => isRu ? 'Редактировать' : 'Edit';
  String get remove => isRu ? 'Удалить' : 'Delete';

  String get noHosts => isRu
      ? 'Хосты не найдены. Добавьте новый профиль.'
      : 'No hosts found. Add a new profile.';

  String get newHost => isRu ? 'Новый хост' : 'New Host';
  String get editHost => isRu ? 'Редактирование хоста' : 'Edit Host';
  String get cancel => isRu ? 'Отмена' : 'Cancel';
  String get save => isRu ? 'Сохранить' : 'Save';

  String get fieldHostAliases => isRu
      ? 'Host (alias, можно несколько через пробел)'
      : 'Host (aliases separated by spaces)';
  String get fieldHostName => 'HostName';
  String get fieldUser => 'User';
  String get fieldPort => 'Port';
  String get fieldIdentityFile => 'IdentityFile';
  String get fieldProxyJump => 'ProxyJump';
  String get fieldForwardAgent =>
      isRu ? 'ForwardAgent (yes/no)' : 'ForwardAgent (yes/no)';
  String get fieldExtraOptions => isRu
      ? 'Дополнительные опции (каждая строка: Key Value)'
      : 'Additional options (one per line: Key Value)';

  String get validateAliasRequired =>
      isRu ? 'Укажите минимум один alias' : 'Provide at least one alias';

  String get deleteTitle => isRu ? 'Удалить хост?' : 'Delete host?';
  String deleteBody(String alias) => isRu
      ? 'Будет удален профиль `$alias`.'
      : 'Profile `$alias` will be deleted.';

  String configSaved(String path) =>
      isRu ? 'Конфиг сохранен: $path' : 'Config saved: $path';
  String loadError(Object error) =>
      isRu ? 'Ошибка загрузки: $error' : 'Load error: $error';
  String saveError(Object error) =>
      isRu ? 'Ошибка сохранения: $error' : 'Save error: $error';

  String get missingAliasToConnect => isRu
      ? 'Для подключения нужен alias Host'
      : 'Host alias is required for connection';
  String get webNotSupported => isRu
      ? 'Web не поддерживает запуск ssh'
      : 'Web does not support ssh launch';
  String get unsupportedPlatform => isRu
      ? 'На этой платформе автоматическое подключение не поддерживается'
      : 'Automatic connection is not supported on this platform';
  String connectStarted(String alias) => isRu
      ? 'Запущено подключение к `$alias`'
      : 'Connection started for `$alias`';
  String connectFailed(Object error) => isRu
      ? 'Не удалось запустить ssh: $error'
      : 'Failed to launch ssh: $error';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
    (supported) => supported.languageCode == locale.languageCode,
  );

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
