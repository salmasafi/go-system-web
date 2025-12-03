class PopupResponse {
  final bool success;
  final PopupData data;

  PopupResponse({required this.success, required this.data});

  factory PopupResponse.fromJson(Map<String, dynamic> json) {
    return PopupResponse(
      success: json['success'] as bool,
      data: PopupData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data.toJson()};
  }
}

class PopupData {
  final String message;
  final List<PopupModel> popups;

  PopupData({
    required this.message,
    required this.popups,
  });

  factory PopupData.fromJson(Map<String, dynamic> json) {
    return PopupData(
      message: json['message'] as String,
      popups: (json['popup'] as List<dynamic>)
          .map((item) => PopupModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'popup': popups.map((item) => item.toJson()).toList(),
    };
  }
}

class PopupModel {
  final String id;
  final String titleEn;
  final String titleAr;
  final String descriptionAr;
  final String descriptionEn;
  final String imageAr;
  final String imageEn;
  final String link;
  final int version;

  PopupModel({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.imageAr,
    required this.imageEn,
    required this.link,
    required this.version,
  });

  factory PopupModel.fromJson(Map<String, dynamic> json) {
    return PopupModel(
      id: json['_id'] as String,
      titleEn: json['title_En'] as String,
      titleAr: json['title_ar'] as String,
      descriptionAr: json['description_ar'] as String,
      descriptionEn: json['description_En'] as String,
      imageAr: json['image_ar'] as String,
      imageEn: json['image_En'] as String,
      link: json['link'] as String,
      version: json['__v'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title_En': titleEn,
      'title_ar': titleAr,
      'description_ar': descriptionAr,
      'description_En': descriptionEn,
      'image_En': imageEn,
      'image_ar': imageAr,
      'link': link,
      '__v': version
    };
  }
}
