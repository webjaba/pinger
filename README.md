# Pinger

Нативное macOS-приложение в строке состояния. Оно показывает обратный отсчет, присылает уведомление после истечения таймера и автоматически запускает таймер заново.

## Возможности

- Таймер отображается в верхней строке macOS.
- Приложение не появляется в Dock.
- По клику на таймер открывается компактная полупрозрачная модалка.
- Можно задать минуты и секунды.
- После истечения времени приходит уведомление.
- После уведомления таймер автоматически перезапускается.
- Значение таймера сохраняется между запусками.

## Требования

Для сборки нужен установленный Xcode. Писать код можно в VSCode или другом редакторе, но сборка macOS `.app` использует инструменты Xcode.

Проверь, что активен полный Xcode:

```sh
xcode-select -p
```

Ожидаемый путь:

```text
/Applications/Xcode.app/Contents/Developer
```

Если выбран не он, переключи:

```sh
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

## Сборка

Из папки проекта:

```sh
xcodebuild -project Pinger.xcodeproj -scheme Pinger -configuration Release build
```

Успешная сборка заканчивается строкой:

```text
** BUILD SUCCEEDED **
```

## Где Лежит App

Узнать точную папку сборки можно так:

```sh
xcodebuild -project Pinger.xcodeproj -scheme Pinger -configuration Release -showBuildSettings | grep BUILT_PRODUCTS_DIR
```

Пример пути обычно выглядит так:

```text
~/Library/Developer/Xcode/DerivedData/.../Build/Products/Release/Pinger.app
```

## Запуск

Запустить собранное приложение:

```sh
open "$(xcodebuild -project Pinger.xcodeproj -scheme Pinger -configuration Release -showBuildSettings | awk '/BUILT_PRODUCTS_DIR = / { print $3; exit }')/Pinger.app"
```

Или открыть одну из итераций на рабочем столе, например:

```sh
open ~/Desktop/Pinger-007.app
```

## Копирование В Applications

```sh
cp -R "$(xcodebuild -project Pinger.xcodeproj -scheme Pinger -configuration Release -showBuildSettings | awk '/BUILT_PRODUCTS_DIR = / { print $3; exit }')/Pinger.app" /Applications/
```

После этого запуск:

```sh
open /Applications/Pinger.app
```

## Использование

- После запуска таймер появляется в верхней строке macOS.
- Иконки в Dock нет, это ожидаемое поведение.
- Клик по таймеру открывает модалку настроек.
- Введи минуты и секунды.
- Нажми `Change Time`, чтобы применить новое время и перезапустить таймер.
- Нажми `Quit`, чтобы закрыть приложение.
- Для быстрой проверки поставь `0 min 5 sec`.

## Уведомления

Если уведомления не приходят:

- Открой `System Settings -> Notifications`.
- Найди `Pinger`.
- Разреши уведомления.
- Перезапусти приложение.

В приложении есть fallback через старый macOS notification API, потому что `UserNotifications` на локальной unsigned/dev-сборке иногда не получает нормальное разрешение.

## Итерации На Рабочем Столе

После визуальных изменений сборки сохраняются на рабочем столе отдельными версиями:

```text
Pinger-001.app
Pinger-002.app
Pinger-003.app
...
```

Старые версии не удаляются и не перезаписываются, чтобы можно было сравнить дизайн и быстро вернуться к предыдущей итерации.

## Открыть Проект В Xcode

```sh
open Pinger.xcodeproj
```
