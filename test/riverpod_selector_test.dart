import 'package:nocterm/nocterm.dart';
import 'package:nocterm_riverpod/nocterm_riverpod.dart';
import 'package:riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart' show expect, group, isNot, test;

class _ComplexState {
  final String name;
  final int counter;
  const _ComplexState({required this.name, required this.counter});
}

final selectorStateProvider = StateProvider<_ComplexState>(
  (ref) => const _ComplexState(name: 'foo', counter: 0),
);

void main() {
  group('RiverpodSelector', () {
    test('renders selected initial value', () async {
      final ProviderContainer container = ProviderContainer();
      container.read(selectorStateProvider.notifier).state =
          const _ComplexState(name: 'hello', counter: 42);
      final NoctermTester tester = await NoctermTester.create();
      try {
        await tester.pumpComponent(
          RiverpodScope(
            container: container,
            child: RiverpodSelector<_ComplexState, String>(
              provider: selectorStateProvider,
              selector: (state) => state.name,
              builder: (context, name) => Text(name),
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

    test('rebuilds when selected slice changes', () async {
      final ProviderContainer container = ProviderContainer();
      container.read(selectorStateProvider.notifier).state =
          const _ComplexState(name: 'before', counter: 0);
      final NoctermTester tester = await NoctermTester.create();
      try {
        await tester.pumpComponent(
          RiverpodScope(
            container: container,
            child: RiverpodSelector<_ComplexState, String>(
              provider: selectorStateProvider,
              selector: (state) => state.name,
              builder: (context, name) => Text(name),
            ),
          ),
        );
        await tester.pump();

        container.read(selectorStateProvider.notifier).state =
            const _ComplexState(name: 'after', counter: 0);
        await tester.pump();

        expect(tester.terminalState, containsText('after'));
      } finally {
        container.dispose();
        tester.dispose();
      }
    });

    test('does not rebuild when unrelated field changes', () async {
      final ProviderContainer container = ProviderContainer();
      container.read(selectorStateProvider.notifier).state =
          const _ComplexState(name: 'stable', counter: 1);
      final NoctermTester tester = await NoctermTester.create();
      try {
        await tester.pumpComponent(
          RiverpodScope(
            container: container,
            child: RiverpodSelector<_ComplexState, String>(
              provider: selectorStateProvider,
              selector: (state) => state.name,
              builder: (context, name) => Text(name),
            ),
          ),
        );
        await tester.pump();
        expect(tester.terminalState, containsText('stable'));

        container.read(selectorStateProvider.notifier).state =
            const _ComplexState(name: 'stable', counter: 999);
        await tester.pump();

        expect(tester.terminalState, containsText('stable'));
        expect(tester.terminalState, isNot(containsText('999')));
      } finally {
        container.dispose();
        tester.dispose();
      }
    });

    test('re-selects when selector function changes', () async {
      final ProviderContainer container = ProviderContainer();
      container.read(selectorStateProvider.notifier).state =
          const _ComplexState(name: 'name', counter: 7);
      final NoctermTester tester = await NoctermTester.create();
      try {
        await tester.pumpComponent(
          RiverpodScope(
            container: container,
            child: RiverpodSelector<_ComplexState, String>(
              provider: selectorStateProvider,
              selector: (state) => state.name,
              builder: (context, value) => Text(value),
            ),
          ),
        );
        await tester.pump();
        expect(tester.terminalState, containsText('name'));

        await tester.pumpComponent(
          RiverpodScope(
            container: container,
            child: RiverpodSelector<_ComplexState, String>(
              provider: selectorStateProvider,
              selector: (state) => '${state.counter}',
              builder: (context, value) => Text(value),
            ),
          ),
        );
        await tester.pump();
        expect(tester.terminalState, containsText('7'));
      } finally {
        container.dispose();
        tester.dispose();
      }
    });
  });
}
