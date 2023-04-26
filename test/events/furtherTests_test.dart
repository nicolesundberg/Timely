import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:timely/event_models/EventModel.dart';
import 'package:timely/event_models/GoogleEvent.dart';
import 'package:timely/event_models/MicrosoftEvent.dart';
import 'package:http/http.dart';
import 'package:googleapis/calendar/v3.dart' as googleAPI;

import 'package:timely/controllers/account_controller.dart';
import 'package:timely/models/calendar_model.dart';


void main() {

  test('dateTimeParse', () async {
    String testDate = "8/11/2014";
    List<String> dateParts = testDate.split('/');
    //String testDateNew = "${dateParts[2]}-${dateParts[1]}-${dateParts[0]}";
    // print(testDateNew);
    // String testDate2 = testDate.replaceAll(RegExp('/'), '-');
    // String testDate3 = testDate2 + " 20:18:04Z";
    //String testDateNew2 = testDateNew + " 20:18:04Z";

    DateTime? test = DateTime.tryParse(testDate);
    // DateTime? test2 = DateTime.tryParse(testDateNew);
    // DateTime? test3 = DateTime.tryParse(testDateNew2);

    // DateTime? test2 = DateTime.tryParse(testDate2);
    // DateTime? test3 = DateTime.tryParse(testDate3);

    print(testDate + "    " + test.toString());
    // print(testDateNew + "    " + test2.toString());
    // print(testDateNew2 + "    " + test3.toString());
    // print(testDate2 + "    " + test2.toString());
    // print(testDate3 + "    " + test3.toString());

    String newDate = "";
    //newDate += dateParts[2] + "-";
    if(int.parse(dateParts[1]) < 10)
    {
      dateParts[1] = "0"+dateParts[1];
    }
    if(int.parse(dateParts[0]) < 10)
    {
      dateParts[0] = "0"+dateParts[0];
    }
    String testDateNew = "${dateParts[2]}-${dateParts[1]}-${dateParts[0]}";
    DateTime? test2 = DateTime.tryParse(testDateNew);
    print(testDateNew + "    " + test2.toString());

    print(EventModel.validateRecurrenceDate(testDate));
    String other = "12/13/14/15";
    print(other + EventModel.validateRecurrenceDate(other).toString());

    other = "12/1";
    print(other + EventModel.validateRecurrenceDate(other).toString());

    other = "11/12/2025";
    print(other + EventModel.validateRecurrenceDate(other).toString());

  });

  test('recurrenceRuleTesting', () async {

    String r1 = "FREQ=DAILY;INTERVAL=1";
    String r2 = "FREQ=DAILY;INTERVAL=1;COUNT=10";
    String r3 = "FREQ=DAILY;INTERVAL=1;UNTIL=8/25/2014";
    String r4 = "FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,WE;COUNT=10";
    String r5 = "FREQ=MONTHLY;BYMONTHDAY=3;INTERVAL=1;COUNT=10";
    String r6 = "FREQ=YEARLY;BYMONTHDAY=16;BYMONTH=6;INTERVAL=1;COUNT=10";
    String r7 = "FREQ=MONTHLY;BYDAY=MO;BYSETPOS=2;UNTIL=8/11/2014";
    String r8 = "FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR;COUNT=10;EXDATE=6/18/2014,6/20/2014;RECUREDITID=1651";
    String r9 = "FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR;COUNT=10;EXDATE=6/18/2014,6/20/2014;RECUREDITID=1651";
    String r10 = "FREQ=DAILY; INTERVAL=1; COUNT=5";
    String r11 = "FREQ=DAILY; INTERVAL=1; UNTIL=12/26/2014";
    String r12 = "FREQ=DAILY; INTERVAL=2; COUNT=10";
    String empty = "";
    print(r1 + "\t" +EventModel.isValidRecurrenceRule(r1).toString());
    print(r2 + "\t" +EventModel.isValidRecurrenceRule(r2).toString());
    print(r3 + "\t" +EventModel.isValidRecurrenceRule(r3).toString());
    print(r4 + "\t" +EventModel.isValidRecurrenceRule(r4).toString());
    print(r5 + "\t" +EventModel.isValidRecurrenceRule(r5).toString());
    print(r6 + "\t" +EventModel.isValidRecurrenceRule(r6).toString());
    print(r7 + "\t" +EventModel.isValidRecurrenceRule(r7).toString());
    print(r8 + "\t" +EventModel.isValidRecurrenceRule(r8).toString());
    print(r9 + "\t" +EventModel.isValidRecurrenceRule(r9).toString());
    print(r10 + "\t" +EventModel.isValidRecurrenceRule(r10).toString());
    print(r11 + "\t" +EventModel.isValidRecurrenceRule(r11).toString());
    print(r12 + "\t" +EventModel.isValidRecurrenceRule(r12).toString());


    print("\'\'" + "\t" +EventModel.isValidRecurrenceRule(empty).toString());

    //print(other + EventModel.validateRecurrenceDate(other).toString());

  });

  test('dateCheck', ()async
  {
    String testDate1 = "20190601T095959Z";
    DateTime testDateTime1 = DateTime.parse(testDate1);
    print(testDateTime1.toString());


  });

  test('moreRecurrence', ()async
  {
    String test1 = "RRULE:FREQ=WEEKLY;UNTIL=20190601T095959Z;BYDAY=FR";
    print(test1 + "\t" +EventModel.isValidRecurrenceRule(test1).toString());
    String test2 = 'FREQ=WEEKLY;COUNT=15';
    print(test2 + "\t" +EventModel.isValidRecurrenceRule(test2).toString());

  });

}