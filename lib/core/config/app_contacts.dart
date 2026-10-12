/// Support contact details. DUMMY values until the real lines are set up.
class AppContacts {
  const AppContacts._();
  static const whatsappNumber = '2348000000000'; // digits only, with country code
  static const phoneNumber = '+2348000000001';
  static const email = 'support@uruvia.com';
  static const hours = 'Monday to Friday, 9am to 5pm';

  static String get whatsappUrl => 'https://wa.me/$whatsappNumber?text=${Uri.encodeComponent('Hello Uruvia support, ')}';
  static String get phoneUrl => 'tel:$phoneNumber';
  static String get emailUrl => 'mailto:$email?subject=${Uri.encodeComponent('Uruvia support')}';
}
