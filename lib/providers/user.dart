class User {
  String accessKey;
  String active;
  String email;
  String name;
  String permission;
  String phone;
  String storeKey;

  User({
    this.accessKey,
    this.active,
    this.email,
    this.name,
    this.permission,
    this.phone,
    this.storeKey,
  });

  factory User.fromJson(Map<String, dynamic> parsedJson) {
    return User(
      accessKey: parsedJson['accessKey'],
      active: parsedJson['active'],
      email: parsedJson['email'],
      name: parsedJson['name'],
      permission: parsedJson['permission'],
      phone: parsedJson['phone'],
      storeKey: parsedJson['storeKey'],
    );
  }
}
