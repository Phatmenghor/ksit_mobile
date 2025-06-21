class ValidationUtils {
  // Email validation
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Phone validation
  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(phone);
  }

  // Password validation
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  // Strong password validation
  static bool isStrongPassword(String password) {
    return RegExp(
            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$')
        .hasMatch(password);
  }

  // Name validation
  static bool isValidName(String name) {
    return name.trim().length >= 2 && RegExp(r'^[a-zA-Z\s]+$').hasMatch(name);
  }

  // URL validation
  static bool isValidUrl(String url) {
    return Uri.tryParse(url) != null && url.startsWith(RegExp(r'https?://'));
  }

  // Credit card validation (Luhn algorithm)
  static bool isValidCreditCard(String cardNumber) {
    cardNumber = cardNumber.replaceAll(RegExp(r'\s+'), '');
    if (cardNumber.length < 13 || cardNumber.length > 19) return false;

    int sum = 0;
    bool alternate = false;

    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) digit = (digit % 10) + 1;
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  // Check if string contains only numbers
  static bool isNumeric(String str) {
    return RegExp(r'^[0-9]+$').hasMatch(str);
  }

  // Check if string is alphanumeric
  static bool isAlphanumeric(String str) {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(str);
  }

  // Validate date format (yyyy-mm-dd)
  static bool isValidDate(String date) {
    try {
      DateTime.parse(date);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Check if string has minimum length
  static bool hasMinLength(String str, int minLength) {
    return str.trim().length >= minLength;
  }

  // Check if string has maximum length
  static bool hasMaxLength(String str, int maxLength) {
    return str.trim().length <= maxLength;
  }

  // Validate file extension
  static bool hasValidExtension(
      String fileName, List<String> allowedExtensions) {
    final extension = fileName.split('.').last.toLowerCase();
    return allowedExtensions.contains(extension);
  }

  // Check if value is within range
  static bool isInRange(num value, num min, num max) {
    return value >= min && value <= max;
  }

  // Postal code validation (US format)
  static bool isValidPostalCode(String postalCode) {
    return RegExp(r'^\d{5}(-\d{4})?$').hasMatch(postalCode);
  }

  // Get validation error message
  static String? getEmailError(String email) {
    if (email.isEmpty) return 'Email is required';
    if (!isValidEmail(email)) return 'Please enter a valid email';
    return null;
  }

  static String? getPasswordError(String password) {
    if (password.isEmpty) return 'Password is required';
    if (!isValidPassword(password)) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? getNameError(String name) {
    if (name.trim().isEmpty) return 'Name is required';
    if (!isValidName(name)) return 'Please enter a valid name';
    return null;
  }

  static String? getPhoneError(String phone) {
    if (phone.isEmpty) return 'Phone number is required';
    if (!isValidPhone(phone)) return 'Please enter a valid phone number';
    return null;
  }
}
