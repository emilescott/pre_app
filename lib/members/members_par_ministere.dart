import 'package:flutter/material.dart';
import '/services/firebase_service.dart';
import '/models/membre.dart';
import 'edit_membre_screen.dart'; // Import de l'écran de modification du membre

class MembresParMinistereScreen extends StatefulWidget {
  final bool isForModification; // Paramètre pour indiquer si l'écran est utilisé pour modifier un membre

  const MembresParMinistereScreen({Key? key, this.isForModification = false}) : super(key: key);

  @override
  _MembresParMinistereScreenState createState() => _MembresParMinistereScreenState();
}

class _MembresParMinistereScreenState extends State<MembresParMinistereScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  Map<String, List<Membre>> membresParMinistere = {};
  bool isLoading = true;
  int totalMembres = 0; // Compteur pour le nombre total de membres

  @override
  void initState() {
    super.initState();
    loadMembres();
  }

  Future<void> loadMembres() async {
    List<Membre> loadedMembres = await _firebaseService.getMembres();

    // Grouper les membres par ministère
    Map<String, List<Membre>> groupedByMinistere = {};
    for (var membre in loadedMembres) {
      if (!groupedByMinistere.containsKey(membre.ministere)) {
        groupedByMinistere[membre.ministere] = [membre];
      } else {
        groupedByMinistere[membre.ministere]!.add(membre);
      }
    }

    // Trier les ministères par ministereNumero
    var sortedKeys = groupedByMinistere.keys.toList()
      ..sort((a, b) {
        int numA = groupedByMinistere[a]!.first.ministereNumero ?? 0;
        int numB = groupedByMinistere[b]!.first.ministereNumero ?? 0;
        return numA.compareTo(numB);
      });

    // Créer un nouveau map trié des ministères
    Map<String, List<Membre>> sortedMembresParMinistere = {
      for (var key in sortedKeys) key: groupedByMinistere[key]!,
    };

    setState(() {
      membresParMinistere = sortedMembresParMinistere;
      totalMembres = loadedMembres.length;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Membres par Ministère'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: membresParMinistere.keys.length,
                itemBuilder: (context, index) {
                  String ministere = membresParMinistere.keys.elementAt(index);
                  List<Membre> membres = membresParMinistere[ministere]!;

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$ministere',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${membres.length} membres',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...membres.map((membre) {
                            return ListTile(
                              leading: const Icon(Icons.person, color: Colors.blue),
                              title: Text('${membre.firstName} ${membre.lastName}'),
                              subtitle: Text('Tel: ${membre.tel}\nNationalité: ${membre.nationalite}'),
                              onTap: widget.isForModification
                                  ? () {
                                // Si l'écran est pour la modification, naviguer vers la page de modification du membre
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => EditMembreScreen(membre: membre),
                                  ),
                                );
                              }
                                  : null,
                            );
                          }).toList(),
                          const Divider(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Nombre total de membres: $totalMembres',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
