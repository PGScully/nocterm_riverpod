// unsafe_variance: ProviderListenable<StateT> is used in field positions
// where StateT appears in non-covariant contexts. This is inherent to
// how Riverpod's ProviderListenable is designed (invariant in StateT).
// ignore_for_file: unsafe_variance

import 'package:nocterm/nocterm.dart';
import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';

import 'riverpod_scope.dart';

/// A nocterm component that rebuilds only when a selected slice of state
/// changes (by equality), analogous to Flutter's `ref.watch(provider.select(...))`.
///
/// Usage:
/// ```dart
/// RiverpodSelector(
///   provider: appBarViewModelProvider,
///   selector: (state) => state.panelFocus,
///   builder: (context, focus) => StatusBar(isFocused: focus == PanelFocus.main),
/// )
/// ```
class RiverpodSelector<T, R> extends StatefulComponent {
  final ProviderListenable<T> provider;
  final R Function(T value) selector;
  final Component Function(BuildContext context, R value) builder;

  const RiverpodSelector({
    super.key,
    required this.provider,
    required this.selector,
    required this.builder,
  });

  @override
  State<RiverpodSelector<T, R>> createState() => _RiverpodSelectorState<T, R>();
}

class _RiverpodSelectorState<T, R> extends State<RiverpodSelector<T, R>> {
  late ProviderContainer _container;
  ProviderSubscription<T>? _subscription;
  late R _selected;

  @override
  void initState() {
    super.initState();
    _container = RiverpodScope.containerOf(context);
    _selected = component.selector(_container.read(component.provider));
    _subscription = _container.listen(component.provider, (prev, next) {
      final R newSelected = component.selector(next);
      if (newSelected != _selected) {
        setState(() {
          _selected = newSelected;
        });
      }
    });
  }

  @override
  void didUpdateComponent(RiverpodSelector<T, R> oldComponent) {
    super.didUpdateComponent(oldComponent);
    if (oldComponent.provider != component.provider ||
        oldComponent.selector != component.selector) {
      _subscription?.close();
      _selected = component.selector(_container.read(component.provider));
      _subscription = _container.listen(component.provider, (prev, next) {
        final R newSelected = component.selector(next);
        if (newSelected != _selected) {
          setState(() {
            _selected = newSelected;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _subscription?.close();
    super.dispose();
  }

  @override
  Component build(BuildContext context) =>
      component.builder(context, _selected);
}
