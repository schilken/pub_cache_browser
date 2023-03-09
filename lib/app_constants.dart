abstract class Constants {
  static const maxGitMessages = 300;
}

enum DateRange {
  halfYear(180, 'Half Year'),
  oneYear(360, 'One Year'),
  twoYears(720, 'Two Years');

  final int value;
  final String displayName;

  const DateRange(
    this.value,
    this.displayName,
  );
}

enum SortOrder {
  projectName('File Name'),
  versionCount('Version Count'),
  diskUsage('Disk Usage');

  final String displayName;

  const SortOrder(
    this.displayName,
  );
}

enum DetailDisplayMode {
  heatMap('Heat Map'),
  heatMapWithAll('Heat Map with All Projects'),
  commitMessage('Commit Messages'),
  diskSpaceUsage('Disk Space Usage'),
  linesOfCode('Lines Of Code');

  final String displayName;

  const DetailDisplayMode(
    this.displayName,
  );
}
