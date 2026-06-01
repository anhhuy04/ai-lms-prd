import 'package:ai_mls/core/services/supabase_service.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/analytics/class_analytics.dart';
import '../../domain/entities/analytics/grade_trend.dart';
import '../../domain/entities/analytics/skill_mastery.dart';
import '../../domain/entities/analytics/student_analytics.dart';

/// DataSource for analytics queries from Supabase
class AnalyticsDatasource {
  SupabaseClient get _client => SupabaseService.client;

  /// Format skill name from code to human-readable format
  /// Example: "mmt.1-6" → "MMT 1-6"
  static String _formatSkillName(String skillName) {
    // Replace dots and dashes with spaces for readability
    String formatted = skillName
        .replaceAll('.', ' ')
        .replaceAll('-', ' - ')
        .trim();

    // Capitalize each word
    final words = formatted.split(' ');
    final capitalized = words
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');

    return capitalized;
  }

  /// Build semantic label combining code and description for AI analysis
  /// Example: code="M3.1", desc="Lượng giác" → "M3.1 - Lượng giác"
  static String _buildSemanticLabel(String? code, String? description) {
    if (code == null || code.isEmpty) {
      return description ?? 'Unknown';
    }
    if (description == null || description.isEmpty) {
      return code;
    }
    // Combine code and description with dash
    return '$code - $description';
  }

  /// Query 1: Basic & Engagement Metrics (ANL-01)
  Future<BasicEngagementMetrics> getBasicMetrics(
    String studentId, {
    String? classId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Dynamic Aggregation via RPC — 1 Verdict per distribution, đúng rule của từng bài.
      // avgScore = trung bình Verdicts, không phải trung bình raw attempts.
      final rpcResult = await _client.rpc(
        'get_student_verdicts_with_meta',
        params: {
          'p_student_id': studentId,
          if (classId != null) 'p_class_id': classId,
        },
      );
      var verdicts = List<Map<String, dynamic>>.from(rpcResult as List);

      // Apply date filter client-side nếu có (dùng last_submitted_at)
      if (startDate != null || endDate != null) {
        verdicts = verdicts.where((v) {
          final raw = v['last_submitted_at'] as String?;
          if (raw == null) return false;
          final dt = DateTime.tryParse(raw);
          if (dt == null) return false;
          if (startDate != null && dt.isBefore(startDate)) return false;
          if (endDate != null && dt.isAfter(endDate)) return false;
          return true;
        }).toList();
      }

      // Sort newest first (để trendDirection tính "recent vs older" đúng thứ tự)
      verdicts.sort((a, b) {
        final ta = DateTime.tryParse(a['last_submitted_at'] as String? ?? '');
        final tb = DateTime.tryParse(b['last_submitted_at'] as String? ?? '');
        if (ta == null && tb == null) return 0;
        if (ta == null) return 1;
        if (tb == null) return -1;
        return tb.compareTo(ta);
      });

      if (verdicts.isEmpty) {
        return const BasicEngagementMetrics();
      }

      final totalScore = verdicts.fold<double>(
        0,
        (sum, v) => sum + ((v['final_score'] ?? 0) as num).toDouble(),
      );
      final onTimeCount = verdicts.where((v) => v['is_late'] != true).length;
      final avgScore = totalScore / verdicts.length;

      // Trend: so sánh Verdict 3 bài gần nhất vs 3 bài trước đó
      TrendDirection? trendDirection;
      if (verdicts.length >= 6) {
        final recent = verdicts
            .take(3)
            .map((v) => ((v['final_score'] ?? 0) as num).toDouble())
            .toList();
        final older = verdicts
            .skip(3)
            .take(3)
            .map((v) => ((v['final_score'] ?? 0) as num).toDouble())
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
        onTimeRate: onTimeCount / verdicts.length,
        totalTimeMinutes: totalTime ~/ 60,
        submissionCount: verdicts.length,
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
  /// Joins with learning_objectives to fetch full semantic context
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
          if (startDate != null) {
            q = q.gte('submitted_at', startDate.toIso8601String());
          }
          if (endDate != null) {
            q = q.lte('submitted_at', endDate.toIso8601String());
          }
          final submissions = await q;

          // Step 3: Extract unique assignment_ids
          final assignmentIds = submissions
              .map((s) => s['assignment_id'] as String?)
              .whereType<String>()
              .toSet()
              .toList();

          if (assignmentIds.isNotEmpty) {
            // Step 4: Get question_ids from assignment_questions for these assignments
            // NOTE: must use 'question_id' (FK → questions.id), NOT 'id' (PK of assignment_questions)
            final aqResult = await _client
                .from('assignment_questions')
                .select('question_id')
                .inFilter('assignment_id', assignmentIds);
            final questionIds = aqResult
                .map((aq) => aq['question_id'] as String?)
                .whereType<String>()
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

      // Fetch skill mastery records with relational join to learning_objectives
      // This ensures we get code + description in a single query
      List<Map<String, dynamic>> result;
      if (objectiveIds.isNotEmpty) {
        result = await _client
            .from('student_skill_mastery')
            .select(
              'objective_id, mastery_level, attempts, learning_objectives(code, description)',
            )
            .eq('student_id', studentId)
            .inFilter('objective_id', objectiveIds.toList());
      } else {
        // Fetch all for student (no class filter or no objectives found)
        result = await _client
            .from('student_skill_mastery')
            .select(
              'objective_id, mastery_level, attempts, learning_objectives(code, description)',
            )
            .eq('student_id', studentId);
      }

      if (result.isEmpty) {
        return [];
      }

      /// Parse related objectives from nested select result
      return result.map((row) {
        final mastery = (row['mastery_level'] ?? 0.0) as num;
        final objectiveId = row['objective_id'] as String;

        // Extract related objective data from nested select
        final objectiveData =
            row['learning_objectives'] as Map<String, dynamic>?;
        final code = objectiveData?['code'] as String?;
        final description = objectiveData?['description'] as String?;

        // Build semantic label: [Code] - [Description]
        final semanticLabel = _buildSemanticLabel(code, description);
        final skillName = code ?? 'Unknown';

        return SkillMastery(
          objectiveId: objectiveId,
          skillName: skillName,
          masteryLevel: mastery.toDouble(),
          attempts: (row['attempts'] ?? 0) as int,
          isStrong: mastery >= 0.7,
          isWeak: mastery < 0.4,
          description: description,
          displayName: _formatSkillName(skillName),
          semanticLabel: semanticLabel,
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
          if (startDate != null) {
            q = q.gte('submitted_at', startDate.toIso8601String());
          }
          if (endDate != null) {
            q = q.lte('submitted_at', endDate.toIso8601String());
          }
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
        if (startDate != null) {
          q = q.gte('submitted_at', startDate.toIso8601String());
        }
        if (endDate != null) {
          q = q.lte('submitted_at', endDate.toIso8601String());
        }
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

      // Fetch class name per distribution_id
      final distributionIds = result
          .where((r) => r['assignment_distribution_id'] != null)
          .map((r) => r['assignment_distribution_id'] as String)
          .toSet()
          .toList();

      Map<String, String> distClassNames = {};
      if (distributionIds.isNotEmpty) {
        final dists = await _client
            .from('assignment_distributions')
            .select('id, classes(name)')
            .inFilter('id', distributionIds);
        for (final d in dists) {
          final classData = d['classes'] as Map<String, dynamic>?;
          final name = classData?['name'] as String?;
          if (name != null) {
            distClassNames[d['id'] as String] = name;
          }
        }
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
            if (startDate != null && parsedDate.isBefore(startDate)) {
              return null;
            }
            if (endDate != null && parsedDate.isAfter(endDate)) return null;
            final assignmentId = row['assignment_id'] as String?;
            final assignmentName = assignmentId != null
                ? (assignmentTitles[assignmentId] ?? 'Assignment')
                : 'Assignment';
            final distId = row['assignment_distribution_id'] as String?;
            final className = distId != null ? distClassNames[distId] : null;
            return GradeTrend(
              date: parsedDate,
              score: ((row['total_score'] ?? 0) as num).toDouble(),
              assignmentName: assignmentName,
              className: className,
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

      // Get all submissions for this class - filter by assignment_distribution_id
      // so we only get submissions for assignments that belong to this class
      final distributions = await _client
          .from('assignment_distributions')
          .select('id, distribution_type, group_id, student_ids')
          .eq('class_id', classId);
      final distributionIds = distributions
          .map((d) => d['id'] as String)
          .toList();

      // Tính tổng bài cần nộp theo distribution_type
      // class → totalStudents mỗi dist; group → count group_members; student → student_ids.length
      final groupIds = distributions
          .where((d) => d['distribution_type'] == 'group' && d['group_id'] != null)
          .map((d) => d['group_id'] as String)
          .toSet()
          .toList();
      final Map<String, int> groupMemberCount = {};
      if (groupIds.isNotEmpty) {
        final groupMembersResult = await _client
            .from('group_members')
            .select('group_id')
            .inFilter('group_id', groupIds);
        for (final row in groupMembersResult) {
          final gid = row['group_id'] as String;
          groupMemberCount[gid] = (groupMemberCount[gid] ?? 0) + 1;
        }
      }
      final totalExpectedSubmissions = distributions.fold<int>(0, (sum, d) {
        final type = d['distribution_type'] as String? ?? 'class';
        if (type == 'group') {
          final gid = d['group_id'] as String?;
          return sum + (gid != null ? (groupMemberCount[gid] ?? 0) : 0);
        } else if (type == 'student') {
          final ids = d['student_ids'] as List<dynamic>?;
          return sum + (ids?.length ?? 0);
        } else {
          return sum + totalStudents;
        }
      });

      // Dynamic Aggregation via RPC — 1 row per (student, distribution), đúng rule của từng bài.
      // Thay thế raw submissions query vốn phồng số liệu khi học sinh làm lại nhiều lần.
      final List<Map<String, dynamic>> submissions;
      if (distributionIds.isEmpty) {
        submissions = [];
      } else {
        final rpcResult = await _client.rpc(
          'get_class_final_scores',
          params: {'p_class_id': classId},
        );
        submissions = [
          for (final row in List<Map<String, dynamic>>.from(rpcResult as List))
            {
              'total_score': row['final_score'],
              'student_id': row['student_id'],
              'assignment_distribution_id': row['distribution_id'],
              'is_late': row['is_late'] ?? false,
              'profiles': {'full_name': row['student_name'] ?? 'Học sinh'},
            },
        ];
      }

      final totalSubmissions = submissions.length;
      final lateSubmissions = submissions
          .where((s) => s['is_late'] == true)
          .length;
      final lateSubmissionsByStudent = <String, int>{};
      for (final sub in submissions) {
        if (sub['is_late'] == true) {
          final sid = sub['student_id'] as String?;
          if (sid != null) {
            lateSubmissionsByStudent[sid] =
                (lateSubmissionsByStudent[sid] ?? 0) + 1;
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
          topPerformers.add(
            StudentPerformance(
              studentId: entry.id,
              studentName: studentName,
              score: entry.avg,
              submissionCount: entry.count,
            ),
          );
        }
      }

      // Bottom: lowest scores, score < threshold
      for (final entry in avgScores.reversed) {
        if (bottomPerformers.length >= maxPerList) break;
        if (entry.avg < scoreThreshold) {
          final studentName = await _getStudentName(entry.id);
          bottomPerformers.add(
            StudentPerformance(
              studentId: entry.id,
              studentName: studentName,
              score: entry.avg,
              submissionCount: entry.count,
            ),
          );
        }
      }

      // Số HS đã nộp ít nhất 1 bài (dedupe theo student_id).
      final participatingStudents = submissions
          .map((s) => s['student_id'] as String?)
          .whereType<String>()
          .toSet()
          .length;

      return ClassAnalytics(
        classId: classId,
        className: (classInfo?['name'] ?? 'Class') as String,
        classAverage: classAverage,
        totalStudents: totalStudents,
        totalSubmissions: totalSubmissions,
        participatingStudents: participatingStudents,
        submissionRate: totalSubmissions > 0
            ? (totalSubmissions - lateSubmissions) / totalSubmissions
            : 0.0,
        lateSubmissionRate: totalSubmissions > 0
            ? lateSubmissions / totalSubmissions
            : 0.0,
        lateSubmissionCount: lateSubmissions,
        totalExpectedSubmissions: totalExpectedSubmissions,
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

  /// Builds a map from distribution id → unique display title + maxScore + sortKey.
  /// Khi 2 distributions trong cùng lớp có CÙNG title (vd: GV phân phối lại 1 bài),
  /// các lần sau được append "(2)", "(3)" để user phân biệt được trên heatmap.
  /// `sortKey` dùng để giữ thứ tự ổn định (created_at ascending — bài cũ hiện trước).
  Future<Map<String, ({String title, double maxScore, int sortKey})>>
  _buildDistributionInfoMap(String classId) async {
    final distributions = await _client
        .from('assignment_distributions')
        .select('id, created_at, assignments(total_points, title)')
        .eq('class_id', classId)
        .order('created_at', ascending: true);

    final result = <String, ({String title, double maxScore, int sortKey})>{};
    final titleCount = <String, int>{};
    int sortKey = 0;
    for (final d in distributions) {
      final id = d['id'] as String?;
      if (id == null) continue;
      final assignment = d['assignments'] as Map<String, dynamic>?;
      final rawTitle = assignment?['title'] as String? ?? 'Bài tập';
      final totalPoints =
          (assignment?['total_points'] as num?)?.toDouble() ?? 10.0;
      // Phân biệt khi cùng tên: lần đầu giữ nguyên, từ lần 2 thêm "(N)".
      final occurrence = (titleCount[rawTitle] ?? 0) + 1;
      titleCount[rawTitle] = occurrence;
      final displayTitle = occurrence == 1 ? rawTitle : '$rawTitle ($occurrence)';
      result[id] = (title: displayTitle, maxScore: totalPoints, sortKey: sortKey++);
    }
    return result;
  }

  /// Map RPC submissions (1 row per (student, distribution)) → SubjectDistribution.
  /// Mỗi DISTRIBUTION = 1 row trên heatmap (KHÔNG group theo title).
  /// → 2 dist cùng tên hiển thị thành 2 row riêng (suffix "(2)" để phân biệt).
  /// → 1 HS không bao giờ xuất hiện 2 lần trong CÙNG 1 row, vì RPC đã dedupe per (student, dist)
  ///   theo aggregation rule (latest/first/max/average).
  /// Buckets: thang điểm 0-100 (đã normalize) → "0-4", "4-6", "6-8", "8-10".
  List<SubjectDistribution> _mapToSubjectDistributions(
    List<Map<String, dynamic>> submissions,
    Map<String, ({String title, double maxScore, int sortKey})> distributionInfo,
  ) {
    // Group theo distributionId (NOT title) — mỗi distribution là 1 row độc lập.
    final Map<String, List<({String studentId, String studentName, double scorePercent})>>
        scoresByDist = {};

    for (final sub in submissions) {
      final distributionId = sub['assignment_distribution_id'] as String?;
      if (distributionId == null) continue;
      final info = distributionInfo[distributionId];
      if (info == null) continue;
      final score = ((sub['total_score'] ?? 0) as num).toDouble();
      final studentId = sub['student_id'] as String? ?? '';
      final studentName =
          sub['profiles']?['full_name'] as String? ?? 'Học sinh';
      final maxScore = info.maxScore;
      // Normalize sang 0-100.
      final scorePercent = maxScore > 0 ? (score / maxScore) * 100 : 0.0;
      scoresByDist.putIfAbsent(distributionId, () => []).add((
        studentId: studentId,
        studentName: studentName,
        scorePercent: scorePercent,
      ));
    }

    // Build SubjectDistribution per distribution, giữ thứ tự theo sortKey (created_at).
    final entries = scoresByDist.entries.toList()
      ..sort((a, b) {
        final ka = distributionInfo[a.key]?.sortKey ?? 0;
        final kb = distributionInfo[b.key]?.sortKey ?? 0;
        return ka.compareTo(kb);
      });

    return entries.map((entry) {
      final info = distributionInfo[entry.key]!;
      final buckets = <String, int>{'0-4': 0, '4-6': 0, '6-8': 0, '8-10': 0};
      final bucketStudents = <String, List<StudentScoreItem>>{
        '0-4': [],
        '4-6': [],
        '6-8': [],
        '8-10': [],
      };

      for (final s in entry.value) {
        final bucket = s.scorePercent < 40
            ? '0-4'
            : s.scorePercent < 60
            ? '4-6'
            : s.scorePercent < 80
            ? '6-8'
            : '8-10';
        buckets[bucket] = buckets[bucket]! + 1;
        bucketStudents[bucket]!.add(
          StudentScoreItem(
            studentId: s.studentId,
            studentName: s.studentName,
            score: s.scorePercent,
          ),
        );
      }

      // Sort mỗi bucket theo điểm giảm dần.
      for (final key in bucketStudents.keys) {
        bucketStudents[key]!.sort((a, b) => b.score.compareTo(a.score));
      }

      return SubjectDistribution(
        subjectName: info.title,
        distributionId: entry.key,
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

  /// Lấy submission_id MỚI NHẤT (không bị void) của 1 HS trong 1 đợt giao —
  /// để mở màn chấm bài làm khi GV bấm HS trong heatmap phân tích.
  /// Trả null nếu không tìm thấy. Ưu tiên bản chưa void; nếu chỉ có bản void thì lấy mới nhất.
  Future<String?> getSubmissionIdForStudent({
    required String distributionId,
    required String studentId,
  }) async {
    final res = await _client
        .from('submissions')
        .select('id, is_voided, created_at')
        .eq('assignment_distribution_id', distributionId)
        .eq('student_id', studentId)
        .order('created_at', ascending: false);

    final rows = List<Map<String, dynamic>>.from(res as List);
    if (rows.isEmpty) return null;
    final notVoided = rows.where((r) => r['is_voided'] != true).toList();
    final pick = notVoided.isNotEmpty ? notVoided.first : rows.first;
    return pick['id'] as String?;
  }

  /// Get class comparison for a student.
  /// REC-03 SECURITY: Uses Supabase RPC to compute class_average and percentile
  /// server-side. NO raw scores sent to client. This replaces the previous
  /// client-side calculation that fetched raw submission scores.
  Future<ClassComparison> getClassComparison(
    String studentId,
    String classId,
  ) async {
    try {
      final result = await _client.rpc(
        'get_student_peer_comparison',
        params: {'p_student_id': studentId, 'p_class_id': classId},
      );

      if (result == null) {
        return const ClassComparison();
      }

      return ClassComparison(
        classAverage: (result['class_average'] as num?)?.toDouble() ?? 0.0,
        percentile: (result['percentile'] as num?)?.toDouble() ?? 0.0,
        rank: (result['rank'] as int?) ?? 0,
        totalStudents: (result['total_students'] as int?) ?? 0,
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

  /// REC-03 (D-22): Fetch average skill mastery per objective for a class.
  /// Calls the SECURITY DEFINER RPC `get_class_average_skill_mastery`.
  /// Returns a map of objectiveId -> avg mastery (0.0-1.0). Empty on error.
  Future<Map<String, double>> getClassAverageSkillMastery(String classId) async {
    try {
      final result = await _client.rpc(
        'get_class_average_skill_mastery',
        params: {'p_class_id': classId},
      );

      if (result == null) return <String, double>{};

      final rows = result as List<dynamic>;
      final map = <String, double>{};
      for (final row in rows) {
        final r = row as Map<String, dynamic>;
        final objectiveId = r['objective_id'] as String?;
        // 5a-G3: PostgREST serialize numeric TABLE-column thành CHUỖI ("0.2000...") →
        // (as num?) = null → 0.0 mọi objective → radar lớp trắng. tryParse từ toString() an toàn cả số lẫn chuỗi.
        final avg = double.tryParse('${r['avg_mastery']}') ?? 0.0;
        if (objectiveId != null) {
          map[objectiveId] = avg;
        }
      }
      return map;
    } catch (e, st) {
      AppLogger.error(
        '[AnalyticsDatasource] getClassAverageSkillMastery error',
        error: e,
        stackTrace: st,
      );
      return <String, double>{};
    }
  }
}
