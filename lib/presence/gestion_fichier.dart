import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:share/share.dart';
import 'package:open_file/open_file.dart';

class FileManagementScreen extends StatefulWidget {
  @override
  _FileManagementScreenState createState() => _FileManagementScreenState();
}

class _FileManagementScreenState extends State<FileManagementScreen> {
  List<String> attendanceFiles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttendanceFiles();
  }

  Future<void> _loadAttendanceFiles() async {
    setState(() {
      isLoading = true;
    });
    final directory = await getExternalStorageDirectory();
    if (directory == null) return;

    final files = directory.listSync().where((file) => file.path.endsWith('.pdf'));

    setState(() {
      attendanceFiles = files.map((file) => file.path).toList();
      isLoading = false;
    });
  }

  Future<void> _deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      _loadAttendanceFiles();
    }
  }

  Future<void> _shareFile(String filePath) async {
    await Share.shareFiles([filePath], text: 'Liste des présences');
  }

  Future<void> _openFile(String filePath) async {
    final result = await OpenFile.open(filePath);
    if (result.type != ResultType.done) {
      print("Erreur lors de l'ouverture du fichier: $filePath. Erreur : ${result.message}");
    }
  }

  Future<void> _uploadFileToFirebase(String filePath) async {
    try {
      final fileName = filePath.split('/').last;
      final storageRef = FirebaseStorage.instance.ref().child('attendance/$fileName');
      final file = File(filePath);

      await storageRef.putFile(file);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fichier uploadé avec succès : $fileName')),
      );
    } catch (e) {
      print("Erreur lors de l'upload du fichier : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'upload du fichier')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Fichiers de Présence'),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : attendanceFiles.isEmpty
          ? Center(child: Text('Aucun fichier trouvé.', style: TextStyle(fontSize: 18)))
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 3 / 4,
          ),
          itemCount: attendanceFiles.length,
          itemBuilder: (context, index) {
            final filePath = attendanceFiles[index];
            final fileName = filePath.split('/').last;

            return Card(
              color: Colors.white,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      fileName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 4,
                      width: 40,
                      color: Colors.deepPurple,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteFile(filePath),
                            tooltip: 'Supprimer',
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _openFile(filePath),
                      child: Text(
                        'Ouvrir',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
