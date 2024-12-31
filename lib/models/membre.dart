class Membre {
  final String id;
  final String firstName;
  final String lastName;
  final String ministere;
  final String tel;
  final String nationalite; // Nouveau champ pour la nationalité
  final int? ministereNumero; // Champ optionnel pour le numéro du ministère

  Membre({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.ministere,
    required this.tel,
    required this.nationalite, // Ajouter la nationalité comme champ obligatoire
    this.ministereNumero,
  });

  // Méthode pour convertir des données venant de Firebase en Membre
  factory Membre.fromMap(Map<String, dynamic> data, String documentId) {
    return Membre(
      id: documentId,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      ministere: data['ministere'] ?? '',
      tel: data['tel'] ?? '',
      nationalite: data['nationalite'] ?? '', // Ajouter la nationalité
      ministereNumero: data['ministereNumero'] ?? 0, // Utilisation du numéro de ministère s'il est disponible
    );
  }

  // Méthode pour convertir un Membre en map (pour l'envoi à Firebase)
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'ministere': ministere,
      'tel': tel,
      'nationalite': nationalite, // Inclure la nationalité dans la map
      'ministereNumero': ministereNumero,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Membre && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}


