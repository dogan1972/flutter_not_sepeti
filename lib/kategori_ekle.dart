import 'package:flutter/material.dart';
import 'package:flutter_not_sepeti/utils/database_helper.dart';

class KategoriEklePage extends StatefulWidget {
  const KategoriEklePage({super.key});

  @override
  State<KategoriEklePage> createState() => _KategoriEklePageState();
}

class _KategoriEklePageState extends State<KategoriEklePage> {
  final _formKey = GlobalKey<FormState>();
  final _kategoriController = TextEditingController();

  List<Map<String, dynamic>> _kategorilerListesi = [];

  // Güncelleme modunu kontrol etmek için değişkenler
  bool _guncellemeModu = false;
  int? _guncellenecekKategoriId;

  @override
  void initState() {
    super.initState();
    _kategorileriGetir(); // Sayfa açılınca kategorileri yükle
  }

  @override
  void dispose() {
    _kategoriController.dispose();
    super.dispose();
  }

  // Veritabanından kategorileri çeken fonksiyon
  void _kategorileriGetir() async {
    final veriler = await DatabaseHelper.numune.kategorileriGetir();
    setState(() {
      _kategorilerListesi = veriler;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategorileri Yönet'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Sayfadan çıkarken ana sayfaya 'true' gönderiyoruz ki oradaki dropdown da güncellensin
            Navigator.pop(context, true);
          },
        ),
      ),
      body: Column(
        children: [
          // 1. GİRİŞ VE FORM ALANI (ÜST KISIM)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _kategoriController,
                    decoration: InputDecoration(
                      labelText: _guncellemeModu
                          ? 'Kategori Adını Düzenle'
                          : 'Yeni Kategori Başlığı',
                      border: const OutlineInputBorder(),
                      hintText: 'Örn: Alışveriş, İş, Kişisel',
                      suffixIcon: _guncellemeModu
                          ? IconButton(
                              icon: const Icon(Icons.cancel),
                              onPressed:
                                  _moduTemizle, // Güncellemeden vazgeçme butonu
                            )
                          : null,
                    ),
                    validator: (deger) {
                      if (deger == null || deger.trim().isEmpty) {
                        return 'Lütfen bir kategori adı giriniz';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _kategoriKaydetVeyaGuncelle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _guncellemeModu ? Colors.orange : null,
                    ),
                    child: Text(
                      _guncellemeModu
                          ? 'Kategoriyi Güncelle'
                          : 'Kategoriyi Kaydet',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(thickness: 2),

          // 2. MEVCUT KATEGORİLERİN LİSTELENDİĞİ ALAN (ALT KISIM)
          // ... Sayfanın üst kısımları, Form ve build metodunun başlangıcı aynı kalıyor ...

          // 2. MEVCUT KATEGORİLERİN LİSTELENDİĞİ ALAN (Silme Özellikli)
          Expanded(
            child: _kategorilerListesi.isEmpty
                ? const Center(child: Text('Henüz bir kategori eklenmemiş.'))
                : ListView.builder(
                    itemCount: _kategorilerListesi.length,
                    itemBuilder: (context, index) {
                      final kat = _kategorilerListesi[index];
                      final int katId = kat['kategoriId'] as int;
                      final String katBaslik = kat['kategoriBaslik'].toString();

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.folder,
                            color: Colors.amber,
                          ),
                          title: Text(katBaslik),
                          // Sağ tarafa Düzenle ve Sil butonlarını yan yana koyuyoruz
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Düzenleme Butonu
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _guncellemeModu = true;
                                    _guncellenecekKategoriId = katId;
                                    _kategoriController.text = katBaslik;
                                  });
                                },
                              ),
                              // Silme Butonu
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  // Doğrudan silmek yerine onay kutusu açıyoruz
                                  _kategoriSilOnayDiyalogu(katId, katBaslik);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Kullanıcıya "Emin misiniz?" sorusu soran onay penceresi
  void _kategoriSilOnayDiyalogu(int id, String baslik) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Kategoriyi Sil?"),
          content: Text(
            "'$baslik' kategorisini silmek istediğinize emin misiniz?\n\n"
            "⚠️ DİKKAT: Bu kategoriye ait TÜM NOTLAR da kalıcı olarak silinecektir!",
          ),
          actions: [
            TextButton(
              child: const Text("İptal"),
              onPressed: () => Navigator.pop(context), // Diyaloğu kapat
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Sil"),
              onPressed: () async {
                Navigator.pop(context); // Önce diyaloğu kapat
                _kategoriSilmeyiBaslat(id); // Silme işlemini tetikle
              },
            ),
          ],
        );
      },
    );
  }

  // Veritabanından silme işlemini yapan fonksiyon
  void _kategoriSilmeyiBaslat(int id) async {
    int sonuc = await DatabaseHelper.numune.kategoriSil(id);

    if (sonuc > 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kategori ve bağlı notlar silindi.')),
        );
      }

      // Eğer silinen kategori o sırada düzenleniyorsa formu temizle
      if (_guncellenecekKategoriId == id) {
        _moduTemizle();
      }

      _kategorileriGetir(); // Listeyi güncelle
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hata: Kategori silinemedi.')),
        );
      }
    }
  }

  // ... _moduTemizle ve _kategoriKaydetVeyaGuncelle fonksiyonları aynen kalıyor ...

  // Kaydetme ve Güncelleme mantığını yöneten fonksiyon
  void _kategoriKaydetVeyaGuncelle() async {
    if (_formKey.currentState!.validate()) {
      String girilenBaslik = _kategoriController.text.trim();
      int sonuc;

      if (_guncellemeModu) {
        // GÜNCELLEME İŞLEMİ
        Map<String, dynamic> guncelVeri = {
          'kategoriId': _guncellenecekKategoriId,
          'kategoriBaslik': girilenBaslik,
        };
        sonuc = await DatabaseHelper.numune.kategoriGuncelle(guncelVeri);
      } else {
        // YENİ EKLEME İŞLEMİ
        Map<String, dynamic> yeniVeri = {'kategoriBaslik': girilenBaslik};
        sonuc = await DatabaseHelper.numune.kategoriEkle(yeniVeri);
      }

      if (sonuc > 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _guncellemeModu
                    ? 'Kategori başarıyla güncellendi!'
                    : 'Kategori başarıyla eklendi!',
              ),
            ),
          );
        }
        _moduTemizle(); // Formu ve modu sıfırla
        _kategorileriGetir(); // Listeyi veritabanından yeniden çek
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('İşlem sırasında bir hata oluştu.')),
          );
        }
      }
    }
  }

  // Formu eski temiz haline getiren yardımcı fonksiyon
  void _moduTemizle() {
    setState(() {
      _guncellemeModu = false;
      _guncellenecekKategoriId = null;
      _kategoriController.clear();
    });
  }
}
