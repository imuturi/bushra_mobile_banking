class CustomerDetails {
  final String passportNumber;
  final String firstName;
  final String lastName;
  final String gender;
  final String address3;
  final String address2;
  final String address1;
  final String middleName;
  final DateTime dateOfBirth;
  final String customerNumber;
  final String email;

  CustomerDetails({
    required this.passportNumber,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.address3,
    required this.address2,
    required this.address1,
    required this.middleName,
    required this.dateOfBirth,
    required this.customerNumber,
    required this.email,
  });

  factory CustomerDetails.fromJson(Map<String, dynamic> json) {
    return CustomerDetails(
      passportNumber: json['passportNumber'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      gender: json['gender'],
      address3: json['address3'],
      address2: json['address2'],
      address1: json['address1'],
      middleName: json['middleName'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      customerNumber: json['customerNumber'],
      email: json['email'],
    );
  }
}