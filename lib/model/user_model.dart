class UserModel{
  final String? uid;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? address;
  final String? icNumber;
  final String? gender;
  final String? password;
  final String? role;
  final String? profilePicture;
  final String? specialist;
  final String? status;

  UserModel({
    this.uid,
    this.firstName,
    this.lastName,
    this.address,
    this.icNumber,
    this.email,
    this.gender,
    this.password,
    this.phone,
    this.profilePicture,
    this.role,
    this.specialist,
    this.status,
  });
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName ?? null,
      'lastName': lastName ?? null,
      'email': email ?? null, 
      'phone': phone ?? null,
      'address': address ?? null, 
      'icNumber': icNumber ?? null,
      'gender': gender ?? null,
      'password': password ?? null,
      'role': role ?? null,
      'profilePicture': profilePicture ?? null,
      'specialist': specialist ?? null ,
      'status' : status ?? 'Offline',
    };
  }
}