import 'package:flutter/material.dart';
import 'package:flutter_not_sepeti/kategori_ekle_page.dart';
import 'package:flutter_not_sepeti/utils/database_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Not Sepeti',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Anasayfa(),
    );
  }
}

class Anasayfa extends StatefulWidget {
  const Anasayfa({super.key});

  @override
  State<Anasayfa> createState() => _AnasayfaState();
}

class _AnasayfaState extends State<Anasayfa> {
  List<Map<String, dynamic>> _tumNotlar = [];
  List<Map<String, dynamic>> _filtrelenmisNotlar = [];
  List<Map<String, dynamic>> _kategoriler = [];
  bool _yukleniyor = true;

  // 2. Kategorileri veritabanından çekip arayüzü güncelleyen fonksiyon
  void _kategorileriYenile() async {
    // Veritabanından güncel listeyi al
    final guncelKategoriler = await DatabaseHelper.numune.kategorileriGetir();

    setState(() {
      _kategoriler = guncelKategoriler;
    });
  }

  void _kategoriEkleEkraniniAc() async {
    final sonuc = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const KategoriEklePage()),
    );

    if (sonuc == true) {
      _kategorileriYenile(); // Geri dönüldüğünde üstteki yenileme fonksiyonunu tetikler
    }
  }

  String? _secilenFiltreTarih;
  int? _secilenFiltreKategoriId;
  int? _secilenFiltreOncelik;

  final TextEditingController _baslikController = TextEditingController();
  final TextEditingController _icerikController = TextEditingController();
  int _secilenOncelik = 1;
  int? _secilenKategoriId;

  @override
  void initState() {
    super.initState();
    _verileriYukle();
    _kategorileriYenile();
  }

  @override
  void dispose() {
    _baslikController.dispose();
    _icerikController.dispose();
    super.dispose();
  }

  Future<void> _verileriYukle() async {
    final notlarVerisi = await DatabaseHelper.numune.notlariGetir();
    final kategorilerVerisi = await DatabaseHelper.numune.kategorileriGetir();
    setState(() {
      _tumNotlar = notlarVerisi;
      _kategoriler = kategorilerVerisi;
      _yukleniyor = false;
      _notlariFiltrele();
    });
  }

  void _notlariFiltrele() {
    setState(() {
      _filtrelenmisNotlar = _tumNotlar.where((not) {
        final kategoriUyusuyor =
            _secilenFiltreKategoriId == null ||
            not['kategoriId'] == _secilenFiltreKategoriId;

        final oncelikUyusuyor =
            _secilenFiltreOncelik == null ||
            not['notOncelik'] == _secilenFiltreOncelik;

        bool tarihUyusuyor = true;
        if (_secilenFiltreTarih != null && not['notTarih'] != null) {
          final String tarihStr = not['notTarih'].toString();
          if (_secilenFiltreTarih == "Bugün") {
            tarihUyusuyor = tarihStr.contains(
              DateTime.now().toString().substring(0, 10),
            );
          }
        }
        return kategoriUyusuyor && oncelikUyusuyor && tarihUyusuyor;
      }).toList();
    });
  }

  Future<void> _notuSil(int id) async {
    await DatabaseHelper.numune.notSil(id);
    _verileriYukle();
  }

  Color _oncelikRenkGetir(int oncelik) {
    switch (oncelik) {
      case 3:
        return Colors.red.shade400;
      case 2:
        return Colors.orange.shade400;
      case 1:
      default:
        return Colors.green.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            tooltip: "Kategori Ekle",
            onPressed: () {
              _kategoriEkleEkraniniAc();
            },
          ),
        ],
        title: const Text("Not Sepeti Uygulaması"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // FİLTRE SATIRI
                Container(
                  height: 100,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  color: Colors.grey.shade100,
                  child: Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text("Tarih"),
                            Text("Kategori"),
                            Text("Öncelik"),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _secilenFiltreTarih,
                                hint: const Text(
                                  "Tarih",
                                  style: TextStyle(fontSize: 12),
                                ),
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text(
                                      "Hepsi",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: "Bugün",
                                    child: Text(
                                      "Bugün",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                                onChanged: (deger) {
                                  _secilenFiltreTarih = deger;
                                  _notlariFiltrele();
                                },
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                // BURAYI GÜNCELLEYİN: Seçilen ID listede gerçekten var mı kontrol et, yoksa null yap (Hepsi seçeneğine döner)
                                initialValue:
                                    _kategoriler.any(
                                      (kat) =>
                                          kat['kategoriId'] ==
                                          _secilenFiltreKategoriId,
                                    )
                                    ? _secilenFiltreKategoriId
                                    : null,
                                hint: const Text(
                                  "Kategori",
                                  style: TextStyle(fontSize: 12),
                                ),
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text(
                                      "Hepsi",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  ..._kategoriler.map((kat) {
                                    return DropdownMenuItem<int>(
                                      value: kat['kategoriId'] as int,
                                      child: Text(
                                        kat['kategoriBaslik'].toString(),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (deger) {
                                  _secilenFiltreKategoriId = deger;
                                  _notlariFiltrele();
                                },
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                initialValue: _secilenFiltreOncelik,
                                hint: const Text(
                                  "Öncelik",
                                  style: TextStyle(fontSize: 12),
                                ),
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text(
                                      "Hepsi",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 1,
                                    child: Text(
                                      "Düşük",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 2,
                                    child: Text(
                                      "Orta",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 3,
                                    child: Text(
                                      "Yüksek",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                                onChanged: (deger) {
                                  _secilenFiltreOncelik = deger;
                                  _notlariFiltrele();
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // LİSTE ALANI
                Expanded(
                  child: _filtrelenmisNotlar.isEmpty
                      ? const Center(
                          child: Text("Filtreye uygun not bulunamadı."),
                        )
                      : ListView.builder(
                          itemCount: _filtrelenmisNotlar.length,
                          itemBuilder: (context, index) {
                            final not = _filtrelenmisNotlar[index];
                            final int oncelik = not["notOncelik"] ?? 1;

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: ListTile(
                                onTap: () => _notGuncelleFormunuAc(not),
                                leading: CircleAvatar(
                                  backgroundColor: _oncelikRenkGetir(oncelik),
                                  child: const Icon(
                                    Icons.note,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  not["notBaslik"]?.toString() ??
                                      "Başlıksız Not",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (not["notIcerik"] != null &&
                                        not["notIcerik"].toString().isNotEmpty)
                                      Text(not["notIcerik"].toString()),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            not["kategoriBaslik"]?.toString() ??
                                                "Genel",
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.blue.shade800,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Tarih: ${not["notTarih"]?.toString() ?? "Bilinmiyor"}",
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _notuSil(not["notId"]),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _notEkleFormunuAc,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _notEkleFormunuAc() async {
    _baslikController.clear();
    _icerikController.clear();
    _secilenOncelik = 1;

    List<Map<String, dynamic>> kategoriler = await DatabaseHelper.numune
        .kategorileriGetir();

    if (kategoriler.isNotEmpty) {
      _secilenKategoriId = kategoriler.first['kategoriId'];
    } else {
      _secilenKategoriId = 1;
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Yeni Not Ekle",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<int>(
                    initialValue: _secilenKategoriId,
                    decoration: const InputDecoration(
                      labelText: "Kategori Seçin",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.folder),
                    ),
                    items: kategoriler.map((kategori) {
                      return DropdownMenuItem<int>(
                        value: kategori['kategoriId'] as int,
                        child: Text(kategori['kategoriBaslik'].toString()),
                      );
                    }).toList(),
                    onChanged: (deger) =>
                        setModalState(() => _secilenKategoriId = deger),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _baslikController,
                    decoration: const InputDecoration(
                      labelText: "Not Başlığı",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _icerikController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Not İçeriği",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: _secilenOncelik,
                    decoration: const InputDecoration(
                      labelText: "Öncelik Derecesi",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.priority_high),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text("Düşük")),
                      DropdownMenuItem(value: 2, child: Text("Orta")),
                      DropdownMenuItem(value: 3, child: Text("Yüksek")),
                    ],
                    onChanged: (deger) =>
                        setModalState(() => _secilenOncelik = deger!),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      if (_baslikController.text.isNotEmpty) {
                        Map<String, dynamic> yeniNot = {
                          "kategoriId": _secilenKategoriId,
                          "notBaslik": _baslikController.text,
                          "notIcerik": _icerikController.text,
                          "notOncelik": _secilenOncelik,
                        };
                        await DatabaseHelper.numune.notEkle(yeniNot);
                        if (context.mounted) Navigator.pop(context);
                        _verileriYukle();
                      }
                    },
                    child: const Text("Kaydet"),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _notGuncelleFormunuAc(Map<String, dynamic> mevcutNot) async {
    _baslikController.text = mevcutNot["notBaslik"] ?? "";
    _icerikController.text = mevcutNot["notIcerik"] ?? "";
    int guncellenecekOncelik = mevcutNot["notOncelik"] ?? 1;
    int guncellenecekKategoriId = mevcutNot["kategoriId"] ?? 1;

    List<Map<String, dynamic>> kategoriler = await DatabaseHelper.numune
        .kategorileriGetir();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Notu Düzenle",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<int>(
                    initialValue: guncellenecekKategoriId,
                    decoration: const InputDecoration(
                      labelText: "Kategori",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.folder),
                    ),
                    items: kategoriler.map((kategori) {
                      return DropdownMenuItem<int>(
                        value: kategori['kategoriId'] as int,
                        child: Text(kategori['kategoriBaslik'].toString()),
                      );
                    }).toList(),
                    onChanged: (deger) =>
                        setModalState(() => guncellenecekKategoriId = deger!),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _baslikController,
                    decoration: const InputDecoration(
                      labelText: "Not Başlığı",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _icerikController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Not İçeriği",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: guncellenecekOncelik,
                    decoration: const InputDecoration(
                      labelText: "Öncelik Derecesi",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.priority_high),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text("Düşük")),
                      DropdownMenuItem(value: 2, child: Text("Orta")),
                      DropdownMenuItem(value: 3, child: Text("Yüksek")),
                    ],
                    onChanged: (deger) =>
                        setModalState(() => guncellenecekOncelik = deger!),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      if (_baslikController.text.isNotEmpty) {
                        Map<String, dynamic> guncelVeri = {
                          "notId": mevcutNot["notId"],
                          "kategoriId": guncellenecekKategoriId,
                          "notBaslik": _baslikController.text,
                          "notIcerik": _icerikController.text,
                          "notOncelik": guncellenecekOncelik,
                        };
                        await DatabaseHelper.numune.notGuncelle(guncelVeri);
                        if (context.mounted) Navigator.pop(context);
                        _verileriYukle();
                      }
                    },
                    child: const Text("Değişiklikleri Kaydet"),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
} // Sınıfın ve dosyanın asıl kapanış parantezi
