import 'package:objectbox/objectbox.dart';

// 1️⃣ Traits Model
@Entity()
class Trait {
  @Id()
  int id = 0;

  String name;
  String description;
  double red;
  double green;
  double blue;
  double alpha;
  int sortOrder;

  @Property(type: PropertyType.dateNano)
  DateTime lastModified;

  Trait({
    required this.name,
    required this.description,
    required this.red,
    required this.green,
    required this.blue,
    required this.alpha,
  })  : sortOrder = 0,
        lastModified = DateTime.now();
}

// 2️⃣ People Model
@Entity()
class Person {
  @Id()
  int id = 0;

  String name;

  final traits = ToMany<Trait>();
  List<String> comments = [];
  int sortOrder;

  @Property(type: PropertyType.dateNano)
  DateTime lastModified;

  Person({required this.name})
      : sortOrder = 0,
        lastModified = DateTime.now();
}

@Entity()
class Daily {
  @Id()
  int id = 0;

  String title;
  List<String> comments = [];
  int sortOrder;

  @Property(type: PropertyType.dateNano)
  DateTime lastModified;

  Daily({required this.title})
      : sortOrder = 0,
        lastModified = DateTime.now();
}

@Entity()
class Category {
  @Id()
  int id = 0;

  String title;
  List<String> comments = [];

  int sortOrder;

  @Property(type: PropertyType.dateNano)
  DateTime lastModified;

  Category({required this.title})
      : sortOrder = 0,
        lastModified = DateTime.now();
}
