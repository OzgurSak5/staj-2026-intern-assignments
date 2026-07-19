mixin AuthValidationMixin {
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-posta alanı boş bırakılamaz';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Geçerli bir e-posta adresi girin';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre alanı boş bırakılamaz';
    }
    if (value.length < 8) {
      return 'Şifre en az 8 karakter olmalıdır';
    }
    return null;
  }

  String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Lütfen şifrenizi tekrar girin';
    }
    if (value != password) {
      return 'Şifreler uyuşmuyor';
    }
    return null;
  }
}
