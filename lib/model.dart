class Notes {
  int _id;
  String _title;
  String _content;

  Notes(this._title, this._content);

  int get id => _id;
  String get title => _title;
  String get content => _content;

  Notes.fromDataBase(Map<String, dynamic> map) {
    _id = map['id'];
    _title = map['title'];
    _content = map['content'];
  }

  Map<String, dynamic> toDataBase() => {
        'id': _id,
        'title': _title,
        'content': _content,
      };
}
