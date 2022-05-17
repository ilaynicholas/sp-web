import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PositiveCasesScreen extends StatefulWidget {
  const PositiveCasesScreen({ Key? key }) : super(key: key);

  @override
  State<PositiveCasesScreen> createState() => _PositiveCasesScreenState();
}

class _PositiveCasesScreenState extends State<PositiveCasesScreen> {
  Query<Map<String, dynamic>> queryPositive = FirebaseFirestore.instance.collection('users')
    .where("covidStatus", isEqualTo: 1);

  Query<Map<String, dynamic>> queryContact = FirebaseFirestore.instance.collection('users')
    .where("covidStatus", isEqualTo: 2);

  List<String> vaccinationStatuses = [
    "Fully vaccinated with booster shot",
    "Fully vaccinated without booster shot",
    "One dose only",
    "Not yet vaccinated"
  ];
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.all(20)),
              const Text(
                "Current COVID-19 Positive Cases",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold
                )
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
              StreamBuilder<QuerySnapshot>(
                stream: queryPositive.snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if(snapshot.hasData) {
                    if(snapshot.data!.docs.isEmpty) return const Text("No current COVID-19 positive individuals.");
        
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black)
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Name: " + snapshot.data!.docs[index]["name"]
                              ),
                              Text(
                                "Mobile Number: " + snapshot.data!.docs[index]["number"]
                              ),
                              Text(
                                "Address: " + snapshot.data!.docs[index]["barangay"] + ", " + snapshot.data!.docs[index]["municipality"]
                              ),
                              Text(
                                "Vaccination Status: " + vaccinationStatuses[snapshot.data!.docs[index]["vaccinationStatus"]]
                              ),
                              const Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    updateCovidStatus(snapshot.data!.docs[index].id);
                                  },
                                  child: const Text(
                                    "REMOVE",
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
                      }
                    );
                  }
        
                  return const CircularProgressIndicator();
                },
              )
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.all(20)),
              const Text(
                "Current COVID-19 Close Contacts",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold
                )
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
              StreamBuilder<QuerySnapshot>(
                stream: queryContact.snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if(snapshot.hasData) {
                    if(snapshot.data!.docs.isEmpty) return const Text("No current COVID-19 close contacts.");
        
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black)
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Name: " + snapshot.data!.docs[index]["name"]
                              ),
                              Text(
                                "Mobile Number: " + snapshot.data!.docs[index]["number"]
                              ),
                              Text(
                                "Address: " + snapshot.data!.docs[index]["barangay"] + ", " + snapshot.data!.docs[index]["municipality"]
                              ),
                              Text(
                                "Vaccination Status: " + vaccinationStatuses[snapshot.data!.docs[index]["vaccinationStatus"]]
                              ),
                              const Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    updateCovidStatus(snapshot.data!.docs[index].id);
                                  },
                                  child: const Text(
                                    "REMOVE",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold
                                      )
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25.0)
                                    ),
                                    primary: const Color(0xFFBCBF1D),
                                    onPrimary: Colors.white
                                  ),
                                ),
                              )
                            ],
                          )
                        );
                      }
                    );
                  }
        
                  return const CircularProgressIndicator();
                },
              )
            ],
          ),
        ),
      ],
    );
  }

  updateCovidStatus(String id) async {
    await FirebaseFirestore.instance
      .collection('users')
      .doc(id)
      .update({
        "covidStatus": 0
      });
  }
}