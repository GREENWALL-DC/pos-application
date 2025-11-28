class UserModel {
  final int id;
  final String username;
  final String email;
  final String userType;
   final String phone;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.userType,
    required this.phone
  });

// ✅ Clean - only handles user data, not token
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
     id: json['id'] ?? json['user']['id'],
    username: json['username'] ?? json['user']['username'],
    email: json['email'] ?? json['user']['email'],
    userType: json['user_type'] ?? json['user']['user_type'],
phone: json['phone'] ?? json['user']['phone'] ?? '', // ✅ Safe default
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
    'user_type': userType, 
     'phone': phone,
    };
  }


}
