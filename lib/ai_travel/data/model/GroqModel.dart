import 'dart:convert';

class GroqModelNew {
  String? id;
  String? object;
  int? created;
  String? model;
  List<Choice>? choices;
  Usage? usage;
  String? systemFingerprint;
  XGroq? xGroq;

  GroqModelNew({
    this.id,
    this.object,
    this.created,
    this.model,
    this.choices,
    this.usage,
    this.systemFingerprint,
    this.xGroq,
  });

  factory GroqModelNew.fromJson(Map<String, dynamic> json) {
    return GroqModelNew(
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

class Place {
  final List<double>? location;
  final String? name;
  final String? description;

  Place({
    required this.location,
    required this.name,
    required this.description,
  });

  // Factory constructor to create a new Place instance from a map.
  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      location: json['coordinates'] != null ? List<double>.from(json['coordinates']) : null,
      name: json['name'],
      description: json['description'],
    );
  }

  // Method to convert a Place instance to a map.
  Map<String, dynamic> toJson() {
    return {
      'coordinates': location,
      'name': name,
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


