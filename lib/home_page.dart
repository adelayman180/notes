import 'package:auto_direction/auto_direction.dart';
import 'package:flutter/material.dart';
import './typing_page.dart';
import './database_helper.dart';
import './model.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final databaseHelper = DatabaseHelper();
  final globalKey = GlobalKey<ScaffoldState>();
  List<int> selectedNotes = [];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return exit();
      },
      child: Scaffold(
        key: globalKey,
        appBar: AppBar(
          title: Text('Your Notes'),
          elevation: 0,
          backgroundColor: Colors.red[300].withOpacity(0.4),
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  selectedNotes.isNotEmpty ? Icons.delete_forever : Icons.add,
                  size: 30,
                ),
                onPressed: () {
                  if (selectedNotes.isEmpty)
                    Navigator.push(context,
                            MaterialPageRoute(builder: (_) => TypingPage()))
                        .then((_) {
                      setState(() {});
                    });
                  else {
                    bottomSheet();
                  }
                })
          ],
        ),
        extendBodyBehindAppBar: true,
        body: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/bg1.jpg'), fit: BoxFit.cover),
          ),
          child: FutureBuilder(
            future: databaseHelper.getNote(),
            builder: (_, AsyncSnapshot snapshot) {
              return !snapshot.hasData || snapshot.data.length == 0
                  ? Text(
                      'No Notes found',
                      style: TextStyle(
                          color: Colors.red[200],
                          fontSize: MediaQuery.of(context).size.width / 10),
                    )
                  : ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (_, i) {
                        final note = Notes.fromDataBase(snapshot.data[i]);
                        final isNoteSelect = selectedNotes.contains(note.id);
                        return Dismissible(
                          key: UniqueKey(),
                          onDismissed: (_) {
                            if (isNoteSelect) selectedNotes.remove(note.id);
                            setState(() {
                              databaseHelper.deleteNote(note.id).then((_) {
                                globalKey.currentState.showSnackBar(SnackBar(
                                  content: Text(
                                      'Note number ${i + 1} has been deleted'),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () {
                                      databaseHelper.insertNote(note).then((_) {
                                        setState(() {});
                                      });
                                    },
                                  ),
                                ));
                              });
                            });
                          },
                          background: Container(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            color: Colors.black54,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Icon(
                                  Icons.delete_outline,
                                  color: Colors.red[200],
                                  size: 30,
                                ),
                                Icon(
                                  Icons.delete_outline,
                                  color: Colors.red[200],
                                  size: 30,
                                )
                              ],
                            ),
                          ),
                          child: Card(
                            color: isNoteSelect
                                ? Colors.redAccent.withOpacity(0.4)
                                : Colors.red[50].withOpacity(0.4),
                            child: ListTile(
                              onLongPress: () {
                                setState(() {
                                  if (!isNoteSelect)
                                    selectedNotes.add(note.id);
                                  else
                                    selectedNotes.remove(note.id);
                                });
                              },
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 5),
                              leading: CircleAvatar(
                                child: isNoteSelect
                                    ? Icon(Icons.done_outline)
                                    : Text('${i + 1}'),
                                backgroundColor: Colors.black45,
                              ),
                              title: AutoDirection(
                                text: note.title,
                                child: Text(
                                  note.title,
                                  style: TextStyle(fontSize: 18),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              subtitle: AutoDirection(
                                text: note.content,
                                child: Text(
                                  note.content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              onTap: () {
                                if (selectedNotes.isEmpty)
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              TypingPage(note.id))).then((_) {
                                    setState(() {});
                                  });
                                else if (isNoteSelect)
                                  setState(() {
                                    selectedNotes.remove(note.id);
                                  });
                                else
                                  setState(() {
                                    selectedNotes.add(note.id);
                                  });
                              },
                            ),
                          ),
                        );
                      },
                    );
            },
          ),
        ),
      ),
    );
  }

  Future<bool> exit() async {
    if (selectedNotes.isEmpty)
      return true;
    else {
      setState(() {
        selectedNotes.clear();
      });
      return false;
    }
  }

  void bottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (context) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Are you sure to delete ${selectedNotes.length} note${selectedNotes.length == 1 ? '' : 's'} ?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('No')),
                      FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              selectedNotes.forEach((id) {
                                databaseHelper.deleteNote(id);
                              });
                              selectedNotes.clear();
                            });
                          },
                          child: Text('Yes'))
                    ],
                  ),
                ],
              ),
            ),
        backgroundColor: Colors.red[200],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(50),
          topRight: Radius.circular(50),
        )));
  }
}
