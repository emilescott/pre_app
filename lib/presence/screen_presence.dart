// lib/presence/screen_presence.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../services/firebase_service.dart';
import '../models/membre.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  Map<String, List<Membre>> membresParMinistere = {};
  Set<String> selectedMembres = {};
  bool isLoading = true;
  bool isFirstCult = true;

  @override
  void initState() {
    super.initState();
    loadMembres();
  }

  Future<void> loadMembres() async {
    try {
      List<Membre> loadedMembres = await _firebaseService.getMembres();
      Map<String, List<Membre>> groupedByMinistere = {};

      for (var membre in loadedMembres) {
        groupedByMinistere.putIfAbsent(membre.ministere, () => []).add(membre);
      }

      // Trier les ministères selon ministereNumero
      var sortedKeys = groupedByMinistere.keys.toList()
        ..sort((a, b) {
          // Utilisation de ?? pour attribuer 0 si ministereNumero est null
          int numA = groupedByMinistere[a]!.first.ministereNumero ?? 0;
          int numB = groupedByMinistere[b]!.first.ministereNumero ?? 0;
          return numA.compareTo(numB);
        });

      // Remettre les ministères triés dans la map
      Map<String, List<Membre>> sortedMembresParMinistere = {
        for (var key in sortedKeys) key: groupedByMinistere[key]!,
      };

      setState(() {
        membresParMinistere = sortedMembresParMinistere;
        isLoading = false;
      });
    } catch (e) {
      print("Erreur lors du chargement des membres : $e");
    }
  }


  void _showFileNameDialog(BuildContext context) {
    final _fileNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Nom du Fichier', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _fileNameController,
            decoration: InputDecoration(
              labelText: 'Entrez le nom du fichier',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await saveAttendance(_fileNameController.text);
              },
              child: Text('Ok', style: TextStyle(color: Colors.deepPurple)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text('Annuler', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  Future<void> saveAttendance(String customFileName) async {
    final now = DateTime.now();
    final dateFormatter = DateFormat('EEEE, d MMMM yyyy');
    final formattedDate = dateFormatter.format(now);

    await _firebaseService.saveAttendance(customFileName, selectedMembres.toList(), isFirstCult);

    final pdf = pw.Document();
    List<Membre> firstCultMembres = await _firebaseService.getAttendanceForCult(customFileName, true);
    List<Membre> secondCultMembres = await _firebaseService.getAttendanceForCult(customFileName, false);

    const int membersPerPage = 17;
    if (firstCultMembres.isNotEmpty) {
      int totalFirstCultMembers = firstCultMembres.length;
      for (int i = 0; i < totalFirstCultMembers; i += membersPerPage) {
        pdf.addPage(pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (i == 0) ...[ // Affiche l'en-tête uniquement sur la première page
                  _buildTitle('*******************************', PdfColors.purple),
                  _buildTitle('Premier culte', PdfColors.blue, fontSize: 25),
                  _buildTitle(formattedDate, PdfColors.orange, fontSize: 15),
                  _buildTitle('*******************************', PdfColors.purple),
                  pw.SizedBox(height: 20),
                ],
                ..._buildMinistereSections(
                  firstCultMembres.skip(i).take(membersPerPage).toList(),
                  secondCultMembres,
                ),

                if (i + membersPerPage >= totalFirstCultMembers) ...[ // Affiche le total uniquement sur la dernière page
                  pw.SizedBox(height: 22),
                  _buildTotalSection(firstCultMembres),
                ],
              ],
            );
          },
        ));
      }
    }


    if (secondCultMembres.isNotEmpty) {
      int totalSecondCultMembers = secondCultMembres.length;
      for (int i = 0; i < totalSecondCultMembers; i += membersPerPage) {
        pdf.addPage(pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (i == 0) ...[ // Affiche l'en-tête uniquement sur la première page
                  _buildTitle('*******************************', PdfColors.purple),
                  _buildTitle('Deuxième culte', PdfColors.blue, fontSize: 25),
                  _buildTitle(formattedDate, PdfColors.orange, fontSize: 15),
                  _buildTitle('*******************************', PdfColors.purple),
                  pw.SizedBox(height: 20),
                ],
                ..._buildMinistereSections(
                  secondCultMembres.skip(i).take(membersPerPage).toList(),
                  firstCultMembres,
                ),
                if (i == 0) ...[ // Ajoute un espace sous l'en-tête uniquement sur la première page
                  pw.SizedBox(height: 22),
                  _buildTotalSection(secondCultMembres),
                ],

                if (i + membersPerPage >= totalSecondCultMembers) ...[ // Affiche le total uniquement sur la dernière page
                  pw.SizedBox(height: 22),
                  _buildTotalSection(secondCultMembres),
                ],
              ],
            );
          },
        ));
      }
    }


    await _savePdf(pdf, customFileName);
  }

  List<pw.Widget> _buildMinistereSections(List<Membre> cultMembres, List<Membre> otherCultMembres) {
    List<pw.Widget> sections = [];
    int num = 1;

    for (var ministere in membresParMinistere.keys) {
      final membres = membresParMinistere[ministere]!;
      final filteredMembres = membres.where((m) => cultMembres.contains(m)).toList();
      final countPresents = cultMembres.where((m) => m.ministere == ministere).length;

      // Si aucun membre n'est affiché pour ce ministère, ignorer le ministère
      if (filteredMembres.isEmpty) {
        continue;
      }

      sections.add(
        pw.Text(
          '        --- $ministere ---\n',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.red),
        ),
      );
      sections.add(
        pw.Text(
          '         $countPresents présents sur ${membres.length}',
          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.blue),
        ),
      );

      for (var membre in filteredMembres) {
        sections.add(
          pw.Text(
            '${num++}- ${membre.firstName} ${membre.lastName} \(${membre.nationalite}\)',
            style: pw.TextStyle(fontSize: 14, color: PdfColors.black, fontWeight: pw.FontWeight.bold),
          ),
        );
      }
      sections.add(pw.SizedBox(height: 10));
    }

    return sections;
  }

  pw.Widget _buildTitle(String text, PdfColor color, {double fontSize = 20}) {
    return pw.Text(text, style: pw.TextStyle(fontSize: fontSize, color: color));
  }

  pw.Widget _buildTotalSection(List<Membre> cultMembres) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Total : ${cultMembres.length} ', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  Future<void> _savePdf(pw.Document pdf, String customFileName) async {
    final directory = await getExternalStorageDirectory();
    if (directory == null) throw Exception('Erreur : Le répertoire de stockage est inaccessible.');

    final file = File('${directory.path}/$customFileName.pdf');
    await file.writeAsBytes(await pdf.save());
    await uploadToFirebase(customFileName, file);
    _showExportDialog(context);
    selectedMembres.clear();
  }

  Future<void> uploadToFirebase(String fileName, File file) async {
    try {
      await FirebaseStorage.instance.ref('presences/$fileName.pdf').putFile(file);
      print('Fichier uploadé avec succès : $fileName.pdf');
    } catch (e) {
      print('Erreur lors de l\'upload : $e');
    }
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Exportation réussie', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          content: Text('Le fichier PDF a été exporté avec succès.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text('Ok', style: TextStyle(color: Colors.green)),
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
        title: const Text('Suivi des Présences', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          SwitchListTile(
            title: Text(isFirstCult ? 'Premier culte' : 'Deuxième culte',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            value: isFirstCult,
            onChanged: (value) {
              setState(() {
                isFirstCult = value;
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: membresParMinistere.keys.length,
              itemBuilder: (context, index) {
                String ministere = membresParMinistere.keys.elementAt(index);
                List<Membre> membres = membresParMinistere[ministere]!;
                int num = 1;

                return Card(
                  elevation: 4,
                  margin: EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            '$ministere \n - ${membres.length} membres',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const Divider(),
                        ...membres.map((membre) {
                          return CheckboxListTile(
                            title: Text(
                              '${num++}- ${membre.firstName} ${membre.lastName} \(${membre.nationalite}\)',
                              style: TextStyle(color: Colors.deepPurpleAccent),
                            ),
                            value: selectedMembres.contains(membre.id),
                            onChanged: (bool? checked) {
                              setState(() {
                                if (checked == true) {
                                  selectedMembres.add(membre.id);
                                } else {
                                  selectedMembres.remove(membre.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () => _showFileNameDialog(context),
              child: const Text('Sauvegarder les Présences'),
            ),
          ),
        ],
      ),
    );
  }
}
