/// One page of a cursor-paginated collection.
class Paginated<T> {
  const Paginated({required this.items, this.nextCursor, this.hasNext = false});

  final List<T> items;

  /// Pass back as the `cursor` query parameter to fetch the next page.
  final String? nextCursor;
  final bool hasNext;

  Paginated<R> map<R>(R Function(T) convert) => Paginated(
    items: items.map(convert).toList(),
    nextCursor: nextCursor,
    hasNext: hasNext,
  );
}
