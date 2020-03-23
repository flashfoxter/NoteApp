import 'package:boostnote_mobile/business_logic/model/Note.dart';
import 'package:boostnote_mobile/presentation/navigation/NavigationService.dart';
import 'package:boostnote_mobile/presentation/screens/ActionConstants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OverviewAppbar extends StatefulWidget implements PreferredSizeWidget {

  Function() onSearchClickCallback;
  Function(String action) onSelectedActionCallback;
  Function() onMenuClickCallback;
  Function() onNaviagteBackCallback;
  Function(List<Note>) onSearchCallback;

  String pageTitle;
  bool listTilesAreExpanded;
  bool showListView;
  Map<String, String> actions;
  List<Note> notes;

  OverviewAppbar({this.listTilesAreExpanded, this.showListView, this.pageTitle, this.notes, this.actions, this.onSearchClickCallback, this.onMenuClickCallback, this.onNaviagteBackCallback, this.onSelectedActionCallback, this.onSearchCallback});

  @override
  _OverviewAppbarState createState() => _OverviewAppbarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

}

class _OverviewAppbarState extends State<OverviewAppbar> {

  NavigationService _newNavigationService;
  TextEditingController _filter;
  Widget _appbarTitle;
  List<Note> filteredNotes;
  Icon _searchIcon;
  String _searchText;

  bool _firstLoad;


  @override
  void initState(){
    super.initState();

    _firstLoad = true;
  }

  //Necessary, because initialization of widgets not possible in initState
  void _init(){
    _newNavigationService = NavigationService();
    _filter = TextEditingController();
    filteredNotes = List();
    _searchIcon = Icon(Icons.search, color: Theme.of(context).buttonColor);
    _appbarTitle = Text(this.widget.pageTitle, style: Theme.of(context).accentTextTheme.title);
    _searchText = "";
    _firstLoad = false;

    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
          List<Note> tempList = new List();
          for (int i = 0; i < this.widget.notes.length; i++) {
            tempList.add(this.widget.notes[i]);
          }
          filteredNotes = tempList;
          this.widget.onSearchCallback(tempList);
        });
      } else {
        setState(() {
          _searchText = _filter.text;
          List<Note> tempList = new List();
          for (int i = 0; i < this.widget.notes.length; i++) {
            if (this.widget.notes[i].title.toLowerCase().contains(_searchText.toLowerCase())) {
              tempList.add(this.widget.notes[i]);
            }
          }
          filteredNotes = tempList;
          this.widget.onSearchCallback(tempList);
        });
      }
    });
  }
 
  @override
  Widget build(BuildContext context) {
    if(_firstLoad){
      _init();
    }
    return AppBar(
      title: _appbarTitle,
      leading: _buildLeadingIcon(),
      actions: _buildActions(),
    );
  }

  List<Widget> _buildActions() {
    return <Widget>[
      IconButton(
        icon: _searchIcon,
        onPressed: (){_searchPressed();}
      ),
      PopupMenuButton<String>(
        icon: Icon(Icons.more_vert, color: Theme.of(context).buttonColor),
        onSelected: this.widget.onSelectedActionCallback,
        itemBuilder: (BuildContext context) {
          return <PopupMenuEntry<String>>[
            PopupMenuItem(
              value: this.widget.listTilesAreExpanded ?  ActionConstants.COLLPASE_ACTION: ActionConstants.EXPAND_ACTION,
              child: ListTile(
                title: Text(this.widget.listTilesAreExpanded ?  ActionConstants.COLLPASE_ACTION : ActionConstants.EXPAND_ACTION , style: Theme.of(context).textTheme.display1), 
              )
            ),
            PopupMenuItem(
              value: this.widget.showListView ? ActionConstants.SHOW_GRIDVIEW_ACTION: ActionConstants.SHOW_LISTVIEW_ACTION,
              child: ListTile(
                title: Text(this.widget.showListView ? ActionConstants.SHOW_GRIDVIEW_ACTION : ActionConstants.SHOW_LISTVIEW_ACTION, style: Theme.of(context).textTheme.display1), 
              )
            ),
          ];
        }
      )
    ];
  }

  _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = Icon(Icons.close, color: Theme.of(context).buttonColor);
        this._appbarTitle = TextField(
          controller: _filter,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, color: Theme.of(context).buttonColor),
            hintText: 'Search...',
            border: InputBorder.none,
          ),
          style: Theme.of(context).accentTextTheme.title,
        );
      } else {
        this._searchIcon = Icon(Icons.search, color: Theme.of(context).buttonColor);
        this._appbarTitle = Text(this.widget.pageTitle, style: Theme.of(context).accentTextTheme.title);
        filteredNotes = this.widget.notes;
        _filter.clear();
      }
    });
  }

  IconButton _buildLeadingIcon() {
    return (_newNavigationService.isNotesWithTagMode() || _newNavigationService.isNotesInFolderMode())
      ? IconButton(
        icon: Icon(Icons.arrow_back, color: Theme.of(context).accentColor), 
        onPressed: this.widget.onNaviagteBackCallback,
      ) : IconButton(
        icon: Icon(Icons.menu, color: Theme.of(context).accentColor), 
        onPressed: this.widget.onMenuClickCallback,
    );
  }

}