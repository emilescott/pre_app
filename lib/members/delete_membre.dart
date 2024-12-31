// lib/members/delete_membre.dart

import 'package:flutter/material.dart';
import '/services/firebase_service.dart';
import '/models/membre.dart';

class DeleteMembreScreen extends StatefulWidget {
  @override
  _DeleteMembreScreenState createState() => _DeleteMembreScreenState();
}

class _DeleteMembreScreenState extends State<DeleteMembreScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Membre> membres = [];

  @override
  void initState() {
    super.initState();
    loadMembres();
  }

  Future<void> loadMembres() async {
    membres = await _firebaseService.getMembres();
    setState(() {});
  }

  Future<void> deleteMembre(String id) async {
    await _firebaseService.deleteMembre(id);
    loadMembres(); // Recharge la liste après la suppression
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supprimer un Membre'),
      ),
      body: ListView.builder(
        itemCount: membres.length,
        itemBuilder: (context, index) {
          final membre = membres[index];
          return ListTile(
            title: Text('${membre.firstName} ${membre.lastName} \(${membre.nationalite}\)'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                deleteMembre(membre.id); // Suppression du membre
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Succès'),
                      content: const Text('Membre supprimé avec succès!'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Fermer la boîte de dialogue
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
