import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// 1. DatabaseHelper sınıfı aç.

class DatabaseHelper {
  static const String _veritabaniDosyaAdi = "notlar_sabit.db";
  static Database? _veritabani;

  // 2. Boş bir yapıcı fonksiyon yap.

  DatabaseHelper._yapicifonksiyon();
  static final DatabaseHelper numune = DatabaseHelper._yapicifonksiyon();

  // 3. Veritabanı önceden var mı kontrol et.

  Future<Database> get veritabaniKontrol async {
    if (_veritabani != null) {
      return _veritabani!;
    } else {
      _veritabani = await veritabaniYukle();
      return _veritabani!;
    }
  }
  // 4. Veritabanı yükle.

  Future<Database> veritabaniYukle() async {
    // 5. Cihazdaki veritabanı klasörünü bul.

    var veritabaniKlasoruBul = await getDatabasesPath();

    // 6. Dosya adı dahil veritabanı adresi

    var veritabaniYolu = join(veritabaniKlasoruBul, _veritabaniDosyaAdi);
    debugPrint("Hedef Yol: $veritabaniYolu");

    // 7. Cihazda veritabanı fiziksel olarak var mı kontrol et.

    var kontrol = await databaseExists(veritabaniYolu);
    debugPrint("Kontrol sonucu: ${kontrol.toString()}");

    //8. Şayet yoksa veritabanı dosyasını kaynak klasörden cihaza kopyala .

    if (!kontrol) {
      try {
        // 9. Dizin tablosuna veritabanı dosya adını ekle
        await Directory(dirname(veritabaniYolu)).create(recursive: true);

        // 10. Kaynak dosyayı byte lara dönüştür.

        ByteData veri = await rootBundle.load("assets/notlar.db");
        List<int> bytes = veri.buffer.asUint8List(
          veri.offsetInBytes,
          veri.lengthInBytes,
        );

        // 11. byte lara dönüştürülmüş dosyayı cihaza fiziksel olarak yaz.

        await File(veritabaniYolu).writeAsBytes(bytes, flush: true);
      } catch (e) {
        debugPrint("Kopyalama hatası: ${e.toString()}");
      }
    }

    // 12. Veritabanını aç. ON DELETE CASCADE kuralının çalışması için onConfigure tetikle.

    return await openDatabase(
      veritabaniYolu,
      version: 1,
      onConfigure: _onConfigure,
    );
  }

  // 13. Foreign key desteğini aktif eden fonksiyon
  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // 14. Tüm notları kategori başlığı ile birlikte getiren fonksiyon

  Future<List<Map<String, dynamic>>> notlariGetir() async {
    Database db = await numune.veritabaniKontrol;
    var sonuc = await db.rawQuery(
      // 15. notTablo daki tüm kayıtları getir. kategori deki kategoriBaslik bilgisini de getir.
      'SELECT notTablo.*, kategori.kategoriBaslik FROM notTablo '
      'INNER JOIN kategori ON kategori.kategoriId = notTablo.kategoriId '
      'ORDER BY notId DESC',
    );
    debugPrint("Database önizleme: ${sonuc.toString()}");
    return sonuc;
  }

  // 16. Yeni not ekler
  Future<int> notEkle(Map<String, dynamic> veri) async {
    Database db = await numune.veritabaniKontrol;
    return await db.insert("notTablo", veri);
  }

  // 17. Notu siler
  Future<int> notSil(int id) async {
    Database db = await numune.veritabaniKontrol;
    return await db.delete("notTablo", where: "notId = ?", whereArgs: [id]);
  }

  // 18. Tüm kategorileri getiren fonksiyon
  Future<List<Map<String, dynamic>>> kategorileriGetir() async {
    Database db = await numune.veritabaniKontrol;
    return await db.query("kategori");
  }

  // 19. Veri güncelleme

  Future<int> notGuncelle(Map<String, dynamic> veri) async {
    Database db = await numune.veritabaniKontrol;
    return await db.update(
      "notTablo",
      veri,
      where: "notId = ?",
      whereArgs: [veri["notId"]],
    );
  }

  // Yeni kategori ekler
  Future<int> kategoriEkle(Map<String, dynamic> veri) async {
    Database db = await numune.veritabaniKontrol;
    return await db.insert("kategori", veri);
  }

  // Mevcut kategoriyi günceller
  Future<int> kategoriGuncelle(Map<String, dynamic> veri) async {
    Database db = await numune.veritabaniKontrol;
    return await db.update(
      "kategori",
      veri,
      where: "kategoriId = ?",
      whereArgs: [veri["kategoriId"]],
    );
  }

  // Kategoriyi siler (ON DELETE CASCADE ile bağlı notlar da silinir)
  Future<int> kategoriSil(int id) async {
    Database db = await numune.veritabaniKontrol;
    return await db.delete(
      "kategori",
      where: "kategoriId = ?",
      whereArgs: [id],
    );
  }
}
