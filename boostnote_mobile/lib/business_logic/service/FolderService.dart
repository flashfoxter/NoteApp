import 'package:boostnote_mobile/business_logic/model/Folder.dart';
import 'package:boostnote_mobile/business_logic/model/Note.dart';
import 'package:boostnote_mobile/business_logic/repository/FolderRepository.dart';
import 'package:boostnote_mobile/business_logic/service/NoteService.dart';
import 'package:boostnote_mobile/data/repositoryImpl/FolderRepositoryImpl.dart';

class FolderService {

  FolderRepository _folderRepository = FolderRepositoryImpl();
  NoteService _noteService = NoteService();

  Future<List<Folder>> findAll() {
    return _folderRepository.findAll();
  }

  Future<List<Folder>> findAllUntrashed() async {
    List<Folder> folders = await findAll();
    List<Folder> filteredFolders = folders.where((folder) => folder.name != 'Trash').toList();
    return Future.value(filteredFolders);
  }

  void createFolderIfNotExisting(Folder folder) {
    folder.id = folder.name.hashCode;
    _folderRepository.save(folder);
  }

  void renameFolder(Folder folder) async {
    createFolderIfNotExisting(folder);
    List<Note> notesToBeMoved = await _noteService.findNotesIn(folder);
    notesToBeMoved.forEach((note) => note.folder = folder);
    _noteService.saveAll(notesToBeMoved);
  }

  void delete(Folder folder) async {
    List<Note> notesToBeDeleted = await _noteService.findNotesIn(folder);
    _noteService.moveAllToTrash(notesToBeDeleted);
    _folderRepository.delete(folder);
  }

}