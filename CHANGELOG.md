## 0.1.0

- Initial release
- `RiverpodScope`: InheritedComponent providing ProviderContainer down the nocterm tree
- `RiverpodConsumer<T>`: rebuilds subtree when a provider emits a new value
- `RiverpodSelector<T, R>`: rebuilds only when a selected slice of state changes
- `RiverpodListener<T>`: side-effect listener without triggering a UI rebuild
- `BuildContext` extensions: `container` and `read<T>()`
