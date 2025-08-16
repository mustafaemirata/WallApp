//format dönüşümü yap
import 'package:cloud_firestore/cloud_firestore.dart';

String formatData(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();

  //get year

  String year = dateTime.year.toString();

  //get month

  String month = dateTime.month.toString();

  //get day

  String day = dateTime.day.toString();

  String _formatted = day + '/' + month + "/" + year;
  return _formatted;
}
