// duplicate_import: riverpod/legacy.dart and riverpod/riverpod.dart are
// separate libraries from the same package; both are required because
// StateProvider is only exported from legacy.dart and ProviderContainer
// from riverpod.dart. The linter incorrectly flags these as duplicates.
// ignore_for_file: duplicate_import

import 'dart:async';

import 'package:nocterm/nocterm.dart';
import 'package:nocterm_riverpod/nocterm_riverpod.dart';
import 'package:riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';

final counterProvider = StateProvider<int>((ref) => 0);

class CounterApp extends StatelessComponent {
  final ProviderContainer container;

  const CounterApp({super.key, required this.container});

  @override
  Component build(BuildContext context) => RiverpodScope(
    container: container,
    child: Column(
      children: [
        RiverpodConsumer<int>(
          provider: counterProvider,
          builder: (context, count) => Text('Count: $count'),
        ),
        RiverpodSelector<int, String>(
          provider: counterProvider,
          selector: (count) => count.isEven ? 'even' : 'odd',
          builder: (context, parity) => Text('Parity: $parity'),
        ),
        GestureDetector(
          onTap: () {
            context.read(counterProvider.notifier).state++;
          },
          child: const Text('+'),
        ),
        RiverpodListener<int>(
          provider: counterProvider,
          listener: (context, previous, next) {},
          child: Container(),
        ),
      ],
    ),
  );
}

Future<void> main() async {
  final ProviderContainer container = ProviderContainer();
  try {
    await testNocterm('Counter app example', (tester) async {
      await tester.pumpComponent(CounterApp(container: container));
      await tester.pump();
    });
  } finally {
    container.dispose();
  }
}
