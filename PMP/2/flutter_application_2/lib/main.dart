abstract interface class UniversityMember {
  void introduce();
}


abstract class UniversityEntity {
  String getInfo();

  void showInfo() {
    print(getInfo());
  }
}


class Student implements UniversityMember {
  String name;
  int age;

  static int studentCount = 0;

  Student(this.name, this.age) {
    studentCount++;
  }

  Student.guest(this.name) : age = 18 {
    studentCount++;
  }

  String get status {
    if (age >= 18) {
      return 'Совершеннолетний';
    } else {
      return 'Несовершеннолетний';
    }
  }

  set changeAge(int value) {
    if (value > 0) {
      age = value;
    }
  }

  @override
  void introduce() {
    print('Студент: $name, возраст: $age');
  }

  static void showCount() {
    print('Количество студентов: $studentCount');
  }
}


class GraduateStudent extends Student {
  String thesis;

  GraduateStudent(String name, int age, this.thesis)
      : super(name, age);

  @override
  void introduce() {
    print('Магистрант: $name, тема: $thesis');
  }
}


class Faculty extends UniversityEntity {
  String name;

  Faculty(this.name);

  @override
  String getInfo() => 'Факультет: $name';
}


class ITFaculty extends Faculty {
  int students;

  ITFaculty(String name, this.students) : super(name);

  @override
  String getInfo() => 'IT-факультет: $name, студентов: $students';
}



class University {
  String name;
  List<Faculty> faculties = [];
  Map<String, Student> students = {};
  Set<String> directions = {};

  University(this.name);

 
  void addStudent(
    Student student, {
    String direction = 'Не указано',
    String? group,
  }) {
    students[student.name] = student;
    directions.add(direction);

    print(
      'Добавлен студент ${student.name}, '
      'направление: $direction'
      '${group != null ? ', группа: $group' : ''}',
    );
  }

  void processStudents(bool Function(Student) condition) {
    for (final student in students.values) {
      if (!condition(student)) {
        continue;
      }

      print('Подходит: ${student.name}');
    }
  }

  void findStudent(String name) {
    for (final student in students.values) {
      if (student.name == name) {
        print('Студент найден: ${student.name}');
        break;
      }
    }
  }
}


class InvalidAgeException implements Exception {
  final String message;

  InvalidAgeException(this.message);

  @override
  String toString() => message;
}


void main() {
  print('===== УНИВЕРСИТЕТ =====');

  final university = University('БГУ');

  university.faculties.add(Faculty('Экономический'));
  university.faculties.add(ITFaculty('Факультет информационных технологий', 500));

  for (final faculty in university.faculties) {
    faculty.showInfo();
  }

  print('\n===== КЛАССЫ И ИНТЕРФЕЙСЫ =====');

  final student = Student('Алексей', 20);
  final guest = Student.guest('Иван');
  final graduate = GraduateStudent(
    'Мария',
    23,
    'Искусственный интеллект в образовании',
  );

  student.introduce();
  guest.introduce();
  graduate.introduce();

  print('Статус: ${student.status}');

  student.changeAge = 21;
  print('Новый возраст: ${student.age}');

  Student.showCount();

  print('\n===== КОЛЛЕКЦИИ =====');


  university.addStudent(
    student,
    direction: 'Программная инженерия',
    group: 'ПО-21',
  );

  university.addStudent(
    guest,
    direction: 'Экономика',
  );

  university.addStudent(
    graduate,
    direction: 'Компьютерные науки',
    group: 'КН-23',
  );

  print('List факультетов: ${university.faculties.length}');
  print('Map студентов: ${university.students.keys}');
  print('Set направлений: ${university.directions}');

  print('\n===== FUNCTION TYPE + CONTINUE =====');

  university.processStudents(
    (student) => student.age >= 20,
  );

  print('\n===== BREAK =====');

  university.findStudent('Мария');

  print('\n===== ИСКЛЮЧЕНИЯ =====');

  try {
    final age = -5;

    if (age <= 0) {
      throw InvalidAgeException('Возраст должен быть положительным');
    }

    print('Возраст: $age');
  } on InvalidAgeException catch (e) {
    print('Ошибка: $e');
  } catch (e) {
    print('Неизвестная ошибка: $e');
  } finally {
    print('Блок finally выполнен');
  }

  print('\n===== ГОТОВО =====');
}
