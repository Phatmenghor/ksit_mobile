// lib/features/profile/models/staff_profile_model.dart
class StaffProfileModel {
  final int? id;
  final String? username;
  final String? email;
  final List<String>? roles;
  final String? status;
  final String? khmerFirstName;
  final String? khmerLastName;
  final String? englishFirstName;
  final String? englishLastName;
  final String? gender;
  final String? dateOfBirth;
  final String? phoneNumber;
  final String? currentAddress;
  final String? nationality;
  final String? ethnicity;
  final String? placeOfBirth;
  final String? identifyNumber;
  final String? staffId;
  final String? nationalId;
  final String? startWorkDate;
  final String? currentPositionDate;
  final String? employeeWork;
  final String? disability;
  final String? payrollAccountNumber;
  final String? cppMembershipNumber;
  final String? province;
  final String? district;
  final String? commune;
  final String? village;
  final String? officeName;
  final String? currentPosition;
  final String? decreeFinal;
  final String? rankAndClass;
  final StaffDepartmentModel? department;
  final String? profileUrl;
  final String? taughtEnglish;
  final String? threeLevelClass;
  final String? referenceNote;
  final String? technicalTeamLeader;
  final String? assistInTeaching;
  final String? serialNumber;
  final String? twoLevelClass;
  final String? classResponsibility;
  final String? lastSalaryIncrementDate;
  final String? teachAcrossSchools;
  final String? overtimeHours;
  final String? issuedDate;
  final String? suitableClass;
  final String? bilingual;
  final String? academicYearTaught;
  final String? workHistory;
  final String? maritalStatus;
  final String? mustBe;
  final String? affiliatedProfession;
  final String? federationName;
  final String? affiliatedOrganization;
  final String? federationEstablishmentDate;
  final String? wivesSalary;
  final List<TeachersProfessionalRankModel>? teachersProfessionalRank;
  final List<TeacherExperienceModel>? teacherExperience;
  final List<TeacherPraiseOrCriticismModel>? teacherPraiseOrCriticism;
  final List<TeacherEducationModel>? teacherEducation;
  final List<TeacherVocationalModel>? teacherVocational;
  final List<TeacherShortCourseModel>? teacherShortCourse;
  final List<TeacherLanguageModel>? teacherLanguage;
  final List<TeacherFamilyModel>? teacherFamily;
  final String? createdAt;

  const StaffProfileModel({
    this.id,
    this.username,
    this.email,
    this.roles,
    this.status,
    this.khmerFirstName,
    this.khmerLastName,
    this.englishFirstName,
    this.englishLastName,
    this.gender,
    this.dateOfBirth,
    this.phoneNumber,
    this.currentAddress,
    this.nationality,
    this.ethnicity,
    this.placeOfBirth,
    this.identifyNumber,
    this.staffId,
    this.nationalId,
    this.startWorkDate,
    this.currentPositionDate,
    this.employeeWork,
    this.disability,
    this.payrollAccountNumber,
    this.cppMembershipNumber,
    this.province,
    this.district,
    this.commune,
    this.village,
    this.officeName,
    this.currentPosition,
    this.decreeFinal,
    this.rankAndClass,
    this.department,
    this.profileUrl,
    this.taughtEnglish,
    this.threeLevelClass,
    this.referenceNote,
    this.technicalTeamLeader,
    this.assistInTeaching,
    this.serialNumber,
    this.twoLevelClass,
    this.classResponsibility,
    this.lastSalaryIncrementDate,
    this.teachAcrossSchools,
    this.overtimeHours,
    this.issuedDate,
    this.suitableClass,
    this.bilingual,
    this.academicYearTaught,
    this.workHistory,
    this.maritalStatus,
    this.mustBe,
    this.affiliatedProfession,
    this.federationName,
    this.affiliatedOrganization,
    this.federationEstablishmentDate,
    this.wivesSalary,
    this.teachersProfessionalRank,
    this.teacherExperience,
    this.teacherPraiseOrCriticism,
    this.teacherEducation,
    this.teacherVocational,
    this.teacherShortCourse,
    this.teacherLanguage,
    this.teacherFamily,
    this.createdAt,
  });

  factory StaffProfileModel.fromJson(Map<String, dynamic> json) {
    return StaffProfileModel(
      id: json['id'] as int?,
      username: json['username'] as String?,
      email: json['email'] as String?,
      roles: json['roles'] != null
          ? (json['roles'] as List).map((e) => e.toString()).toList()
          : null,
      status: json['status'] as String?,
      khmerFirstName: json['khmerFirstName'] as String?,
      khmerLastName: json['khmerLastName'] as String?,
      englishFirstName: json['englishFirstName'] as String?,
      englishLastName: json['englishLastName'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      currentAddress: json['currentAddress'] as String?,
      nationality: json['nationality'] as String?,
      ethnicity: json['ethnicity'] as String?,
      placeOfBirth: json['placeOfBirth'] as String?,
      identifyNumber: json['identifyNumber'] as String?,
      staffId: json['staffId'] as String?,
      nationalId: json['nationalId'] as String?,
      startWorkDate: json['startWorkDate'] as String?,
      currentPositionDate: json['currentPositionDate'] as String?,
      employeeWork: json['employeeWork'] as String?,
      disability: json['disability'] as String?,
      payrollAccountNumber: json['payrollAccountNumber'] as String?,
      cppMembershipNumber: json['cppMembershipNumber'] as String?,
      province: json['province'] as String?,
      district: json['district'] as String?,
      commune: json['commune'] as String?,
      village: json['village'] as String?,
      officeName: json['officeName'] as String?,
      currentPosition: json['currentPosition'] as String?,
      decreeFinal: json['decreeFinal'] as String?,
      rankAndClass: json['rankAndClass'] as String?,
      department: json['department'] != null
          ? StaffDepartmentModel.fromJson(
              json['department'] as Map<String, dynamic>)
          : null,
      profileUrl: json['profileUrl'] as String?,
      taughtEnglish: json['taughtEnglish'] as String?,
      threeLevelClass: json['threeLevelClass'] as String?,
      referenceNote: json['referenceNote'] as String?,
      technicalTeamLeader: json['technicalTeamLeader'] as String?,
      assistInTeaching: json['assistInTeaching'] as String?,
      serialNumber: json['serialNumber'] as String?,
      twoLevelClass: json['twoLevelClass'] as String?,
      classResponsibility: json['classResponsibility'] as String?,
      lastSalaryIncrementDate: json['lastSalaryIncrementDate'] as String?,
      teachAcrossSchools: json['teachAcrossSchools'] as String?,
      overtimeHours: json['overtimeHours'] as String?,
      issuedDate: json['issuedDate'] as String?,
      suitableClass: json['suitableClass'] as String?,
      bilingual: json['bilingual'] as String?,
      academicYearTaught: json['academicYearTaught'] as String?,
      workHistory: json['workHistory'] as String?,
      maritalStatus: json['maritalStatus'] as String?,
      mustBe: json['mustBe'] as String?,
      affiliatedProfession: json['affiliatedProfession'] as String?,
      federationName: json['federationName'] as String?,
      affiliatedOrganization: json['affiliatedOrganization'] as String?,
      federationEstablishmentDate:
          json['federationEstablishmentDate'] as String?,
      wivesSalary: json['wivesSalary'] as String?,
      teachersProfessionalRank: json['teachersProfessionalRank'] != null
          ? (json['teachersProfessionalRank'] as List)
              .map((e) => TeachersProfessionalRankModel.fromJson(
                  e as Map<String, dynamic>))
              .toList()
          : null,
      teacherExperience: json['teacherExperience'] != null
          ? (json['teacherExperience'] as List)
              .map((e) =>
                  TeacherExperienceModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      teacherPraiseOrCriticism: json['teacherPraiseOrCriticism'] != null
          ? (json['teacherPraiseOrCriticism'] as List)
              .map((e) => TeacherPraiseOrCriticismModel.fromJson(
                  e as Map<String, dynamic>))
              .toList()
          : null,
      teacherEducation: json['teacherEducation'] != null
          ? (json['teacherEducation'] as List)
              .map((e) =>
                  TeacherEducationModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      teacherVocational: json['teacherVocational'] != null
          ? (json['teacherVocational'] as List)
              .map((e) =>
                  TeacherVocationalModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      teacherShortCourse: json['teacherShortCourse'] != null
          ? (json['teacherShortCourse'] as List)
              .map((e) =>
                  TeacherShortCourseModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      teacherLanguage: json['teacherLanguage'] != null
          ? (json['teacherLanguage'] as List)
              .map((e) =>
                  TeacherLanguageModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      teacherFamily: json['teacherFamily'] != null
          ? (json['teacherFamily'] as List)
              .map(
                  (e) => TeacherFamilyModel.fromJson(e as Map<String, dynamic>))
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
      'roles': roles,
      'status': status,
      'khmerFirstName': khmerFirstName,
      'khmerLastName': khmerLastName,
      'englishFirstName': englishFirstName,
      'englishLastName': englishLastName,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'phoneNumber': phoneNumber,
      'currentAddress': currentAddress,
      'nationality': nationality,
      'ethnicity': ethnicity,
      'placeOfBirth': placeOfBirth,
      'identifyNumber': identifyNumber,
      'staffId': staffId,
      'nationalId': nationalId,
      'startWorkDate': startWorkDate,
      'currentPositionDate': currentPositionDate,
      'employeeWork': employeeWork,
      'disability': disability,
      'payrollAccountNumber': payrollAccountNumber,
      'cppMembershipNumber': cppMembershipNumber,
      'province': province,
      'district': district,
      'commune': commune,
      'village': village,
      'officeName': officeName,
      'currentPosition': currentPosition,
      'decreeFinal': decreeFinal,
      'rankAndClass': rankAndClass,
      'department': department?.toJson(),
      'profileUrl': profileUrl,
      'taughtEnglish': taughtEnglish,
      'threeLevelClass': threeLevelClass,
      'referenceNote': referenceNote,
      'technicalTeamLeader': technicalTeamLeader,
      'assistInTeaching': assistInTeaching,
      'serialNumber': serialNumber,
      'twoLevelClass': twoLevelClass,
      'classResponsibility': classResponsibility,
      'lastSalaryIncrementDate': lastSalaryIncrementDate,
      'teachAcrossSchools': teachAcrossSchools,
      'overtimeHours': overtimeHours,
      'issuedDate': issuedDate,
      'suitableClass': suitableClass,
      'bilingual': bilingual,
      'academicYearTaught': academicYearTaught,
      'workHistory': workHistory,
      'maritalStatus': maritalStatus,
      'mustBe': mustBe,
      'affiliatedProfession': affiliatedProfession,
      'federationName': federationName,
      'affiliatedOrganization': affiliatedOrganization,
      'federationEstablishmentDate': federationEstablishmentDate,
      'wivesSalary': wivesSalary,
      'teachersProfessionalRank':
          teachersProfessionalRank?.map((e) => e.toJson()).toList(),
      'teacherExperience': teacherExperience?.map((e) => e.toJson()).toList(),
      'teacherPraiseOrCriticism':
          teacherPraiseOrCriticism?.map((e) => e.toJson()).toList(),
      'teacherEducation': teacherEducation?.map((e) => e.toJson()).toList(),
      'teacherVocational': teacherVocational?.map((e) => e.toJson()).toList(),
      'teacherShortCourse': teacherShortCourse?.map((e) => e.toJson()).toList(),
      'teacherLanguage': teacherLanguage?.map((e) => e.toJson()).toList(),
      'teacherFamily': teacherFamily?.map((e) => e.toJson()).toList(),
      'createdAt': createdAt,
    };
  }

  StaffProfileModel copyWith({
    int? id,
    String? username,
    String? email,
    List<String>? roles,
    String? status,
    String? khmerFirstName,
    String? khmerLastName,
    String? englishFirstName,
    String? englishLastName,
    String? gender,
    String? dateOfBirth,
    String? phoneNumber,
    String? currentAddress,
    String? nationality,
    String? ethnicity,
    String? placeOfBirth,
    String? identifyNumber,
    String? staffId,
    String? nationalId,
    String? startWorkDate,
    String? currentPositionDate,
    String? employeeWork,
    String? disability,
    String? payrollAccountNumber,
    String? cppMembershipNumber,
    String? province,
    String? district,
    String? commune,
    String? village,
    String? officeName,
    String? currentPosition,
    String? decreeFinal,
    String? rankAndClass,
    StaffDepartmentModel? department,
    String? profileUrl,
    String? createdAt,
  }) {
    return StaffProfileModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      roles: roles ?? this.roles,
      status: status ?? this.status,
      khmerFirstName: khmerFirstName ?? this.khmerFirstName,
      khmerLastName: khmerLastName ?? this.khmerLastName,
      englishFirstName: englishFirstName ?? this.englishFirstName,
      englishLastName: englishLastName ?? this.englishLastName,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      currentAddress: currentAddress ?? this.currentAddress,
      nationality: nationality ?? this.nationality,
      ethnicity: ethnicity ?? this.ethnicity,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      identifyNumber: identifyNumber ?? this.identifyNumber,
      staffId: staffId ?? this.staffId,
      nationalId: nationalId ?? this.nationalId,
      startWorkDate: startWorkDate ?? this.startWorkDate,
      currentPositionDate: currentPositionDate ?? this.currentPositionDate,
      employeeWork: employeeWork ?? this.employeeWork,
      disability: disability ?? this.disability,
      payrollAccountNumber: payrollAccountNumber ?? this.payrollAccountNumber,
      cppMembershipNumber: cppMembershipNumber ?? this.cppMembershipNumber,
      province: province ?? this.province,
      district: district ?? this.district,
      commune: commune ?? this.commune,
      village: village ?? this.village,
      officeName: officeName ?? this.officeName,
      currentPosition: currentPosition ?? this.currentPosition,
      decreeFinal: decreeFinal ?? this.decreeFinal,
      rankAndClass: rankAndClass ?? this.rankAndClass,
      department: department ?? this.department,
      profileUrl: profileUrl ?? this.profileUrl,
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
    return username ?? '';
  }

  String get primaryRole {
    if (roles != null && roles!.isNotEmpty) {
      return roles!.first;
    }
    return 'STAFF';
  }
}

class StaffDepartmentModel {
  final int? id;
  final String? code;
  final String? name;
  final String? urlLogo;
  final String? status;

  const StaffDepartmentModel({
    this.id,
    this.code,
    this.name,
    this.urlLogo,
    this.status,
  });

  factory StaffDepartmentModel.fromJson(Map<String, dynamic> json) {
    return StaffDepartmentModel(
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

// Teacher-related models
class TeachersProfessionalRankModel {
  final int? id;
  final String? rank;
  final String? date;
  final String? reference;

  const TeachersProfessionalRankModel({
    this.id,
    this.rank,
    this.date,
    this.reference,
  });

  factory TeachersProfessionalRankModel.fromJson(Map<String, dynamic> json) {
    return TeachersProfessionalRankModel(
      id: json['id'] as int?,
      rank: json['rank'] as String?,
      date: json['date'] as String?,
      reference: json['reference'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rank': rank,
      'date': date,
      'reference': reference,
    };
  }
}

class TeacherExperienceModel {
  final int? id;
  final String? position;
  final String? organization;
  final String? startDate;
  final String? endDate;
  final String? description;

  const TeacherExperienceModel({
    this.id,
    this.position,
    this.organization,
    this.startDate,
    this.endDate,
    this.description,
  });

  factory TeacherExperienceModel.fromJson(Map<String, dynamic> json) {
    return TeacherExperienceModel(
      id: json['id'] as int?,
      position: json['position'] as String?,
      organization: json['organization'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'position': position,
      'organization': organization,
      'startDate': startDate,
      'endDate': endDate,
      'description': description,
    };
  }
}

class TeacherPraiseOrCriticismModel {
  final int? id;
  final String? type;
  final String? description;
  final String? date;
  final String? issuedBy;

  const TeacherPraiseOrCriticismModel({
    this.id,
    this.type,
    this.description,
    this.date,
    this.issuedBy,
  });

  factory TeacherPraiseOrCriticismModel.fromJson(Map<String, dynamic> json) {
    return TeacherPraiseOrCriticismModel(
      id: json['id'] as int?,
      type: json['type'] as String?,
      description: json['description'] as String?,
      date: json['date'] as String?,
      issuedBy: json['issuedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'date': date,
      'issuedBy': issuedBy,
    };
  }
}

class TeacherEducationModel {
  final int? id;
  final String? degree;
  final String? institution;
  final String? yearFrom;
  final String? yearTo;
  final String? major;

  const TeacherEducationModel({
    this.id,
    this.degree,
    this.institution,
    this.yearFrom,
    this.yearTo,
    this.major,
  });

  factory TeacherEducationModel.fromJson(Map<String, dynamic> json) {
    return TeacherEducationModel(
      id: json['id'] as int?,
      degree: json['degree'] as String?,
      institution: json['institution'] as String?,
      yearFrom: json['yearFrom'] as String?,
      yearTo: json['yearTo'] as String?,
      major: json['major'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'degree': degree,
      'institution': institution,
      'yearFrom': yearFrom,
      'yearTo': yearTo,
      'major': major,
    };
  }
}

class TeacherVocationalModel {
  final int? id;
  final String? courseName;
  final String? institution;
  final String? duration;
  final String? completionDate;

  const TeacherVocationalModel({
    this.id,
    this.courseName,
    this.institution,
    this.duration,
    this.completionDate,
  });

  factory TeacherVocationalModel.fromJson(Map<String, dynamic> json) {
    return TeacherVocationalModel(
      id: json['id'] as int?,
      courseName: json['courseName'] as String?,
      institution: json['institution'] as String?,
      duration: json['duration'] as String?,
      completionDate: json['completionDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseName': courseName,
      'institution': institution,
      'duration': duration,
      'completionDate': completionDate,
    };
  }
}

class TeacherShortCourseModel {
  final int? id;
  final String? courseName;
  final String? provider;
  final String? duration;
  final String? completionDate;

  const TeacherShortCourseModel({
    this.id,
    this.courseName,
    this.provider,
    this.duration,
    this.completionDate,
  });

  factory TeacherShortCourseModel.fromJson(Map<String, dynamic> json) {
    return TeacherShortCourseModel(
      id: json['id'] as int?,
      courseName: json['courseName'] as String?,
      provider: json['provider'] as String?,
      duration: json['duration'] as String?,
      completionDate: json['completionDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseName': courseName,
      'provider': provider,
      'duration': duration,
      'completionDate': completionDate,
    };
  }
}

class TeacherLanguageModel {
  final int? id;
  final String? language;
  final String? proficiencyLevel;
  final String? certificationDate;

  const TeacherLanguageModel({
    this.id,
    this.language,
    this.proficiencyLevel,
    this.certificationDate,
  });

  factory TeacherLanguageModel.fromJson(Map<String, dynamic> json) {
    return TeacherLanguageModel(
      id: json['id'] as int?,
      language: json['language'] as String?,
      proficiencyLevel: json['proficiencyLevel'] as String?,
      certificationDate: json['certificationDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'language': language,
      'proficiencyLevel': proficiencyLevel,
      'certificationDate': certificationDate,
    };
  }
}

class TeacherFamilyModel {
  final int? id;
  final String? relationship;
  final String? name;
  final String? dateOfBirth;
  final String? occupation;

  const TeacherFamilyModel({
    this.id,
    this.relationship,
    this.name,
    this.dateOfBirth,
    this.occupation,
  });

  factory TeacherFamilyModel.fromJson(Map<String, dynamic> json) {
    return TeacherFamilyModel(
      id: json['id'] as int?,
      relationship: json['relationship'] as String?,
      name: json['name'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      occupation: json['occupation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'relationship': relationship,
      'name': name,
      'dateOfBirth': dateOfBirth,
      'occupation': occupation,
    };
  }
}
