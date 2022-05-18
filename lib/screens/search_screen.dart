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

  late Query<Map<String, dynamic>> querySearch;

  bool isVisible = false;
  bool isButtonDisabled = false;

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
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 50),
          child: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: "Type full name to search.",
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
        Visibility(
          visible: isVisible,
          child: const Text(
            "Classifying close contacts...",
            style: TextStyle(fontStyle: FontStyle.italic)
          )
        ),
        const Padding(padding: EdgeInsets.only(bottom: 8)),
        buildSearchStream()
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
    setState(() {
      isVisible = true;
    });

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
        .then((value) async {
          for (var element in value.docs) {
            bool result = await isPositive(element.data()['userId']);
            if(element.data()['userId'] != estab['userId'] && element.data()['establishmentId'] == estab['establishmentId'] && !result) closeContacts.add(element.data());
          }
        });
    }
    
    for(var user in closeContacts) {
      filteredCloseContacts.add(user['userId']);
    }

    for(var user in filteredCloseContacts) {
      updateCloseContact(user);
    }

    setState(() {
      isVisible = false;
    });
  }

  Future<bool> isPositive(String id) async {
    bool isPositive = false;

    await FirebaseFirestore.instance
      .collection('users')
      .doc(id)
      .get()
      .then((value) {
        if (value.get('covidStatus') == 1) {
          isPositive = true;
        }
      });

    return isPositive;
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
                margin: const EdgeInsets.symmetric(horizontal: 200),
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
                        onPressed: isButtonDisabled ? null : () {
                          updateCovidStatus(snapshot.data!.docs[index].id);
                          findCloseContacts(snapshot.data!.docs[index].id);
                          setState(() {
                            isButtonDisabled = true;
                          });
                        },
                        child: Text(
                          isButtonDisabled ? "ALREADY CLASSIFIED" : "CLASSIFY AS COVID-19 POSITIVE",
                          style: const TextStyle(
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