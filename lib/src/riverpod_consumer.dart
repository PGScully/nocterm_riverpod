// unsafe_variance: ProviderListenable<StateT> is used in field positions
// where StateT appears in non-covariant contexts. This is inherent to
// how Riverpod's ProviderListenable is designed (invariant in StateT).
// ignore_for_file: unsafe_variance

import 'package:nocterm/nocterm.dart';
import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';

import 'riverpod_scope.dart';

/// A nocterm component that rebuilds when a [ProviderListenable] emits a new
/// value. Only the subtree wrapped by this component rebuilds — not the entire
/// app.
///
/// Usage:
/// ```dart
/// RiverpodConsumer(
///   provider: tasksPanelViewModelProvider,
///   builder: (context, state) {
///     final vm = context.read(tasksPanelViewModelProvider.notifier);
///     return TasksPanel(state: state, viewModel: vm);
///   },
/// )
/// ```
class RiverpodConsumer<T> extends StatefulComponent {
  final ProviderListenable<T> provider;
  final Component Function(BuildContext context, T value) builder;

  const RiverpodConsumer({
    super.key,
    required this.provider,
    required this.builder,
  });

  @override
  State<RiverpodConsumer<T>> createState() => _RiverpodConsumerState<T>();
}

class _RiverpodConsumerState<T> extends State<RiverpodConsumer<T>> {
  late ProviderContainer _container;
  ProviderSubscription<T>? _subscription;
  late T _value;

  @override
  void initState() {
    super.initState();
    _container = RiverpodScope.containerOf(context);
    _value = _container.read(component.provider);
    _subscription = _container.listen(component.provider, (prev, next) {
      setState(() {
        _value = next;
      });
    });
  }

  @override
  void didUpdateComponent(RiverpodConsumer<T> oldComponent) {
    super.didUpdateComponent(oldComponent);
    if (oldComponent.provider != component.provider) {
      _subscription?.close();
      _value = _container.read(component.provider);
      _subscription = _container.listen(component.provider, (prev, next) {
        setState(() {
          _value = next;
        });
      });
    }
  }

  @override
  void dispose() {
    _subscription?.close();
    super.dispose();
  }

  @override
  Component build(BuildContext context) => component.builder(context, _value);
}
