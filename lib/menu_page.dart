

import 'package:flutter/material.dart';
import 'package:login_tasarim/CihazDetay.dart';
import 'package:login_tasarim/CihazEkle_page.dart'; // Cihaz Ekle Sayfası
import 'package:login_tasarim/login_screen.dart';
import 'package:login_tasarim/register_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MenuPage extends StatefulWidget {
  final int kullaniciId; // Kullanıcı ID'sini buraya al

  MenuPage({required this.kullaniciId});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<Map<String, dynamic>> cihazListesi = []; // Cihaz bilgilerini tutacak liste

  @override
  void initState() {
    super.initState();
    cihazlariGetir();  // Uygulama açıldığında cihazları getir
  }

  // Cihaz ID'sine göre isim oluşturan fonksiyon
  String cihazAdiOlustur(int cihazId) {
    return 'Cihaz $cihazId'; // Örneğin, 'Cihaz 1', 'Cihaz 2' vb.
  }

  Future<void> cihazlariGetir() async {
    try {
      final response = await http.get(
        Uri.parse('http://API ADRESİ YER ALMALI/api/CihazKullanici/${widget.kullaniciId}'),
      );

      if (response.statusCode == 200) {
        List<dynamic> cihazlar = jsonDecode(response.body);
        print('Cihazlar: $cihazlar');

        final durumResponse = await http.get(
          Uri.parse('http://API ADRESİ YER ALMALI/api/CihazGet'),
        );

        if (durumResponse.statusCode == 200) {
          List<dynamic> cihazDurumlari = jsonDecode(durumResponse.body);
          print('CihazDurumlari: $cihazDurumlari');

          Map<int, dynamic> cihazDurumMap = {};
          for (var cihazDurumu in cihazDurumlari) {
            cihazDurumMap[cihazDurumu['cihazId']] = {
              'durum': (cihazDurumu['durum'] == 1),
              'setSicaklik': cihazDurumu['setSicaklik']?.toString() ?? 'null', // SetSicaklik string olarak alınıyor
            };
          }

          setState(() {
            cihazListesi = cihazlar.map((cihaz) {
              int cihazId = cihaz['cihazId'];
              var cihazDurum = cihazDurumMap[cihazId];

              // setSicaklik değerini alıp kontrol ediyoruz
              String? setSicaklik = cihazDurum?['setSicaklik'];

              if (setSicaklik == 'null' || setSicaklik == null) {
                print('SetSicaklik değeri null, cihaz ID: $cihazId. Güncelleme yapılamayacak.');
              } else {
                print('Cihaz ID: $cihazId, SetSicaklik: $setSicaklik');
              }

              return {
                'cihazId': cihazId,
                'cihazAdi': cihazAdiOlustur(cihazId),
                'aktifMi': cihazDurum?['durum'] ?? false,
                'setSicaklik': setSicaklik ?? 'Veri bulunamadı',
              };
            }).toList();
          });
        } else {
          print('Cihaz durumları getirilemedi: ${durumResponse.statusCode}');
        }
      } else {
        print('Cihazlar getirilemedi: ${response.statusCode}');
      }
    } catch (e) {
      print('Hata oluştu: $e');
    }
  }





// Cihaz durumunu güncelleyen fonksiyon
  Future<void> cihazDurumunuGuncelle(int cihazId, bool yeniDurum) async {
    try {
      print('Güncellenmeye çalışılan cihaz ID: $cihazId');

      final cihaz = cihazListesi.firstWhere(
            (c) => c['cihazId'] == cihazId,
        orElse: () => {'cihazId': -1, 'setSicaklik': null}, // Boş bir cihaz nesnesi döndür
      );

      if (cihaz == null || cihaz['cihazId'] == -1) {
        print('Cihaz bulunamadı!');
        return;
      }

      String? setSicaklik = cihaz['setSicaklik'];

      if (setSicaklik == null) {
        print('SetSicaklik değeri null, güncelleme yapılamayacak!');
        return;
      }
      // Gönderilen veriyi kontrol etmek için bu satırı ekleyin
      print('Gönderilen veri: ${jsonEncode({
        'durum': yeniDurum ? 1 : 0,
        'SetSicaklik': setSicaklik.replaceAll(',', '.'),
      })}');

      // HTTP isteği gönder
      final response = await http.put(
        Uri.parse('http://API ADRESİ YER ALMALI/api/CihazGet/$cihazId'), // Gerekirse endpointi değiştirin
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'durum': yeniDurum ? 1 : 0,
          'SetSicaklik': setSicaklik.replaceAll(',', '.'),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Cihaz durumu başarıyla güncellendi.');
      } else {
        print('Cihaz durumu güncellenemedi: ${response.statusCode}');
        print('Hata Detayı: ${response.body}');
      }

    } catch (e) {
      print('Hata oluştu: $e');
    }
  }




  // Cihaz ekle fonksiyonu
  void cihazEkle(String cihazAdi) {
    setState(() {
      if (cihazAdi.isNotEmpty && !cihazListesi.any((cihaz) => cihaz['cihazAdi'] == cihazAdi)) {
        cihazListesi.add({'cihazAdi': cihazAdi, 'aktifMi': false}); // Cihaz adını ve aktiflik durumunu listeye ekle
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Giriş',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal.shade700,
        actions: [
          IconButton(
            icon: Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
          SizedBox(width: 10),
          IconButton(
            icon: Icon(Icons.person_add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterScreen()),
              );
            },
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,  // Cihazları sola hizala
                children: [
                  // Cihaz butonlarını listele
                  for (var cihaz in cihazListesi)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: cihaz['aktifMi'] // Eğer cihaz aktifse
                            ? () {
                          // Cihaz Detay sayfasına yönlendir
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CihazDetaySayfasi(
                                  cihazId: cihaz['cihazId'].toString()), // Cihaz ID'yi gönder
                            ),
                          );
                        }
                            : null, // Eğer cihaz aktif değilse butona basılmasın
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          backgroundColor: cihaz['aktifMi']
                              ? Colors.teal.shade700 // Aktifse yeşil
                              : Colors.grey, // Pasifse gri
                          minimumSize: Size(MediaQuery.of(context).size.width * 0.9, 60),
                          maximumSize: Size(MediaQuery.of(context).size.width * 0.9, 60),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              cihaz['cihazAdi'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // Yazıyı beyaz yap
                              ),
                            ),
                            Switch(
                              value: cihaz['aktifMi'],
                              onChanged: (value) {
                                // Durumu güncelle
                                cihazDurumunuGuncelle(cihaz['cihazId'], value);

                                setState(() {
                                  cihaz['aktifMi'] = value; // Switch durumu değiştir
                                });
                              },
                            ),

                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Cihaz Ekle butonu
          ElevatedButton(
            onPressed: () async {
              // Cihaz ekleme sayfasına kullanıcı ID'sini ve callback fonksiyonunu gönderiyoruz
              final cihazAdi = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CihazEkleSayfasi(
                    kullaniciId: widget.kullaniciId, // Kullanıcı ID'sini gönder
                    cihazEkleCallback: cihazEkle, // cihazEkle fonksiyonunu callback olarak gönderiyoruz
                  ),
                ),
              );

              if (cihazAdi != null) {
                cihazlariGetir(); // Yeni cihaz eklendikten sonra cihazları tekrar getir
              }
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              backgroundColor: Colors.teal.shade700,
              minimumSize: Size(MediaQuery.of(context).size.width * 0.95, 80),
              maximumSize: Size(MediaQuery.of(context).size.width * 0.95, 80),
            ),
            child: Text(
              'Cihaz ekle +',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Yazıyı beyaz yap
              ),
            ),
          ),
        ],
      ),
    );
  }
}