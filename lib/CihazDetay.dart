

import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CihazDetaySayfasi extends StatefulWidget {
  final String cihazId;

  CihazDetaySayfasi({required this.cihazId});

  @override
  _CihazDetaySayfasiState createState() => _CihazDetaySayfasiState();
}

class _CihazDetaySayfasiState extends State<CihazDetaySayfasi> {
  Map<String, dynamic>? _cihazData;
  Map<String, dynamic>? _cihazRoleData;
  Map<String, dynamic>? _cihazGetData;


  // Toplam zaman aralığını hesaplayın


  List<FlSpot> _temperatureSpots = []; // Sıcaklık verilerini barındıran liste
  List<FlSpot> _weightSpots = [];// ağırlık verileri barındıran liste
  List<FlSpot> _generateSpots(List<FlSpot> originalSpots, double pixelInterval) {
    List<FlSpot> adjustedSpots = [];
    for (int i = 0; i < originalSpots.length; i++) {
      adjustedSpots.add(FlSpot(i * pixelInterval, originalSpots[i].y));
    }
    return adjustedSpots;
  }


  @override
  void initState() {
    super.initState();
    _fetchData();
  }
  Future<void> _fetchData() async {
    try {
      print('API\'den veri çekiliyor...');

      // Cihaz verileri API çağrısı
      final cihazResponse = await http.get(Uri.parse('http://API ADRESİ YER ALMALI/api/Cihaz/${widget.cihazId}'));

      if (cihazResponse.statusCode == 200) {
        // JSON response'ı çözümle ve Map'e çevir
        Map<String, dynamic> cihazData = jsonDecode(cihazResponse.body);

        // Eğer cihaz verisi boş değilse işle
        if (cihazData.isNotEmpty) {
          setState(() {
            _cihazData = _mapDynamicToStringDynamic(cihazData);
            print('Cihaz verileri alındı: $_cihazData');
          });
        } else {
          print('Cihaz verisi bulunamadı.');
        }
      } else {
        print('Cihaz verisi yüklenemedi: ${cihazResponse.statusCode} ${cihazResponse.reasonPhrase}');
      }

      // CihazRole verileri API çağrısı
      final cihazRoleResponse = await http.get(Uri.parse('http://API ADRESİ YER ALMALI/api/CihazRole/${widget.cihazId}'));

      if (cihazRoleResponse.statusCode == 200) {
        // JSON response'ı çözümle
        var responseBody = jsonDecode(cihazRoleResponse.body);

        // Gelen veri bir listeyse ve boş değilse işle
        if (responseBody is List && responseBody.isNotEmpty) {
          setState(() {
            // İlk CihazRole verisini al
            _cihazRoleData = _mapDynamicToStringDynamic(responseBody[0]);
            print('CihazRole verileri alındı: $_cihazRoleData');
          });
        }
        // Gelen veri tek bir Map ise
        else if (responseBody is Map) {
          setState(() {
            _cihazRoleData = _mapDynamicToStringDynamic(responseBody);
            print('CihazRole verileri alındı: $_cihazRoleData');
          });
        } else {
          print('CihazRole için beklenmedik yanıt formatı.');
        }
      } else {
        print('CihazRole verisi yüklenemedi: ${cihazRoleResponse.statusCode} ${cihazRoleResponse.reasonPhrase}');
      }

      // CihazGet verileri API çağrısı
      final cihazGetResponse = await http.get(Uri.parse('http://API ADRESİ YER ALMALI/api/CihazGet/${widget.cihazId}'));

      if (cihazGetResponse.statusCode == 200) {
        Map<String, dynamic> cihazGetData = jsonDecode(cihazGetResponse.body);

        if (cihazGetData.isNotEmpty) {
          setState(() {
            _cihazGetData = _mapDynamicToStringDynamic(cihazGetData);
            print('CihazGet verileri alındı: $_cihazGetData');
          });
        } else {
          print('CihazGet verisi bulunamadı.');
        }
      } else {
        print('CihazGet verisi yüklenemedi: ${cihazGetResponse.statusCode} ${cihazGetResponse.reasonPhrase}');
      }



    } catch (error) {
      print('Hata: $error');
    }
  }



  Future<void> _updateSicaklik(double newSicaklik) async {
    try {
      final response = await http.put(
        Uri.parse('http://API ADRESİ YER ALMALI/api/Cihaz/${widget.cihazId}'), // widget.cihazId kullanılıyor
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'cihazId': int.parse(widget.cihazId), // Eğer API int bekliyorsa
          'sıcaklık': newSicaklik.toString() + '°C',
          'ağırlık': _cihazData!['ağırlık'],
          'zaman': _cihazData!['zaman'] ?? '',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          _cihazData!['sıcaklık'] = newSicaklik.toString() + '°C';
        });
        print('Sıcaklık başarıyla güncellendi: $newSicaklik');
      } else {
        print('Sıcaklık güncellenemedi: ${response.statusCode} ${response.reasonPhrase}');
        print('Hata Detayı: ${response.body}'); // Hata detayını yazdır

      }

      // CihazGet güncelleme isteği
      final cihazGetResponse = await http.put(
        Uri.parse('http://API ADRESİ YER ALMALI/api/CihazGet/${widget.cihazId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'cihazGetId': _cihazGetData!['cihazGetId'],
          'cihazId': int.parse(widget.cihazId),
          'durum': _cihazGetData!['durum'],
          'setSicaklik': newSicaklik.toString(),
          'role1': _cihazGetData!['role1'],
          'role2': _cihazGetData!['role2'],
          'role3': _cihazGetData!['role3'],
          'role4': _cihazGetData!['role4'],
          'zaman': _cihazGetData!['zaman'] ?? DateTime.now().toIso8601String(),
        }),
      );

      if (cihazGetResponse.statusCode == 200 || cihazGetResponse.statusCode == 204) {
        print('CihazGet sıcaklık başarıyla güncellendi.');
      } else {
        print('CihazGet sıcaklık güncellenemedi: ${cihazGetResponse.statusCode} ${cihazGetResponse.reasonPhrase}');
        print('Hata Detayı: ${cihazGetResponse.body}');
      }



    } catch (error) {
      print('Hata: $error');
    }
  }



  Future<void> _updateRole(String roleKey, bool newValue) async {
    try {
      print('Gönderilen Cihaz ID: ${widget.cihazId}');

      // İç içe "cihazRole" olmadan güncellenen JSON verisi
      final updatedData = {
        'cihazId': int.parse(widget.cihazId), // Eğer API int bekliyorsa
        'role1': _cihazRoleData!['role1'] ?? 0,
        'role2': _cihazRoleData!['role2'] ?? 0,
        'role3': _cihazRoleData!['role3'] ?? 0,
        'role4': _cihazRoleData!['role4'] ?? 0,
        roleKey: newValue ? 1 : 0, // Değiştirilen role
        'zaman': _cihazRoleData!['zaman'] ?? DateTime.now().toIso8601String(),
      };

      print('Gönderilen JSON: ${jsonEncode(updatedData)}');
      print('PUT URL: http://API ADRESİ YER ALMALI/api/CihazRole/${widget.cihazId}');

      final response = await http.put(
        Uri.parse('http://API ADRESİ YER ALMALI/api/CihazRole/${widget.cihazId}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updatedData), // Doğru formatta JSON gönderiliyor
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          _cihazRoleData![roleKey] = newValue ? 1 : 0;
        });
        print('$roleKey başarıyla güncellendi: ${newValue ? 1 : 0}');
      } else {
        print('$roleKey güncellenemedi: ${response.statusCode} ${response.reasonPhrase}');
        print('Hata Detayı: ${response.body}');
      }
      // İkinci API: CihazGet role güncellemesi
      final updatedRoleDataGet = {
       // 'cihazGetId': _cihazGetData!['cihazGetId'],
        'cihazId': int.parse(widget.cihazId),
        'durum': _cihazGetData!['durum'],
        'setSicaklik': _cihazGetData!['setSicaklik'],
        'role1': _cihazGetData!['role1'],
        'role2': _cihazGetData!['role2'],
        'role3': _cihazGetData!['role3'],
        'role4': _cihazGetData!['role4'],
        roleKey: newValue ? 1 : 0, // Güncellenen role verisi
        'zaman': DateTime.now().toIso8601String(),
      };
      print('Güncellenen role verisi: ${jsonEncode(updatedRoleDataGet)}');

      final responseCihazGetRole = await http.put(
        Uri.parse('http://API ADRESİ YER ALMALI/api/CihazGet/${widget.cihazId}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updatedRoleDataGet),
      );
      print('Sunucudan gelen yanıt: ${responseCihazGetRole.body}');

      if (responseCihazGetRole.statusCode == 200 || responseCihazGetRole.statusCode == 204) {
        print('$roleKey CihazGet API\'sinde başarıyla güncellendi.');
      } else {
        print('$roleKey CihazGet API\'sinde güncellenemedi: ${responseCihazGetRole.statusCode} ${responseCihazGetRole.reasonPhrase}');
        print('Hata Detayı: ${responseCihazGetRole.body}');
      }

      // UI'yi güncelle
      setState(() {
        _cihazRoleData![roleKey] = newValue ? 1 : 0;
        _cihazGetData![roleKey] = newValue ? 1 : 0;
      });


    } catch (error) {
      print('Hata: $error');
    }
  }




  // Veri ekleme fonksiyonu
  void addTemperatureData(double newTemperature, int timestamp) {
    // Yeni veri ekleme
    _temperatureSpots.add(FlSpot(timestamp.toDouble(), newTemperature));

    // Eğer veri sayısı 150'den fazla ise eski verileri sil
    if (_temperatureSpots.length > 150) {
      _temperatureSpots.removeAt(0); // En eski veriyi sil
    }

    // Grafiği yeniden çizmek için setState'i çağırın
    setState(() {});
  }



  Map<String, dynamic> _mapDynamicToStringDynamic(dynamic map) {
    if (map is Map<String, dynamic>) {
      // Eğer zaten Map<String, dynamic> türünde ise direkt döndür
      return map;
    } else if (map is Map) {
      // Eğer Map fakat anahtarlar/dinamik türler karışıksa
      return Map<String, dynamic>.from(map);
    }
    // Eğer map değilse, boş bir Map döndür
    return {};
  }

  double _extractSicaklik(String sicaklikStr) {
    return double.tryParse(sicaklikStr.replaceAll('°C', '')) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cihaz Kontrol Paneli'),
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            height: 57.0, // Yüksekliği belirle

            color: Colors.pink[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SICAKLIK: ${_cihazData?['sıcaklık'] ?? '--'}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'AĞIRLIK: ${_cihazData?['ağırlık'] ?? '--'} ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.all(16.0),
            height: 700.0, // Yüksekliği belirle
            child: _cihazData != null
                ? _buildCihazCharts()
                : Center(child: Text('Cihaz verisi yüklenmedi.')),
            color: Colors.blue[50],
          ),
          Divider(height: 1, color: Colors.black),

          Container(
            padding: EdgeInsets.all(16.0),
            height: 57.0, // Yüksekliği belirle
            color: Colors.green[50],
            child: Center(
              child: _buildTemperatureControls(), // Sıcaklık kontrollerini çağır

            ),
          ),


          Divider(height: 1, color: Colors.black),





          Container(
            padding: EdgeInsets.all(16.0),
            height: 260.0, // Yüksekliği belirle
            child: _cihazRoleData != null
                ? _buildCihazRoleControls()
                : Center(child: Text('Cihaz Role verisi yüklenmedi.')),
            color: Colors.grey[50],
          ),

        ],
      ),
    );
  }

  void addTemperatureSpot(double temperature) {
    final currentTimeMillis = DateTime.now().millisecondsSinceEpoch.toDouble();
    _temperatureSpots.add(FlSpot(currentTimeMillis, temperature));
    setState(() {});
  }




  Widget _buildCihazCharts() {
    return Column(
      children: [
        SizedBox(
          width: 400, // Grafiğin genişliği
          height: 350, // Grafiğin yüksekliği

          child: Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SICAKLIK',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                      child:LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: _generateSpots(_temperatureSpots, 10), // X eksenindeki aralıkları yeniden hesaplıyoruz
                              isCurved: true,
                              curveSmoothness: 0.5,
                              color: Colors.blue,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.blue.withOpacity(0.3),
                              ),
                            ),
                          ],
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: (value, meta) {
                                  if (value % 0.5 == 0) {
                                    return Text(
                                      value.toStringAsFixed(1),
                                      style: TextStyle(color: Colors.black, fontSize: 10),
                                    );
                                  } else {
                                    return Container();
                                  }
                                },
                              ),
                            ),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index >= 0 && index < _temperatureSpots.length) {
                                    final time = DateTime.fromMillisecondsSinceEpoch(
                                        _temperatureSpots[index].x.toInt());
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                        style: TextStyle(color: Colors.black, fontSize: 12),
                                      ),
                                    );
                                  } else {
                                    return Container();
                                  }
                                },
                              ),
                            ),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            getDrawingVerticalLine: (value) {
                              return FlLine(
                                color: Colors.grey.withOpacity(0.2),
                                strokeWidth: 0.5,
                              );
                            },
                            drawHorizontalLine: true,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey.withOpacity(0.2),
                                strokeWidth: 0.5,
                              );
                            },
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: const Color(0xff37434d),
                              width: 1,
                            ),
                          ),
                        ),
                      )



                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AĞIRLIK',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Expanded(child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: _weightSpots, // Ağırlık verilerini gösterir
                          isCurved: true,
                          color: Colors.red, // Ağırlık çizgisi rengi
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                      titlesData:FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1, // Y ekseni etiketlerini 1 birimde bir gösterir.
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toString(),
                                style: TextStyle(
                                  fontSize: 10, // Yazı tipi boyutunu küçük yaparak karışıklığı önle.
                                ),
                              );
                            },
                            reservedSize: 30, // Etiketler için daha fazla boşluk ayır.
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1, // X ekseni etiketlerini 1 birimde bir gösterir.
                            getTitlesWidget: (value, meta) {
                              return Transform.rotate(
                                angle: -45 * 3.1415927 / 180, // Etiketi 45 derece döndür.
                                child: Text(
                                  value.toString(),
                                  style: TextStyle(
                                    fontSize: 10, // Yazı tipi boyutunu küçük yaparak karışıklığı önle.
                                  ),
                                ),
                              );
                            },
                            reservedSize: 30, // Etiketler için daha fazla boşluk ayır.
                          ),
                        ),
                      ),

                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                          color: const Color(0xff37434d),
                          width: 1,
                        ),
                      ),
                    ),
                  ),

                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
// Sıcaklık kontrolü fonksiyonu
  Widget _buildTemperatureControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(Icons.remove),
          iconSize: 30.0, // İkonun boyutu
          onPressed: () {
            double currentSicaklik = _extractSicaklik(_cihazData?['sıcaklık'] ?? '0.0°C');
            double newSicaklik = currentSicaklik - 0.5; // Azaltma miktarını ayarlayın
            _updateSicaklik(newSicaklik);
          },
        ),
        Text(
          '${_cihazData?['sıcaklık'] ?? '0.0°C'}',
          style: TextStyle(fontSize: 24),
        ),
        IconButton(
          icon: Icon(Icons.add),
          iconSize: 40.0, // İkonun boyutu
          onPressed: () {
            double currentSicaklik = _extractSicaklik(_cihazData?['sıcaklık'] ?? '0.0°C');
            double newSicaklik = currentSicaklik + 0.5; // Artırma miktarını ayarlayın
            _updateSicaklik(newSicaklik);
          },
        ),
      ],
    );
  }

  Widget _buildCihazRoleControls() {
    return Column(
      children: [
        SwitchListTile(
          title: Text('Role 1'),
          value: (_cihazRoleData?['role1'] ?? 0) == 1,
          onChanged: (bool value) => _updateRole('role1', value),
        ),
        SwitchListTile(
          title: Text('Role 2'),
          value: (_cihazRoleData?['role2'] ?? 0) == 1,
          onChanged: (bool value) => _updateRole('role2', value),
        ),
        SwitchListTile(
          title: Text('Role 3'),
          value: (_cihazRoleData?['role3'] ?? 0) == 1,
          onChanged: (bool value) => _updateRole('role3', value),
        ),
        SwitchListTile(
          title: Text('Role 4'),
          value: (_cihazRoleData?['role4'] ?? 0) == 1,
          onChanged: (bool value) => _updateRole('role4', value),
        ),
      ],
    );
  }
}
