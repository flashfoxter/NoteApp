import 'package:boostnote_mobile/business_logic/model/Note.dart';
import 'package:boostnote_mobile/business_logic/repository/TagRepository.dart';
import 'package:boostnote_mobile/business_logic/service/NoteService.dart';
import 'package:boostnote_mobile/data/repositoryImpl/TagRepositoryImp.dart';

class TagService {
 
  TagRepository _tagRepository = TagRepositoryImpl();
  NoteService _noteService = NoteService();

  Future<List<String>> findAll() {
    return _tagRepository.findAll();
  }

  Future<void> createTagIfNotExisting(String tag) async {
    _tagRepository.save(tag);
  }

  void renameTag(String oldTag, String newTag) async {
    createTagIfNotExisting(newTag);

    List<Note> notesToBeMoved = await _noteService.findNotesByTag(oldTag);
    notesToBeMoved.forEach((note) =>note.tags.add(newTag));
    _noteService.saveAll(notesToBeMoved);

    delete(oldTag);
  }

  void delete(String oldTag) async {
    List<Note> notesWithOldTag = await _noteService.findNotesByTag(oldTag);
    notesWithOldTag.forEach((note) => note.tags.remove(oldTag));
    _noteService.saveAll(notesWithOldTag);

    _tagRepository.delete(oldTag);
  }

}