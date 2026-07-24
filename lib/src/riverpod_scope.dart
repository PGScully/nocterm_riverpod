import 'package:nocterm/nocterm.dart';
import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';

/// Provides a [ProviderContainer] to descendant nocterm components via
/// [InheritedComponent], analogous to Flutter's `ProviderScope`.
///
/// Wrap the root of your nocterm app with this to enable [RiverpodConsumer],
/// [RiverpodSelector], and [RiverpodListener] in descendant components.
///
/// The caller is responsible for creating and disposing the [ProviderContainer].
/// This component does NOT dispose the container when removed from the tree.
class RiverpodScope extends InheritedComponent {
  final ProviderContainer container;

  const RiverpodScope({
    super.key,
    required super.child,
    required this.container,
  });

  /// Returns the [ProviderContainer] from the nearest ancestor [RiverpodScope].
  static ProviderContainer containerOf(BuildContext context) {
    final RiverpodScope? scope = context
        .dependOnInheritedComponentOfExactType<RiverpodScope>();
    assert(scope != null, 'No RiverpodScope found in context');
    return scope!.container;
  }

  @override
  bool updateShouldNotify(RiverpodScope oldComponent) => false;
}

/// BuildContext extensions for convenient access to the Riverpod scope.
extension RiverpodBuildContextX on BuildContext {
  /// Returns the [ProviderContainer] from the nearest ancestor [RiverpodScope].
  ProviderContainer get container => RiverpodScope.containerOf(this);

  /// Reads a provider value without subscribing for rebuilds.
  T read<T>(ProviderListenable<T> provider) => container.read(provider);
}
