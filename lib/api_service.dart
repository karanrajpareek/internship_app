import 'dart:convert';
import 'package:http/http.dart' as http;
import 'internship_model.dart';

class ApiService {
  static const String apiUrl = 'https://internshala.com/flutter_hiring/search';

  static Future<List<Internship>> fetchInternships() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<Internship> internships = [];
      data['internships_meta'].forEach((key, value) {
        internships.add(Internship.fromJson(value));
      });
      return internships;
    } else {
      throw Exception('Failed to load internships');
    }
  }
}
