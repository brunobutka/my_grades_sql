
import 'package:flutter/material.dart';
import 'package:my_grades/add.dart';
import 'package:my_grades/gradle.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ListGrades extends StatefulWidget {
  const ListGrades({super.key});

  @override
  _ListGradesState createState() => _ListGradesState();
}

class _ListGradesState extends State<ListGrades> {
  late Future<Database> database;
  late List<Gradle> gradleList;

  @override
  void initState() {
    super.initState();
    database = getDatabase();
    gradleList = <Gradle>[];
    readAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notas"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Future<dynamic> future = Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddGradle(),
                ),
              );
              future.then((gradle) {
                setState(() {
                  gradleList.add(gradle);
                });
                insertGradle(gradle);
              });
            },
          )
        ],
      ),
      body: ListView.separated(
        itemCount: gradleList.length,
        itemBuilder: (context, index) => buildListItem(index),
        separatorBuilder: (context, index) => const Divider(
          height: 1,
        ),
      ),
    );
  }

  Widget buildListItem(int index) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          leading: Text("${gradleList[index].id}"),
          trailing: Text("${gradleList[index].value}"),
          title: Text(gradleList[index].subject),
          subtitle: Text(gradleList[index].phase),
          onLongPress: () {
            deleteGradle(index);
          },
        ),
      ),
    );
  }

  Future<Database> getDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'my_grades.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE gradles(id INTEGER PRIMARY KEY AUTOINCREMENT, subject TEXT, phase TEXT, value REAL)",
        );
      },
      version: 1,
    );
  }

  Future<void> readAll() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('gradles');

    setState(() {
      gradleList = List.generate(maps.length, (i) {
        return Gradle(
          id: maps[i]['id'],
          subject: maps[i]['subject'],
          phase: maps[i]['phase'],
          value: maps[i]['value'],
        );
      });
    });
  }

  Future<void> insertGradle(Gradle gradle) async {
    final db = await getDatabase();

    await db.insert(
      'gradles',
      gradle.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    readAll();
  }

  Future<void> deleteGradle(int id) async {
    final db = await getDatabase();

    await db.delete(
      'gradles',
      // Use a `where` clause to delete a specific dog.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [gradleList[id].id],
    );
    readAll();
  }
}