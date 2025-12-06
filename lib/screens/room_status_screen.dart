import 'package:flutter/material.dart';
import 'room.dart';
import 'package:hotel_reservation_demo/models/database_service.dart';


class RoomStatusScreen extends StatefulWidget {
  const RoomStatusScreen({Key? key}) : super(key: key);

  @override
  _RoomStatusScreenState createState() => _RoomStatusScreenState();
}

class _RoomStatusScreenState extends State<RoomStatusScreen> {
  List<Room> rooms = [];

  Future<void> updateRoomStatus(String roomId, String status) async {
    Room? room = rooms.firstWhere((r) => r.id == roomId, orElse: () => null);
    if (room != null) {
      room.status = status;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Room Status')),
      body: ListView.builder(
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          Room room = rooms[index];
          return ListTile(
            title: Text(room.name),
            subtitle: Text('Status: ${room.status}'),
            trailing: DropdownButton<String>(
              value: room.status,
              items: ['available', 'occupied', 'maintenance'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                updateRoomStatus(room.id, newValue!);
              },
            ),
          );
        },
      ),
    );
  }
}

