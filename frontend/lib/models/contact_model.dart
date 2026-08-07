class ContactModel {
  final String id;
  final String name;
  final String phone;
  final bool isTrusted;

  ContactModel({
    required this.id,
    required this.name,
    required this.phone,
    this.isTrusted = true,
  });
}
