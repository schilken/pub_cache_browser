import 'package:pub_cache_browser/providers/epub_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('epub repository ...', (tester) async {
    final sut = EpubRepository();
    const filePath =
//        '/Users/aschilken/Downloads/epub_books/Hermann Scherer - Find Your Frame.epub';
        '/Users/aschilken/Downloads/epub_books/Heidenreich, Elke - Alles kein Zufall.epub';
    await sut.parseContent(filePath);
  });
}
