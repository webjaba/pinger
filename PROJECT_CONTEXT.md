# Project Context

## Цель

Pinger - простое нативное macOS-приложение для периодических напоминаний. Приложение живет в строке состояния, показывает оставшееся время, присылает уведомление после истечения таймера и автоматически запускает таймер заново.

## Текущий UX

- Приложение не отображается в Dock.
- В menu bar отображается countdown в формате `MM:SS` или `H:MM:SS`.
- По клику открывается компактная полупрозрачная модалка.
- Модалка сделана в стиле liquid glass: прозрачный material, тонкая светлая обводка, мягкая тень.
- Поля минут и секунд компактные.
- Кнопки кастомные: овальные, прозрачные, с material-фоном, обводкой, тенями и press-effect.
- `Change Time` применяет новый интервал и сразу перезапускает таймер.
- `Quit` завершает приложение.

## Основные Файлы

- `Pinger/PingerApp.swift` - точка входа SwiftUI-приложения.
- `Pinger/AppDelegate.swift` - запуск приложения, создание менеджеров, установка accessory policy.
- `Pinger/TimerManager.swift` - логика таймера, сохранение интервала, форматирование времени, автоперезапуск.
- `Pinger/StatusBarController.swift` - `NSStatusItem`, отображение времени в menu bar, открытие `NSPopover`.
- `Pinger/SettingsView.swift` - SwiftUI-интерфейс модалки настроек.
- `Pinger/NotificationManager.swift` - уведомления через `UserNotifications` и fallback через `NSUserNotificationCenter`.
- `Pinger/Info.plist` - настройки bundle, включая `LSUIElement`.

## Архитектура

Приложение использует SwiftUI для UI и AppKit для macOS-specific поведения.

- `NSStatusItem` нужен для menu bar.
- `NSPopover` нужен для компактного окна настроек.
- `LSUIElement = true` скрывает приложение из Dock и Cmd+Tab.
- `TimerManager` помечен `@MainActor`, потому что управляет published UI-state.
- `UserDefaults` хранит последний выбранный интервал.

## Уведомления

Основной путь уведомлений - `UNUserNotificationCenter`.

Есть fallback через deprecated `NSUserNotificationCenter`, потому что локальные unsigned/dev-сборки menu bar apps иногда получают ошибку authorization в `UserNotifications`. Это дает warning при сборке, но оставлено осознанно как практичный fallback для текущего MVP.

Если уведомления не приходят, нужно проверить `System Settings -> Notifications -> Pinger`.

## Сборка

Сборка выполняется через Xcode toolchain:

```sh
xcodebuild -project Pinger.xcodeproj -scheme Pinger -configuration Release build
```

Release `.app` появляется в Xcode `DerivedData`. Пример пути:

```text
~/Library/Developer/Xcode/DerivedData/.../Build/Products/Release/Pinger.app
```

## Правило Итераций

После заметной визуальной или функциональной правки новая сборка копируется на рабочий стол с новым номером:

```text
Pinger-001.app
Pinger-002.app
Pinger-003.app
...
```

Старые `.app` на рабочем столе не удалять и не перезаписывать без явного запроса пользователя.

## Текущая Последняя Итерация

Последняя созданная итерация:

```text
~/Desktop/Pinger-007.app
```

## Что Можно Сделать Позже

- Добавить app icon через `Assets.xcassets/AppIcon.appiconset`.
- Добавить автозапуск при входе в систему.
- Добавить pause/resume.
- Добавить presets, например `5`, `15`, `30`, `60` минут.
- Улучшить локализацию текста.
- Перейти на подписанную сборку, чтобы `UserNotifications` вел себя стабильнее.
