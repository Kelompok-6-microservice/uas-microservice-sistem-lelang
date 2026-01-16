class ApiConfig {
  // Gunakan 10.0.2.2 jika pakai Emulator Android
  // Gunakan localhost jika pakai iOS Simulator
  static const String baseUrl = "http://10.0.2.2"; 
  
  // Asumsi Port berdasarkan docker-compose (Sesuaikan jika di .env beda)
  static const String userService = "$baseUrl:8001"; // Port Lumen
  static const String itemService = "$baseUrl:8002"; // Port FastAPI
  static const String biddingService = "$baseUrl:8003"; // Port Node.js
  static const String notifService = "$baseUrl:8004";   // Port Go
}
