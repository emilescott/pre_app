// lib/member_management.dart

import 'package:flutter/material.dart';
import '/services/firebase_service.dart';
import '/models/membre.dart';
import 'add_member.dart';
import '/members/members_par_ministere.dart';
import 'delete_membre.dart';
import '../presence/screen_presence.dart';
import '../presence/gestion_fichier.dart';

class MemberManagementScreen extends StatelessWidget {
  const MemberManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseService _firebaseService = FirebaseService();
    final Color primaryColor = Colors.blueAccent;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestion des Membres',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Bouton pour ajouter un membre
              _buildMenuButton(
                context,
                label: 'Ajouter un Membre',
                icon: Icons.person_add,
                color: Colors.greenAccent,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AddMemberScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Bouton pour afficher les membres par ministère
              _buildMenuButton(
                context,
                label: 'Liste des Membres de Ac_Agadir',
                icon: Icons.list,
                color: Colors.orangeAccent,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const MembresParMinistereScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Bouton pour modifier un membre
              _buildMenuButton(
                context,
                label: 'Modifier un Membre',
                icon: Icons.edit,
                color: Colors.blueAccent,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const MembresParMinistereScreen(
                        isForModification: true,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Bouton pour supprimer un membre
              _buildMenuButton(
                context,
                label: 'Supprimer un Membre',
                icon: Icons.delete,
                color: Colors.redAccent,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => DeleteMembreScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Bouton pour le suivi des présences
              _buildMenuButton(
                context,
                label: 'Suivi des Présences',
                icon: Icons.check_circle,
                color: Colors.purpleAccent,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => AttendanceScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Bouton pour la gestion des fichiers
              _buildMenuButton(
                context,
                label: 'Gestion des Fichiers',
                icon: Icons.folder,
                color: Colors.cyanAccent,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => FileManagementScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, {required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: color.withOpacity(0.1),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black54),
        onTap: onTap,
      ),
    );
  }
}
