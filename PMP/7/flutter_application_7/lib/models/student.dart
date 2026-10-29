
class Student {
  final int? id;
  final String name;
  final int age;
  final String group;
  final String faculty;
  final String direction;

  const Student({
    this.id,
    required this.name,
    required this.age,
    required this.group,
    required this.faculty,
    required this.direction,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'student_group': group,
      'faculty': faculty,
      'direction': direction,
    };
  }

  factory Student.fromMap(Map<String, Object?> map) {
    return Student(
      id: map['id'] as int?,
      name: map['name'] as String,
      age: map['age'] as int,
      group: map['student_group'] as String,
      faculty: map['faculty'] as String,
      direction: map['direction'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'group': group,
      'faculty': faculty,
      'direction': direction,
    };
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as int?,
      name: json['name'] as String,
      age: (json['age'] as num).toInt(),
      group: json['group'] as String,
      faculty: json['faculty'] as String,
      direction: json['direction'] as String,
    );
  }

  Student copyWith({
    int? id,
    String? name,
    int? age,
    String? group,
    String? faculty,
    String? direction,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      group: group ?? this.group,
      faculty: faculty ?? this.faculty,
      direction: direction ?? this.direction,
    );
  }
}
