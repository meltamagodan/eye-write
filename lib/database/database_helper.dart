import 'models.dart';
import 'objectbox.g.dart';

class DatabaseHelper {
  static late Store store;
  static late Box<Trait> traitBox;
  static late Box<Person> personBox;
  static late Box<Daily> dailyBox;
  static late Box<Category> categoryBox;


  // Initialize Database
  static Future<void> init() async {
    store = await openStore();
    traitBox = store.box<Trait>();
    personBox = store.box<Person>();
    dailyBox = store.box<Daily>();
    categoryBox = store.box<Category>();
  }

  // Update order of data
  static void updateTraitOrder(List<Trait> updatedTraits) {
    for (int i = 0; i < updatedTraits.length; i++) {
      updatedTraits[i].sortOrder = i + 1;
    }
    traitBox.putMany(updatedTraits);
  }

  static void updatePersonOrder(List<Person> updatedPeople) {
    for (int i = 0; i < updatedPeople.length; i++) {
      updatedPeople[i].sortOrder = i + 1;
    }
    personBox.putMany(updatedPeople);
  }


  // Get Data Sorted By sortOrder Column
  static List<Trait> getAllTraits() {
    final query = traitBox.query()..order(Trait_.sortOrder);
    return query.build().find();
  }

  static List<Person> getAllPeople() {
    final query = personBox.query()..order(Person_.sortOrder);
    return query.build().find();
  }

  static List<Daily> getAllDailies() {
    final query = dailyBox.query()..order(Daily_.sortOrder);
    return query.build().find();
  }

  static List<Category> getAllCategories() {
    final query = categoryBox.query()..order(Category_.sortOrder);
    return query.build().find();
  }


  // Close Database
  static void close(){
    store.close();
  }
}
