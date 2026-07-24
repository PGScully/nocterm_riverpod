import 'package:nocterm/nocterm.dart';
import 'package:nocterm_riverpod/nocterm_riverpod.dart';
import 'package:riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart' show expect, group, isNot, test;

final consumerCounterProvider = StateProvider<int>((ref) => 0);
final consumerLabelProvider = StateProvider<String>((ref) => 'initial');

void main() {
  group('RiverpodConsumer', () {
    test('renders initial provider value', () async {
      final ProviderContainer container = ProviderContainer();
      container.read(consumerLabelProvider.notifier).state = 'hello';
      final NoctermTester tester = await NoctermTester.create();
      try {
        await tester.pumpComponent(
          RiverpodScope(
            container: container,
            child: RiverpodConsumer<String>(
              provider: consumerLabelProvider,
              builder: (context, value) => Text(value),
            ),
          ),
        );
        await tester.pump();
        expect(tester.terminalState, containsText('hello'));
      } finally {
        container.dispose();
        tester.dispose();
      }
    });

    test('rebuilds when provider emits new value', () async {
      final ProviderContainer container = ProviderContainer();
      container.read(consumerLabelProvider.notifier).state = 'before';
      final NoctermTester tester = await NoctermTester.create();
      try {
        await tester.pumpComponent(
          RiverpodScope(
            container: container,
            child: RiverpodConsumer<String>(
              provider: consumerLabelProvider,
              builder: (context, value) => Text(value),
            ),
          ),
        );
        await tester.pump();

        container.read(consumerLabelProvider.notifier).state = 'after';
        await tester.pump();

        expect(tester.terminalState, containsText('after'));
      } finally {
        container.dispose();
        tester.dispose();
      }
    });

    test('rebuilds when counter provider changes', () async {
      final ProviderContainer container = ProviderContainer();
      container.read(consumerCounterProvider.notifier).state = 1;
      final NoctermTester tester = await NoctermTester.create();
      try {
        await tester.pumpComponent(
          RiverpodScope(
            container: container,
            child: RiverpodConsumer<int>(
              provider: consumerCounterProvider,
              builder: (context, value) => Text('$value'),
            ),
          ),
        );
        await tester.pump();

        container.read(consumerCounterProvider.notifier).state = 2;
        await tester.pump();

        expect(tester.terminalState, containsText('2'));
        expect(tester.terminalState, isNot(containsText('1')));
      } finally {
        container.dispose();
        tester.dispose();
      }
    });

    test('switches subscription when provider changes', () async {
      final ProviderContainer container = ProviderContainer();
      container.read(consumerLabelProvider.notifier).state = 'a';
      final NoctermTester tester = await NoctermTester.create();
      try {
        await tester.pumpComponent(
          RiverpodScope(
            container: container,
            child: RiverpodConsumer<String>(
              provider: consumerLabelProvider,
              builder: (context, value) => Text(value),
            ),
          ),
        );
        await tester.pump();
        expect(tester.terminalState, containsText('a'));

        final int counterValue = container.read(consumerCounterProvider);
        await tester.pumpComponent(
          RiverpodScope(
            container: container,
            child: RiverpodConsumer<int>(
              provider: consumerCounterProvider,
              builder: (context, value) => Text('$value'),
            ),
          ),
        );
        await tester.pump();
        expect(tester.terminalState, containsText('$counterValue'));
      } finally {
        container.dispose();
        tester.dispose();
      }
    });
  });
}
