class GroqAiModels {
  final String? id;
  final String? object;
  final int? created;
  final String? ownedBy;
  final bool? active;
  final int? contextWindow;

  GroqAiModels({
    this.id,
    this.object,
    this.created,
    this.ownedBy,
    this.active,
    this.contextWindow,
  });

  factory GroqAiModels.fromJson(Map<String, dynamic> json) {
    return GroqAiModels(
      id: json['id'] as String?,
      object: json['object'] as String?,
      created: json['created'] as int?,
      ownedBy: json['owned_by'] as String?,
      active: json['active'] as bool?,
      contextWindow: json['context_window'] as int?,
    );
  }

  static List<GroqAiModels> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => GroqAiModels.fromJson(json)).toList();
  }
}

class GroqAiModelList {
  final String? object;
  final List<GroqAiModels>? data;

  GroqAiModelList({
    this.object,
    this.data,
  });

  factory GroqAiModelList.fromJson(Map<String, dynamic> json) {
    return GroqAiModelList(
      object: json['object'] as String?,
      data: json['data'] != null ? GroqAiModels.fromJsonList(json['data']) : null,
    );
  }
}
