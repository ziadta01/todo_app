import 'package:flutter/material.dart';
import 'package:todo_app/shared/cubit/cubit.dart';

Widget textFieldBuilder({
  bool readOnly = false,
  bool showCursor = false,
  required TextEditingController? controller,
  TextInputType type = TextInputType.text,
  required String? label,
  bool isPassword = false,
  required Icon? prefixIcon,
  Icon? suffixIcon,
  double borderRadius = 5.0,
  required String? Function(String?)? validator,
  void Function()? onTap,
  void Function(String)? onSubmit,
}) {
  return TextFormField(
    readOnly: readOnly,
    showCursor: showCursor,
    controller: controller,
    keyboardType: type,
    onFieldSubmitted: onSubmit,
    onTap: onTap,
    validator: validator,
    obscureText: isPassword,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    ),
  );
}

Widget buildListItem(Map model, BuildContext context) {
  return Dismissible(
    onDismissed: (directon) {
      AppCubit.get(context).deleteDatabase(id: model['id']);
    },
    key: Key(model['id'].toString()),
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40.0,
            child: Text(
              '${model["time"]}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${model["title"]}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${model["date"]}',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 20,
          ),
          IconButton(
            icon: Icon(
              Icons.check_box,
              color: Colors.green[400],
            ),
            onPressed: () {
              AppCubit.get(context).updateDatabase(
                status: 'done',
                id: model['id'],
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.archive_rounded,
              color: Colors.grey[600],
            ),
            onPressed: () {
              AppCubit.get(context).updateDatabase(
                status: 'archived',
                id: model['id'],
              );
            },
          ),
        ],
      ),
    ),
  );
}
