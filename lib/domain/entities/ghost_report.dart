class GhostReport {
  final int ghostCount;
  final int totalCount;
  const GhostReport({required this.ghostCount, required this.totalCount});

  bool get hasGhosts => ghostCount > 0;

  factory GhostReport.fromJson(Map<String, dynamic> json) => GhostReport(
        ghostCount: (json['ghost_count'] as num?)?.toInt() ?? 0,
        totalCount: (json['total_count'] as num?)?.toInt() ?? 0,
      );
}
