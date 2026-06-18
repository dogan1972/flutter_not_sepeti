import 'package:flutter/material.dart';
import 'package:flutter_not_sepeti/pages/kategori_ekle_page.dart';
import 'package:flutter_not_sepeti/utils/database_helper.dart';
import 'package:flutter_not_sepeti/widgets/add_note_fab.dart';
import 'package:flutter_not_sepeti/widgets/custom_app_bar.dart';
import 'package:flutter_not_sepeti/widgets/filter_row.dart';
import 'package:flutter_not_sepeti/widgets/note_list_view.dart';

// Oluşturduğunuz 4 yeni dosyayı projenizdeki klasör yoluna göre import edin:

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

  void _kategorileriYenile() async {
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
      _kategorileriYenile();
    }
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
                  DropdownButtonFormField(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(onMenuPressed: _kategoriEkleEkraniniAc),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                FilterRow(
                  secilenFiltreTarih: _secilenFiltreTarih,
                  secilenFiltreKategoriId: _secilenFiltreKategoriId,
                  secilenFiltreOncelik: _secilenFiltreOncelik,
                  kategoriler: _kategoriler,
                  onTarihChanged: (deger) {
                    _secilenFiltreTarih = deger;
                    _notlariFiltrele();
                  },
                  onKategoriChanged: (deger) {
                    _secilenFiltreKategoriId = deger;
                    _notlariFiltrele();
                  },
                  onOncelikChanged: (deger) {
                    _secilenFiltreOncelik = deger;
                    _notlariFiltrele();
                  },
                ),
                Expanded(
                  child: NoteListView(
                    filtrelenmisNotlar: _filtrelenmisNotlar,
                    onNotTap: _notGuncelleFormunuAc,
                    onNotSil: _notuSil,
                  ),
                ),
              ],
            ),
      floatingActionButton: AddNoteFab(onPressed: _notEkleFormunuAc),
    );
  }
}
