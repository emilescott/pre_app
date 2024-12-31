import 'package:flutter/material.dart';
import '/services/firebase_service.dart';
import '/models/membre.dart';

class EditMembreScreen extends StatefulWidget {
  final Membre membre;

  const EditMembreScreen({Key? key, required this.membre}) : super(key: key);

  @override
  _EditMembreScreenState createState() => _EditMembreScreenState();
}

class _EditMembreScreenState extends State<EditMembreScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _telController;
  late TextEditingController _nationaliteController;
  String? _selectedMinistere;

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

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.membre.firstName);
    _lastNameController = TextEditingController(text: widget.membre.lastName);
    _telController = TextEditingController(text: widget.membre.tel);
    _nationaliteController = TextEditingController(text: widget.membre.nationalite);
    _selectedMinistere = widget.membre.ministere;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _telController.dispose();
    _nationaliteController.dispose();
    super.dispose();
  }

  Future<void> _updateMembre() async {
    if (_formKey.currentState!.validate()) {
      Membre updatedMembre = Membre(
        id: widget.membre.id,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        tel: _telController.text,
        nationalite: _nationaliteController.text,
        ministere: _selectedMinistere ?? widget.membre.ministere,
        ministereNumero: widget.membre.ministereNumero,
      );

      await _firebaseService.updateMembre(updatedMembre);
      _showConfirmationDialog();
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirmation',
            style: TextStyle(color: Colors.green),
          ),
          content: const Text('Membre mis à jour avec succès'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Modifier ${widget.membre.firstName} ${widget.membre.lastName}',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _firstNameController,
                label: 'Prénom',
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _lastNameController,
                label: 'Nom',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _telController,
                label: 'Téléphone',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nationaliteController,
                label: 'Nationalité',
                icon: Icons.flag,
              ),
              const SizedBox(height: 16),
              _buildDropdown(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updateMembre,
                style: ElevatedButton.styleFrom(
                  primary: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Mettre à jour',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer $label';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedMinistere,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
        isExpanded: true,
        onChanged: (String? newValue) {
          setState(() {
            _selectedMinistere = newValue;
          });
        },
        items: _ministeres.map((ministere) {
          return DropdownMenuItem<String>(
            value: ministere['nom'],
            child: Text('${ministere['numero']} - ${ministere['nom']}'),
          );
        }).toList(),
        decoration: const InputDecoration(
          labelText: 'Ministère',
          border: InputBorder.none,
        ),
        validator: (value) {
          if (value == null) {
            return 'Veuillez sélectionner un ministère';
          }
          return null;
        },
      ),
    );
  }
}
