import 'package:flutter/material.dart';

class NoteListView extends StatelessWidget {
  final List<Map<String, dynamic>> filtrelenmisNotlar;
  final Function(Map<String, dynamic>) onNotTap;
  final Function(int) onNotSil;

  const NoteListView({
    super.key,
    required this.filtrelenmisNotlar,
    required this.onNotTap,
    required this.onNotSil,
  });

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
    if (filtrelenmisNotlar.isEmpty) {
      return const Center(
        child: Text("Filtreye uygun not bulunamadı."),
      );
    }

    return ListView.builder(
      itemCount: filtrelenmisNotlar.length,
      itemBuilder: (context, index) {
        final not = filtrelenmisNotlar[index];
        final int oncelik = not["notOncelik"] ?? 1;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            onTap: () => onNotTap(not),
            leading: CircleAvatar(
              backgroundColor: _oncelikRenkGetir(oncelik),
              child: const Icon(Icons.note, color: Colors.white),
            ),
            title: Text(
              not["notBaslik"]?.toString() ?? "Başlıksız Not",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (not["notIcerik"] != null && not["notIcerik"].toString().isNotEmpty)
                  Text(not["notIcerik"].toString()),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        not["kategoriBaslik"]?.toString() ?? "Genel",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Tarih: ${not["notTarih"]?.toString() ?? "Bilinmiyor"}",
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                if (not['notId'] != null) {
                  onNotSil(not['notId'] as int);
                }
              },
            ),
          ),
        );
      },
    );
  }
}
