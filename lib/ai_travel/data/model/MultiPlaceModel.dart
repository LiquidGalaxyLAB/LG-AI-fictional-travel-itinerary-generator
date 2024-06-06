import 'dart:convert';

class GroqResponseModel {
  String? id;
  String? object;
  int? created;
  String? model;
  List<Choice>? choices;
  Usage? usage;
  String? systemFingerprint;
  XGroq? xGroq;

  GroqResponseModel({
    this.id,
    this.object,
    this.created,
    this.model,
    this.choices,
    this.usage,
    this.systemFingerprint,
    this.xGroq,
  });

  factory GroqResponseModel.fromJson(Map<String, dynamic> json) {
    return GroqResponseModel(
      id: json['id'],
      object: json['object'],
      created: json['created'],
      model: json['model'],
      choices: json['choices'] != null
          ? List<Choice>.from(json['choices'].map((x) => Choice.fromJson(x)))
          : null,
      usage: json['usage'] != null ? Usage.fromJson(json['usage']) : null,
      systemFingerprint: json['system_fingerprint'],
      xGroq: json['x_groq'] != null ? XGroq.fromJson(json['x_groq']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'object': object,
      'created': created,
      'model': model,
      'choices': choices != null
          ? List<dynamic>.from(choices!.map((x) => x.toJson()))
          : null,
      'usage': usage?.toJson(),
      'system_fingerprint': systemFingerprint,
      'x_groq': xGroq?.toJson(),
    };
  }
}

class Choice {
  int? index;
  Message? message;
  dynamic logprobs;
  String? finishReason;

  Choice({
    this.index,
    this.message,
    this.logprobs,
    this.finishReason,
  });

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      index: json['index'],
      message: json['message'] != null ? Message.fromJson(json['message']) : null,
      logprobs: json['logprobs'],
      finishReason: json['finish_reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'message': message?.toJson(),
      'logprobs': logprobs,
      'finish_reason': finishReason,
    };
  }
}

class Message {
  String? role;
  String? content;

  Message({
    this.role,
    this.content,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      role: json['role'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }
}

class Places {
  final List<String>? name;
  final List<String>? address;
  final List<String>? description;

  Places({
    required this.name,
    required this.address,
    required this.description,
  });

  factory Places.fromJson(Map<String, dynamic> json) {
    List<dynamic> placesJson = json['places'];
    List<String> names = placesJson.map<String>((placeJson) => placeJson['name']).toList();
    List<String> addresses = placesJson.map<String>((placeJson) => placeJson['address']).toList();
    List<String> descriptions = placesJson.map<String>((placeJson) => placeJson['description']).toList();

    return Places(
      name: names,
      address: addresses,
      description: descriptions,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'description': description,
    };
  }
}


class Usage {
  int? promptTokens;
  double? promptTime;
  int? completionTokens;
  double? completionTime;
  int? totalTokens;
  double? totalTime;

  Usage({
    this.promptTokens,
    this.promptTime,
    this.completionTokens,
    this.completionTime,
    this.totalTokens,
    this.totalTime,
  });

  factory Usage.fromJson(Map<String, dynamic> json) {
    return Usage(
      promptTokens: json['prompt_tokens'],
      promptTime: json['prompt_time'],
      completionTokens: json['completion_tokens'],
      completionTime: json['completion_time'],
      totalTokens: json['total_tokens'],
      totalTime: json['total_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prompt_tokens': promptTokens,
      'prompt_time': promptTime,
      'completion_tokens': completionTokens,
      'completion_time': completionTime,
      'total_tokens': totalTokens,
      'total_time': totalTime,
    };
  }
}

class XGroq {
  String? id;

  XGroq({
    this.id,
  });

  factory XGroq.fromJson(Map<String, dynamic> json) {
    return XGroq(
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
