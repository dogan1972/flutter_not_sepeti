import 'package:flutter/material.dart';

class FilterRow extends StatelessWidget {
  final String? secilenFiltreTarih;
  final int? secilenFiltreKategoriId;
  final int? secilenFiltreOncelik;
  final List<Map<String, dynamic>> kategoriler;
  final Function(String?) onTarihChanged;
  final Function(int?) onKategoriChanged;
  final Function(int?) onOncelikChanged;

  const FilterRow({
    super.key,
    required this.secilenFiltreTarih,
    required this.secilenFiltreKategoriId,
    required this.secilenFiltreOncelik,
    required this.kategoriler,
    required this.onTarihChanged,
    required this.onKategoriChanged,
    required this.onOncelikChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.grey.shade100,
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [Text("Tarih"), Text("Kategori"), Text("Öncelik")],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              // Tarih Filtresi
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: secilenFiltreTarih,
                  hint: const Text("Tarih", style: TextStyle(fontSize: 12)),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: null,
                      child: Text("Hepsi", style: TextStyle(fontSize: 12)),
                    ),
                    DropdownMenuItem(
                      value: "Bugün",
                      child: Text("Bugün", style: TextStyle(fontSize: 12)),
                    ),
                  ],
                  onChanged: onTarihChanged,
                ),
              ),
              const SizedBox(width: 6),
              // Kategori Filtresi
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue:
                      kategoriler.any(
                        (kat) => kat['kategoriId'] == secilenFiltreKategoriId,
                      )
                      ? secilenFiltreKategoriId
                      : null,
                  hint: const Text("Kategori", style: TextStyle(fontSize: 12)),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text("Hepsi", style: TextStyle(fontSize: 12)),
                    ),
                    ...kategoriler.map((kat) {
                      return DropdownMenuItem<int>(
                        value: kat['kategoriId'] as int,
                        child: Text(
                          kat['kategoriBaslik'].toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    }),
                  ],
                  onChanged: onKategoriChanged,
                ),
              ),
              const SizedBox(width: 6),
              // Öncelik Filtresi
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: secilenFiltreOncelik,
                  hint: const Text("Öncelik", style: TextStyle(fontSize: 12)),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: null,
                      child: Text("Hepsi", style: TextStyle(fontSize: 12)),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text("Düşük", style: TextStyle(fontSize: 12)),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text("Orta", style: TextStyle(fontSize: 12)),
                    ),
                    DropdownMenuItem(
                      value: 3,
                      child: Text("Yüksek", style: TextStyle(fontSize: 12)),
                    ),
                  ],
                  onChanged: onOncelikChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
