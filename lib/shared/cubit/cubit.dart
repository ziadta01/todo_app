// ignore_for_file: body_might_complete_normally_nullable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archivedscreen.dart';
import 'package:todo_app/modules/donescreen.dart';
import 'package:todo_app/modules/newscreen.dart';
import 'package:todo_app/shared/cubit/states.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppInitlializeState());
  static AppCubit get(context) => BlocProvider.of(context);
  int currentIndex = 0;

  bool isBottomBarShown = false;
  IconData fabIcon = Icons.edit;

  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  Database? myDB;

  List<Widget> screens = [
    NewTasks(),
    DoneTasks(),
    ArchivedTasks(),
  ];

  void changeIndex(index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  void createDatabase() {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (myDB, version) {
        print('DataBase Created');
        myDB
            .execute(
          'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)',
        )
            .then((value) {
          print('Table Created');
        }).catchError((error) {
          print('Error while creating database : ${error.toString()}');
        });
      },
      onOpen: (myDB) {
        getFromDatabase(myDB);
      },
    ).then((value) {
      myDB = value;
      emit(AppCreateDatabaseState());
    });
  }

  int? id;

  insertToDatabase({
    required String title,
    required String date,
    required String time,
  }) async {
    await myDB!.transaction((txn) async {
      id = await txn
          .rawInsert(
              'INSERT INTO tasks (title,date,time,status) VALUES("$title", "$date", "$time", "new")')
          .then((value) {
        print('$value Done Inserting Successfully');
        getFromDatabase(myDB!);
      });
    });
  }

  void getFromDatabase(Database myDB) {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
    emit(AppDatabaseLoadingState());
    myDB.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element) {
        if (element['status'] == 'new') {
          newTasks.add(element);
        } else if (element['status'] == 'done') {
          doneTasks.add(element);
        } else {
          archivedTasks.add(element);
        }
      });
      emit(AppGetDatabaseState());
    });
  }

  void changeBottomSheetState({
    required bool? isShow,
    required IconData? icon,
  }) {
    isBottomBarShown = isShow!;
    fabIcon = icon!;
    emit(AppChangeBottomSheetState());
  }

  updateDatabase({
    required String? status,
    required int? id,
  }) async {
    return await myDB!.rawUpdate(
      'UPDATE tasks SET status = ? WHERE id = ?',
      ['$status', id],
      // ignore: missing_return
    ).then((value) {
      getFromDatabase(myDB!);
      emit(AppUpdateDatabaseState());
    });
  }

  void deleteDatabase({required int id}) {
    myDB!.rawDelete('DELETE FROM tasks WHERE id = ?', ['$id']).then((value) {
      getFromDatabase(myDB!);
      emit(AppDeleteDatabaseState());
    });
  }
}
