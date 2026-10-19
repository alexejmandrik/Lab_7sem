import 'dart:async';
import 'dart:convert';


mixin Logger {
  void log(String message) {
    print('[LOG] $message');
  }
}



class Student with Logger implements Comparable<Student> {
  String name;
  int age;

  Student(this.name, this.age);



  @override
  int compareTo(Student other) {
    return age.compareTo(other.age);
  }




  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
    };
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      json['name'],
      json['age'],
    );
  }

  @override
  String toString() {
    return '$name ($age лет)';
  }
}




class StudentCollection extends Iterable<Student> {
  final List<Student> students;

  StudentCollection(this.students);

  @override
  Iterator<Student> get iterator => students.iterator;
}




Future<Student> loadStudent() async {
  await Future.delayed(
    const Duration(seconds: 1),
  );

  return Student('Мария', 22);
}

Future<Student> loadStudentWithError() async {
  await Future.delayed(
    const Duration(seconds: 1),
  );

  throw Exception('Ошибка загрузки студента');
}




Stream<int> createStream() async* {
  for (int i = 1; i <= 5; i++) {
    await Future.delayed(
      const Duration(milliseconds: 300),
    );

    yield i;
  }
}




Future<void> main() async {



  print('===== 1. MIXIN =====');

  final student = Student('Алексей', 20);

  student.log('Создан студент ${student.name}');



  print('\n===== 2. COMPARABLE =====');

  final students = [
    Student('Алексей', 20),
    Student('Иван', 18),
    Student('Мария', 22),
  ];

  students.sort();

  print('Студенты после сортировки:');

  for (final student in students) {
    print(student);
  }


  print('\n===== ITERATOR =====');

  final iterator = students.iterator;

  while (iterator.moveNext()) {
    print(iterator.current);
  }


  print('\n===== ITERABLE =====');

  final collection = StudentCollection(students);

  for (final student in collection) {
    print(student);
  }




  print('\n===== 3. JSON =====');

  final jsonStudent = Student('Дмитрий', 21);
  final json = jsonEncode(jsonStudent.toJson());

  print('JSON: $json');
  final restoredStudent = Student.fromJson(
    jsonDecode(json),
  );

  print('Объект: $restoredStudent');




  print('\n===== 4. ASYNC =====');
  print('Загрузка студента...');

  final loadedStudent = await loadStudent();
  print('Загружен: $loadedStudent');




  print('\n===== 5. FUTURE =====');

  await loadStudent().then((student) {
    print('Получен: $student');
  });

  // Обработка ошибки
  try {
    await loadStudentWithError();
  } catch (e) {
    print('Ошибка: $e');
  }

  await loadStudent()
      .then((student) {
        print('1. Получен: $student');
        return student.age;
      })
      .then((age) {
        print('2. Возраст: $age');
      });




  print('\n===== 6. SINGLE STREAM =====');

  final subscription = createStream().listen(
    (value) {
      print('Получено: $value');
    },
    onDone: () {
      print('Stream завершён');
    },
  );

  await subscription.asFuture();




  print('\n===== BROADCAST STREAM =====');

  final controller = StreamController<int>.broadcast();

  final subscription1 = controller.stream.listen(
    (value) {
      print('Подписчик 1: $value');
    },
  );

  final subscription2 = controller.stream.listen(
    (value) {
      print('Подписчик 2: $value');
    },
  );
 
await Future.delayed(const Duration(milliseconds: 100));

  controller.add(10);
  controller.add(20);

await Future.delayed(const Duration(milliseconds: 100));

  await subscription2.cancel();

  controller.add(30);

  await Future.delayed(
    const Duration(milliseconds: 100),
  );

  await subscription1.cancel();
  await controller.close();


  print('\n===== ГОТОВО =====');
}