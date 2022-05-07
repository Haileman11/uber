class Profile {
  late String firstName;
  late String lastName;
  late String userName;
  Profile.fromJson(json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    userName = json['userName'];
  }
}
