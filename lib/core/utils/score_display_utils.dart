/// Utility class for formatting score display values.
/// All analytics scores use /10 scale via [toRawString].
class ScoreDisplayUtils {
  ScoreDisplayUtils._();

  /// Formats a raw score as a displayable string (1 decimal place).
  /// Used throughout analytics screens for /10 scale display.
  /// e.g., toRawString(8.5) returns "8.5"
  static String toRawString(double score) {
    return score.toStringAsFixed(1);
  }
}
