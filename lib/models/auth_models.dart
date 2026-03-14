/// Request/Response models cho Authentication

class RegisterRequest {
  final String username;
  final String contactEmail;
  final String password;
  final String firstName;
  final String lastName;
  final String? phoneNumber;

  RegisterRequest({
    required this.username,
    required this.contactEmail,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'contactEmail': contactEmail,
      'password': password,
      'orgName': '$firstName $lastName', // Backend expects orgName
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
    };
  }
}

class RegisterResponse {
  final String message;
  final int? userId;

  RegisterResponse({
    required this.message,
    this.userId,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'] as String? ?? 'Registration successful',
      userId: json['userId'] as int?,
    );
  }
}

class LoginRequest {
  final String contactEmail;
  final String password;

  LoginRequest({
    required this.contactEmail,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'contactEmail': contactEmail,
      'password': password,
    };
  }
}

class LoginResponse {
  final String token;
  final String type;
  final String? userId; // UUID string
  final String username;
  final String email;
  final List<String> roles;

  LoginResponse({
    required this.token,
    required this.type,
    this.userId,
    required this.username,
    required this.email,
    required this.roles,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: (json['token'] ?? json['accessToken']) as String,
      type: json['type'] as String? ?? 'Bearer',
      userId: json['user']?['id']?.toString() ?? json['userId']?.toString(), // Handle both nested and flat responses
      username: json['user']?['orgName']?.toString() ?? json['username']?.toString() ?? 'User',
      email: json['user']?['contactEmail']?.toString() ?? json['email']?.toString() ?? '',
      roles: (json['user']?['role'] != null) 
          ? [json['user']!['role'].toString()] 
          : ((json['roles'] as List<dynamic>?)?.map((r) => r.toString()).toList() ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'type': type,
      'userId': userId,
      'username': username,
      'email': email,
      'roles': roles,
    };
  }
}

class UserProfile {
  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final List<String> roles;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.roles = const [],
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      roles: (json['roles'] as List<dynamic>?)
              ?.map((role) => role.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'roles': roles,
    };
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return username;
  }
}

class UpdateProfileRequest {
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? email;

  UpdateProfileRequest({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.email,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (email != null) data['email'] = email;
    return data;
  }
}
