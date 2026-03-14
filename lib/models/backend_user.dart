class BackendUser {
  final String id;
  final String email;
  final String orgName;
  final String role;
  final String? createDate;
  final String? updateDate;
  final bool? isActive;

  const BackendUser({
    required this.id,
    required this.email,
    required this.orgName,
    required this.role,
    this.createDate,
    this.updateDate,
    this.isActive,
  });

  factory BackendUser.fromJson(Map<String, dynamic> json) {
    return BackendUser(
      id: (json['id'] ?? '').toString(),
      email: (json['contactEmail'] ?? json['email'] ?? '').toString(),
      orgName: (json['orgName'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      createDate: json['createDate']?.toString(),
      updateDate: json['updateDate']?.toString(),
      isActive: json['isActive'] as bool?,
    );
  }
}
