class UserRoles {
  static const eo = 'eo';
  static const talent = 'talent';

  static bool isMobileRole(String role) => role == talent || role == eo;
}
