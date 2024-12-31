// lib/members/menu.dart

import 'package:flutter/material.dart';
import 'member_management.dart'; // Assurez-vous que le chemin est correct

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.blueAccent;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Menu Principal',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Titre
            const Text(
              'Bienvenue!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Bouton pour la gestion des membres
            _buildMenuCard(
              context,
              label: 'Gestionnaire de Membres',
              icon: Icons.people,
              color: Colors.blueAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MemberManagementScreen()),
                );
              },
            ),
            const SizedBox(height: 20),

            // Placeholder pour d'autres opérations (ajoutez d'autres cartes ici)
            _buildMenuCard(
              context,
              label: 'Placeholder Opération',
              icon: Icons.settings,
              color: Colors.orangeAccent,
              onTap: () {
                // Future operation or navigation goes here
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 6,
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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black54),
        onTap: onTap,
      ),
    );
  }
}
