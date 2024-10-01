import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:login_tasarim/login_screen.dart';
import 'package:login_tasarim/menu_page.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();
final userId = uuid.v4();  // UUID v4 oluşturur


class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final url = Uri.parse('http://10.56.8.249:5266/api/kullanici/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'KullaniciAdi': _usernameController.text,
          'Adı': _firstNameController.text,
          'Soyadı': _lastNameController.text,
          'Sifre': _passwordController.text,
        }),
      );

      print('HTTP Durum Kodu: ${response.statusCode}');
      print('Yanıt: ${response.body}');

      final jsonResponse = jsonDecode(response.body);
      print('JSON Yanıtı: $jsonResponse');

     /* if (response.statusCode == 200 && jsonResponse['message'] == 'Kayıt başarılı') {
        // Kullanıcıyı ana sayfaya yönlendirme veya başka bir işlem yapabilirsiniz
        // MenuPage'e kullaniciId'yi geçerek yönlendir
        final kullaniciId = jsonResponse['kullaniciId'];
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MenuPage(kullaniciId: kullaniciId),)


        );
      } */

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        print('JSON Yanıtı: $jsonResponse');

        final message = jsonResponse['message'];
        final kullaniciId = jsonResponse['kullaniciId'] as int?;

        print('Mesaj: $message');
        print('Kullanıcı ID: $kullaniciId');

        if (message == 'Kayıt başarılı') {
          if (kullaniciId != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MenuPage(kullaniciId: kullaniciId),
              ),
            );
          } else {
            setState(() {
              _errorMessage = 'Kullanıcı ID alınamadı';
            });
          }
        } else {
          setState(() {
            _errorMessage = 'Kayıt sırasında bir hata oluştu';
          });
        }
      }





      else {
        setState(() {
          _errorMessage = jsonResponse['message'] ?? 'Kayıt başarısız';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Bir hata oluştu: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.teal.shade800,
              Colors.teal.shade300,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person_add,
                    color: Colors.teal.shade700,
                    size: 100,
                  ),
                ),
                SizedBox(height: 60),
                Container(
                  height: 400,
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'REGISTER',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Kullanıcı Adı',
                          labelStyle: TextStyle(color: Colors.teal.shade900),
                          filled: true,
                          fillColor: Colors.white,
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.teal.shade300,
                              width: 1,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.teal.shade900,
                              width: 2,
                            ),
                          ),
                        ),
                        style: TextStyle(color: Colors.teal.shade900),
                      ),
                      TextField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          labelText: 'Adı',
                          labelStyle: TextStyle(color: Colors.teal.shade900),
                          filled: true,
                          fillColor: Colors.white,
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.teal.shade300,
                              width: 1,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.teal.shade900,
                              width: 2,
                            ),
                          ),
                        ),
                        style: TextStyle(color: Colors.teal.shade900),
                      ),
                      TextField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          labelText: 'Soyadı',
                          labelStyle: TextStyle(color: Colors.teal.shade900),
                          filled: true,
                          fillColor: Colors.white,
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.teal.shade300,
                              width: 1,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.teal.shade900,
                              width: 2,
                            ),
                          ),
                        ),
                        style: TextStyle(color: Colors.teal.shade900),
                      ),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Şifre',
                          labelStyle: TextStyle(color: Colors.teal.shade900),
                          filled: true,
                          fillColor: Colors.white,
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.teal.shade300,
                              width: 1,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.teal.shade900,
                              width: 2,
                            ),
                          ),
                        ),
                        style: TextStyle(color: Colors.teal.shade900),
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Divider(
                            color: Colors.grey.shade300,
                            thickness: 1,
                            height: 40,
                          ),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade700,
                              padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 5,
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                              'REGISTER',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text(
                    'Already have an account? Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

