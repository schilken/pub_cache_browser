// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io' as io;

import 'package:epub_view/epub_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mixin_logger/mixin_logger.dart' as log;

import '../models/epub_content_record.dart';

class EpubRepository {
  late EpubBook epubBook;

  Future<List<EpubContentRecord>> parseContent(String filePath) async {
    final targetFile = io.File(filePath);
    final bytes = targetFile.readAsBytesSync();

// Opens a book and reads all of its content into memory
    epubBook = await EpubReader.readBook(bytes);

// COMMON PROPERTIES

// Book's title
    var title = epubBook.title;
    debugPrint('title: $title');

// Book's authors (comma separated list)
    var author = epubBook.author;
    debugPrint('author: $author');

// Book's authors (list of authors names)
    var authors = epubBook.authorList;

// Book's cover image (null if there is no cover)
    var coverImage = epubBook.coverImage;
    debugPrint('coverImage: $coverImage');

    final records = <EpubContentRecord>[];
// Book's content (HTML files, stylesheets, images, fonts, etc.)
    var bookContent = epubBook.content;
    if (bookContent != null) {
      for (final entry in bookContent.allFiles.entries) {
        debugPrint('${entry.key}  ${entry.value} ');
        late String type;
        late int size;
        if (entry.value is EpubTextContentFile) {
          type = 'TextContent';
          size = (entry.value as EpubTextContentFile).content?.length ?? 0;
        } else {
          type = 'ByteContent';
          size = (entry.value as EpubByteContentFile).content?.length ?? 0;
        }
        final record =
            EpubContentRecord(fileName: entry.key, size: size, type: type);
        records.add(record);
      }
    }
    return records;
// CHAPTERS

// Enumerating chapters
    for (final chapter in epubBook.chapters!) {
      // Title of chapter
      var chapterTitle = chapter.title;

      // HTML content of current chapter
      var chapterHtmlContent = chapter.htmlContent;

      // Nested chapters
      var subChapters = chapter.subChapters;
    }

// CONTENT

// IMAGES

// // All images in the book (file name is the key)
//     var imagesMap = bookContent!.Images;

//     EpubByteContentFile firstImage = imagesMap.values.first;

// // Content type (e.g. EpubContentType.IMAGE_JPEG, EpubContentType.IMAGE_PNG)
//     var contentType = firstImage.ContentType;

// // MIME type (e.g. "image/jpeg", "image/png")
//     var mimeContentType = firstImage.ContentMimeType;

// // HTML & CSS

// // All XHTML files in the book (file name is the key)
//     var htmlFilesMap = bookContent.Html;

// // All CSS files in the book (file name is the key)
//     var cssFilesMap = bookContent!.Css;

// // Entire HTML content of the book
//     htmlFilesMap.values.forEach((EpubTextContentFile htmlFile) {
//       String htmlContent = htmlFile.Content;
//     });

// // All CSS content in the book
//     cssFilesMap.values.forEach((EpubTextContentFile cssFile) {
//       String cssContent = cssFile.Content;
//     });

// // OTHER CONTENT

// // All fonts in the book (file name is the key)
//     Map<String, EpubByteContentFile> fonts = bookContent.Fonts;

// // All files in the book (including HTML, CSS, images, fonts, and other types of files)
//     Map<String, EpubContentFile> allFiles = bookContent.AllFiles;

// // ACCESSING RAW SCHEMA INFORMATION

// // EPUB OPF data
//     EpubPackage package = epubBook.Schema.Package;

// // Enumerating book's contributors
//     package.Metadata.Contributors
//         .forEach((EpubMetadataContributor contributor) {
//       String contributorName = contributor.Contributor;
//       String contributorRole = contributor.Role;
//     });

// // EPUB NCX data
//     EpubNavigation navigation = epubBook.Schema.Navigation;

// // Enumerating NCX metadata
//     navigation.Head.Metadata.forEach((EpubNavigationHeadMeta meta) {
//       String metadataItemName = meta.Name;
//       String metadataItemContent = meta.Content;
//     });
  }

  Uint8List getImageBytes(String fileName) {
    final fileContent = epubBook.content!.allFiles[fileName];
    if (fileContent is EpubByteContentFile) {
      return Uint8List.fromList(fileContent.content ?? <int>[]);
    }
    return Uint8List.fromList(<int>[]);
  }

  String getText(String fileName) {
    final fileContent = epubBook.content!.allFiles[fileName];
    if (fileContent is EpubTextContentFile) {
      return fileContent.content ?? '';
    }
    return '';
  }

}

final epubRepositoryProvider = Provider<EpubRepository>((ref) {
  final fileSystemRepository = EpubRepository();
  return fileSystemRepository;
});
