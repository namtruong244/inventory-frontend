// Text helpers for matching what people type against what they stored.

const _accented =
    'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
const _plain =
    'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';

final _combiningMarks = RegExp(r'[\u0300-\u036f]');

/// Lower-cases [text] and removes Vietnamese diacritics ("Bàn Đèn" -> "ban den"),
/// so "ban" finds "bàn". Text typed with combining marks (decomposed Unicode) works too.
String normalizeVi(String text) {
  final buffer = StringBuffer();
  for (final rune in text.toLowerCase().replaceAll(_combiningMarks, '').runes) {
    final char = String.fromCharCode(rune);
    final at = _accented.indexOf(char);
    buffer.write(at == -1 ? char : _plain[at]);
  }
  return buffer.toString();
}

/// True when [haystack] contains [normalizedQuery] ignoring case and diacritics.
/// [normalizedQuery] must already have gone through [normalizeVi].
bool containsNormalized(String? haystack, String normalizedQuery) =>
    haystack != null && normalizeVi(haystack).contains(normalizedQuery);
