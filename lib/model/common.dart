class SearchResult<T> {
  final int offSet;
  final int pageSize;
  final int startIndex;
  final int endIndex;
  final int totalRecords;
  final List<T> elements;

  SearchResult({
    required this.offSet,
    required this.pageSize,
    required this.startIndex,
    required this.endIndex,
    required this.totalRecords,
    required this.elements,
  });

  SearchResult.empty({
    required this.offSet,
    required this.pageSize,
  })  : startIndex = 0,
        endIndex = 0,
        totalRecords = 0,
        elements = [];
}
