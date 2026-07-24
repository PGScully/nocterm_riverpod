// duplicate_import: riverpod/legacy.dart and riverpod/riverpod.dart are
// separate libraries from the same package; both are required because
// StateProvider is only exported from legacy.dart and ProviderContainer
// from riverpod.dart. The linter incorrectly flags these as duplicates.
// ignore_for_file: duplicate_import

import 'package:nocterm/nocterm.dart';
import 'package:nocterm_riverpod/nocterm_riverpod.dart';
import 'package:riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';

final counterProvider = StateProvider<int>((ref) => 0);

class CounterScreen extends StatelessComponent {
  const CounterScreen({super.key});

  @override
  Component build(BuildContext context) => Column(
    children: [
      RiverpodConsumer<int>(
        provider: counterProvider,
        builder: (context, count) => Container(
          padding: const EdgeInsets.all(1),
          child: Text('Count: $count'),
        ),
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
        child: const Text('[ Press Enter to increment ]'),
      ),
    ],
  );
}

void main() {
  final ProviderContainer container = ProviderContainer();
  runApp(
    Focusable(
      focused: true,
      onKeyEvent: (event) {
        if (event.logicalKey == LogicalKey.enter) {
          container.read(counterProvider.notifier).state++;
          return true;
        }
        if (event.logicalKey == LogicalKey.keyQ) {
          shutdownApp();
          return true;
        }
        return false;
      },
      child: RiverpodScope(
        container: container,
        child: const CounterScreen(),
      ),
    ),
  );
}
