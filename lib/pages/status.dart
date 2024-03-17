import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stepit/classes/user.dart';

class StatusPage extends StatefulWidget {
  @override
  _StatusPageState createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

   
  Stream<DocumentSnapshot> fetchFromFirebase(int userID) {
    return _firestore.collection('users').doc(userID.toString().padLeft(6, '0')).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Status'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: fetchFromFirebase(user!.uniqueNumber),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }
          if (snapshot.data?.data() != null) {
            Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
            if (data['steps and location'] != null) {
              Map<String, dynamic> stepsAndLocation = data['steps and location'] as Map<String, dynamic>;

              return ListView(
                children: stepsAndLocation.entries.map((entry) {
                  String time = entry.key;
                  Map<String, dynamic> details = entry.value;
                  return ListTile(
                    title: Text('Time: $time'),
                    //subtitle: Text('Steps: ${details['steps']}'),
                    subtitle: Text('Steps: ${details['steps']}, Location: ${details['location'].latitude}, ${details['location'].longitude}'),
                  );
                }).toList(),
              );
            }
          }
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'No data yet. Start walking to see your steps and location.',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
          );        
        },
      ),
    );
  }
}