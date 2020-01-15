
import 'package:boostnote_mobile/business_logic/model/Folder.dart';
import 'package:boostnote_mobile/business_logic/model/MarkdownNote.dart';
import 'package:boostnote_mobile/business_logic/service/FolderService.dart';
import 'package:boostnote_mobile/business_logic/service/NoteService.dart';
import 'package:boostnote_mobile/data/entity/FolderEntity.dart';
import 'package:boostnote_mobile/presentation/screens/overview/Refreshable.dart';
import 'package:boostnote_mobile/presentation/widgets/markdown/MarkdownEditor.dart';
import 'package:boostnote_mobile/presentation/widgets/markdown/MarkdownPreview.dart';
import 'package:boostnote_mobile/presentation/widgets/dialogs/EditMarkdownNoteDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Editor extends StatefulWidget {

  final Refreshable _parentWidget;
  final bool _isTablet;
  final MarkdownNote _note;

  Editor(this._isTablet, this._note, this._parentWidget);

  @override
  State<StatefulWidget> createState() => EditorState();
}
  

class EditorState extends State<Editor> {

  NoteService _noteService;
  FolderService _folderService;

  bool _previewMode = false;
  List<FolderEntity> _folders;
  FolderEntity _dropdownValue;

  static const String DELETE_ACTION = 'Delete';
  static const String SAVE_ACTION = 'Save';
  static const String EDIT_ACTION = 'Edit Note';
  static const String MARK_ACTION = 'Mark Note';
  static const String UNMARK_ACTION = 'Unmark Note';

  @override
  void initState() {
    super.initState();
    _noteService = NoteService();
    _folderService = FolderService();
    _folders = List();
   
    _folderService.findAll().then((folders) { 
      setState(() { 
        _folders = folders;
         _dropdownValue = _folders.firstWhere((folder) => folder.id == this.widget._note.folder.id);
      });
    });
  }

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

  @override
  void dispose() {
    super.dispose();
    print('DISPOSE');
    NoteService().save(this.widget._note);
    this.widget._parentWidget.refresh();
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(this.widget._note.title),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Color(0xFFF6F5F5)), 
        onPressed: () {
         Navigator.of(context).pop();  
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
              ),
              PopupMenuItem(
                value: this.widget._note.isStarred ?  UNMARK_ACTION : MARK_ACTION,
                child: ListTile(
                  title: Text(this.widget._note.isStarred ?  UNMARK_ACTION : MARK_ACTION)
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
      if(action == DELETE_ACTION){
        noteService.moveToTrash(this.widget._note);
        this.widget._parentWidget.refresh();
        Navigator.of(context).pop();
      } else if(action == SAVE_ACTION){
        noteService.save(this.widget._note);
        this.widget._parentWidget.refresh();
        Navigator.of(context).pop();
      } else if(action == EDIT_ACTION){
        showEditNoteDialog(context, this.widget._note, (note){
          setState(() {
            this.widget._note.title = note.title;
          });
          noteService.save(this.widget._note);
          Navigator.of(context).pop();
        });
      } else if(action == MARK_ACTION){
        this.widget._note.isStarred = true;
        noteService.save(this.widget._note);
      } else if(action == UNMARK_ACTION){
        this.widget._note.isStarred = false;
        noteService.save(this.widget._note);
      } 
  }

  Widget _buildMobileLayout() {
    return Column(
      children: <Widget>[
        Flexible(flex: 1, 
        child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: EdgeInsetsDirectional.only(start: 10),
                  child:  DropdownButton<FolderEntity> (    //TODO FolderEntity
                    value: _dropdownValue, 
                    underline: Container(), 
                    icon: Icon(Icons.folder_open),
                    items: _folders.map<DropdownMenuItem<FolderEntity>>((folder) => DropdownMenuItem<FolderEntity>(
                      value: folder,
                      child: Text(folder.name)
                    )).toList(),
                    onChanged: (folder) {
                        setState(() {
                          _dropdownValue = folder;
                        });
                        this.widget._note.folder = folder;
                        _noteService.save(this.widget._note);
                      }
                  )
                ),
                Row(
                children: <Widget>[
                  IconButton(icon: Icon(Icons.label_outline), onPressed: () {}),
                  IconButton(icon: Icon(Icons.info_outline), onPressed: () {})
                  ],
                ),
              ],
            ),
          )
        ),
        Flexible(flex: 7,
          child: Align(
                  alignment: Alignment.topLeft,
                  child: _previewMode ? MarkdownPreview(this.widget._note.content, _launchURL) : MarkdownEditor(this.widget._note.content, _onTextChangedCallback),
                )
        )
      ],
    );
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





 
