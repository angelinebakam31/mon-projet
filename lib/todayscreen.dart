import 'dart:async';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart';
import 'package:intl/intl.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'dart:core' as core;
import 'package:attendance/model/user.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @core.override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  core.double screenHeight = 0;
  core.double screenWidth = 0;

  String checkIn = "--/--";
  String checkOut = "--/--";
  String location = " ";

  Color primary = const Color(0xffeef444c);

  @override
  void initState() {
    super.initState();
    getRecord();
  }

  void _getLocation() async {
    List<Placemark> placemark =
        await placemarkFromCoordinates(User.latitude, User.longitude);

    setState(() {
      location =
          "${placemark[0].street}, ${placemark[0].administrativeArea}, ${placemark[0].postalCode}, ${placemark[0].country}";
    });
  }

  void getRecord() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection("employee")
          .where('id ', isEqualTo: User.employeeid)
          .get();

      DocumentSnapshot snap2 = await FirebaseFirestore.instance
          .collection("employee")
          .doc(snap.docs[0].id)
          .collection("Record")
          .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
          .get();

      setState(() {
        checkIn = snap2['checkIn'];
        checkOut = snap2['checkOut'];
      });
    } catch (e) {
      setState(() {
        checkIn = "--/--";
        checkOut = "--/--";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(top: 32),
              child: Text(
                "welcome",
                style: TextStyle(
                  color: Colors.black54,
                  fontFamily: "NexaRegular",
                  fontSize: screenWidth / 20,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                "employee${User.employeeid}",
                style: TextStyle(
                  fontFamily: "NexaBold",
                  fontSize: screenWidth / 18,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(top: 32),
              child: Text(
                "Today's Status",
                style: TextStyle(
                  fontFamily: "NexaBold",
                  fontSize: screenWidth / 18,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 32),
              height: 150,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(2, 2),
                  ),
                ],
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Check In",
                          style: TextStyle(
                            fontFamily: "NexaRegular",
                            fontSize: screenWidth / 20,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          checkIn,
                          style: TextStyle(
                            fontFamily: "NexaBold",
                            fontSize: screenWidth / 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Check Out",
                          style: TextStyle(
                            fontFamily: "NexaRegular",
                            fontSize: screenWidth / 20,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          checkOut,
                          style: TextStyle(
                            fontFamily: "NexaBold",
                            fontSize: screenWidth / 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                    text: DateTime.now().day.toString(),
                    style: TextStyle(
                      color: primary,
                      fontSize: screenWidth / 18,
                      fontFamily: "NexaBold",
                    ),
                    children: [
                      TextSpan(
                        text: DateFormat('  MMMM  yyyy').format(DateTime.now()),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenWidth / 20,
                          fontFamily: "NexaBold",
                        ),
                      ),
                    ]),
              ),
            ),
            StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1)),
              builder: (context, snapshot) {
                return Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    DateFormat('hh:mm: ss a').format(DateTime.now()),
                    style: TextStyle(
                      fontFamily: "NexaRegular",
                      fontSize: screenWidth / 20,
                      color: Colors.black54,
                    ),
                  ),
                );
              },
            ),
            checkOut == "--/--"
                ? Container(
                    margin: const EdgeInsets.only(top: 24, bottom: 12),
                    child: Builder(
                      builder: (context) {
                        final slideActionKey = GlobalKey<SlideActionState>();
                        return SlideAction(
                          key: slideActionKey,
                          text: checkIn == "--/--"
                              ? "Slide to Check In"
                              : "Slide to Check Out",
                          textStyle: TextStyle(
                            color: Colors.black54,
                            fontSize: screenWidth / 20,
                            fontFamily: "NexaRegular",
                          ),
                          outerColor: Colors.white,
                          innerColor: primary,
                          onSubmit: () async {
                            if (User.latitude != 0) {
                              _getLocation();
                              String currentTime =
                                  DateFormat('HH:mm').format(DateTime.now());

                              QuerySnapshot snap = await FirebaseFirestore
                                  .instance
                                  .collection("employee")
                                  .where('id', isEqualTo: User.employeeid)
                                  .get();

                              // Vérifiez si le document existe
                              DocumentSnapshot snap2 = await FirebaseFirestore
                                  .instance
                                  .collection("employee")
                                  .doc(snap.docs[0].id)
                                  .collection("Record")
                                  .doc(DateFormat('dd MMMM yyyy')
                                      .format(DateTime.now()))
                                  .get();

                              if (snap2.exists) {
                                if (checkIn == "--/--") {
                                  setState(() {
                                    checkIn = currentTime;
                                  });

                                  await FirebaseFirestore.instance
                                      .collection("employee")
                                      .doc(snap.docs[0].id)
                                      .collection("Record")
                                      .doc(DateFormat('dd MMMM yyyy')
                                          .format(DateTime.now()))
                                      .update({
                                    'date': Timestamp.now(),
                                    'checkIn': currentTime,
                                    'checkInLocation': location,
                                  });
                                } else {
                                  setState(() {
                                    checkOut = currentTime;
                                  });

                                  await FirebaseFirestore.instance
                                      .collection("employee")
                                      .doc(snap.docs[0].id)
                                      .collection("Record")
                                      .doc(DateFormat('dd MMMM yyyy')
                                          .format(DateTime.now()))
                                      .update({
                                    'date': Timestamp.now(),
                                    'checkOut': currentTime,
                                    'checkOutLocation': location,
                                  });
                                }
                              } else {
                                // Le document n'existe pas, créez-le
                                await FirebaseFirestore.instance
                                    .collection("employee")
                                    .doc(snap.docs[0].id)
                                    .collection("Record")
                                    .doc(DateFormat('dd MMMM yyyy')
                                        .format(DateTime.now()))
                                    .set({
                                  'checkIn':
                                      checkIn == "--/--" ? currentTime : null,
                                  'checkOut':
                                      checkOut == "--/--" ? currentTime : null,
                                  'checkInLocation': location,
                                  'checkOutLocation': location,
                                  'date': Timestamp.now(),
                                });
                              }

                              // Mettre à jour l'interface utilisateur
                              setState(() {});

                              final slideActionState =
                                  slideActionKey.currentState;
                              if (slideActionState != null &&
                                  slideActionState.mounted) {
                                slideActionState.reset();
                              }
                            } else {
                              // Votre code si la latitude est égale à 0
                            }
                          },
                        );
                      },
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.only(top: 32, bottom: 32),
                    child: Text(
                      "you have completed this day!",
                      style: TextStyle(
                        fontFamily: "NexaRegular",
                        fontSize: screenWidth / 18,
                        color: Colors.black54,
                      ),
                    ),
                  ),
            location != " "
                ? Text(
                    "Location: $location",
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
