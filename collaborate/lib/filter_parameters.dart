//this class is used to filter the groups based on user filters
class FilterParameters {
  final List category;
  final List domains;
  final bool? isMember;

  FilterParameters(
      {required this.category, required this.domains, this.isMember});
}
