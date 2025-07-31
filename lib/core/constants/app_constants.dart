class AppConstants {
  // App Info
  static const String appName = 'Booking Tiket Kereta Api';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'train_booking.db';
  static const int databaseVersion = 1;
  
  // User Types
  static const String userTypeAdmin = 'admin';
  static const String userTypePassenger = 'passenger';
  
  // Train Classes
  static const List<String> trainClasses = [
    'Ekonomi',
    'Bisnis', 
    'Eksekutif',
    'Luxury'
  ];
  
  // Stations
  static const List<String> stations = [
    'Gambir (GMR)',
    'Pasar Senen (PSE)',
    'Yogyakarta (YK)',
    'Bandung (BD)',
    'Surabaya Gubeng (SGU)',
    'Semarang Tawang (SMT)',
    'Solo Balapan (SLO)',
    'Malang (ML)',
  ];
  
  // Default Admin Credentials
  static const String defaultAdminUsername = 'admin';
  static const String defaultAdminPassword = 'admin123';
} 