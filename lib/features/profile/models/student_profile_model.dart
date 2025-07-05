// lib/features/profile/models/student_profile_model.dart
class StudentProfileModel {
  final int? id;
  final String? username;
  final String? email;
  final String? status;
  final String? khmerFirstName;
  final String? khmerLastName;
  final String? englishFirstName;
  final String? englishLastName;
  final String? gender;
  final String? profileUrl;
  final String? dateOfBirth;
  final String? phoneNumber;
  final String? currentAddress;
  final String? nationality;
  final String? ethnicity;
  final String? placeOfBirth;
  final String? identifyNumber;
  final String? memberSiblings;
  final String? numberOfSiblings;
  final StudentClassModel? studentClass;
  final List<StudentStudiesHistoryModel>? studentStudiesHistory;
  final List<StudentParentModel>? studentParent;
  final List<StudentSiblingModel>? studentSibling;
  final String? createdAt;

  const StudentProfileModel({
    this.id,
    this.username,
    this.email,
    this.status,
    this.khmerFirstName,
    this.khmerLastName,
    this.englishFirstName,
    this.englishLastName,
    this.gender,
    this.profileUrl,
    this.dateOfBirth,
    this.phoneNumber,
    this.currentAddress,
    this.nationality,
    this.ethnicity,
    this.placeOfBirth,
    this.identifyNumber,
    this.memberSiblings,
    this.numberOfSiblings,
    this.studentClass,
    this.studentStudiesHistory,
    this.studentParent,
    this.studentSibling,
    this.createdAt,
  });

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    return StudentProfileModel(
      id: json['id'] as int?,
      username: json['username'] as String?,
      email: json['email'] as String?,
      status: json['status'] as String?,
      khmerFirstName: json['khmerFirstName'] as String?,
      khmerLastName: json['khmerLastName'] as String?,
      englishFirstName: json['englishFirstName'] as String?,
      englishLastName: json['englishLastName'] as String?,
      gender: json['gender'] as String?,
      profileUrl: json['profileUrl'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      currentAddress: json['currentAddress'] as String?,
      nationality: json['nationality'] as String?,
      ethnicity: json['ethnicity'] as String?,
      placeOfBirth: json['placeOfBirth'] as String?,
      identifyNumber: json['identifyNumber'] as String?,
      memberSiblings: json['memberSiblings'] as String?,
      numberOfSiblings: json['numberOfSiblings'] as String?,
      studentClass: json['studentClass'] != null
          ? StudentClassModel.fromJson(
              json['studentClass'] as Map<String, dynamic>)
          : null,
      studentStudiesHistory: json['studentStudiesHistory'] != null
          ? (json['studentStudiesHistory'] as List)
              .map((e) => StudentStudiesHistoryModel.fromJson(
                  e as Map<String, dynamic>))
              .toList()
          : null,
      studentParent: json['studentParent'] != null
          ? (json['studentParent'] as List)
              .map(
                  (e) => StudentParentModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      studentSibling: json['studentSibling'] != null
          ? (json['studentSibling'] as List)
              .map((e) =>
                  StudentSiblingModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'status': status,
      'khmerFirstName': khmerFirstName,
      'khmerLastName': khmerLastName,
      'englishFirstName': englishFirstName,
      'englishLastName': englishLastName,
      'gender': gender,
      'profileUrl': profileUrl,
      'dateOfBirth': dateOfBirth,
      'phoneNumber': phoneNumber,
      'currentAddress': currentAddress,
      'nationality': nationality,
      'ethnicity': ethnicity,
      'placeOfBirth': placeOfBirth,
      'identifyNumber': identifyNumber,
      'memberSiblings': memberSiblings,
      'numberOfSiblings': numberOfSiblings,
      'studentClass': studentClass?.toJson(),
      'studentStudiesHistory':
          studentStudiesHistory?.map((e) => e.toJson()).toList(),
      'studentParent': studentParent?.map((e) => e.toJson()).toList(),
      'studentSibling': studentSibling?.map((e) => e.toJson()).toList(),
      'createdAt': createdAt,
    };
  }

  StudentProfileModel copyWith({
    int? id,
    String? username,
    String? email,
    String? status,
    String? khmerFirstName,
    String? khmerLastName,
    String? englishFirstName,
    String? englishLastName,
    String? gender,
    String? profileUrl,
    String? dateOfBirth,
    String? phoneNumber,
    String? currentAddress,
    String? nationality,
    String? ethnicity,
    String? placeOfBirth,
    String? identifyNumber,
    String? memberSiblings,
    String? numberOfSiblings,
    StudentClassModel? studentClass,
    List<StudentStudiesHistoryModel>? studentStudiesHistory,
    List<StudentParentModel>? studentParent,
    List<StudentSiblingModel>? studentSibling,
    String? createdAt,
  }) {
    return StudentProfileModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      status: status ?? this.status,
      khmerFirstName: khmerFirstName ?? this.khmerFirstName,
      khmerLastName: khmerLastName ?? this.khmerLastName,
      englishFirstName: englishFirstName ?? this.englishFirstName,
      englishLastName: englishLastName ?? this.englishLastName,
      gender: gender ?? this.gender,
      profileUrl: profileUrl ?? this.profileUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      currentAddress: currentAddress ?? this.currentAddress,
      nationality: nationality ?? this.nationality,
      ethnicity: ethnicity ?? this.ethnicity,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      identifyNumber: identifyNumber ?? this.identifyNumber,
      memberSiblings: memberSiblings ?? this.memberSiblings,
      numberOfSiblings: numberOfSiblings ?? this.numberOfSiblings,
      studentClass: studentClass ?? this.studentClass,
      studentStudiesHistory:
          studentStudiesHistory ?? this.studentStudiesHistory,
      studentParent: studentParent ?? this.studentParent,
      studentSibling: studentSibling ?? this.studentSibling,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get displayName {
    if (englishFirstName != null && englishLastName != null) {
      return '$englishFirstName $englishLastName';
    }
    if (khmerFirstName != null && khmerLastName != null) {
      return '$khmerFirstName $khmerLastName';
    }
    return username ?? 'Unknown';
  }
}

class StudentClassModel {
  final int? id;
  final String? code;
  final int? academyYear;
  final String? degree;
  final String? yearLevel;
  final String? status;
  final StudentMajorModel? major;

  const StudentClassModel({
    this.id,
    this.code,
    this.academyYear,
    this.degree,
    this.yearLevel,
    this.status,
    this.major,
  });

  factory StudentClassModel.fromJson(Map<String, dynamic> json) {
    return StudentClassModel(
      id: json['id'] as int?,
      code: json['code'] as String?,
      academyYear: json['academyYear'] as int?,
      degree: json['degree'] as String?,
      yearLevel: json['yearLevel'] as String?,
      status: json['status'] as String?,
      major: json['major'] != null
          ? StudentMajorModel.fromJson(json['major'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'academyYear': academyYear,
      'degree': degree,
      'yearLevel': yearLevel,
      'status': status,
      'major': major?.toJson(),
    };
  }
}

class StudentMajorModel {
  final int? id;
  final String? code;
  final String? name;
  final String? status;
  final StudentDepartmentModel? department;

  const StudentMajorModel({
    this.id,
    this.code,
    this.name,
    this.status,
    this.department,
  });

  factory StudentMajorModel.fromJson(Map<String, dynamic> json) {
    return StudentMajorModel(
      id: json['id'] as int?,
      code: json['code'] as String?,
      name: json['name'] as String?,
      status: json['status'] as String?,
      department: json['department'] != null
          ? StudentDepartmentModel.fromJson(
              json['department'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'status': status,
      'department': department?.toJson(),
    };
  }
}

class StudentDepartmentModel {
  final int? id;
  final String? code;
  final String? name;
  final String? urlLogo;
  final String? status;

  const StudentDepartmentModel({
    this.id,
    this.code,
    this.name,
    this.urlLogo,
    this.status,
  });

  factory StudentDepartmentModel.fromJson(Map<String, dynamic> json) {
    return StudentDepartmentModel(
      id: json['id'] as int?,
      code: json['code'] as String?,
      name: json['name'] as String?,
      urlLogo: json['urlLogo'] as String?,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'urlLogo': urlLogo,
      'status': status,
    };
  }
}

class StudentStudiesHistoryModel {
  final int? id;
  final String? schoolName;
  final String? yearFrom;
  final String? yearTo;
  final String? certificate;

  const StudentStudiesHistoryModel({
    this.id,
    this.schoolName,
    this.yearFrom,
    this.yearTo,
    this.certificate,
  });

  factory StudentStudiesHistoryModel.fromJson(Map<String, dynamic> json) {
    return StudentStudiesHistoryModel(
      id: json['id'] as int?,
      schoolName: json['schoolName'] as String?,
      yearFrom: json['yearFrom'] as String?,
      yearTo: json['yearTo'] as String?,
      certificate: json['certificate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schoolName': schoolName,
      'yearFrom': yearFrom,
      'yearTo': yearTo,
      'certificate': certificate,
    };
  }
}

class StudentParentModel {
  final int? id;
  final String? relationship;
  final String? khmerFirstName;
  final String? khmerLastName;
  final String? englishFirstName;
  final String? englishLastName;
  final String? gender;
  final String? dateOfBirth;
  final String? phoneNumber;
  final String? occupation;
  final String? workPlace;
  final String? address;

  const StudentParentModel({
    this.id,
    this.relationship,
    this.khmerFirstName,
    this.khmerLastName,
    this.englishFirstName,
    this.englishLastName,
    this.gender,
    this.dateOfBirth,
    this.phoneNumber,
    this.occupation,
    this.workPlace,
    this.address,
  });

  factory StudentParentModel.fromJson(Map<String, dynamic> json) {
    return StudentParentModel(
      id: json['id'] as int?,
      relationship: json['relationship'] as String?,
      khmerFirstName: json['khmerFirstName'] as String?,
      khmerLastName: json['khmerLastName'] as String?,
      englishFirstName: json['englishFirstName'] as String?,
      englishLastName: json['englishLastName'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      occupation: json['occupation'] as String?,
      workPlace: json['workPlace'] as String?,
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'relationship': relationship,
      'khmerFirstName': khmerFirstName,
      'khmerLastName': khmerLastName,
      'englishFirstName': englishFirstName,
      'englishLastName': englishLastName,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'phoneNumber': phoneNumber,
      'occupation': occupation,
      'workPlace': workPlace,
      'address': address,
    };
  }
}

class StudentSiblingModel {
  final int? id;
  final String? khmerFirstName;
  final String? khmerLastName;
  final String? englishFirstName;
  final String? englishLastName;
  final String? gender;
  final String? dateOfBirth;
  final String? occupation;
  final String? workPlace;

  const StudentSiblingModel({
    this.id,
    this.khmerFirstName,
    this.khmerLastName,
    this.englishFirstName,
    this.englishLastName,
    this.gender,
    this.dateOfBirth,
    this.occupation,
    this.workPlace,
  });

  factory StudentSiblingModel.fromJson(Map<String, dynamic> json) {
    return StudentSiblingModel(
      id: json['id'] as int?,
      khmerFirstName: json['khmerFirstName'] as String?,
      khmerLastName: json['khmerLastName'] as String?,
      englishFirstName: json['englishFirstName'] as String?,
      englishLastName: json['englishLastName'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      occupation: json['occupation'] as String?,
      workPlace: json['workPlace'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'khmerFirstName': khmerFirstName,
      'khmerLastName': khmerLastName,
      'englishFirstName': englishFirstName,
      'englishLastName': englishLastName,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'occupation': occupation,
      'workPlace': workPlace,
    };
  }
}
