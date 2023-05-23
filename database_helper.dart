import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  final String contactTable = 'contacts';
  final String idColumn = 'id';
  final String nameColumn = 'name';
  final String phoneColumn = 'phone';
  final String databaseName = 'phonebook.db';

  static final DatabaseHelper _instance = DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper.internal();
  late Database _db;

  Future<Database> get db async {
    _db = await initDb();
      return _db;
  }

  // initDb()

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, databaseName);
    return await openDatabase(path, version: 1,
        onCreate: (db, newerVersion) async {
      await db.execute("""CREATE TABLE "$contactTable" (
	"$idColumn"	INTEGER,
	"$nameColumn"	TEXT NOT NULL,
	"$phoneColumn"	TEXT NOT NULL,
	PRIMARY KEY("$idColumn" AUTOINCREMENT)
)
""");
    });
  }

  // saveContact(

  Future<int> saveContact(Contact contact) async {
    var dbClient = await db;
    var result = await dbClient.insert(contactTable, contact.toMap());
    return result;
  }


  // getContacts() List<Contact>

  Future<List<Contact>> getContacts() async {
    var dbClient = await db;
    var result = await dbClient.query(contactTable, columns: [idColumn, nameColumn, phoneColumn]);
    return result.map((item) => Contact.fromMap(item)).toList();
  }




  // getContact()
  Future<Contact> getContact(int id) async {
    var dbClient = await db;
    var result = await dbClient.rawQuery('SELECT * FROM $contactTable WHERE $idColumn = $id');
    if (result.length > 0) {
      return Contact.fromMap(result.first);
    }
   throw Exception('Contact not found');
  } 

  // deleteContact()
  Future<int> deleteContact(int id) async {
    var dbClient = await db;
    return await dbClient.delete(contactTable, where: '$idColumn = ?', whereArgs: [id]);
  }  

  // updateContact()
  Future<int> updateContact(Contact contact) async {
    var dbClient = await db;
    return await dbClient.update(contactTable, contact.toMap(), where: '$idColumn = ?', whereArgs: [contact.id]);
  }

 
}

// create class Contact
class Contact{
  late int id;
  late String name;
  late String phone;

  Contact({required this.id, required this.name,required this.phone});

  // Convert Contact to Map
  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{
      'name': name,
      'phone': phone
    };
    return map;
  }

  // Convert Map to Contact
  Contact.fromMap(Map<String, dynamic> map){
    id = map['id'];
    name = map['name'];
    phone = map['phone'];
  }
}