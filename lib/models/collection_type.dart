// Collection Type

class CollectionType {
  final String id;
  final String name;
  final String iconName;
  final bool isCustom; // Default or custom collection

  const CollectionType({
    required this.id,
    required this.name,
    required this.iconName,
    this.isCustom = false,
  });

  static const List<CollectionType> defaults = [
    CollectionType(id: 'cds',     name: 'CDs',    iconName: 'album'),
    CollectionType(id: 'dvds',    name: 'DVDs',   iconName: 'movie'),
    CollectionType(id: 'books',   name: 'Books',  iconName: 'menu_book'),
  ];
}
