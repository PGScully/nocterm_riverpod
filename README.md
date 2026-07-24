# nocterm_riverpod

Riverpod state management bindings for [nocterm](https://nocterm.dev) terminal UIs.

Bridges [Riverpod](https://riverpod.dev) providers into nocterm's component tree via `InheritedComponent`, enabling per-component granular rebuilds without manual `container.listen()` wiring or prop drilling.

## Features

- **`RiverpodScope`** — provides a `ProviderContainer` down the nocterm component tree
- **`RiverpodConsumer<T>`** — rebuilds its subtree when a provider emits a new value
- **`RiverpodSelector<T, R>`** — rebuilds only when a selected slice of state changes (by equality)
- **`RiverpodListener<T>`** — listens for provider changes for side effects without rebuilding
- **`BuildContext` extensions** — `context.container` and `context.read<T>(provider)` convenience accessors

## Getting started

```yaml
dependencies:
  nocterm_riverpod: ^0.1.0
```

Wrap your app in `RiverpodScope`, then use `RiverpodConsumer` anywhere in the tree:

```dart
import 'package:nocterm/nocterm.dart';
import 'package:nocterm_riverpod/nocterm_riverpod.dart';
import 'package:riverpod/riverpod.dart';

final counterProvider = StateProvider<int>((ref) => 0);

void main() {
  final container = ProviderContainer();
  runApp(
    RiverpodScope(
      container: container,
      child: RiverpodConsumer(
        provider: counterProvider,
        builder: (context, count) => Text('Count: $count'),
      ),
    ),
  );
}
```

## Usage with View Models

```dart
RiverpodConsumer(
  provider: tasksPanelViewModelProvider,
  builder: (context, state) {
    final vm = context.read(tasksPanelViewModelProvider.notifier);
    return TasksPanel(state: state, viewModel: vm);
  },
)
```

## Selective Rebuilds

```dart
RiverpodSelector(
  provider: appBarViewModelProvider,
  selector: (state) => state.panelFocus,
  builder: (context, focus) => StatusBar(isFocused: focus == PanelFocus.main),
)
```

## Side Effects

```dart
RiverpodListener(
  provider: statusMessageProvider,
  listener: (context, previous, message) {
    if (message != null) log(message);
  },
  child: MyPanel(),
)
```
