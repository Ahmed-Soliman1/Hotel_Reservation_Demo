import 'package:flutter/material.dart';

// ============ USER MODEL ============

enum UserRole { guest, staff, manager }

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final UserRole role;
  final DateTime createdAt;
  final bool isActive;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.role,
    DateTime? createdAt,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'role': role.toString(),
        'createdAt': createdAt.toIso8601String(),
        'isActive': isActive,
      };

  static User fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        email: json['email'],
        password: json['password'],
        role: UserRole.values.firstWhere(
          (e) => e.toString() == json['role'],
          orElse: () => UserRole.guest,
        ),
        createdAt: DateTime.parse(json['createdAt']),
        isActive: json['isActive'] ?? true,
      );

  String get fullName => '$firstName $lastName';
}

// ============ ROOM MODEL ============

enum RoomStatus { available, occupied, booked, maintenance, cleaning }

class Room {
  final String id;
  final String name;
  final String image;
  final double price;
  final double rating;
  final String description;
  final RoomStatus status;
  final int capacity;
  final List<String> amenities;
  final String zoneId;
  final DateTime? maintenanceUntil; // NEW: Track when maintenance ends

  Room({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.rating,
    required this.description,
    this.status = RoomStatus.available,
    required this.capacity,
    required this.amenities,
    required this.zoneId,
    this.maintenanceUntil,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': image,
        'price': price,
        'rating': rating,
        'description': description,
        'status': status.toString(),
        'capacity': capacity,
        'amenities': amenities,
        'zoneId': zoneId,
        'maintenanceUntil': maintenanceUntil?.toIso8601String(),
      };

  static Room fromJson(Map<String, dynamic> json) => Room(
        id: json['id'],
        name: json['name'],
        image: json['image'],
        price: json['price'].toDouble(),
        rating: json['rating'].toDouble(),
        description: json['description'],
        status: RoomStatus.values.firstWhere(
          (e) => e.toString() == json['status'],
          orElse: () => RoomStatus.available,
        ),
        capacity: json['capacity'],
        amenities: List<String>.from(json['amenities'] ?? []),
        zoneId: json['zoneId'],
        maintenanceUntil: json['maintenanceUntil'] != null
            ? DateTime.parse(json['maintenanceUntil'])
            : null,
      );
}

// ============ BOOKING MODEL ============

enum BookingStatus { pending, confirmed, checkedIn, checkedOut, cancelled }

class Booking {
  final String id;
  final String guestId;
  final String roomId;
  final String? roomName;
  final String? guestName;
  final String? specialRequests;
  final DateTime checkIn;
  final DateTime checkOut;
  final BookingStatus status;
  final double totalPrice;
  final int numberOfGuests;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.guestId,
    required this.roomId,
    this.roomName,
    this.guestName,
    this.specialRequests,
    required this.checkIn,
    required this.checkOut,
    this.status = BookingStatus.pending,
    required this.totalPrice,
    required this.numberOfGuests,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'guestId': guestId,
        'roomId': roomId,
        'roomName': roomName,
        'guestName': guestName,
        'specialRequests': specialRequests,
        'checkIn': checkIn.toIso8601String(),
        'checkOut': checkOut.toIso8601String(),
        'status': status.toString(),
        'totalPrice': totalPrice,
        'numberOfGuests': numberOfGuests,
        'createdAt': createdAt.toIso8601String(),
      };

  static Booking fromJson(Map<String, dynamic> json) => Booking(
        id: json['id'],
        guestId: json['guestId'],
        roomId: json['roomId'],
        roomName: json['roomName'],
        guestName: json['guestName'],
        specialRequests: json['specialRequests'],
        checkIn: DateTime.parse(json['checkIn']),
        checkOut: DateTime.parse(json['checkOut']),
        status: BookingStatus.values.firstWhere(
          (e) => e.toString() == json['status'],
          orElse: () => BookingStatus.pending,
        ),
        totalPrice: json['totalPrice'].toDouble(),
        numberOfGuests: json['numberOfGuests'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  int get numberOfNights => checkOut.difference(checkIn).inDays;
}

// ============ ZONE MODEL ============

class Zone {
  final String id;
  final String name;
  final String description;
  final String image;
  final String restriction;
  final List<String> roomIds;

  Zone({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.restriction,
    required this.roomIds,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'image': image,
        'restriction': restriction,
        'roomIds': roomIds,
      };

  static Zone fromJson(Map<String, dynamic> json) => Zone(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        image: json['image'],
        restriction: json['restriction'],
        roomIds: List<String>.from(json['roomIds'] ?? []),
      );
}

// ============ REVIEW MODEL ============

class Review {
  final String id;
  final String bookingId;
  final String guestId;
  final String roomId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.bookingId,
    required this.guestId,
    required this.roomId,
    required this.rating,
    required this.comment,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookingId': bookingId,
        'guestId': guestId,
        'roomId': roomId,
        'rating': rating,
        'comment': comment,
        'createdAt': createdAt.toIso8601String(),
      };

  static Review fromJson(Map<String, dynamic> json) => Review(
        id: json['id'],
        bookingId: json['bookingId'],
        guestId: json['guestId'],
        roomId: json['roomId'],
        rating: json['rating'].toDouble(),
        comment: json['comment'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}

// ============ HOTEL ANALYTICS MODEL ============

class HotelAnalytics {
  final int totalBookings;
  final int totalRevenue;
  final int occupancyRate;
  final double averageRating;
  final int totalRooms;
  final int occupiedRooms;

  HotelAnalytics({
    required this.totalBookings,
    required this.totalRevenue,
    required this.occupancyRate,
    required this.averageRating,
    required this.totalRooms,
    required this.occupiedRooms,
  });

  Map<String, dynamic> toJson() => {
        'totalBookings': totalBookings,
        'totalRevenue': totalRevenue,
        'occupancyRate': occupancyRate,
        'averageRating': averageRating,
        'totalRooms': totalRooms,
        'occupiedRooms': occupiedRooms,
      };

  static HotelAnalytics fromJson(Map<String, dynamic> json) => HotelAnalytics(
        totalBookings: json['totalBookings'] ?? 0,
        totalRevenue: json['totalRevenue'] ?? 0,
        occupancyRate: json['occupancyRate'] ?? 0,
        averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
        totalRooms: json['totalRooms'] ?? 0,
        occupiedRooms: json['occupiedRooms'] ?? 0,
      );
}

// ============ STAFF ACTION LOG MODEL ============

class StaffActionLog {
  final String id;
  final String staffId;
  final String staffName;
  final String action;
  final String roomId;
  final String roomName;
  final String details;
  final DateTime timestamp;

  StaffActionLog({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.action,
    required this.roomId,
    required this.roomName,
    required this.details,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'staffId': staffId,
        'staffName': staffName,
        'action': action,
        'roomId': roomId,
        'roomName': roomName,
        'details': details,
        'timestamp': timestamp.toIso8601String(),
      };

  static StaffActionLog fromJson(Map<String, dynamic> json) => StaffActionLog(
        id: json['id'],
        staffId: json['staffId'],
        staffName: json['staffName'],
        action: json['action'],
        roomId: json['roomId'],
        roomName: json['roomName'],
        details: json['details'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}
