import 'package:flutter_test/flutter_test.dart';
import 'package:inventory/utils/text_normalize.dart';

void main() {
  test('normalizeVi drops diacritics and case', () {
    expect(normalizeVi('Bàn Đèn'), 'ban den');
    expect(normalizeVi('ĐỒ ĐẠC'), 'do dac');
    expect(normalizeVi('Nguyễn Thị Thu Hương'), 'nguyen thi thu huong');
    expect(normalizeVi('Tủ lạnh – Ngăn mát'), 'tu lanh – ngan mat');
    expect(normalizeVi('Plain ASCII 123'), 'plain ascii 123');
    expect(normalizeVi(''), '');
  });

  test('every Vietnamese letter maps to its base letter', () {
    const base = {
      'a': 'àáạảãâầấậẩẫăằắặẳẵ',
      'e': 'èéẹẻẽêềếệểễ',
      'i': 'ìíịỉĩ',
      'o': 'òóọỏõôồốộổỗơờớợởỡ',
      'u': 'ùúụủũưừứựửữ',
      'y': 'ỳýỵỷỹ',
      'd': 'đ',
    };
    base.forEach((plain, accented) {
      for (final ch in accented.split('')) {
        expect(normalizeVi(ch), plain, reason: ch);
        expect(normalizeVi(ch.toUpperCase()), plain, reason: ch.toUpperCase());
      }
    });
  });

  test('text typed with combining marks matches too', () {
    // "ban" + U+0300 (decomposed "bàn")
    expect(normalizeVi('bàn'), 'ban');
    expect(normalizeVi('ế'), 'e');
  });

  test('containsNormalized matches across accents and ignores null', () {
    expect(containsNormalized('Bàn làm việc', normalizeVi('ban lam')), isTrue);
    expect(containsNormalized('Bàn làm việc', normalizeVi('BÀN')), isTrue);
    expect(containsNormalized('Ghế', normalizeVi('ban')), isFalse);
    expect(containsNormalized(null, 'x'), isFalse);
  });
}
