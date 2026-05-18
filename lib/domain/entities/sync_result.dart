class SyncResult {
  final int created;
  final int linked;
  final int total;
  const SyncResult({
    required this.created,
    required this.linked,
    required this.total,
  });

  factory SyncResult.fromJson(Map<String, dynamic> json) => SyncResult(
        created: (json['created'] as num?)?.toInt() ?? 0,
        linked: (json['linked'] as num?)?.toInt() ?? 0,
        total: (json['total'] as num?)?.toInt() ?? 0,
      );
}
