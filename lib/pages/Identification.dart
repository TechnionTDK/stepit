import 'package:flutter/material.dart';
import 'dart:math';
import "package:stepit/background/steps_tracking.dart";
import 'package:stepit/classes/database.dart';
import 'package:stepit/classes/objects.dart';
import 'package:stepit/pages/homepage.dart';

class IdentificationPage extends StatefulWidget {
  @override
  _IdentificationPageState createState() => _IdentificationPageState();
}

class _IdentificationPageState extends State<IdentificationPage> {
  String _username = '';
  late Future<int> _uniqueNumber;

  @override
  void initState() {
    super.initState();
    _uniqueNumber = _generateUniqueNumber();
  }

  Future<int> _generateUniqueNumber() async {
    int uniqueNumber = 100000 +
        Random().nextInt(
            900000); // Generates a random number between 100000 and 999999
    bool isUnique = await _checkUniqueNumber(uniqueNumber);
    while (!isUnique) {
      uniqueNumber = 100000 + Random().nextInt(900000);
      isUnique = await _checkUniqueNumber(uniqueNumber);
    }
    return uniqueNumber;
  }

  Future<bool> _checkUniqueNumber(int uniqueNumber) async {
    return DataBase.userExists(uniqueNumber);
  }

  void _saveToFirestore() async {
    int uniqueNumber = await _uniqueNumber;
    DataBase.addUser(User(_username, uniqueNumber));
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('Welcome to StepIT!'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 50),
              const Text(
                'Enter a username to get started',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _username = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Enter username',
                  ),
                ),
              ),
              FutureBuilder<int>(
                future: _uniqueNumber,
                builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else {
                    return Text('Unique number: ${snapshot.data}');
                  }
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  _saveToFirestore();
                  DataBase.loadUser();
                  startStepsTracking();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    color: Color.fromARGB(
                        255, 0, 0, 0), // Set the desired text color here
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}