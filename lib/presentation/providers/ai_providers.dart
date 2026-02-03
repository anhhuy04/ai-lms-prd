import 'package:ai_mls/data/datasources/ai_datasource.dart';
import 'package:ai_mls/data/repositories/ai_repository_impl.dart';
import 'package:ai_mls/domain/repositories/ai_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_providers.g.dart';

/// Provider cho AiDataSource
@riverpod
AiDataSource aiDataSource(Ref ref) {
  return AiDataSource();
}

/// Provider cho AiRepository
@riverpod
AiRepository aiRepository(Ref ref) {
  final dataSource = ref.watch(aiDataSourceProvider);
  return AiRepositoryImpl(dataSource);
}
