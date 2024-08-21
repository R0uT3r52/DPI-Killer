import 'package:flutter/material.dart';

class CheckBoxList extends StatefulWidget {
  final List<List<dynamic>> settings;

  const CheckBoxList({super.key, required this.settings});

  @override
  // ignore: library_private_types_in_public_api
  _CheckBoxListState createState() => _CheckBoxListState();
}

class _CheckBoxListState extends State<CheckBoxList> {

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.settings.length,
      itemBuilder: (context, index) {
        return CheckboxListTile(
          title: Text(widget.settings[index][0]),
          value: widget.settings[index][2],
          onChanged: (bool? value) {

            setState(() {
              widget.settings[index][2] = value ?? false;
            });

            if(index == 0 && widget.settings[index][2] != false && widget.settings[1][2] != false){
              widget.settings[1][2] = false;
            }
            else if(index == 1 && widget.settings[index][2] != false && widget.settings[0][2] != false){
              widget.settings[0][2] = false;
            }
            setState(() {});
          },
        );
      },
    );
  }
}
