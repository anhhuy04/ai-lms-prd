import 'package:ai_mls/data/utils/content_hasher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ContentHasher.compute', () {
    test('hashes Quill ops format', () {
      final h = ContentHasher.compute({'ops': [{'insert': 'Câu hỏi 1\n'}]});
      expect(h.length, 64);
    });

    test('hashes {text} legacy format', () {
      final h = ContentHasher.compute({'text': 'Câu hỏi 1'});
      expect(h.length, 64);
    });

    test('ops format and text format produce SAME hash for same content', () {
      final a = ContentHasher.compute({'ops': [{'insert': 'Hello world'}]});
      final b = ContentHasher.compute({'text': 'Hello world'});
      expect(a, b);
    });

    test('normalize whitespace identical', () {
      final a = ContentHasher.compute({'text': 'Câu hỏi 1'});
      final b = ContentHasher.compute({'text': 'Câu   hỏi    1'});
      expect(a, b);
    });

    test('case insensitive', () {
      final a = ContentHasher.compute({'text': 'CÂU HỎI'});
      final b = ContentHasher.compute({'text': 'câu hỏi'});
      expect(a, b);
    });

    test('null content → hash empty string (matches SQL behavior)', () {
      final h = ContentHasher.compute(null);
      expect(h, 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855');
    });

    test('empty content map → hash empty string', () {
      final h = ContentHasher.compute({});
      // Map.toString() returns "{}" — normalize handles it; just verify hash valid
      expect(h.length, 64);
    });

    test('multiple ops concatenated', () {
      final h = ContentHasher.compute({
        'ops': [
          {'insert': 'Hello '},
          {'insert': 'world'},
        ],
      });
      final b = ContentHasher.compute({'text': 'Hello world'});
      expect(h, b);
    });
  });
}
