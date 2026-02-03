import 'package:ai_mls/core/services/supabase_service.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/data/datasources/assignment_datasource.dart';
import 'package:ai_mls/data/repositories/assignment_repository_impl.dart';
import 'package:ai_mls/domain/repositories/assignment_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Test script để verify chức năng save assignment draft và publish
///
/// Test này sẽ:
/// 1. Initialize Supabase
/// 2. Sign in với test user (hoặc sử dụng current user)
/// 3. Test create assignment
/// 4. Test save draft
/// 5. Test publish assignment
/// 6. Verify data trong database
/// 7. Cleanup test data
void main() {
  group('Assignment Creation & Save Draft Tests', () {
    late AssignmentRepository repository;
    late String testTeacherId;
    String? testAssignmentId;

    setUpAll(() async {
      // Initialize Supabase
      try {
        if (Supabase.instance.isInitialized) {
          // Already initialized
        } else {
          await SupabaseService.initialize(timeout: const Duration(seconds: 15));
        }
      } catch (e) {
        // If check fails, initialize anyway
        await SupabaseService.initialize(timeout: const Duration(seconds: 15));
      }

      // Get repository
      final client = SupabaseService.client;
      final assignmentDataSource = AssignmentDataSource(client);
      repository = AssignmentRepositoryImpl(assignmentDataSource);

      // Get current user ID (assumes user is already signed in)
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        throw Exception(
          'No user signed in. Please sign in before running tests.',
        );
      }
      testTeacherId = currentUser.id;
      AppLogger.info('✅ Test teacher ID: $testTeacherId');
    });

    tearDownAll(() async {
      // Cleanup: Delete test assignment if it exists
      if (testAssignmentId != null) {
        try {
          final client = SupabaseService.client;
          await client.from('assignments').delete().eq('id', testAssignmentId!);
          AppLogger.info('✅ Cleaned up test assignment: $testAssignmentId');
        } catch (e) {
          AppLogger.warning('⚠️ Failed to cleanup test assignment: $e');
        }
      }
    });

    test('Test 1: Create new assignment', () async {
      AppLogger.info('🧪 Test 1: Creating new assignment...');

      final assignmentData = {
        'teacher_id': testTeacherId,
        'title': 'Test Assignment - ${DateTime.now().millisecondsSinceEpoch}',
        'description': 'This is a test assignment created by automated test',
        'is_published': false,
        'due_at': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        'time_limit_minutes': 45,
        'total_points': 100.0,
      };

      final assignment = await repository.createAssignment(assignmentData);

      expect(assignment, isNotNull, reason: 'Assignment should be created');
      expect(assignment.id, isNotEmpty, reason: 'Assignment should have an ID');
      expect(assignment.teacherId, equals(testTeacherId),
          reason: 'Assignment should belong to test teacher');
      expect(assignment.isPublished, isFalse,
          reason: 'Assignment should not be published initially');
      expect(assignment.title, contains('Test Assignment'),
          reason: 'Assignment title should match');

      testAssignmentId = assignment.id;
      AppLogger.info('✅ Test 1 passed: Assignment created with ID: ${assignment.id}');
    });

    test('Test 2: Save draft with questions', () async {
      if (testAssignmentId == null) {
        // Create assignment first if not exists
        final assignmentData = {
          'teacher_id': testTeacherId,
          'title': 'Test Assignment Draft - ${DateTime.now().millisecondsSinceEpoch}',
          'description': 'Test assignment for draft',
          'is_published': false,
        };
        final assignment = await repository.createAssignment(assignmentData);
        testAssignmentId = assignment.id;
      }

      AppLogger.info('🧪 Test 2: Saving draft with questions...');

      final questions = [
        {
          'assignment_id': testAssignmentId,
          'question_id': null,
          'custom_content': {
            'type': 'multiple_choice',
            'text': 'What is 2 + 2?',
            'options': [
              {'text': '3', 'isCorrect': false},
              {'text': '4', 'isCorrect': true},
              {'text': '5', 'isCorrect': false},
              {'text': '6', 'isCorrect': false},
            ],
          },
          'points': 10.0,
          'order_idx': 1,
        },
        {
          'assignment_id': testAssignmentId,
          'question_id': null,
          'custom_content': {
            'type': 'essay',
            'text': 'Write a short essay about your favorite subject.',
          },
          'points': 20.0,
          'order_idx': 2,
        },
      ];

      final distributions = <Map<String, dynamic>>[];

      final assignmentPatch = {
        'title': 'Updated Test Assignment Draft',
        'total_points': 30.0,
      };

      final updatedAssignment = await repository.saveDraft(
        assignmentId: testAssignmentId!,
        assignmentPatch: assignmentPatch,
        questions: questions,
        distributions: distributions,
      );

      expect(updatedAssignment, isNotNull,
          reason: 'Assignment should be updated');
      expect(updatedAssignment.id, equals(testAssignmentId),
          reason: 'Assignment ID should remain the same');
      expect(updatedAssignment.title, equals('Updated Test Assignment Draft'),
          reason: 'Assignment title should be updated');

      // Verify questions were saved
      final savedQuestions = await repository.getAssignmentQuestions(testAssignmentId!);
      expect(savedQuestions.length, equals(2),
          reason: 'Should have 2 questions saved');
      expect(savedQuestions[0].points, equals(10.0),
          reason: 'First question should have 10 points');
      expect(savedQuestions[1].points, equals(20.0),
          reason: 'Second question should have 20 points');

      AppLogger.info('✅ Test 2 passed: Draft saved with ${savedQuestions.length} questions');
    });

    test('Test 3: Publish assignment', () async {
      if (testAssignmentId == null) {
        // Create assignment first if not exists
        final assignmentData = {
          'teacher_id': testTeacherId,
          'title': 'Test Assignment Publish - ${DateTime.now().millisecondsSinceEpoch}',
          'description': 'Test assignment for publishing',
          'is_published': false,
        };
        final assignment = await repository.createAssignment(assignmentData);
        testAssignmentId = assignment.id;

        // Add questions first
        final questions = [
          {
            'assignment_id': testAssignmentId,
            'question_id': null,
            'custom_content': {
              'type': 'multiple_choice',
              'text': 'Test question for publish',
              'options': [
                {'text': 'Option 1', 'isCorrect': false},
                {'text': 'Option 2', 'isCorrect': true},
              ],
            },
            'points': 10.0,
            'order_idx': 1,
          },
        ];
        await repository.saveDraft(
          assignmentId: testAssignmentId!,
          assignmentPatch: {},
          questions: questions,
          distributions: [],
        );
      }

      AppLogger.info('🧪 Test 3: Publishing assignment...');

      final assignmentData = {
        'id': testAssignmentId,
        'teacher_id': testTeacherId,
        'title': 'Published Test Assignment',
        'description': 'This assignment is published',
        'is_published': true,
        'due_at': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        'time_limit_minutes': 60,
        'total_points': 50.0,
      };

      final questions = [
        {
          'assignment_id': testAssignmentId,
          'question_id': null,
          'custom_content': {
            'type': 'multiple_choice',
            'text': 'Published question',
            'options': [
              {'text': 'A', 'isCorrect': false},
              {'text': 'B', 'isCorrect': true},
            ],
          },
          'points': 50.0,
          'order_idx': 1,
        },
      ];

      final distributions = <Map<String, dynamic>>[];

      final publishedAssignment = await repository.publishAssignment(
        assignment: assignmentData,
        questions: questions,
        distributions: distributions,
      );

      expect(publishedAssignment, isNotNull,
          reason: 'Assignment should be published');
      expect(publishedAssignment.id, equals(testAssignmentId),
          reason: 'Assignment ID should remain the same');
      expect(publishedAssignment.isPublished, isTrue,
          reason: 'Assignment should be published');
      expect(publishedAssignment.publishedAt, isNotNull,
          reason: 'Assignment should have published_at timestamp');

      // Verify questions were saved
      final savedQuestions = await repository.getAssignmentQuestions(testAssignmentId!);
      expect(savedQuestions.length, equals(1),
          reason: 'Should have 1 question saved');
      expect(savedQuestions[0].points, equals(50.0),
          reason: 'Question should have 50 points');

      AppLogger.info('✅ Test 3 passed: Assignment published successfully');
      AppLogger.info('   Published at: ${publishedAssignment.publishedAt}');
    });

    test('Test 4: Verify data persistence', () async {
      if (testAssignmentId == null) {
        fail('Test assignment ID is null. Run previous tests first.');
      }

      AppLogger.info('🧪 Test 4: Verifying data persistence...');

      // Fetch assignment from database
      final assignment = await repository.getAssignmentById(testAssignmentId!);
      expect(assignment, isNotNull, reason: 'Assignment should exist in database');
      expect(assignment.id, equals(testAssignmentId),
          reason: 'Assignment ID should match');

      // Fetch questions
      final questions = await repository.getAssignmentQuestions(testAssignmentId!);
      expect(questions.isNotEmpty, isTrue,
          reason: 'Assignment should have questions');

      // Verify assignment data
      expect(assignment.teacherId, equals(testTeacherId),
          reason: 'Assignment should belong to correct teacher');
      expect(assignment.title, isNotEmpty,
          reason: 'Assignment should have a title');

      AppLogger.info('✅ Test 4 passed: Data persistence verified');
      AppLogger.info('   Assignment: ${assignment.title}');
      AppLogger.info('   Questions: ${questions.length}');
      AppLogger.info('   Published: ${assignment.isPublished}');
    });

    test('Test 5: Error handling - Invalid assignment data', () async {
      AppLogger.info('🧪 Test 5: Testing error handling...');

      try {
        // Try to create assignment with invalid data (missing required fields)
        await repository.createAssignment({});
        fail('Should throw error for invalid assignment data');
      } catch (e) {
        expect(e, isNotNull, reason: 'Should catch error');
        AppLogger.info('✅ Test 5 passed: Error handling works correctly');
        AppLogger.info('   Error message: $e');
      }
    });
  });

  // Integration test: Full flow from create to publish
  test('Integration Test: Full assignment creation flow', () async {
    AppLogger.info('🧪 Integration Test: Full assignment creation flow...');

    // Initialize
    try {
      if (Supabase.instance.isInitialized) {
        // Already initialized
      } else {
        await SupabaseService.initialize(timeout: const Duration(seconds: 15));
      }
    } catch (e) {
      // If check fails, initialize anyway
      await SupabaseService.initialize(timeout: const Duration(seconds: 15));
    }

    final client = SupabaseService.client;
    final currentUser = client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('No user signed in. Please sign in before running tests.');
    }

    final assignmentDataSource = AssignmentDataSource(client);
    final repository = AssignmentRepositoryImpl(assignmentDataSource);
    final teacherId = currentUser.id;

    String? integrationTestAssignmentId;

    try {
      // Step 1: Create assignment
      final assignmentData = {
        'teacher_id': teacherId,
        'title': 'Integration Test Assignment - ${DateTime.now().millisecondsSinceEpoch}',
        'description': 'Full flow integration test',
        'is_published': false,
        'due_at': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        'time_limit_minutes': 45,
        'total_points': 100.0,
      };

      final assignment = await repository.createAssignment(assignmentData);
      integrationTestAssignmentId = assignment.id;
      AppLogger.info('✅ Step 1: Assignment created: ${assignment.id}');

      // Step 2: Save draft with questions
      final questions = [
        {
          'assignment_id': integrationTestAssignmentId,
          'question_id': null,
          'custom_content': {
            'type': 'multiple_choice',
            'text': 'Integration test question 1',
            'options': [
              {'text': 'A', 'isCorrect': false},
              {'text': 'B', 'isCorrect': true},
            ],
          },
          'points': 50.0,
          'order_idx': 1,
        },
        {
          'assignment_id': integrationTestAssignmentId,
          'question_id': null,
          'custom_content': {
            'type': 'essay',
            'text': 'Integration test question 2',
          },
          'points': 50.0,
          'order_idx': 2,
        },
      ];

      await repository.saveDraft(
        assignmentId: integrationTestAssignmentId,
        assignmentPatch: {'total_points': 100.0},
        questions: questions,
        distributions: [],
      );
      AppLogger.info('✅ Step 2: Draft saved with ${questions.length} questions');

      // Step 3: Publish assignment
      final publishData = Map<String, dynamic>.from(assignmentData);
      publishData['id'] = integrationTestAssignmentId;
      publishData['is_published'] = true;

      final publishedAssignment = await repository.publishAssignment(
        assignment: publishData,
        questions: questions,
        distributions: [],
      );
      AppLogger.info('✅ Step 3: Assignment published: ${publishedAssignment.id}');

      // Step 4: Verify final state
      final finalAssignment = await repository.getAssignmentById(integrationTestAssignmentId);
      expect(finalAssignment.isPublished, isTrue,
          reason: 'Assignment should be published');
      expect(finalAssignment.publishedAt, isNotNull,
          reason: 'Assignment should have published_at');

      final finalQuestions = await repository.getAssignmentQuestions(integrationTestAssignmentId);
      expect(finalQuestions.length, equals(2),
          reason: 'Should have 2 questions');

      AppLogger.info('✅ Integration Test passed: Full flow completed successfully');
      AppLogger.info('   Final state: Published=${finalAssignment.isPublished}, Questions=${finalQuestions.length}');
    } finally {
      // Cleanup
      if (integrationTestAssignmentId != null) {
        try {
          await client.from('assignments').delete().eq('id', integrationTestAssignmentId);
          AppLogger.info('✅ Cleaned up integration test assignment');
        } catch (e) {
          AppLogger.warning('⚠️ Failed to cleanup: $e');
        }
      }
    }
  });
}
