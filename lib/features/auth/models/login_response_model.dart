class LoginResponseModel {
  final String accessToken;
  final String tokenType;
  final int userId;
  final String username;
  final String email;
  final List<String> roles;
  final String fullToken;

  const LoginResponseModel({
    required this.accessToken,
    required this.tokenType,
    required this.userId,
    required this.username,
    required this.email,
    required this.roles,
    required this.fullToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'tokenType': tokenType,
      'userId': userId,
      'username': username,
      'email': email,
      'roles': roles,
      'fullToken': fullToken,
    };
  }

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      accessToken: json['accessToken'] as String,
      tokenType: json['tokenType'] as String,
      userId: (json['userId'] as num).toInt(),
      username: json['username'] as String,
      email: json['email'] as String,
      roles: (json['roles'] as List<dynamic>).map((e) => e as String).toList(),
      fullToken: json['fullToken'] as String,
    );
  }

  LoginResponseModel copyWith({
    String? accessToken,
    String? tokenType,
    int? userId,
    String? username,
    String? email,
    List<String>? roles,
    String? fullToken,
  }) {
    return LoginResponseModel(
      accessToken: accessToken ?? this.accessToken,
      tokenType: tokenType ?? this.tokenType,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      roles: roles ?? this.roles,
      fullToken: fullToken ?? this.fullToken,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginResponseModel &&
        other.accessToken == accessToken &&
        other.tokenType == tokenType &&
        other.userId == userId &&
        other.username == username &&
        other.email == email &&
        _listEquals(other.roles, roles) &&
        other.fullToken == fullToken;
  }

  @override
  int get hashCode {
    return accessToken.hashCode ^
        tokenType.hashCode ^
        userId.hashCode ^
        username.hashCode ^
        email.hashCode ^
        roles.hashCode ^
        fullToken.hashCode;
  }

  @override
  String toString() {
    return 'LoginResponseModel(accessToken: $accessToken, tokenType: $tokenType, userId: $userId, username: $username, email: $email, roles: $roles, fullToken: $fullToken)';
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
