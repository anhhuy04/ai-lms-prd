import 'package:ai_mls/core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/analytics/student_analytics.dart';
import '../../domain/entities/analytics/skill_mastery.dart';
import '../../domain/entities/analytics/grade_trend.dart';
import '../../domain/entities/analytics/class_analytics.dart';

/// DataSource for analytics queries from Supabase
class AnalyticsDatasource {
  SupabaseClient get _client => SupabaseService.client;

  /// Query 1: Basic & Engagement Metrics (ANL-01)
  Future<BasicEngagementMetrics> getBasicMetrics(String studentId) async {
    final submissions = await _client
        .from('submissions')
        .select('total_score, is_late, submitted_at')
        .eq('student_id', studentId)
        .order('submitted_at', ascending: false);

    if (submissions.isEmpty) {
      return const BasicEngagementMetrics();
    }

    final totalScore = submissions.fold<double>(
        0, (sum, s) => sum + ((s['total_score'] ?? 0) as num).toDouble());
    final onTimeCount = submissions.where((s) => s['is_late'] != true).length;
    final avgScore =
        submissions.isNotEmpty ? totalScore / submissions.length : 0.0;

    // Calculate trend direction (compare last 3 vs previous 3)
    TrendDirection? trendDirection;
    if (submissions.length >= 6) {
      final recent = submissions
          .take(3)
          .map((s) => ((s['total_score'] ?? 0) as num).toDouble())
          .toList();
      final older = submissions
          .skip(3)
          .take(3)
          .map((s) => ((s['total_score'] ?? 0) as num).toDouble())
          .toList();
      final recentAvg = recent.reduce((a, b) => a + b) / 3;
      final olderAvg = older.reduce((a, b) => a + b) / 3;
      if (recentAvg > olderAvg + 2) {
        trendDirection = TrendDirection.up;
      } else if (recentAvg < olderAvg - 2) {
        trendDirection = TrendDirection.down;
      } else {
        trendDirection = TrendDirection.stable;
      }
    }

    // Get total time from work_sessions
    final timeResult = await _client
        .from('work_sessions')
        .select('time_spent_seconds')
        .eq('student_id', studentId);
    final totalTime = timeResult.fold<int>(
        0, (sum, s) => sum + ((s['time_spent_seconds'] ?? 0) as num).toInt());

    return BasicEngagementMetrics(
      avgScore: avgScore,
      onTimeRate:
          submissions.isNotEmpty ? onTimeCount / submissions.length : 0.0,
      totalTimeMinutes: totalTime ~/ 60,
      submissionCount: submissions.length,
      trendDirection: trendDirection,
    );
  }

  /// Query 2: Skill Mastery for Radar Chart (ANL-04)
  Future<List<SkillMastery>> getSkillMastery(String studentId) async {
    final result = await _client
        .from('student_skill_mastery')
        .select('*, learning_objectives(name)')
        .eq('student_id', studentId);

    return result.map((row) {
      final mastery = (row['mastery_level'] ?? 0.0) as num;
      return SkillMastery(
        objectiveId: row['objective_id'] ?? '',
        skillName: (row['learning_objectives'] as Map<String, dynamic>?)?['name'] ?? 'Unknown',
        masteryLevel: mastery.toDouble(),
        attempts: (row['attempts'] ?? 0) as int,
        isStrong: mastery >= 0.7,
        isWeak: mastery < 0.4,
      );
    }).toList();
  }

  /// Query 3: Grade Trends for Line Chart (ANL-03)
  /// Note: Date filtering not implemented - uses default last 20 submissions
  Future<List<GradeTrend>> getGradeTrends(String studentId,
      {DateTime? startDate, DateTime? endDate}) async {
    final result = await _client
        .from('submissions')
        .select('total_score, submitted_at, assignment_distributions(title)')
        .eq('student_id', studentId)
        .not('total_score', 'is', null)
        .order('submitted_at', ascending: true)
        .limit(20);

    return result.map((row) {
      final ad = row['assignment_distributions'] as Map<String, dynamic>?;
      return GradeTrend(
        date: DateTime.parse(row['submitted_at']),
        score: ((row['total_score'] ?? 0) as num).toDouble(),
        assignmentName: ad?['title'] ?? 'Assignment',
      );
    }).toList();
  }

  /// Query 4: Class Analytics for Teachers (ANL-02)
  Future<ClassAnalytics> getClassAnalytics(String classId) async {
    // Get class info
    final classInfo = await _client
        .from('classes')
        .select('name')
        .eq('id', classId)
        .maybeSingle();

    // Get all students in class
    final studentsResult = await _client
        .from('class_members')
        .select('student_id')
        .eq('class_id', classId);
    final totalStudents = studentsResult.length;

    // Get all submissions for this class
    final submissions = await _client
        .from('submissions')
        .select('total_score, student_id')
        .eq('class_id', classId)
        .not('total_score', 'is', null);

    final totalSubmissions = submissions.length;
    final classAverage = submissions.isNotEmpty
        ? submissions.fold<double>(
                0,
                (sum, s) =>
                    sum + ((s['total_score'] ?? 0) as num).toDouble()) /
            submissions.length
        : 0.0;

    // Calculate distribution histogram (0-10, 11-20, ..., 91-100)
    final distribution = _calculateDistribution(submissions);

    // Get top/bottom performers
    final studentScores = <String, List<double>>{};
    for (final sub in submissions) {
      final studentId = sub['student_id'] as String?;
      if (studentId != null) {
        final score = ((sub['total_score'] ?? 0) as num).toDouble();
        studentScores.putIfAbsent(studentId, () => []).add(score);
      }
    }

    // Calculate average per student and sort
    final avgScores = studentScores.entries.map((e) {
      final avg = e.value.reduce((a, b) => a + b) / e.value.length;
      return MapEntry(e.key, avg);
    }).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Get student names
    final topPerformers = <StudentPerformance>[];
    final bottomPerformers = <StudentPerformance>[];

    for (int i = 0; i < avgScores.length && i < 5; i++) {
      final studentId = avgScores[i].key;
      final studentName = await _getStudentName(studentId);
      topPerformers.add(StudentPerformance(
        studentId: studentId,
        studentName: studentName,
        score: avgScores[i].value,
      ));
    }

    for (int i = avgScores.length - 1;
        i >= avgScores.length - 5 && i >= 0;
        i--) {
      final studentId = avgScores[i].key;
      final studentName = await _getStudentName(studentId);
      bottomPerformers.add(StudentPerformance(
        studentId: studentId,
        studentName: studentName,
        score: avgScores[i].value,
      ));
    }

    return ClassAnalytics(
      classId: classId,
      className: (classInfo?['name'] ?? 'Class') as String,
      classAverage: classAverage,
      totalStudents: totalStudents,
      totalSubmissions: totalSubmissions,
      submissionRate:
          totalStudents > 0 ? totalSubmissions / totalStudents : 0.0,
      distribution: distribution,
      topPerformers: topPerformers,
      bottomPerformers: bottomPerformers,
    );
  }

  List<ClassDistribution> _calculateDistribution(
      List<Map<String, dynamic>> submissions) {
    final buckets = <int, int>{};
    for (int i = 0; i <= 10; i++) {
      buckets[i] = 0;
    }

    for (final sub in submissions) {
      final score = ((sub['total_score'] ?? 0) as num).toDouble();
      final bucketIndex = (score ~/ 10).clamp(0, 10);
      buckets[bucketIndex] = (buckets[bucketIndex] ?? 0) + 1;
    }

    return List.generate(10, (i) {
      return ClassDistribution(
        rangeStart: i * 10,
        rangeEnd: (i + 1) * 10,
        count: buckets[i] ?? 0,
      );
    });
  }

  Future<String> _getStudentName(String studentId) async {
    final result = await _client
        .from('profiles')
        .select('name')
        .eq('id', studentId)
        .maybeSingle();
    return (result?['name'] ?? 'Student') as String;
  }

  /// Get class comparison for a student
  Future<ClassComparison> getClassComparison(
      String studentId, String classId) async {
    final submissions = await _client
        .from('submissions')
        .select('total_score')
        .eq('student_id', studentId)
        .eq('class_id', classId)
        .not('total_score', 'is', null);

    if (submissions.isEmpty) {
      return const ClassComparison();
    }

    final studentAvg = submissions.fold<double>(
            0, (sum, s) => sum + ((s['total_score'] ?? 0) as num).toDouble()) /
        submissions.length;

    // Get all students' averages in class
    final allSubmissions = await _client
        .from('submissions')
        .select('student_id, total_score')
        .eq('class_id', classId)
        .not('total_score', 'is', null);

    final studentAverages = <String, List<double>>{};
    for (final sub in allSubmissions) {
      final sid = sub['student_id'] as String?;
      if (sid != null) {
        final score = ((sub['total_score'] ?? 0) as num).toDouble();
        studentAverages.putIfAbsent(sid, () => []).add(score);
      }
    }

    final averages = studentAverages.entries.map((e) {
      return e.value.reduce((a, b) => a + b) / e.value.length;
    }).toList()
      ..sort((a, b) => b.compareTo(a));

    final classAverage =
        averages.isNotEmpty ? averages.reduce((a, b) => a + b) / averages.length : 0.0;

    // Calculate percentile
    final belowCount = averages.where((a) => a < studentAvg).length;
    final percentile = averages.isNotEmpty ? belowCount / averages.length * 100 : 0.0;

    // Find rank
    final rank = averages.indexWhere((a) => a <= studentAvg) + 1;

    return ClassComparison(
      classAverage: classAverage,
      percentile: percentile,
      rank: rank,
      totalStudents: averages.length,
    );
  }
}
