import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: ListUserDataPage());
  }
}

class UserModel {
  int? id;
  String nama;
  int umur;

  UserModel(this.id, {required this.nama, required this.umur});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(json["id"], nama: json["nama"], umur: json["umur"]);
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "nama": nama, "umur": umur};
  }
}

class DatabaseHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    String path = p.join(await getDatabasesPath(), "user_db.db");

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, nama TEXT, umur INTEGER)",
        );
      },
    );
  }

  static Future<void> insert(UserModel user) async {
    final db = await database;
    await db.insert("users", user.toJson());
  }

  static Future<List<UserModel>> getAll() async {
    final db = await database;
    final data = await db.query("users");
    return data.map((e) => UserModel.fromJson(e)).toList();
  }

  static Future<void> update(UserModel user) async {
    final db = await database;
    await db.update("users", user.toJson(), where: "id=?", whereArgs: [user.id]);
  }

  static Future<void> delete(int id) async {
    final db = await database;
    await db.delete("users", where: "id=?", whereArgs: [id]);
  }
}

class ListUserDataPage extends StatefulWidget {
  const ListUserDataPage({super.key});

  @override
  State<ListUserDataPage> createState() => _ListUserDataPageState();
}

class _ListUserDataPageState extends State<ListUserDataPage> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _umurCtrl = TextEditingController();

  List<UserModel> userList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    userList = await DatabaseHelper.getAll();
    setState(() {});
  }

  void _save(int? id) async {
    if (id == null) {
      await DatabaseHelper.insert(
        UserModel(null, nama: _nameCtrl.text, umur: int.parse(_umurCtrl.text)),
      );
    } else {
      await DatabaseHelper.update(
        UserModel(id, nama: _nameCtrl.text, umur: int.parse(_umurCtrl.text)),
      );
    }
    _loadData();
    Navigator.pop(context);
  }

  void _delete(int id) async {
    await DatabaseHelper.delete(id);
    _loadData();
  }

  void _form(int? id) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameCtrl),
            TextField(controller: _umurCtrl),
            ElevatedButton(
              onPressed: () => _save(id),
              child: Text(id == null ? "Tambah" : "Update"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SQLite CRUD")),
      body: ListView.builder(
        itemCount: userList.length,
        itemBuilder: (_, i) => ListTile(
          title: Text(userList[i].nama),
          subtitle: Text("Umur: ${userList[i].umur}"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(onPressed: () => _form(userList[i].id), icon: const Icon(Icons.edit)),
              IconButton(onPressed: () => _delete(userList[i].id!), icon: const Icon(Icons.delete)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _form(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}