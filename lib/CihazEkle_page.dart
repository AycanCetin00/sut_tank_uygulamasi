
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class CihazEkleSayfasi extends StatefulWidget {
  final int kullaniciId; // Kullanıcı ID'sini burada alıyoruz
  final Function(String) cihazEkleCallback; // Callback fonksiyonu

  CihazEkleSayfasi({
    required this.kullaniciId, // Kullanıcı ID'si gerekli
    required this.cihazEkleCallback, // Callback fonksiyonu gerekli
  });

  @override
  _CihazEkleSayfasiState createState() => _CihazEkleSayfasiState();
}

class _CihazEkleSayfasiState extends State<CihazEkleSayfasi> {
  final TextEditingController _cihazIdController = TextEditingController();
  final TextEditingController _cihazAdiController = TextEditingController();

  // Cihaz ekle fonksiyonu
  Future<void> cihazEkle() async {
    final cihazAdi = _cihazAdiController.text.trim();
    final cihazId = int.tryParse(_cihazIdController.text.trim());

    if (cihazAdi.isNotEmpty && cihazId != null) {
      try {
        // Cihazı API'ye ekleyin
        final cihazResponse = await http.post(
          Uri.parse('http://API ADRESİ YER ALMALI/api/Cihaz'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'cihazId': cihazId, // Bu alan sunucu tarafından doldurulabilir.
            'sıcaklık': '24', // Varsayılan sıcaklık değeri
            'ağırlık': '0', // Varsayılan ağırlık değeri
            'zaman': DateTime.now().toIso8601String(),
          }),
        );

        final response = await http.post(
          Uri.parse('http://API ADRESİ YER ALMALI/api/CihazGet'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'cihazId': cihazId,
            'durum': 0,
            'setSicaklik': '24',
            'role1': 0,
            'role2': 0,
            'role3': 0,
            'role4': 0,
            'zaman': DateTime.now().toIso8601String(),
          }),
        );

        print('Cihaz Ekleme Yanıtı: ${response.body}');
        if (response.statusCode == 201) {
          // Cihaz Kullanıcı ekleme API'si
          final cihazKullaniciResponse = await http.post(
            Uri.parse('http://API ADRESİ YER ALMALI/api/CihazKullanici'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'cihazId': cihazId,
              'kullaniciId': widget.kullaniciId,
              'cihazKayitTarihi': DateTime.now().toIso8601String(),
            }),
          );

          print('Cihaz Kullanıcı Yanıtı: ${cihazKullaniciResponse.body}');

          // Cihaz Set API'si

          final cihazSetResponse = await http.post(
            Uri.parse('http://API ADRESİ YER ALMALI/api/CihazSet'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'cihazId': cihazId,
              'sıcaklık': '24',
              'ağırlık': '0',
              'zaman': DateTime.now().toIso8601String(),
            }),
          );

          print('Cihaz Set Yanıtı: ${cihazSetResponse.body}');
          // Hata durumunda sunucudan gelen mesajı konsolda göster
          if (cihazSetResponse.statusCode != 201) {
            print('Cihaz Set Yanıtı: ${cihazSetResponse.body}');
          }

          // Cihaz Role API'si
          final cihazRoleResponse = await http.post(
            Uri.parse('http://API ADRESİ YER ALMALI/api/CihazRole'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'cihazId': cihazId,
              'role1': 0,
              'role2': 0,
              'role3': 0,
              'role4': 0,
              'zaman': DateTime.now().toIso8601String(),
            }),
          );

          print('Cihaz Role Yanıtı: ${cihazRoleResponse.body}');

          // Eğer tüm işlemler başarılı olursa cihaz adını geri döndür
          widget.cihazEkleCallback(cihazAdi);
          Navigator.pop(context, cihazAdi); // Sayfayı kapat
        } else {
          // Eğer API çağrısı başarısız olursa hata göster
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Cihaz ekleme başarısız oldu. Lütfen tekrar deneyin.'),
          ));
        }
      } catch (e) {
        print('Exception caught: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Bir hata oluştu: ${e.toString()}'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Lütfen geçerli bir cihaz ID ve adı girin.'),
      ));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cihaz Ekle'),
        backgroundColor: Colors.teal.shade700,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _cihazIdController,
              decoration: InputDecoration(
                labelText: 'Cihaz ID',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _cihazAdiController,
              decoration: InputDecoration(
                labelText: 'Cihaz Adı',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: cihazEkle,
              child: Text('Cihazı Ekle'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                backgroundColor: Colors.teal.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
