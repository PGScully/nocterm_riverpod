import 'package:nocterm/nocterm.dart';
import 'package:nocterm_riverpod/nocterm_riverpod.dart';
import 'package:riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart' show expect, group, isNotNull, test;

final scopeTestCounterProvider = StateProvider<int>((ref) => 0);

void main() {
  group('RiverpodScope', () {
    test('containerOf returns the container', () async {
      final ProviderContainer container = ProviderContainer();
      final NoctermTester tester = await NoctermTester.create();
      try {
        await tester.pumpComponent(
          RiverpodScope(
            container: container,
            child: Builder(
              builder: (context) {
                final ProviderContainer resolved = RiverpodScope.containerOf(
                  context,
                );
                expect(resolved, isNotNull);
                return Container();
              },
            ),
          ),
        );
        await tester.pump();
      } finally {
        container.dispose();
        tester.dispose();
      }
    });

    test('context.container returns the container', () async {
      final ProviderContainer container = ProviderContainer();
      final NoctermTester tester = await NoctermTester.create();
      try {
        await tester.pumpComponent(
          RiverpodScope(
            container: container,
            child: Builder(
              builder: (context) {
                final ProviderContainer resolved = context.container;
                expect(resolved, isNotNull);
                return Container();
              },
            ),
          ),
        );
        await tester.pump();
      } finally {
        container.dispose();
        tester.dispose();
      }
    });

    test('context.read reads provider value', () async {
      final ProviderContainer container = ProviderContainer();
      container.read(scopeTestCounterProvider.notifier).state = 42;
      final NoctermTester tester = await NoctermTester.create();
      try {
        await tester.pumpComponent(
          RiverpodScope(
            container: container,
            child: Builder(
              builder: (context) {
                final int value = context.read(scopeTestCounterProvider);
                expect(value, 42);
                return Container();
              },
            ),
          ),
        );
        await tester.pump();
      } finally {
        container.dispose();
        tester.dispose();
      }
    });
  });
}
