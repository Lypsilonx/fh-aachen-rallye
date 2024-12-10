import 'package:fh_aachen_rallye/data/server_object.dart';

class Translation extends ServerObject {
  final String key;
  final String language;
  final String value;

  const Translation(super.id, this.key, this.language, this.value);

  static Translation empty(String id) {
    return Translation(id, '', '', '');
  }

  factory Translation.fromJson(Map<String, dynamic> json) {
    return Translation(
      json['id'],
      json['key'],
      json['language'],
      json['value'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'language': language,
      'value': value,
    };
  }
}
