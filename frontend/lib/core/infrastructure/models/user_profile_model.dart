class UserProfileModel {
  final String userId;
  final String authUserId;
  final String email;
  final String fullName;
  final String activeStatus;

  final String? phoneNumber;
  final String? address;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? phone;
  final String avatarUrl;

  UserProfileModel({
    required this.userId,
    required this.authUserId,
    required this.email,
    required this.fullName,
    required this.activeStatus,
    this.phoneNumber,
    this.address,
    this.createdAt,
    this.updatedAt,
    this.phone,
    this.avatarUrl = '',
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userId: (json['userId'] ?? json['user_id'] ?? '').toString(),
      authUserId: (json['authUserId'] ?? json['auth_user_id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      fullName:
          (json['fullName'] ?? json['full_name'] ?? 'Unknown User').toString(),
      activeStatus:
          (json['activeStatus'] ?? json['active_status'] ?? 'inactive')
              .toString(),
      phoneNumber: (json['phoneNumber'] ?? json['phone'])?.toString(),
      address: json['address']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'].toString())
              : null,
      avatarUrl: json['avatarUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'authUserId': authUserId,
      'email': email,
      'fullName': fullName,
      'activeStatus': activeStatus,
      'phoneNumber': phoneNumber,
      'address': address,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (avatarUrl.isNotEmpty) 'avatarUrl': avatarUrl,
    };
  }

  UserProfileModel copyWith({
    String? userId,
    String? authUserId,
    String? email,
    String? fullName,
    String? activeStatus,
    String? phoneNumber,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? phone,
    String? avatarUrl,
  }) {
    return UserProfileModel(
      userId: userId ?? this.userId,
      authUserId: authUserId ?? this.authUserId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      activeStatus: activeStatus ?? this.activeStatus,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
