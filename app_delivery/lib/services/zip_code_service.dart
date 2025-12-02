import 'dart:convert';
import 'package:http/http.dart' as http;

class ZipCodeService {
  // Uses ViaCEP - Free Brazilian ZIP code API
  // For other countries, you can use different APIs like:
  // - US: https://www.zipcodeapi.com/ or https://zippopotam.us/
  // - International: https://postcodes.io/

  static Future<Map<String, String>> lookupZipCode(String zipCode) async {
    try {
      // Remove any formatting (dashes, spaces)
      final cleanZip = zipCode.replaceAll(RegExp(r'[^0-9]'), '');

      // Brazilian ZIP code lookup using ViaCEP (free API)
      final response = await http.get(
        Uri.parse('https://viacep.com.br/ws/$cleanZip/json/'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if ZIP was found
        if (data.containsKey('erro')) {
          throw Exception('ZIP code not found');
        }

        return {
          'street': data['logradouro'] ?? '',
          'neighborhood': data['bairro'] ?? '',
          'city': data['localidade'] ?? '',
          'state': data['uf'] ?? '',
        };
      } else {
        throw Exception('Failed to lookup ZIP code');
      }
    } catch (e) {
      throw Exception('Error looking up ZIP: ${e.toString()}');
    }
  }

  // Alternative method for US ZIP codes using Zippopotam
  static Future<Map<String, String>> lookupUSZipCode(String zipCode) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.zippopotam.us/us/$zipCode'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final place = data['places'][0];

        return {
          'street': '',
          'neighborhood': '',
          'city': place['place name'] ?? '',
          'state': place['state abbreviation'] ?? '',
        };
      } else {
        throw Exception('ZIP code not found');
      }
    } catch (e) {
      throw Exception('Error looking up ZIP: ${e.toString()}');
    }
  }
}
