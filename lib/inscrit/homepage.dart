// lib/inscrit/homepage.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/members/menu.dart'; // Assurez-vous d'importer votre fichier menu.dart

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Définition du contrôleur pour le PageView
  final PageController _pageController = PageController();
  late Timer _timer;
  int _currentPageIndex = 0;

  // Liste des éléments affichés (le message de bienvenue et les images)
  late List<Widget> _welcomeSlides;
  TextStyle? welcomeTextStyle;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Obtenir l'utilisateur actuel et générer le message de bienvenue
    User? user = FirebaseAuth.instance.currentUser;
    String welcomeMessage = user != null
        ? 'Bienvenue ${user.displayName ?? user.email}!'
        : 'Bienvenue dans l\'application!';

    // Initialiser le style de texte en utilisant le thème
    welcomeTextStyle = Theme.of(context).textTheme.headline5;

    // Initialiser les éléments du carrousel (message + images)
    _welcomeSlides = [
      Center(child: Text(welcomeMessage, style: welcomeTextStyle)),
      _buildImageSlide('assets/image1.png'),
      _buildImageSlide('assets/image2.png'),
      _buildImageSlide('assets/image3.png'),
      _buildImageSlide('assets/image4.png'),
      _buildImageSlide('assets/image5.png'),
      _buildImageSlide('assets/image6.png'),
    ];

    // Configurer un timer pour changer automatiquement de page toutes les 2 secondes
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentPageIndex < _welcomeSlides.length - 1) {
        _currentPageIndex++;
      } else {
        _currentPageIndex = 0;
      }
      _pageController.animateToPage(
        _currentPageIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  // Fonction pour générer un slide d'image
  Widget _buildImageSlide(String imagePath) {
    return Center(
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
        height: 400,
      ),
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              children: _welcomeSlides,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout),
                  label: const Text('Déconnexion'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const MenuPage()),
                    );
                  },
                  child: const Text('Suivant'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
