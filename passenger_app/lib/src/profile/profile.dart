class Profile {
  late String firstName;
  late String lastName;
  String? userName;
  String? licensePlate;
  Profile.fromJson(json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    userName = json['userName'];
    licensePlate = json['licensePlateNo'];
  }
}
