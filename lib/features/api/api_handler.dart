import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:event_app/model/model.dart';
import 'package:http/http.dart' as http;

class ApiHandler {
  final String baseUri = 'https://10.0.2.2:7169/api/Users';
  final Dio _dio = Dio();

  ApiHandler() {
    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }

  Future<List<User>> getUserData() async {
    List<User> data = [];

    try {
      final response = await _dio.get(
        baseUri,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = response.data;
        for (var item in jsonData) {
          data.add(User.fromJson(item));
        }
      } else {
        print('Error: Server returned status code ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
    return data;
  }

  Future<http.Response> updateUser(
      {required int userId, required User user}) async {
    final uri = Uri.parse('$baseUri/$userId');
    late http.Response response;

    // Configure http client to ignore certificate validation
    final client = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    try {
      // Use the configured client for the request
      final request = await client.putUrl(uri);
      request.headers.set('Content-Type', 'application/json; charset=UTF-8');
      request.write(json.encode(user));

      // Send the request
      final httpResponse = await request.close();
      final responseBody = await httpResponse.transform(utf8.decoder).join();
      response = http.Response(responseBody, httpResponse.statusCode);
    } catch (e) {
      return response;
    }
    return response;
  }

  Future<http.Response> addUser({required User user}) async {
    http.Response response =
        http.Response('', 500); // Default response initialization

    try {
      final dioResponse = await _dio.post(
        baseUri,
        data: user
            .toJson(), // Assuming toJson method is implemented in User model
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );

      // Convert Dio Response to http.Response
      response = http.Response(
        json.encode(dioResponse
            .data), // Assuming Dio response data can be encoded to JSON
        dioResponse.statusCode ?? 500,
      );
    } catch (e) {
      print('Error: $e'); // Logging the error for debugging
    }

    return response;
  }

  Future<http.Response> deleteUser({required int userId}) async {
    final uri = Uri.parse('$baseUri/$userId');
    http.Response response;

    try {
      final client = HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;

      final request = await client.deleteUrl(uri);
      request.headers.set('Content-Type', 'application/json; charset=UTF-8');

      final httpResponse = await request.close();
      final responseBody = await httpResponse.transform(utf8.decoder).join();

      response = http.Response(responseBody, httpResponse.statusCode);
    } catch (e) {
      print('Error deleting user: $e');
      response = http.Response('Error deleting user', 500);
    }

    return response;
  }

  Future<User?> getUserById({required int userId}) async {
    final uri = Uri.parse('$baseUri/$userId');
    User? user;

    try {
      HttpOverrides.global = MyHttpOverrides();
      final response = await http.get(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200 && response.statusCode <= 299) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        user = User.fromJson(jsonData);
      } else {
        print('Error: Server returned status code ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      HttpOverrides.global = null;
    }

    return user;
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  }
}
