// File: lib/data/datasources/base_repository.dart
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Base Repository để giao tiếp với Supabase
/// Có thể tái sử dụng cho nhiều bảng khác nhau
class BaseTableDataSource {
  final SupabaseClient _client;
  final String tableName;

  BaseTableDataSource(this._client, this.tableName);

  /// 1. SELECT: Lấy tất cả dữ liệu hoặc theo bộ lọc
  Future<List<Map<String, dynamic>>> getAll({
    String? column,
    dynamic value,
    String? orderBy,
    bool ascending = true,
  }) async {
    try {
      dynamic query = _client.from(tableName).select();

      // Áp dụng filter trước, sau đó mới order
      if (column != null && value != null) {
        query = query.eq(column, value);
      }

      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      throw Exception(
        'Lỗi Database tại $tableName.getAll(): '
        '\n- Code: ${e.code}'
        '\n- Message: ${e.message}'
        '\n- Details: ${e.details}'
        '\n- Hint: ${e.hint}',
      );
    } catch (e) {
      throw Exception('Lỗi không xác định tại $tableName.getAll(): $e');
    }
  }

  /// 2. SELECT BY ID: Lấy một bản ghi theo ID
  Future<Map<String, dynamic>?> getById(String id) async {
    try {
      final response = await _client
          .from(tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      return response;
    } on PostgrestException catch (e) {
      throw Exception(
        'Lỗi Database tại $tableName.getById($id): '
        '\n- Code: ${e.code}'
        '\n- Message: ${e.message}'
        '\n- Details: ${e.details}'
        '\n- Hint: ${e.hint}',
      );
    } catch (e) {
      throw Exception('Lỗi không xác định tại $tableName.getById($id): $e');
    }
  }

  /// 3. INSERT: Thêm mới một dòng dữ liệu
  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from(tableName)
          .insert(data)
          .select()
          .single();

      return response;
    } on PostgrestException catch (e) {
      String userFriendlyMessage = _getUserFriendlyError(e, 'INSERT');

      throw Exception(
        'Lỗi Database tại $tableName.insert(): '
        '\n- Lỗi: $userFriendlyMessage'
        '\n- Code: ${e.code}'
        '\n- Message: ${e.message}'
        '\n- Details: ${e.details}'
        '\n- Hint: ${e.hint}',
      );
    } catch (e) {
      throw Exception('Lỗi không xác định tại $tableName.insert(): $e');
    }
  }

  /// 4. INSERT MANY: Thêm nhiều dòng dữ liệu
  /// QUAN TRỌNG: Supabase sử dụng TRANSACTION tự động
  /// - Nếu 1 dòng lỗi => TẤT CẢ đều ROLLBACK (không thay đổi gì)
  Future<List<Map<String, dynamic>>> insertMany(
    List<Map<String, dynamic>> dataList,
  ) async {
    try {
      final response = await _client.from(tableName).insert(dataList).select();

      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      String userFriendlyMessage = _getUserFriendlyError(e, 'INSERT');

      throw Exception(
        'Lỗi Database tại $tableName.insertMany(): '
        '\n- Lỗi: $userFriendlyMessage'
        '\n- Code: ${e.code}'
        '\n- Message: ${e.message}'
        '\n- Details: ${e.details}'
        '\n- Hint: ${e.hint}'
        '\n⚠️ KHÔNG CÓ dòng nào được thêm (Transaction rollback)',
      );
    } catch (e) {
      throw Exception('Lỗi không xác định tại $tableName.insertMany(): $e');
    }
  }

  /// 4b. INSERT MANY SAFE: Thêm từng dòng riêng lẻ
  Future<Map<String, dynamic>> insertManySafe(
    List<Map<String, dynamic>> dataList,
  ) async {
    final List<Map<String, dynamic>> successList = [];
    final List<Map<String, dynamic>> failedList = [];

    for (int i = 0; i < dataList.length; i++) {
      try {
        final result = await _client
            .from(tableName)
            .insert(dataList[i])
            .select()
            .single();

        successList.add(result);
      } on PostgrestException catch (e) {
        String userFriendlyMessage = _getUserFriendlyError(e, 'INSERT');

        failedList.add({
          'index': i,
          'data': dataList[i],
          'error': userFriendlyMessage,
          'errorCode': e.code,
          'errorDetails': e.details,
          'errorHint': e.hint,
        });
      } catch (e) {
        failedList.add({
          'index': i,
          'data': dataList[i],
          'error': 'Lỗi không xác định: $e',
        });
      }
    }

    return {
      'success': successList,
      'failed': failedList,
      'total': dataList.length,
      'successCount': successList.length,
      'failedCount': failedList.length,
    };
  }

  /// 5. UPDATE: Cập nhật dữ liệu theo ID
  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client
          .from(tableName)
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return response;
    } on PostgrestException catch (e) {
      String userFriendlyMessage = _getUserFriendlyError(e, 'UPDATE');

      throw Exception(
        'Lỗi Database tại $tableName.update($id): '
        '\n- Lỗi: $userFriendlyMessage'
        '\n- Code: ${e.code}'
        '\n- Message: ${e.message}'
        '\n- Details: ${e.details}'
        '\n- Hint: ${e.hint}',
      );
    } catch (e) {
      throw Exception('Lỗi không xác định tại $tableName.update($id): $e');
    }
  }

  /// 6. UPDATE WITH CONDITION: Cập nhật theo điều kiện
  Future<List<Map<String, dynamic>>> updateWhere({
    required String column,
    required dynamic value,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _client
          .from(tableName)
          .update(data)
          .eq(column, value)
          .select();

      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      String userFriendlyMessage = _getUserFriendlyError(e, 'UPDATE');

      throw Exception(
        'Lỗi Database tại $tableName.updateWhere($column=$value): '
        '\n- Lỗi: $userFriendlyMessage'
        '\n- Code: ${e.code}'
        '\n- Message: ${e.message}'
        '\n- Details: ${e.details}'
        '\n- Hint: ${e.hint}',
      );
    } catch (e) {
      throw Exception('Lỗi không xác định tại $tableName.updateWhere(): $e');
    }
  }

  /// 6b. UPDATE MANY BY IDS: Cập nhật nhiều dòng theo danh sách ID
  Future<List<Map<String, dynamic>>> updateManyByIds({
    required List<String> ids,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _client
          .from(tableName)
          .update(data)
          .inFilter('id', ids)
          .select();

      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      String userFriendlyMessage = _getUserFriendlyError(e, 'UPDATE');

      throw Exception(
        'Lỗi Database tại $tableName.updateManyByIds(): '
        '\n- Lỗi: $userFriendlyMessage'
        '\n- Code: ${e.code}'
        '\n- Message: ${e.message}'
        '\n- Details: ${e.details}'
        '\n- Hint: ${e.hint}'
        '\n⚠️ KHÔNG CÓ dòng nào được cập nhật (Transaction rollback)',
      );
    } catch (e) {
      throw Exception(
        'Lỗi không xác định tại $tableName.updateManyByIds(): $e',
      );
    }
  }

  /// 6c. UPDATE MANY SAFE: Cập nhật từng dòng riêng lẻ
  Future<Map<String, dynamic>> updateManySafe(
    List<Map<String, dynamic>> updateList,
  ) async {
    final List<Map<String, dynamic>> successList = [];
    final List<Map<String, dynamic>> failedList = [];

    for (int i = 0; i < updateList.length; i++) {
      try {
        final id = updateList[i]['id'] as String;
        final data = updateList[i]['data'] as Map<String, dynamic>;

        final result = await _client
            .from(tableName)
            .update(data)
            .eq('id', id)
            .select()
            .single();

        successList.add(result);
      } on PostgrestException catch (e) {
        String userFriendlyMessage = _getUserFriendlyError(e, 'UPDATE');

        failedList.add({
          'index': i,
          'id': updateList[i]['id'],
          'data': updateList[i]['data'],
          'error': userFriendlyMessage,
          'errorCode': e.code,
          'errorDetails': e.details,
          'errorHint': e.hint,
        });
      } catch (e) {
        failedList.add({
          'index': i,
          'id': updateList[i]['id'],
          'data': updateList[i]['data'],
          'error': 'Lỗi không xác định: $e',
        });
      }
    }

    return {
      'success': successList,
      'failed': failedList,
      'total': updateList.length,
      'successCount': successList.length,
      'failedCount': failedList.length,
    };
  }

  /// 7. DELETE: Xóa dữ liệu theo ID
  Future<void> delete(String id) async {
    try {
      AppLogger.debug('🟢 [DATASOURCE] delete: Bắt đầu xóa $tableName với id=$id');
      AppLogger.debug('🟢 [DATASOURCE] delete: Table: $tableName');
      AppLogger.debug('🟢 [DATASOURCE] delete: ID: $id');

      // Kiểm tra authentication trước
      final user = _client.auth.currentUser;
      if (user == null) {
        AppLogger.warning('⚠️ [DATASOURCE] delete: User chưa đăng nhập!');
        throw Exception('Bạn cần đăng nhập để thực hiện thao tác này');
      }
      AppLogger.debug('🟢 [DATASOURCE] delete: User ID: ${user.id}');

      // Thực hiện delete và verify bằng cách select
      AppLogger.debug('🟢 [DATASOURCE] delete: Gửi DELETE request đến Supabase...');
      final response = await _client
          .from(tableName)
          .delete()
          .eq('id', id)
          .select();

      AppLogger.debug('🟢 [DATASOURCE] delete: Response từ Supabase: $response');
      AppLogger.debug('🟢 [DATASOURCE] delete: Response type: ${response.runtimeType}');

      // Kiểm tra xem có dòng nào bị xóa không
      final responseList = response as List;
      if (responseList.isEmpty) {
        AppLogger.warning(
          '⚠️ [DATASOURCE] delete: Không có dòng nào bị xóa. Có thể:',
        );
        AppLogger.warning('   - ID không tồn tại trong database');
        AppLogger.warning('   - Không có quyền DELETE (RLS policies)');
        AppLogger.warning('   - User không phải là owner của record');
        throw Exception(
          'Không thể xóa dữ liệu. Có thể bạn không có quyền hoặc dữ liệu không tồn tại.',
        );
      } else {
        AppLogger.info(
          '✅ [DATASOURCE] delete: Đã xóa ${responseList.length} dòng thành công',
        );
        AppLogger.debug('✅ [DATASOURCE] delete: Dữ liệu đã xóa: ${responseList.first}');
      }

      AppLogger.info('✅ [DATASOURCE] delete: Hoàn tất xóa $tableName với id=$id');
    } on PostgrestException catch (e) {
      String userFriendlyMessage = _getUserFriendlyError(e, 'DELETE');

      AppLogger.error('🔴 [DATASOURCE ERROR] delete: PostgrestException', error: e);
      AppLogger.error('   Code: ${e.code}');
      AppLogger.error('   Message: ${e.message}');
      AppLogger.error('   Details: ${e.details}');
      AppLogger.error('   Hint: ${e.hint}');
      AppLogger.error('   Table: $tableName');
      AppLogger.error('   ID: $id');

      // Log thêm thông tin về loại lỗi
      if (e.code == '42501') {
        AppLogger.warning('⚠️ [DATASOURCE ERROR] delete: Lỗi permission - RLS policy chặn DELETE');
      } else if (e.code == 'PGRST116') {
        AppLogger.warning('⚠️ [DATASOURCE ERROR] delete: Không tìm thấy dữ liệu');
      } else if (e.code == '23503') {
        AppLogger.warning('⚠️ [DATASOURCE ERROR] delete: Lỗi foreign key constraint');
      }

      throw Exception(
        'Lỗi Database tại $tableName.delete($id): '
        '\n- Lỗi: $userFriendlyMessage'
        '\n- Code: ${e.code}'
        '\n- Message: ${e.message}'
        '\n- Details: ${e.details}'
        '\n- Hint: ${e.hint}',
      );
    } catch (e, stackTrace) {
      AppLogger.error('🔴 [DATASOURCE ERROR] delete: Lỗi không xác định: $e', error: e, stackTrace: stackTrace);
      AppLogger.error('🔴 [DATASOURCE ERROR] delete: Table: $tableName, ID: $id');
      throw Exception('Lỗi không xác định tại $tableName.delete($id): $e');
    }
  }

  /// 8. DELETE WITH CONDITION: Xóa theo điều kiện
  Future<void> deleteWhere(String column, dynamic value) async {
    try {
      await _client.from(tableName).delete().eq(column, value);
    } on PostgrestException catch (e) {
      String userFriendlyMessage = _getUserFriendlyError(e, 'DELETE');

      throw Exception(
        'Lỗi Database tại $tableName.deleteWhere($column=$value): '
        '\n- Lỗi: $userFriendlyMessage'
        '\n- Code: ${e.code}'
        '\n- Message: ${e.message}'
        '\n- Details: ${e.details}'
        '\n- Hint: ${e.hint}',
      );
    } catch (e) {
      throw Exception('Lỗi không xác định tại $tableName.deleteWhere(): $e');
    }
  }

  /// 8b. DELETE MANY BY IDS: Xóa nhiều dòng theo danh sách ID
  Future<void> deleteManyByIds(List<String> ids) async {
    try {
      for (var id in ids) {
        await _client.from(tableName).delete().eq('id', id);
      }
    } on PostgrestException catch (e) {
      String userFriendlyMessage = _getUserFriendlyError(e, 'DELETE');

      throw Exception(
        'Lỗi Database tại $tableName.deleteManyByIds(): '
        '\n- Lỗi: $userFriendlyMessage'
        '\n- Code: ${e.code}'
        '\n- Message: ${e.message}'
        '\n- Details: ${e.details}'
        '\n- Hint: ${e.hint}'
        '\n⚠️ KHÔNG CÓ dòng nào bị xóa (Transaction rollback)',
      );
    } catch (e) {
      throw Exception(
        'Lỗi không xác định tại $tableName.deleteManyByIds(): $e',
      );
    }
  }

  /// 8c. DELETE MANY SAFE: Xóa từng dòng riêng lẻ
  Future<Map<String, dynamic>> deleteManySafe(List<String> ids) async {
    final List<String> successList = [];
    final List<Map<String, dynamic>> failedList = [];

    for (int i = 0; i < ids.length; i++) {
      try {
        await _client.from(tableName).delete().eq('id', ids[i]);
        successList.add(ids[i]);
      } on PostgrestException catch (e) {
        String userFriendlyMessage = _getUserFriendlyError(e, 'DELETE');

        failedList.add({
          'index': i,
          'id': ids[i],
          'error': userFriendlyMessage,
          'errorCode': e.code,
          'errorDetails': e.details,
          'errorHint': e.hint,
        });
      } catch (e) {
        failedList.add({
          'index': i,
          'id': ids[i],
          'error': 'Lỗi không xác định: $e',
        });
      }
    }

    return {
      'success': successList,
      'failed': failedList,
      'total': ids.length,
      'successCount': successList.length,
      'failedCount': failedList.length,
    };
  }

  /// 9. COUNT: Đếm số lượng bản ghi
  Future<int> count({String? column, dynamic value}) async {
    try {
      var query = _client.from(tableName).select();

      if (column != null && value != null) {
        query = query.eq(column, value) as dynamic;
      }

      final response = await (query as dynamic);
      // Nếu response là list, sử dụng length
      return (response is List) ? response.length : 0;
    } on PostgrestException catch (e) {
      throw Exception(
        'Lỗi Database tại $tableName.count(): '
        '\n- Code: ${e.code}'
        '\n- Message: ${e.message}'
        '\n- Details: ${e.details}'
        '\n- Hint: ${e.hint}',
      );
    } catch (e) {
      throw Exception('Lỗi không xác định tại $tableName.count(): $e');
    }
  }

  /// 10. SEARCH: Tìm kiếm văn bản
  Future<List<Map<String, dynamic>>> search({
    required String column,
    required String keyword,
  }) async {
    try {
      final response = await _client
          .from(tableName)
          .select()
          .ilike(column, '%$keyword%');

      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      throw Exception(
        'Lỗi Database tại $tableName.search($column="$keyword"): '
        '\n- Code: ${e.code}'
        '\n- Message: ${e.message}'
        '\n- Details: ${e.details}'
        '\n- Hint: ${e.hint}',
      );
    } catch (e) {
      throw Exception('Lỗi không xác định tại $tableName.search(): $e');
    }
  }

  /// 11. PAGINATION: Phân trang
  Future<List<Map<String, dynamic>>> getPaginated({
    required int page,
    required int pageSize,
    String? orderBy,
    bool ascending = true,
  }) async {
    try {
      final from = (page - 1) * pageSize;
      final to = from + pageSize - 1;

      var query = _client.from(tableName).select();

      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending) as dynamic;
      }

      final response = await (query as dynamic).range(from, to);
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      throw Exception(
        'Lỗi Database tại $tableName.getPaginated(page=$page): '
        '\n- Code: ${e.code}'
        '\n- Message: ${e.message}'
        '\n- Details: ${e.details}'
        '\n- Hint: ${e.hint}',
      );
    } catch (e) {
      throw Exception('Lỗi không xác định tại $tableName.getPaginated(): $e');
    }
  }

  /// 12. REALTIME SUBSCRIPTION: Lắng nghe thay đổi dữ liệu
  RealtimeChannel subscribeToChanges({
    String? filter,
    dynamic filterValue,
    required Function(PostgresChangePayload payload) onInsert,
    required Function(PostgresChangePayload payload) onUpdate,
    required Function(PostgresChangePayload payload) onDelete,
  }) {
    try {
      var channel = _client.channel('$tableName-changes');

      var subscription = channel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: tableName,
        filter: filter != null && filterValue != null
            ? PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: filter,
                value: filterValue,
              )
            : null,
        callback: (payload) {
          // payload.eventType là PostgresChangeEvent.
          // Không so sánh với String để tránh unrelated_type_equality_checks.
          switch (payload.eventType) {
            case PostgresChangeEvent.insert:
              onInsert(payload);
              break;
            case PostgresChangeEvent.update:
              onUpdate(payload);
              break;
            case PostgresChangeEvent.delete:
              onDelete(payload);
              break;
            case PostgresChangeEvent.all:
              // eventType = all thường không được gửi trong payload, nhưng thêm cho exhaustiveness.
              break;
          }
        },
      );

      subscription.subscribe();
      return channel;
    } catch (e) {
      throw Exception('Lỗi khi đăng ký realtime cho $tableName: $e');
    }
  }

  /// 13. HỦY REALTIME SUBSCRIPTION
  Future<void> unsubscribe(RealtimeChannel channel) async {
    try {
      await _client.removeChannel(channel);
    } catch (e) {
      throw Exception('Lỗi khi hủy subscription: $e');
    }
  }

  /// HÀM HỖ TRỢ: Chuyển đổi lỗi PostgreSQL sang thông báo dễ hiểu
  String _getUserFriendlyError(PostgrestException e, String operation) {
    switch (e.code) {
      case '23505':
        return 'Dữ liệu bị trùng lặp. Giá trị này đã tồn tại trong hệ thống.';
      case '23503':
        return 'Vi phạm ràng buộc khóa ngoại. Dữ liệu liên quan không tồn tại.';
      case '23502':
        return 'Thiếu dữ liệu bắt buộc. Vui lòng điền đầy đủ thông tin.';
      case '23514':
        return 'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại giá trị nhập vào.';
      case '42501':
        return 'Không có quyền thực hiện thao tác này.';
      case '42P01':
        return 'Bảng dữ liệu không tồn tại.';
      case '42703':
        return 'Cột dữ liệu không tồn tại.';
      case '22P02':
        return 'Định dạng dữ liệu không đúng.';
      case 'PGRST116':
        return 'Không tìm thấy dữ liệu.';
      case 'PGRST301':
        return 'Truy vấn không rõ ràng.';
      default:
        return e.message;
    }
  }
}
