import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ApproveScreen extends StatefulWidget {
  const ApproveScreen({ Key? key }) : super(key: key);

  @override
  State<ApproveScreen> createState() => _ApproveScreenState();
}

class _ApproveScreenState extends State<ApproveScreen> {
  Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('establishments').where('isApproved', isEqualTo: false);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Padding(padding: EdgeInsets.all(20)),
          const Text(
            "Establishments pending approval",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
          StreamBuilder<QuerySnapshot>(
            stream: query.snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if(snapshot.hasData) {
                if(snapshot.data!.docs.isEmpty) return const Text("No establishments pending approval.");
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 500),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Establishment Name: " + snapshot.data!.docs[index]["name"]
                          ),
                          Text(
                            "Mobile Number: " + snapshot.data!.docs[index]["number"]
                          ),
                          Text(
                            "Address: " + snapshot.data!.docs[index]["barangay"] + ", " + snapshot.data!.docs[index]["municipality"]
                          ),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                updateApprovalStatus(snapshot.data!.docs[index].id);
                              },
                              child: const Text(
                                  "APPROVE",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold
                                    )
                                ),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0)
                                ),
                                primary: const Color(0xFF2FA804),
                                onPrimary: Colors.white
                              ),
                            ),
                          )
                        ],
                      )
                    );
                  },
                );
              }

              return const CircularProgressIndicator();
            },
          ),
          const Spacer(),
        ],
      ),
    );
  }

  updateApprovalStatus(String id) async {
    await FirebaseFirestore.instance
      .collection('establishments')
      .doc(id)
      .update({
        "isApproved": true
      });
  }
}