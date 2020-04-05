import 'package:boostnote_mobile/business_logic/model/MarkdownNote.dart';
import 'package:boostnote_mobile/presentation/notifiers/NoteNotifier.dart';
import 'package:boostnote_mobile/presentation/notifiers/SnippetNotifier.dart';
import 'package:boostnote_mobile/presentation/pages/EmptyAppbar.dart';
import 'package:boostnote_mobile/presentation/screens/editor/markdown_editor/widgets/MarkdownEditorAppBar.dart';
import 'package:boostnote_mobile/presentation/screens/editor/snippet_editor/widgets/CodeSnippetAppBar.dart';
import 'package:boostnote_mobile/presentation/widgets/appbar/FolderOverviewAppbar.dart';
import 'package:boostnote_mobile/presentation/widgets/responsive/ResponsiveChild.dart';
import 'package:boostnote_mobile/presentation/widgets/responsive/ResponsiveWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FoldersPageAppbar extends StatefulWidget  implements PreferredSizeWidget{

  final Function(String action) onSelectedActionCallback;
  final Function() openDrawer;

  FoldersPageAppbar({this.onSelectedActionCallback, this.openDrawer});

  @override
  _FoldersPageAppbarState createState() => _FoldersPageAppbarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _FoldersPageAppbarState extends State<FoldersPageAppbar> {

  NoteNotifier _noteNotifier;
  SnippetNotifier _snippetNotifier;

  @override
  Widget build(BuildContext context) {
    _noteNotifier = Provider.of<NoteNotifier>(context);
    _snippetNotifier = Provider.of<SnippetNotifier>(context);

    return _buildWiget(context);
  }

  ResponsiveWidget _buildWiget(BuildContext context) {
    return ResponsiveWidget(
      showDivider: true,
      widgets: <ResponsiveChild> [
         ResponsiveChild(
              smallFlex: _noteNotifier.note == null ? 1 : 0, 
              largeFlex: 2, 
              child: FolderOverviewAppbar(openDrawer: widget.openDrawer)
            ),
        ResponsiveChild(
          smallFlex: _noteNotifier.note == null ? 0 : 1, 
          largeFlex: 3, 
          child: buildSecondChild(context)
        )
      ]
    );
  }

  Widget buildSecondChild(BuildContext context) {
    return _noteNotifier.note == null   //Sonst fliegt komische exception, wenn in methode ausgelagert
      ? EmptyAppbar()
      : _noteNotifier.note is MarkdownNote
        ? MarkdownEditorAppBar(selectedActionCallback: widget.onSelectedActionCallback)
        : _snippetNotifier.isEditMode
          ? AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Theme.of(context).buttonColor), 
                onPressed: () {
                  _noteNotifier.note = null;
                }
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.check, color: Theme.of(context).buttonColor), 
                  onPressed: () => _snippetNotifier.isEditMode = !_snippetNotifier.isEditMode
                )
              ]
          )
          : CodeSnippetAppBar(selectedActionCallback: widget.onSelectedActionCallback);
  }
}