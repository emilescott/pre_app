// lib/inscrit/add_member_screen.dart

import 'package:flutter/material.dart';
import '../models/membre.dart';
import '../services/firebase_service.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  _AddMemberScreenState createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _telController = TextEditingController();
  final TextEditingController _nationaliteController = TextEditingController();
  String _selectedMinistere = 'I-ORATEUR';
  int _selectedMinistereNumero = 1;

  // Liste des ministères avec numérotation
  final List<Map<String, dynamic>> _ministeres = [
    {'numero': 1, 'nom': 'I-ORATEUR'},
    {'numero': 2, 'nom': 'II-MINISTÈRE DE L\'ACCUEIL'},
    {'numero': 3, 'nom': 'III-MINISTÈRE DE LA LOUANGE'},
    {'numero': 4, 'nom': 'IV-MINISTÈRE DE LA PRIÈRE'},
    {'numero': 5, 'nom': 'V-MINISTÈRE DE LA MOISSON'},
    {'numero': 6, 'nom': 'VI-MINISTÈRE DU MULTIMÉDIA'},
    {'numero': 7, 'nom': 'VII-MINISTÈRE DE L\'ECODIUM'},
    {'numero': 8, 'nom': 'VIII-NOUVELLES PERSONNES'},
    {'numero': 9, 'nom': 'IX-AUTRE MEMBRES'},
  ];

  Future<void> _addMember() async {
    if (_firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _telController.text.isNotEmpty &&
        _nationaliteController.text.isNotEmpty) {
      Membre newMember = Membre(
        id: '',
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        tel: _telController.text,
        ministere: _selectedMinistere,
        ministereNumero: _selectedMinistereNumero,
        nationalite: _nationaliteController.text,
      );

      await _firebaseService.addMembre(newMember);
      Navigator.pop(context); // Retour à l'écran précédent après ajout
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un Membre'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _firstNameController,
                        label: 'Prénom',
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        controller: _lastNameController,
                        label: 'Nom',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        controller: _telController,
                        label: 'Téléphone',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        controller: _nationaliteController,
                        label: 'Nationalité',
                        icon: Icons.flag,
                      ),
                      const SizedBox(height: 20),
                      _buildDropdown(),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _addMember,
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Ajouter Membre',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fonction pour créer un champ de texte stylisé
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Fonction pour créer un menu déroulant stylisé
  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedMinistere,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
          isExpanded: true,
          onChanged: (String? newValue) {
            setState(() {
              Map<String, dynamic> selected = _ministeres.firstWhere(
                    (ministere) => ministere['nom'] == newValue,
              );
              _selectedMinistere = newValue!;
              _selectedMinistereNumero = selected['numero'];
            });
          },
          items: _ministeres.map<DropdownMenuItem<String>>((ministere) {
            return DropdownMenuItem<String>(
              value: ministere['nom'],
              child: Text(
                '${ministere['numero']} - ${ministere['nom']}',
                style: const TextStyle(fontSize: 16),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
