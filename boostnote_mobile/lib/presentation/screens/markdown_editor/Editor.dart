
import 'package:boostnote_mobile/business_logic/model/MarkdownNote.dart';
import 'package:boostnote_mobile/business_logic/service/NoteService.dart';
import 'package:boostnote_mobile/presentation/widgets/markdown/MarkdownEditor.dart';
import 'package:boostnote_mobile/presentation/screens/overview/OverviewView.dart';
import 'package:boostnote_mobile/presentation/widgets/markdown/MarkdownPreview.dart';
import 'package:boostnote_mobile/presentation/widgets/dialogs/EditMarkdownNoteDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Editor extends StatefulWidget {

  final OverviewView _overview;
  final bool _isTablet;
  final MarkdownNote _note;

  Editor(this._isTablet, this._note, this._overview);

  @override
  State<StatefulWidget> createState() => EditorState();
}
  

class EditorState extends State<Editor> {

  bool _previewMode = false;

  static const String DELETE_ACTION = 'Delete';
  static const String SAVE_ACTION = 'Save';
  static const String EDIT_ACTION = 'Edit Note';

  @override
  Widget build(BuildContext context) {

    Widget body;
    if (this.widget._isTablet) {
      body = _buildTabletLayout();
    } else {
      body = _buildMobileLayout();
    }

    return Scaffold(
      appBar: _buildAppBar(context),
      body: body,
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(this.widget._note.title),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Color(0xFFF6F5F5)), 
        onPressed: () {
          Navigator.of(context).pop(); //TODO: Presenter??
        },
      ),
      actions: <Widget>[
        Switch(
          value: _previewMode, 
          onChanged: (bool value) {
            setState(() {
              _previewMode = value;
            });
          }, 
          ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert),
          onSelected: _selectedAction,
          itemBuilder: (BuildContext context) {
            return <PopupMenuEntry<String>>[
              PopupMenuItem(
                value: SAVE_ACTION,
                child: ListTile(
                  title: Text(SAVE_ACTION)
                )
              ),
              PopupMenuItem(
                value: DELETE_ACTION,
                child: ListTile(
                  title: Text(DELETE_ACTION)
                )
              ),
              PopupMenuItem(
                value: EDIT_ACTION,
                child: ListTile(
                  title: Text(EDIT_ACTION)
                )
              )
            ];
          }
        )
      ],
    );
  }

  //TODO: Presenter??
  void _selectedAction(String action){
      NoteService noteService = NoteService();
      if(action == 'Delete'){
        noteService.delete(this.widget._note);
        this.widget._overview.refresh();
        Navigator.of(context).pop();
      } else if(action == 'Save'){
        noteService.save(this.widget._note);
        this.widget._overview.refresh();
        Navigator.of(context).pop();
      }  else if(action == 'Edit Note'){
        showEditNoteDialog(context, this.widget._note, (note){
          setState(() {
            this.widget._note.title = note.title;
          });
          noteService.save(this.widget._note);
          Navigator.of(context).pop();
        });
      }
  }

  Widget _buildMobileLayout() {
    return _previewMode ? MarkdownPreview(this.widget._note.content, _launchURL) : MarkdownEditor(this.widget._note.content, _onTextChangedCallback);
  }

  Widget _buildTabletLayout() {
    return Column(
      children: <Widget>[
        Flexible(
          flex: 1,
          child: MarkdownEditor(this.widget._note.content, _onTextChangedCallback)
        ),
        Divider(),
        Flexible(
          flex: 1,
          child: MarkdownPreview(this.widget._note.content, _launchURL)
        ),
      ],
    );
  }

  void _onTextChangedCallback(String text){
      this.widget._note.content = text;
  }

//TODO: Presenter??
  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<MarkdownNote> showEditNoteDialog(BuildContext context, MarkdownNote note, Function(MarkdownNote) callback) => showDialog(
    context: context, 
    builder: (context){
      return EditMarkdownNoteDialog(
        note: note, 
        saveCallback: (note){
          NoteService service = NoteService();  //TODO: Presenter
          service.save(note);
          Navigator.of(context).pop();
        },
        cancelCallback: (){
          Navigator.of(context).pop();
        },
      );
  }); 
}





 