abstract class SearchEvent {}

class SearchInvoices extends SearchEvent {
  final String keyword;

  SearchInvoices(this.keyword);
}