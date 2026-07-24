// unsafe_variance: ProviderListenable<StateT> is used in field positions
// where StateT appears in non-covariant contexts. This is inherent to
// how Riverpod's ProviderListenable is designed (invariant in StateT).
// ignore_for_file: unsafe_variance

import 'package:nocterm/nocterm.dart';
import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';

import 'riverpod_scope.dart';

/// A nocterm component that listens for provider changes for side effects
/// without triggering a UI rebuild. Analogous to Flutter's `ref.listen()`.
///
/// The listener callback fires on every change including the initial value.
/// Use [listenWhen] to filter.
///
/// Usage:
/// ```dart
/// RiverpodListener(
///   provider: statusMessageProvider,
///   listener: (context, previous, message) {
///     if (message != null) log(message);
///   },
///   child: MyPanel(),
/// )
/// ```
class RiverpodListener<T> extends StatefulComponent {
  final ProviderListenable<T> provider;
  final void Function(BuildContext context, T? previous, T next) listener;
  final Component child;
  final bool Function(T? previous, T next)? listenWhen;

  const RiverpodListener({
    super.key,
    required this.provider,
    required this.listener,
    required this.child,
    this.listenWhen,
  });

  @override
  State<RiverpodListener<T>> createState() => _RiverpodListenerState<T>();
}

class _RiverpodListenerState<T> extends State<RiverpodListener<T>> {
  late ProviderContainer _container;
  ProviderSubscription<T>? _subscription;

  @override
  void initState() {
    super.initState();
    _container = RiverpodScope.containerOf(context);
    _subscription = _container.listen(component.provider, (prev, next) {
      if (component.listenWhen != null && !component.listenWhen!(prev, next)) {
        return;
      }
      component.listener(context, prev, next);
    });
  }

  @override
  void didUpdateComponent(RiverpodListener<T> oldComponent) {
    super.didUpdateComponent(oldComponent);
    if (oldComponent.provider != component.provider) {
      _subscription?.close();
      _subscription = _container.listen(component.provider, (prev, next) {
        if (component.listenWhen != null &&
            !component.listenWhen!(prev, next)) {
          return;
        }
        component.listener(context, prev, next);
      });
    }
  }

  @override
  void dispose() {
    _subscription?.close();
    super.dispose();
  }

  @override
  Component build(BuildContext context) => component.child;
}
