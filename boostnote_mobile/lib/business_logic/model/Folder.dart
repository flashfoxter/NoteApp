
class Folder {

  String name;
  String id;
  String color;

  Folder({this.name = 'Default', this.id, this.color});

  static Folder clone(Folder folder) {
    return Folder(
      name: folder.name,
      id: folder.id,
      color: folder.color
    );
  }

  @override
  String toString() => 'Folder[id: $id, name: $name, color: $color]';
  
  @override 
  bool operator == (Object other) => 
    identical(this, other)||
    other is Folder &&
    runtimeType == other.runtimeType &&
    id == other.id;

  @override
  int get hashCode => id.hashCode;
}