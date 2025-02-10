import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity()
      .onConnectivityChanged
      .map((status) => status != ConnectivityResult.none);
});

class ConnectivityService {
  Future<bool> isConnected() async {
    // I tried it with neosilver.fr but the response time is above 5 sec xD
    String url = 'https://www.google.fr';

    final result = await Connectivity().checkConnectivity();
    // I used it only for the simulator (an issue with testing the deactivate the WIFI/5G in simulator)
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 3));
      // If the response is successful, return true
      return response.statusCode == 200 && result != ConnectivityResult.none;
    } catch (e) {
      // If there's an error (timeout or other), return false
      print(
          'Error checking internet connection: $e'); // Log the error for debugging
      return false;
    }
  }

  Stream<bool> get onConnectivityChanged {
    return Connectivity()
        .onConnectivityChanged
        .map((status) => status != ConnectivityResult.none);
  }
}
