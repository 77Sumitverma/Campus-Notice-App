class ExamModel {
  final String title;
  final String description;
  final String date;
  final List<String> fileUrls;
  final List<String> fileTypes;
  final String uploaderName;
  final String uploaderUID;

  ExamModel({
    required this.title,
    required this.description,
    required this.date,
    this.fileUrls = const [],
    this.fileTypes = const [],
    required this.uploaderName,
    required this.uploaderUID,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date,
      'fileUrls': fileUrls,
      'fileTypes': fileTypes,
      'uploaderName': uploaderName,
      'uploaderUID': uploaderUID,
      'createdAt': DateTime.now(),
    };
  }
}
