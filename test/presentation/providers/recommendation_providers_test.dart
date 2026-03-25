import 'package:flutter_test/flutter_test.dart';
import 'package:ai_mls/presentation/providers/recommendation_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Stub test - actual implementation requires Supabase mock
void main() {
  group('RecommendationProviders', () {
    test('recommendationDatasourceProvider can be created', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final ds = container.read(recommendationDatasourceProvider);
      expect(ds, isNotNull);
    });

    test('recommendationRepositoryProvider can be created', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repo = container.read(recommendationRepositoryProvider);
      expect(repo, isNotNull);
    });
  });
}
