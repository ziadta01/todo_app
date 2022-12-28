// ignore_for_file: must_be_immutable, import_of_legacy_library_into_null_safe, body_might_complete_normally_nullable

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';


class HomeLayout extends StatelessWidget {
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppState>(
        listener: (context, state) {},
        builder: (context, state) {
          AppCubit cubit = AppCubit.get(context);
          return Form(
            key: formKey,
            child: Scaffold(
              key: scaffoldKey,
              appBar: AppBar(
                title: Text(
                  'Todo App',
                ),
                centerTitle: true,
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  if (cubit.isBottomBarShown) {
                    if (formKey.currentState!.validate()) {
                      cubit
                          .insertToDatabase(
                        title: titleController.text,
                        date: dateController.text,
                        time: timeController.text,
                      )
                          .then((value) {
                        Navigator.pop(context);
                      });
                    }
                  } else {
                    scaffoldKey.currentState!
                        .showBottomSheet((context) {
                          return Container(
                            color: Colors.grey[100],
                            padding: EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 11,
                                ),
                                textFieldBuilder(
                                  controller: titleController,
                                  label: 'Task Title',
                                  prefixIcon: Icon(Icons.title),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Task Title Must not be empty';
                                    }
                                  },
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                textFieldBuilder(
                                  readOnly: true,
                                  showCursor: true,
                                  onTap: () {
                                    showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    ).then((value) {
                                      timeController.text =
                                          value!.format(context).toString();
                                    });
                                  },
                                  controller: timeController,
                                  type: TextInputType.datetime,
                                  label: 'Task Time',
                                  prefixIcon: Icon(Icons.watch_later_outlined),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Task Title Must not be empty';
                                    }
                                  },
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                textFieldBuilder(
                                  readOnly: true,
                                  showCursor: true,
                                  onTap: () {
                                    showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.parse('2032-12-31'),
                                    ).then(
                                      (value) {
                                        dateController.text = DateFormat.yMMMd()
                                            .format(value!)
                                            .toString();
                                      },
                                    );
                                  },
                                  controller: dateController,
                                  type: TextInputType.datetime,
                                  label: 'Task Date',
                                  prefixIcon: Icon(Icons.calendar_today),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Task Title Must not be empty';
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        })
                        .closed
                        .then((value) {
                          cubit.changeBottomSheetState(
                              isShow: false, icon: Icons.edit);
                        });
                    cubit.changeBottomSheetState(
                      isShow: true,
                      icon: Icons.add,
                    );
                  }
                },
                child: Icon(
                  cubit.fabIcon,
                ),
              ),
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.blue,
                fixedColor: Colors.white,
                currentIndex: cubit.currentIndex,
                onTap: (index) {
                  cubit.changeIndex(index);
                },
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.menu),
                    label: 'New Tasks',
                  ),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.check_circle_outline),
                      label: 'Done Tasks'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.archive_outlined),
                      label: 'Archived Tasks'),
                ],
              ),
              body: ConditionalBuilder(
                builder: (context) {
                  return cubit.screens[cubit.currentIndex];
                },
                fallback: (context) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
                condition: state is! AppDatabaseLoadingState,
              ),
            ),
          );
        },
      ),
    );
  }
}
