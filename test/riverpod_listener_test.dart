import 'package:nocterm/nocterm.dart';
import 'package:nocterm_riverpod/nocterm_riverpod.dart';
import 'package:riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart' show expect, group, isTrue, test;

final listenerCounterProvider = StateProvider<int>((ref) => 0);

int _buildCounter = 0;

class _CountingChild extends StatelessComponent {
  const _CountingChild();
  @override
  Component build(BuildContext context) {
    _buildCounter++;
    return Container();
  }
}

void main() {
  group('RiverpodListener', () {
    test('fires listener on provider change', () async {
      final ProviderContainer container = ProviderContainer();
      final List<(int?, int)> calls = <(int?, int)>[];
      final NoctermTester tester = await NoctermTester.create();
      try {
        await tester.pumpComponent(
          RiverpodScope(
            container: container,
            child: RiverpodListener<int>(
              provider: listenerCounterProvider,
              listener: (context, previous, next) {
                calls.add((previous, next));
              },
              child: const _CountingChild(),
            ),
          ),
        );
        await tester.pump();

        container.read(listenerCounterProvider.notifier).state = 1;
        await tester.pump();

        expect(calls.isNotEmpty, isTrue);
      } finally {
        container.dispose();
        tester.dispose();
      }
    });

    test('does not rebuild child when listener fires', () async {
      final ProviderContainer container = ProviderContainer();
      _buildCounter = 0;
      final NoctermTester tester = await NoctermTester.create();
      try {
        await tester.pumpComponent(
          RiverpodScope(
            container: container,
            child: RiverpodListener<int>(
              provider: listenerCounterProvider,
              listener: (context, previous, next) {},
              child: const _CountingChild(),
            ),
          ),
        );
        await tester.pump();
        final int initialBuilds = _buildCounter;

        container.read(listenerCounterProvider.notifier).state = 42;
        await tester.pump();

        expect(_buildCounter, initialBuilds);
      } finally {
        container.dispose();
        tester.dispose();
      }
    });

    test('listener receives previous and current values', () async {
      final ProviderContainer container = ProviderContainer();
      container.read(listenerCounterProvider.notifier).state = 10;
      (int?, int)? lastCall;
      final NoctermTester tester = await NoctermTester.create();
      try {
        await tester.pumpComponent(
          RiverpodScope(
            container: container,
            child: RiverpodListener<int>(
              provider: listenerCounterProvider,
              listener: (context, previous, next) {
                lastCall = (previous, next);
              },
              child: Container(),
            ),
          ),
        );
        await tester.pump();

        container.read(listenerCounterProvider.notifier).state = 20;
        await tester.pump();

        expect(lastCall?.$1, 10);
        expect(lastCall?.$2, 20);
      } finally {
        container.dispose();
        tester.dispose();
      }
    });

    test('listenWhen true fires, false skips', () async {
      final ProviderContainer container = ProviderContainer();
      container.read(listenerCounterProvider.notifier).state = 0;
      final List<int> calls = <int>[];
      final NoctermTester tester = await NoctermTester.create();
      try {
        await tester.pumpComponent(
          RiverpodScope(
            container: container,
            child: RiverpodListener<int>(
              provider: listenerCounterProvider,
              listenWhen: (previous, next) => next.isEven,
              listener: (context, previous, next) {
                calls.add(next);
              },
              child: Container(),
            ),
          ),
        );
        await tester.pump();

        container.read(listenerCounterProvider.notifier).state = 1;
        await tester.pump();

        container.read(listenerCounterProvider.notifier).state = 2;
        await tester.pump();

        expect(calls.length, 1);
        expect(calls.first, 2);
      } finally {
        container.dispose();
        tester.dispose();
      }
    });
  });
}
