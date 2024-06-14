class Song{

  Song({required this.id,
        required this.title,
        required this.album,
        required this.artists,
        required this.source,
        required this.image,
        required this.duration
  });

  factory Song.formJson(Map<String, dynamic >map){
    return Song(id: map["id"]??'',
                title: map["title"]??'',
                album: map["album"]??'',
                artists: map["artists"]??'',
                source: map["source"]??'',
                image: map["image"]??'',
                duration: map["duration"]?? 0
            );
  }

  String id;
  String title;
  String album;
  String artists;
  String source;
  String image;
  int duration;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Song{id: $id, '
        'title: $title, '
        'album: $album, '
        'artits: $artists, '
        'source: $source, '
        'image: $image, '
        'duration: $duration}';
  }
}