import 'package:flutter/material.dart';
import './model.dart';
import './database_helper.dart';
import 'package:auto_direction/auto_direction.dart';

class TypingPage extends StatefulWidget {
  final id;
  TypingPage([this.id]);
  @override
  _TypingPageState createState() => _TypingPageState();
}

class _TypingPageState extends State<TypingPage> {
  bool valid1 = true, valid2 = true;
  final controllerTitle = TextEditingController();
  final controllerContent = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.id != null) {
      DatabaseHelper().getNote(widget.id).then((val) {
        Notes n = Notes.fromDataBase(val[0]);
        setState(() {
          controllerTitle.text = n.title;
          controllerContent.text = n.content;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.vertical,
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/bg2.jpg'), fit: BoxFit.cover),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              AutoDirection(
                text: controllerTitle.text,
                child: TextField(
                  onChanged: (_) {
                    setState(() {});
                  },
                  onTap: () {
                    setState(() {
                      valid1 = true;
                    });
                  },
                  controller: controllerTitle,
                  cursorColor: Colors.red[300],
                  decoration: InputDecoration(
                    labelText: 'Title',
                    errorText: !valid1 ? 'Type note`s title !' : null,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25)),
                    filled: true,
                    fillColor: Colors.red[50].withOpacity(0.4),
                  ),
                  maxLength: 50,
                ),
              ),
              AutoDirection(
                text: controllerContent.text,
                child: TextField(
                  onChanged: (_) {
                    setState(() {});
                  },
                  onTap: () {
                    setState(() {
                      valid2 = true;
                    });
                  },
                  controller: controllerContent,
                  cursorColor: Colors.red[300],
                  decoration: InputDecoration(
                    labelText: 'Content',
                    errorText: !valid2 ? 'Type note`s content !' : null,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25)),
                    filled: true,
                    fillColor: Colors.red[50].withOpacity(0.4),
                  ),
                  maxLines: 12,
                ),
              ),
              RaisedButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    if (validation()) {
                      widget.id == null
                          ? addNewNote().then((_) {
                              Navigator.pop(context);
                            })
                          : updateANote().then((_) {
                              Navigator.pop(context);
                            });
                    }
                  });
                },
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(widget.id == null ? 'Add' : 'Update'),
                elevation: 0.1,
                textColor: Colors.white,
                color: Colors.red[200].withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  bool validation() {
    if (controllerTitle.text.trim().isEmpty) {
      valid1 = false;
    }
    if (controllerContent.text.trim().isEmpty) {
      valid2 = false;
    }
    return valid1 & valid2;
  }

  Future<void> addNewNote() async {
    await DatabaseHelper()
        .insertNote(Notes(controllerTitle.text, controllerContent.text));
  }

  Future<void> updateANote() async {
    await DatabaseHelper().updateNote(Notes.fromDataBase({
      'id': widget.id,
      'title': controllerTitle.text,
      'content': controllerContent.text
    }));
  }
}
