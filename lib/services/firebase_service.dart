import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/membre.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference membresCollection = FirebaseFirestore.instance.collection('membres');

  // Récupérer tous les membres
  Future<List<Membre>> getMembres() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('membres').get();
      print('Nombre de membres récupérés: ${snapshot.docs.length}');
      for (var doc in snapshot.docs) {
        print('Membre: ${doc.data()}');
      }
      return snapshot.docs.map((doc) {
        return Membre.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des membres: $e');
      return [];
    }
  }

  // Ajouter un membre
  Future<void> addMembre(Membre membre) async {
    try {
      await _firestore.collection('membres').add(membre.toMap());
    } catch (e) {
      print('Erreur lors de l\'ajout du membre: $e');
    }
  }

  // Supprimer un membre par ID
  Future<void> deleteMembre(String id) async {
    try {
      await _firestore.collection('membres').doc(id).delete();
    } catch (e) {
      print('Erreur lors de la suppression du membre: $e');
    }
  }

  // lib/services/firebase_service.dart


  // Méthode pour mettre à jour un membre
  Future<void> updateMembre(Membre membre) async {
  try {
  await membresCollection.doc(membre.id).update({
  'firstName': membre.firstName,
  'lastName': membre.lastName,
  'tel': membre.tel,
  'nationalite': membre.nationalite,
  'ministere': membre.ministere,
  });
  } catch (e) {
  print('Erreur lors de la mise à jour du membre : $e');
  throw e;
  }
  }



  // Récupérer les membres par ministère
  Future<Map<String, List<Membre>>> getMembresByMinistere() async {
    Map<String, List<Membre>> membresByMinistere = {};
    try {
      QuerySnapshot snapshot = await _firestore.collection('membres').get();
      for (var doc in snapshot.docs) {
        Membre membre = Membre.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
        String ministere = membre.ministere;

        // Regrouper les membres par ministère
        if (!membresByMinistere.containsKey(ministere)) {
          membresByMinistere[ministere] = [];
        }
        membresByMinistere[ministere]!.add(membre);
      }
    } catch (e) {
      print('Erreur lors de la récupération des membres: $e');
    }
    return membresByMinistere;
  }


  // Récupérer les membres présents pour un culte donné
// Récupérer les membres présents pour un culte donné
  Future<List<Membre>> getAttendanceForCult(String cultName, bool isFirstCult) async {
    List<Membre> membres = [];
    try {
      DocumentSnapshot doc = await _firestore.collection('attendance').doc(cultName).get();
      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

        List<dynamic> cultIds;
        if (isFirstCult) {
          cultIds = data?['first_culte'] ?? [];
        } else {
          cultIds = data?['second_culte'] ?? [];
        }

        print('IDs récupérés pour $cultName: $cultIds');

        // Récupération des membres par ID
        for (String id in cultIds) {
          Membre membre = await getMembreById(id);
          membres.add(membre);
        }
      } else {
        print('Aucun document trouvé pour le culte: $cultName');
      }
    } catch (e) {
      print('Erreur lors de la récupération des présences : $e');
    }
    return membres;
  }


  // Récupérer un membre par ID
  Future<Membre> getMembreById(String id) async {
    DocumentSnapshot doc = await _firestore.collection('membres').doc(id).get();
    return Membre.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  // Enregistrer ou mettre à jour les présences pour un culte
  Future<void> saveAttendance(String cultName, List<String> selectedIds,
      bool isFirstCult) async {
    try {
      DocumentReference docRef = _firestore.collection('attendance').doc(
          cultName);
      DocumentSnapshot doc = await docRef.get();

      if (doc.exists) {
        // Mise à jour des présences
        await docRef.update({
          isFirstCult ? 'first_culte' : 'second_culte': FieldValue.arrayUnion(
              selectedIds),
        });
      } else {
        // Création d'un nouveau document
        await docRef.set({
          'first_culte': isFirstCult ? selectedIds : [],
          'second_culte': isFirstCult ? [] : selectedIds,
        });
      }

      print('Présences enregistrées pour le document $cultName');
    } catch (e) {
      print('Erreur lors de l\'enregistrement des présences : $e');
    }
  }
}