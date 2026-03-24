import 'package:ai_mls/core/services/supabase_service.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/analytics/student_analytics.dart';
import '../../domain/entities/analytics/skill_mastery.dart';
import '../../domain/entities/analytics/grade_trend.dart';
import '../../domain/entities/analytics/class_analytics.dart';

/// DataSource for analytics queries from Supabase
class AnalyticsDatasource {
  SupabaseClient get _client => SupabaseService.client;

  /// Query 1: Basic & Engagement Metrics (ANL-01)
  Future<BasicEngagementMetrics> getBasicMetrics(
    String studentId, {
    String? classId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Build submission query - filter by class via assignment_distributions if classId provided
      List<Map<String, dynamic>> submissions;

      if (classId != null) {
        // Join via assignment_distributions to filter by class
        final distributions = await _client
            .from('assignment_distributions')
            .select('id')
            .eq('class_id', classId);
        final distributionIds = distributions
            .map((d) => d['id'] as String)
            .toList();

        if (distributionIds.isEmpty) {
          submissions = [];
        } else {
          var q = _client
              .from('submissions')
              .select('total_score, is_late, submitted_at')
              .eq('student_id', studentId)
              .inFilter('assignment_distribution_id', distributionIds);
          if (startDate != null) q = q.gte('submitted_at', startDate.toIso8601String());
          if (endDate != null) q = q.lte('submitted_at', endDate.toIso8601String());
          submissions = await q.order('submitted_at', ascending: false);
        }
      } else {
        var q = _client
            .from('submissions')
            .select('total_score, is_late, submitted_at')
            .eq('student_id', studentId);
        if (startDate != null) q = q.gte('submitted_at', startDate.toIso8601String());
        if (endDate != null) q = q.lte('submitted_at', endDate.toIso8601String());
        submissions = await q.order('submitted_at', ascending: false);
      }

      if (submissions.isEmpty) {
        return const BasicEngagementMetrics();
      }

      final totalScore = submissions.fold<double>(
        0,
        (sum, s) => sum + ((s['total_score'] ?? 0) as num).toDouble(),
      );
      final onTimeCount = submissions.where((s) => s['is_late'] != true).length;
      final avgScore = submissions.isNotEmpty
          ? totalScore / submissions.length
          : 0.0;

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
      final totalTime = timeResult.isEmpty
          ? 0
          : timeResult.fold<int>(
              0,
              (sum, s) => sum + ((s['time_spent_seconds'] ?? 0) as num).toInt(),
            );

      return BasicEngagementMetrics(
        avgScore: avgScore,
        onTimeRate: submissions.isNotEmpty
            ? onTimeCount / submissions.length
            : 0.0,
        totalTimeMinutes: totalTime ~/ 60,
        submissionCount: submissions.length,
        trendDirection: trendDirection,
      );
    } catch (e, st) {
      AppLogger.error(
        '[AnalyticsDatasource] getBasicMetrics error',
        error: e,
        stackTrace: st,
      );
      return const BasicEngagementMetrics();
    }
  }

  /// Query 2: Skill Mastery for Radar Chart (ANL-04)
  Future<List<SkillMastery>> getSkillMastery(
    String studentId, {
    String? classId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Skill mastery is independent of class/date — query student_skill_mastery directly.
      // Filter by objective_ids only when classId is provided (resolve objectives via question_objectives).
      Set<String> objectiveIds = {};

      if (classId != null) {
        // Step 1: Get distribution IDs for this class
        final distributions = await _client
            .from('assignment_distributions')
            .select('id')
            .eq('class_id', classId);
        final distributionIds = distributions
            .map((d) => d['id'] as String)
            .toList();

        if (distributionIds.isNotEmpty) {
          // Step 2: Get submissions for this class (filter by date if provided)
          var q = _client
              .from('submissions')
              .select('id, assignment_id')
              .eq('student_id', studentId)
              .inFilter('assignment_distribution_id', distributionIds);
          if (startDate != null) q = q.gte('submitted_at', startDate.toIso8601String());
          if (endDate != null) q = q.lte('submitted_at', endDate.toIso8601String());
          final submissions = await q;

          // Step 3: Extract unique assignment_ids
          final assignmentIds = submissions
              .map((s) => s['assignment_id'] as String?)
              .whereType<String>()
              .toSet()
              .toList();

          if (assignmentIds.isNotEmpty) {
            // Step 4: Get question_ids from assignment_questions for these assignments
            final aqResult = await _client
                .from('assignment_questions')
                .select('id')
                .inFilter('assignment_id', assignmentIds);
            final questionIds = aqResult
                .map((aq) => aq['id'] as String)
                .toList();

            if (questionIds.isNotEmpty) {
              // Step 5: Get objective_ids via question_objectives
              final qoResult = await _client
                  .from('question_objectives')
                  .select('objective_id')
                  .inFilter('question_id', questionIds);
              for (final qo in qoResult) {
                final oid = qo['objective_id'] as String?;
                if (oid != null) objectiveIds.add(oid);
              }
            }
          }
        }
      }

      // Fetch skill mastery records
      List<Map<String, dynamic>> result;
      if (objectiveIds.isNotEmpty) {
        result = await _client
            .from('student_skill_mastery')
            .select('objective_id, mastery_level, attempts')
            .eq('student_id', studentId)
            .inFilter('objective_id', objectiveIds.toList());
      } else {
        // Fetch all for student (no class filter or no objectives found)
        result = await _client
            .from('student_skill_mastery')
            .select('objective_id, mastery_level, attempts')
            .eq('student_id', studentId);
      }

      if (result.isEmpty) {
        return [];
      }

      // Fetch objective names
      final allObjectiveIds = result
          .map((r) => r['objective_id'] as String)
          .toList();

      final objectives = await _client
          .from('learning_objectives')
          .select('id, code, description')
          .inFilter('id', allObjectiveIds);

      final objectiveMap = {
        for (var o in objectives)
          o['id'] as String: (o['code'] as String?)?.isNotEmpty == true
              ? o['code'] as String
              : (o['description'] as String?) ?? 'Unknown',
      };

      return result.map((row) {
        final mastery = (row['mastery_level'] ?? 0.0) as num;
        final objectiveId = row['objective_id'] as String;
        return SkillMastery(
          objectiveId: objectiveId,
          skillName: objectiveMap[objectiveId] ?? 'Unknown',
          masteryLevel: mastery.toDouble(),
          attempts: (row['attempts'] ?? 0) as int,
          isStrong: mastery >= 0.7,
          isWeak: mastery < 0.4,
        );
      }).toList();
    } catch (e, st) {
      AppLogger.error(
        '[AnalyticsDatasource] getSkillMastery error',
        error: e,
        stackTrace: st,
      );
      return [];
    }
  }

  /// Query 3: Grade Trends for Line Chart (ANL-03)
  Future<List<GradeTrend>> getGradeTrends(
    String studentId, {
    String? classId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      List<Map<String, dynamic>> result;

      if (classId != null) {
        // Filter by class via assignment_distributions
        final distributions = await _client
            .from('assignment_distributions')
            .select('id')
            .eq('class_id', classId);
        final distributionIds = distributions
            .map((d) => d['id'] as String)
            .toList();

        if (distributionIds.isEmpty) {
          result = [];
        } else {
          var q = _client
              .from('submissions')
              .select(
                'total_score, submitted_at, assignment_distribution_id, assignment_id',
              )
              .eq('student_id', studentId)
              .inFilter('assignment_distribution_id', distributionIds)
              .not('total_score', 'is', null);
          if (startDate != null) q = q.gte('submitted_at', startDate.toIso8601String());
          if (endDate != null) q = q.lte('submitted_at', endDate.toIso8601String());
          result = await q.order('submitted_at', ascending: true).limit(20);
        }
      } else {
        // Global view - all submissions
        var q = _client
            .from('submissions')
            .select(
              'total_score, submitted_at, assignment_distribution_id, assignment_id',
            )
            .eq('student_id', studentId)
            .not('total_score', 'is', null);
        if (startDate != null) q = q.gte('submitted_at', startDate.toIso8601String());
        if (endDate != null) q = q.lte('submitted_at', endDate.toIso8601String());
        result = await q.order('submitted_at', ascending: true).limit(20);
      }

      if (result.isEmpty) return [];

      // Collect unique assignment_ids to fetch titles
      final assignmentIds = result
          .where((r) => r['assignment_id'] != null)
          .map((r) => r['assignment_id'] as String)
          .toSet()
          .toList();

      Map<String, String> assignmentTitles = {};
      if (assignmentIds.isNotEmpty) {
        final assignments = await _client
            .from('assignments')
            .select('id, title')
            .inFilter('id', assignmentIds);
        assignmentTitles = {
          for (var a in assignments) a['id'] as String: a['title'] as String,
        };
      }

      return result
          .map((row) {
            final dateStr = row['submitted_at'] as String?;
            if (dateStr == null) return null;
            DateTime? parsedDate;
            try {
              parsedDate = DateTime.parse(dateStr);
            } catch (_) {
              return null;
            }
            // Apply date filtering if provided
            if (startDate != null && parsedDate.isBefore(startDate)) return null;
            if (endDate != null && parsedDate.isAfter(endDate)) return null;
            final assignmentId = row['assignment_id'] as String?;
            final assignmentName = assignmentId != null
                ? (assignmentTitles[assignmentId] ?? 'Assignment')
                : 'Assignment';
            return GradeTrend(
              date: parsedDate,
              score: ((row['total_score'] ?? 0) as num).toDouble(),
              assignmentName: assignmentName,
            );
          })
          .whereType<GradeTrend>()
          .toList();
    } catch (e, st) {
      AppLogger.error(
        '[AnalyticsDatasource] getGradeTrends error',
        error: e,
        stackTrace: st,
      );
      return [];
    }
  }

  /// Query 4: Class Analytics for Teachers (ANL-02)
  Future<ClassAnalytics> getClassAnalytics(String classId) async {
    try {
      // Get class info
      final classInfo = await _client
          .from('classes')
          .select('name, subject')
          .eq('id', classId)
          .maybeSingle();

      // Get all approved students in class
      final studentsResult = await _client
          .from('class_members')
          .select('student_id')
          .eq('class_id', classId)
          .eq('status', 'approved');
      final totalStudents = studentsResult.length;
      final studentIds = studentsResult
          .map((s) => s['student_id'] as String)
          .toList();

      // Get all submissions for this class - filter by assignment_distribution_id
      // so we only get submissions for assignments that belong to this class
      final distributions = await _client
          .from('assignment_distributions')
          .select('id')
          .eq('class_id', classId);
      final distributionIds = distributions
          .map((d) => d['id'] as String)
          .toList();

      final submissions = studentIds.isEmpty || distributionIds.isEmpty
          ? <Map<String, dynamic>>[]
          : await _client
                .from('submissions')
                .select('total_score, student_id, assignment_distribution_id, is_late, profiles(full_name)')
                .inFilter('student_id', studentIds)
                .inFilter('assignment_distribution_id', distributionIds)
                .not('total_score', 'is', null);

      final totalSubmissions = submissions.length;
      final submittedStudentIds = submissions
          .map((s) => s['student_id'] as String)
          .toSet();
      final lateSubmissions = submissions.where((s) => s['is_late'] == true).length;
      final lateSubmissionsByStudent = <String, int>{};
      for (final sub in submissions) {
        if (sub['is_late'] == true) {
          final sid = sub['student_id'] as String?;
          if (sid != null) {
            lateSubmissionsByStudent[sid] = (lateSubmissionsByStudent[sid] ?? 0) + 1;
          }
        }
      }
      WorstOffender? worstOffender;
      if (lateSubmissionsByStudent.isNotEmpty) {
        final worstId = lateSubmissionsByStudent.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
        final worstName = await _getStudentName(worstId);
        worstOffender = WorstOffender(
          studentId: worstId,
          studentName: worstName,
          lateCount: lateSubmissionsByStudent[worstId] ?? 0,
        );
      }
      final classAverage = submissions.isNotEmpty
          ? submissions.fold<double>(
                  0,
                  (sum, s) => sum + ((s['total_score'] ?? 0) as num).toDouble(),
                ) /
                submissions.length
          : 0.0;

      // Calculate distribution histogram (0-10, 11-20, ..., 91-100)
      final distribution = _calculateDistribution(submissions);

      // Build distribution info map from assignment_distributions
      final distributionInfo = await _buildDistributionInfoMap(classId);

      // Map subject distributions for heatmap
      final subjectDistributions = _mapToSubjectDistributions(
        submissions,
        distributionInfo,
      );

      // Get top/bottom performers
      final studentScores = <String, List<double>>{};
      for (final sub in submissions) {
        final studentId = sub['student_id'] as String?;
        if (studentId != null) {
          final score = ((sub['total_score'] ?? 0) as num).toDouble();
          studentScores.putIfAbsent(studentId, () => []).add(score);
        }
      }

      // Calculate average per student and sort descending
      final avgScores = studentScores.entries.map((e) {
        final avg = e.value.reduce((a, b) => a + b) / e.value.length;
        return (id: e.key, avg: avg, count: e.value.length);
      }).toList()..sort((a, b) => b.avg.compareTo(a.avg));

      // Threshold-based logic: >= 5.0 → Học sinh xuất sắc (top), < 5.0 → Cần chú ý (bottom)
      const scoreThreshold = 5.0;
      const maxPerList = 5;
      final topPerformers = <StudentPerformance>[];
      final bottomPerformers = <StudentPerformance>[];

      // Top: highest scores, score >= threshold
      for (final entry in avgScores) {
        if (topPerformers.length >= maxPerList) break;
        if (entry.avg >= scoreThreshold) {
          final studentName = await _getStudentName(entry.id);
          topPerformers.add(StudentPerformance(
            studentId: entry.id,
            studentName: studentName,
            score: entry.avg,
            submissionCount: entry.count,
          ));
        }
      }

      // Bottom: lowest scores, score < threshold
      for (final entry in avgScores.reversed) {
        if (bottomPerformers.length >= maxPerList) break;
        if (entry.avg < scoreThreshold) {
          final studentName = await _getStudentName(entry.id);
          bottomPerformers.add(StudentPerformance(
            studentId: entry.id,
            studentName: studentName,
            score: entry.avg,
            submissionCount: entry.count,
          ));
        }
      }

      return ClassAnalytics(
        classId: classId,
        className: (classInfo?['name'] ?? 'Class') as String,
        classAverage: classAverage,
        totalStudents: totalStudents,
        totalSubmissions: totalSubmissions,
        submissionRate: totalStudents > 0
            ? submittedStudentIds.length / totalStudents
            : 0.0,
        lateSubmissionRate: totalSubmissions > 0
            ? lateSubmissions / totalSubmissions
            : 0.0,
        lateSubmissionCount: lateSubmissions,
        worstOffender: worstOffender,
        highestScore: avgScores.isNotEmpty ? avgScores.first.avg : null,
        lowestScore: avgScores.isNotEmpty ? avgScores.last.avg : null,
        distribution: distribution,
        subjectDistributions: subjectDistributions,
        topPerformers: topPerformers,
        bottomPerformers: bottomPerformers,
      );
    } catch (e, st) {
      AppLogger.error(
        '[AnalyticsDatasource] getClassAnalytics error',
        error: e,
        stackTrace: st,
      );
      return ClassAnalytics(
        classId: classId,
        className: 'Error',
        classAverage: 0,
        totalStudents: 0,
        totalSubmissions: 0,
        submissionRate: 0,
        lateSubmissionRate: 0,
        lateSubmissionCount: 0,
        worstOffender: null,
        highestScore: null,
        lowestScore: null,
        distribution: [],
        subjectDistributions: const [],
        topPerformers: [],
        bottomPerformers: [],
      );
    }
  }

  /// Builds a map from distribution id → assignment title, filtered by classId.
  Future<Map<String, ({String title, double maxScore})>> _buildDistributionInfoMap(String classId) async {
    final distributions = await _client
        .from('assignment_distributions')
        .select('id, assignments(total_points, title)')
        .eq('class_id', classId)
        .order('created_at', ascending: false);

    final result = <String, ({String title, double maxScore})>{};
    for (final d in distributions) {
      final id = d['id'] as String?;
      final assignment = d['assignments'] as Map<String, dynamic>?;
      final title = assignment?['title'] as String? ?? 'Bài tập';
      final totalPoints = (assignment?['total_points'] as num?)?.toDouble() ?? 10.0;
      if (id != null) {
        result[id] = (title: title, maxScore: totalPoints);
      }
    }
    return result;
  }

  /// Maps raw submissions grouped by assignment → SubjectDistribution.
  /// Buckets: thang diem 10 → "0-4", "4-6", "6-8", "8-10"
  List<SubjectDistribution> _mapToSubjectDistributions(
    List<Map<String, dynamic>> submissions,
    Map<String, ({String title, double maxScore})> distributionInfo,
  ) {
    // Track scores + student info per bucket per assignment
    final Map<String, List<double>> assignmentScores = {};
    final Map<String, List<({String studentId, String studentName, double score})>>
        assignmentStudents = {};

    for (final sub in submissions) {
      final distributionId = sub['assignment_distribution_id'] as String?;
      final score = ((sub['total_score'] ?? 0) as num).toDouble();
      final studentId = sub['student_id'] as String? ?? '';
      final studentName = sub['profiles']?['full_name'] as String? ?? 'Học sinh';
      final info = distributionInfo[distributionId];
      final title = info?.title ?? 'Bài tập';
      final maxScore = info?.maxScore ?? 10.0;

      // Normalize score to 100-scale for consistent bucket comparison
      final scorePercent = maxScore > 0 ? (score / maxScore) * 100 : 0.0;
      assignmentScores.putIfAbsent(title, () => []).add(scorePercent);
      assignmentStudents
          .putIfAbsent(title, () => [])
          .add((studentId: studentId, studentName: studentName, score: scorePercent));
    }

    return assignmentScores.entries.map((entry) {
      final buckets = <String, int>{
        '0-4': 0,
        '4-6': 0,
        '6-8': 0,
        '8-10': 0,
      };
      final bucketStudents = <String, List<StudentScoreItem>>{
        '0-4': [],
        '4-6': [],
        '6-8': [],
        '8-10': [],
      };

      for (int i = 0; i < entry.value.length; i++) {
        final scorePercent = entry.value[i];
        final student = assignmentStudents[entry.key]![i];
        final bucket = scorePercent < 40
            ? '0-4'
            : scorePercent < 60
                ? '4-6'
                : scorePercent < 80
                    ? '6-8'
                    : '8-10';
        buckets[bucket] = buckets[bucket]! + 1;
        bucketStudents[bucket]!.add(StudentScoreItem(
          studentId: student.studentId,
          studentName: student.studentName,
          score: scorePercent,
        ));
      }

      // Sort each bucket by score descending
      for (final key in bucketStudents.keys) {
        bucketStudents[key]!.sort((a, b) => b.score.compareTo(a.score));
      }

      return SubjectDistribution(
        subjectName: entry.key,
        below50Count: buckets['0-4']!,
        below60Count: buckets['4-6']!,
        below80Count: buckets['6-8']!,
        above80Count: buckets['8-10']!,
        below50Students: bucketStudents['0-4'] ?? const [],
        below60Students: bucketStudents['4-6'] ?? const [],
        below80Students: bucketStudents['6-8'] ?? const [],
        above80Students: bucketStudents['8-10'] ?? const [],
      );
    }).toList();
  }

  List<ClassDistribution> _calculateDistribution(
    List<Map<String, dynamic>> submissions,
  ) {
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
        .select('full_name')
        .eq('id', studentId)
        .maybeSingle();
    return (result?['full_name'] ?? 'Học sinh') as String;
  }

  /// Get class comparison for a student
  Future<ClassComparison> getClassComparison(
    String studentId,
    String classId,
  ) async {
    try {
      // Get students in this class first
      final studentsResult = await _client
          .from('class_members')
          .select('student_id')
          .eq('class_id', classId);
      final studentIds = studentsResult
          .map((s) => s['student_id'] as String)
          .toList();

      if (studentIds.isEmpty) {
        return const ClassComparison();
      }

      // Get this student's submissions filtered by class's assignment distributions
      final distributions = await _client
          .from('assignment_distributions')
          .select('id')
          .eq('class_id', classId);
      final distributionIds = distributions
          .map((d) => d['id'] as String)
          .toList();

      final submissions = distributionIds.isEmpty
          ? <Map<String, dynamic>>[]
          : await _client
                .from('submissions')
                .select('total_score')
                .eq('student_id', studentId)
                .inFilter('assignment_distribution_id', distributionIds)
                .not('total_score', 'is', null);

      if (submissions.isEmpty) {
        return const ClassComparison();
      }

      final studentAvg =
          submissions.fold<double>(
            0,
            (sum, s) => sum + ((s['total_score'] ?? 0) as num).toDouble(),
          ) /
          submissions.length;

      // Get all students' averages in class (filtered by this class's distributions)
      final allSubmissions = distributionIds.isEmpty
          ? <Map<String, dynamic>>[]
          : await _client
                .from('submissions')
                .select('student_id, total_score')
                .inFilter('student_id', studentIds)
                .inFilter('assignment_distribution_id', distributionIds)
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
      }).toList()..sort((a, b) => b.compareTo(a));

      final classAverage = averages.isNotEmpty
          ? averages.reduce((a, b) => a + b) / averages.length
          : 0.0;

      // Calculate percentile
      final belowCount = averages.where((a) => a < studentAvg).length;
      final percentile = averages.isNotEmpty
          ? belowCount / averages.length * 100
          : 0.0;

      // Find rank
      final rank = averages.indexWhere((a) => a <= studentAvg) + 1;

      return ClassComparison(
        classAverage: classAverage,
        percentile: percentile,
        rank: rank,
        totalStudents: averages.length,
      );
    } catch (e, st) {
      AppLogger.error(
        '[AnalyticsDatasource] getClassComparison error',
        error: e,
        stackTrace: st,
      );
      return const ClassComparison();
    }
  }
}
