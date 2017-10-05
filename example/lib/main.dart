import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:calendar/calendar.dart';
import 'package:calendar/controllers.dart';

Widget appBar = new AppBar(title: new Text('Calendar Example'), backgroundColor: Colors.blue[500]);
ThemeData theme = new ThemeData(primarySwatch: Colors.blue);

///
/// INFO(mperrotte):
/// - Define the model class that will represent your data.
/// - Extend the DataModel for functionality and type checking
class Event extends DataModel {
  Event(
    Map<String, dynamic> data,
  )
      : id = data['id'],
        title = data['title'],
        url = data['url'],
        start = DateTime.parse(data['date_start']),
        end = DateTime.parse(data['date_end']),
        details = data['details'],
        super(
          year: DateTime.parse(data['date_start']).year,
          month: DateTime.parse(data['date_start']).month,
          date: DateTime.parse(data['date_start']).day,
        );

  final int id;
  final String title;
  final String url;
  final DateTime start;
  final DateTime end;
  final dynamic details;
}

EventsView renderEventsHandler(List<DataModel> events, Map<String, int> currentDay) {
  if (events.length == 0) {
    // TODO(mperrotte): handle empty list
  }

  List<DataModel> eventsByDate = reduceEvents(events, currentDay);
  List<Event> filteredEvents = new List.from(eventsByDate);

  return new EventsView(
    itemCount: filteredEvents.length,
    itemBuilder: (BuildContext context, int index) {
      return new Dismissible(
        key: new ObjectKey(filteredEvents[index]),
        direction: DismissDirection.horizontal,
        onDismissed: (DismissDirection direction) {},
        background: new Container(
          decoration: new BoxDecoration(
            color: theme.primaryColor,
          ),
          child: new ListTile(
            leading: new Icon(
              Icons.input,
              color: Colors.white,
              size: 36.0,
            ),
          ),
        ),
        child: new Container(
          decoration: new BoxDecoration(
            color: theme.canvasColor,
            border: new Border(
              bottom: new BorderSide(color: theme.dividerColor),
            ),
          ),
          child: new ListTile(
            title: new Text(filteredEvents[index].title),
            subtitle: new Text(filteredEvents[index].url),
            isThreeLine: true,
          ),
        ),
      );
    },
  );
}

dynamic fetchDataHandler(String uri) async {
  Response response = await get(uri);
  String json = response.body;
  if (json == null) {
    // NOTE(mperrotte): no body value from response; bail out;
    return null;
  }
  JsonDecoder decoder = new JsonDecoder();
  try {
    dynamic payload = decoder.convert(json);
    return payload;
  } on ArgumentError {
    // NOTE(mperrotte): unable to decode json payload
    return null;
  }
}

List<Event> parseDataHandler(List<Map<String, dynamic>> payload) {
  List<Event> events = new List<Event>();
  for (Map<String, dynamic> item in payload) {
    events.add(new Event(item));
  }
  return events;
}

String getUriHandler() {
  return 'https://gist.githubusercontent.com/mikemimik/2da9df7ca94f0bdfd493bf70e53ec3b6/raw/f4e0fe43219b02091f4eec79ebd10e37185e213d/data-events.json';
}

CalendarController calendarController = new CalendarController(
  renderEvents: renderEventsHandler,
);
DataController dataController = new DataController(
  fetchData: fetchDataHandler,
  parseData: parseDataHandler,
  getUri: getUriHandler,
);

void main() {
  debugPaintSizeEnabled = false;

  runApp(
    new MaterialApp(
      title: 'Calendar Example',
      theme: theme,
      home: new Scaffold(
        appBar: appBar,
        body: new Calendar(
          calendarController: calendarController,
          dataController: dataController,
        ),
      ),
    ),
  );
}