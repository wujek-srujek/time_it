// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interval_input.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$intervalInputNotifierHash() =>
    r'af2358db0bcb21a8b2a0ba5743bde65e8581bbb7';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$IntervalInputNotifier
    extends BuildlessAutoDisposeNotifier<IntervalDefinition> {
  late final IntervalDefinition? prototype;

  IntervalDefinition build(
    IntervalDefinition? prototype,
  );
}

/// See also [IntervalInputNotifier].
@ProviderFor(IntervalInputNotifier)
const intervalInputNotifierProvider = IntervalInputNotifierFamily();

/// See also [IntervalInputNotifier].
class IntervalInputNotifierFamily extends Family<IntervalDefinition> {
  /// See also [IntervalInputNotifier].
  const IntervalInputNotifierFamily();

  /// See also [IntervalInputNotifier].
  IntervalInputNotifierProvider call(
    IntervalDefinition? prototype,
  ) {
    return IntervalInputNotifierProvider(
      prototype,
    );
  }

  @override
  IntervalInputNotifierProvider getProviderOverride(
    covariant IntervalInputNotifierProvider provider,
  ) {
    return call(
      provider.prototype,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'intervalInputNotifierProvider';
}

/// See also [IntervalInputNotifier].
class IntervalInputNotifierProvider extends AutoDisposeNotifierProviderImpl<
    IntervalInputNotifier, IntervalDefinition> {
  /// See also [IntervalInputNotifier].
  IntervalInputNotifierProvider(
    IntervalDefinition? prototype,
  ) : this._internal(
          () => IntervalInputNotifier()..prototype = prototype,
          from: intervalInputNotifierProvider,
          name: r'intervalInputNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$intervalInputNotifierHash,
          dependencies: IntervalInputNotifierFamily._dependencies,
          allTransitiveDependencies:
              IntervalInputNotifierFamily._allTransitiveDependencies,
          prototype: prototype,
        );

  IntervalInputNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.prototype,
  }) : super.internal();

  final IntervalDefinition? prototype;

  @override
  IntervalDefinition runNotifierBuild(
    covariant IntervalInputNotifier notifier,
  ) {
    return notifier.build(
      prototype,
    );
  }

  @override
  Override overrideWith(IntervalInputNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: IntervalInputNotifierProvider._internal(
        () => create()..prototype = prototype,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        prototype: prototype,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<IntervalInputNotifier, IntervalDefinition>
      createElement() {
    return _IntervalInputNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IntervalInputNotifierProvider &&
        other.prototype == prototype;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, prototype.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin IntervalInputNotifierRef
    on AutoDisposeNotifierProviderRef<IntervalDefinition> {
  /// The parameter `prototype` of this provider.
  IntervalDefinition? get prototype;
}

class _IntervalInputNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<IntervalInputNotifier,
        IntervalDefinition> with IntervalInputNotifierRef {
  _IntervalInputNotifierProviderElement(super.provider);

  @override
  IntervalDefinition? get prototype =>
      (origin as IntervalInputNotifierProvider).prototype;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
