import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({ Key? key }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final nameController = TextEditingController();

  String queryText = "";
  String queryContact = "";

  late Query<Map<String, dynamic>> querySearch;
  late Query<Map<String, dynamic>> querySearchContact;

  List<String> vaccinationStatuses = [
    "Fully vaccinated with booster shot",
    "Fully vaccinated without booster shot",
    "One dose only",
    "Not yet vaccinated"
  ];

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    querySearch = searchDatabase(queryText);
    querySearchContact = searchCloseContacts(queryContact);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 50),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "Type name to search.",
                    hintStyle: const TextStyle(
                      fontSize: 14
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFF008999))
                    )
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    queryText = nameController.text;
                    querySearch = searchDatabase(queryText);
                  });
                },
                child: const Text(
                  "SEARCH",
                  style: TextStyle(
                      fontWeight: FontWeight.bold
                    )
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0)
                  ),
                  primary: const Color(0xFF008999),
                  onPrimary: Colors.white
                ),
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
              buildSearchStream()
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.all(20)),
              const Text(
                "Close contacts within last 2 days",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold
                )
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
              buildContactStream()
            ],
          ),
        )
      ],
    );
  }

  searchDatabase(String name) {
    return FirebaseFirestore.instance
      .collection('users')
      .where(
        "name", isEqualTo: name
      );
  }

  updateCovidStatus(String id) async {
    await FirebaseFirestore.instance
      .collection('users')
      .doc(id)
      .update({
        "covidStatus": 1
      });
  }

  findCloseContacts(String id) async {
    final estabs = [];
    final estabsWithUser = [];
    final closeContacts = [];
    final filteredCloseContacts = [];
    DateTime now = DateTime.now();
    DateTime start = DateTime(now.year, now.month, now.day, 0, 0);
    DateTime end = DateTime(now.year, now.month, now.day-2, 0, 0);

    await FirebaseFirestore.instance
      .collection('logs')
      .where('timestamp', isLessThan: start)
      .where('timestamp', isGreaterThan: end)
      .get()
      .then((value) {
        for (var element in value.docs) {
          estabs.add(element.data());
        }
      });

    for(var estab in estabs) {
      if(estab['userId'] == id) estabsWithUser.add(estab);
    }

    for(var estab in estabsWithUser) {
      await FirebaseFirestore.instance
        .collection('logs')
        .where('timestamp', isLessThan: start)
        .where('timestamp', isGreaterThan: end)
        .get()
        .then((value) {
          for (var element in value.docs) {
            if(element.data()['userId'] != estab['userId'] && element.data()['establishmentId'] == estab['establishmentId']) closeContacts.add(element.data());
          }
        });
    }
    
    for(var user in closeContacts) {
      filteredCloseContacts.add(user['userId']);
    }

    print(filteredCloseContacts);
  }
  
  searchCloseContacts(String id) {
    DateTime now = DateTime.now();
    DateTime start = DateTime(now.year, now.month, now.day, 0, 0);
    DateTime end = DateTime(now.year, now.month, now.day-2, 0, 0);

    findCloseContacts(id);

    Query timeQuery = FirebaseFirestore.instance
      .collection('logs')
      .where(
        'timestamp', isLessThan: start
      )
      .where(
        'timestamp', isGreaterThan: end
      );

    return timeQuery;

    // return timeQuery.where(
    //   'userId', isEqualTo: id
    // );   
    // return FirebaseFirestore.instance
    //   .collection('logs')
    //   .where(
    //     'timestamp', isLessThanOrEqualTo: start
    //   )
    //   .where(
    //     'timestamp', isGreaterThanOrEqualTo: end
    //   );
  }

  updateCloseContact(String id) async {
    await FirebaseFirestore.instance
      .collection('users')
      .doc(id)
      .update({
        "covidStatus": 2
      });
  }

  Widget buildSearchStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: querySearch.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if(snapshot.hasData) {
          if(snapshot.data!.docs.isEmpty) return const Text("No users match your search.");

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
                          setState(() {
                            queryContact = snapshot.data!.docs[index].id;
                            querySearchContact = searchCloseContacts(queryContact);
                          });
                        },
                        child: const Text(
                          "CLASSIFY AS COVID-19 POSITIVE",
                          style: TextStyle(
                              fontWeight: FontWeight.bold
                            )
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0)
                          ),
                          primary: const Color(0xFFFF0000),
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
    );
  }

  Widget buildContactStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: querySearchContact.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if(snapshot.hasData) {
          if(snapshot.data!.docs.isEmpty) return const Text("No close contacts.");

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
                      "userId: " + snapshot.data!.docs[index]["userId"]
                    ),
                    Text(
                      "establishmentId: " + snapshot.data!.docs[index]["establishmentId"]
                    ),
                    Text(
                      "timestamp: " + snapshot.data!.docs[index]["timestamp"].toString()
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          updateCovidStatus(snapshot.data!.docs[index].id);
                        },
                        child: const Text(
                          "CLASSIFY AS COVID-19 POSITIVE",
                          style: TextStyle(
                              fontWeight: FontWeight.bold
                            )
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0)
                          ),
                          primary: const Color(0xFFFF0000),
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
    );
  }
}