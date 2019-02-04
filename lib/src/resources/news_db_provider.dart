import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'dart:async';
import '../models/item_model.dart';

class NewsDbProvider {
  //Instance var - sql lite db
  Database db;

  //we can't use async on a constructor, so we will use an init method
  init() async {
    //this is provided by the path_provider. This gets a folder from our device, so we can store items- so refernce to directory
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    //reference to db itself
    final path = join(documentsDirectory.path, 'items.db');

    //Create or open db
    db = await openDatabase(
      path, // is there something at this location? if yes open otherwise create
      version: 1,
      onCreate: (Database newDb, int version) {
        // this is called when the user opens our app for the very first time
        newDb.execute("""
            CREATE TABLE Items
              (
                id INTEGER PRIMARY KEY,
                type TEXT,
                by TEXT, 
                time INTEGER, 
                text TEXT, 
                parent INTEGER, 
                kids BLOB, 
                dead INTEGER, 
                deleted INTEGER,
                url TEXT,
                score INTEGER,
                title TEXT, 
                descendants INTEGER
              )
          """);
      },
    );
  }

  fetchItem(int id) async {
    final maps = await db.query(
      'Items',
      columns: null, //will allow us to get all
      where: "id = ?", //search clause
      whereArgs: [id], //this will replace the ? in the where
    );

    if (maps.length > 0) {
      return ItemModel.fromDb(maps.first);
    }

    return null;
  }

  addItem(ItemModel item) {
    return db.insert('Items', item.toMapForDb());
  }
}
