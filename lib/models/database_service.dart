import 'models.dart';

import 'dart:async';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  // In-memory storage
  final Map<String, User> _users = {};
  final List<Room> _rooms = [];
  final List<Booking> _bookings = [];
  final List<Zone> _zones = [];
  User? _currentUser;

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  void initializeData() {
    if (_rooms.isEmpty) {
      _initializeRooms();
    }

    if (_zones.isEmpty) {
      _initializeZones();
    }

    if (_users.isEmpty) {
      _initializeUsers();
    }
  }

  // ============================================================================
  // AUTHENTICATION
  // ============================================================================

  Future<User?> loginUser({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    initializeData();

    try {
      final user = _users.values.firstWhere(
        (u) => u.email == email && u.password == password,
      );
      _currentUser = user;
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<User?> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    initializeData();

    if (_users.values.any((u) => u.email == email)) {
      return null;
    }

    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      role: role,
    );

    _users[newUser.id] = newUser;
    _currentUser = newUser;
    return newUser;
  }

  Future<void> createUser(User user) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _users[user.id] = user;
  }

  Future<void> deleteUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _users.remove(userId);
  }

  void logout() {
    _currentUser = null;
  }

  User? getCurrentUser() => _currentUser;

  Future<List<User>> getAllUsers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    initializeData();
    return _users.values.toList();
  }

  // ============================================================================
  // ROOMS
  // ============================================================================

  Future<List<Room>> getAllRooms() async {
    await Future.delayed(const Duration(milliseconds: 300));
    initializeData();
    return _rooms;
  }

  Future<Room?> getRoom(String roomId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    initializeData();

    try {
      return _rooms.firstWhere((r) => r.id == roomId);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateRoomStatus(
    String roomId,
    RoomStatus status, {
    DateTime? maintenanceUntil,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _rooms.indexWhere((r) => r.id == roomId);
    if (index != -1) {
      final room = _rooms[index];
      _rooms[index] = Room(
        id: room.id,
        name: room.name,
        image: room.image,
        price: room.price,
        rating: room.rating,
        description: room.description,
        status: status,
        capacity: room.capacity,
        amenities: room.amenities,
        zoneId: room.zoneId,
        maintenanceUntil: maintenanceUntil,
      );
    }
  }

  // ✨ NEW METHOD: Search rooms with filters
  Future<List<Room>> searchRooms({
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    String? zoneId,
    double? minPrice,
    double? maxPrice,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    initializeData();

    List<Room> filteredRooms = List.from(_rooms);

    // Filter by zone if specified
    if (zoneId != null) {
      filteredRooms = filteredRooms.where((r) => r.zoneId == zoneId).toList();
    }

    // Filter by price range
    if (minPrice != null) {
      filteredRooms = filteredRooms.where((r) => r.price >= minPrice).toList();
    }
    if (maxPrice != null) {
      filteredRooms = filteredRooms.where((r) => r.price <= maxPrice).toList();
    }

    // Filter by availability (only available or occupied rooms, not maintenance)
    filteredRooms = filteredRooms
        .where((r) => r.status == RoomStatus.available || r.status == RoomStatus.occupied)
        .toList();

    // Filter by capacity (room must accommodate guests)
    filteredRooms = filteredRooms.where((r) => r.capacity >= guests).toList();

    return filteredRooms;
  }

  // ============================================================================
  // BOOKINGS
  // ============================================================================

  Future<void> createBooking(Booking booking) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _bookings.add(booking);
  }

  Future<List<Booking>> getAllBookings() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _bookings;
  }

  Future<List<Booking>> getGuestBookings(String guestId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _bookings.where((b) => b.guestId == guestId).toList();
  }

  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final booking = _bookings[index];
      _bookings[index] = Booking(
        id: booking.id,
        guestId: booking.guestId,
        roomId: booking.roomId,
        roomName: booking.roomName,
        guestName: booking.guestName,
        specialRequests: booking.specialRequests,
        checkIn: booking.checkIn,
        checkOut: booking.checkOut,
        status: status,
        totalPrice: booking.totalPrice,
        numberOfGuests: booking.numberOfGuests,
        createdAt: booking.createdAt,
      );
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    await updateBookingStatus(bookingId, BookingStatus.cancelled);
  }

  /// Updates an entire booking with new details
  Future<void> updateBooking(Booking updatedBooking) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _bookings.indexWhere((b) => b.id == updatedBooking.id);
    if (index != -1) {
      _bookings[index] = updatedBooking;
    }
  }

  /// Updates specific booking fields
  Future<void> updateBookingDetails({
    required String bookingId,
    DateTime? checkIn,
    DateTime? checkOut,
    String? roomId,
    String? roomName,
    int? numberOfGuests,
    double? totalPrice,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final booking = _bookings[index];

      _bookings[index] = Booking(
        id: booking.id,
        guestId: booking.guestId,
        roomId: roomId ?? booking.roomId,
        roomName: roomName ?? booking.roomName,
        guestName: booking.guestName,
        specialRequests: booking.specialRequests,
        checkIn: checkIn ?? booking.checkIn,
        checkOut: checkOut ?? booking.checkOut,
        status: booking.status,
        totalPrice: totalPrice ?? booking.totalPrice,
        numberOfGuests: numberOfGuests ?? booking.numberOfGuests,
        createdAt: booking.createdAt,
      );
    }
  }

  // ============================================================================
  // ZONES
  // ============================================================================

  Future<List<Zone>> getAllZones() async {
    await Future.delayed(const Duration(milliseconds: 300));
    initializeData();
    return _zones;
  }

  Future<Zone?> getZone(String zoneId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    initializeData();

    try {
      return _zones.firstWhere((z) => z.id == zoneId);
    } catch (e) {
      return null;
    }
  }

  // ============================================================================
  // ANALYTICS
  // ============================================================================

  Future<HotelAnalytics> getAnalytics() async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      int totalBookings = _bookings.length;
      double totalRevenue = 0;
      int occupiedRooms = 0;
      double totalRating = 0;
      int ratedRooms = 0;

      for (var booking in _bookings) {
        totalRevenue += booking.totalPrice;
      }

      for (var room in _rooms) {
        if (room.status == RoomStatus.occupied) occupiedRooms++;
        if (room.rating > 0) {
          totalRating += room.rating;
          ratedRooms++;
        }
      }

      final occupancyRate =
          _rooms.isNotEmpty ? ((occupiedRooms / _rooms.length) * 100).toInt() : 0;
      final averageRating = ratedRooms > 0 ? totalRating / ratedRooms : 0.0;

      return HotelAnalytics(
        totalBookings: totalBookings,
        totalRevenue: totalRevenue.toInt(),
        occupancyRate: occupancyRate,
        averageRating: averageRating,
        totalRooms: _rooms.length,
        occupiedRooms: occupiedRooms,
      );
    } catch (e) {
      return HotelAnalytics(
        totalBookings: 0,
        totalRevenue: 0,
        occupancyRate: 0,
        averageRating: 0.0,
        totalRooms: 0,
        occupiedRooms: 0,
      );
    }
  }

  // ============================================================================
  // STAFF LOGS
  // ============================================================================

  Future<void> saveStaffActionLog(Map<String, dynamic> log) async {
    await Future.delayed(const Duration(milliseconds: 300));
    print('Staff Action Logged: $log');
  }

  Future<List<Map<String, dynamic>>> getStaffActionLogs() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [];
  }

  // ============================================================================
  // INITIALIZE
  // ============================================================================

  void _initializeUsers() {
    _users.addAll({
      'manager_1': User(
        id: 'manager_1',
        firstName: 'Ahmed',
        lastName: 'Smith',
        email: 'manager@sphinxhotel.com',
        password: 'password123',
        role: UserRole.manager,
      ),
      'staff_1': User(
        id: 'staff_1',
        firstName: 'John',
        lastName: 'Johnson',
        email: 'staff@sphinxhotel.com',
        password: 'password123',
        role: UserRole.staff,
      ),
      'guest_1': User(
        id: 'guest_1',
        firstName: 'Alice',
        lastName: 'Williams',
        email: 'guest@example.com',
        password: 'password123',
        role: UserRole.guest,
      ),
      'guest_2': User(
        id: 'guest_2',
        firstName: 'Bob',
        lastName: 'Brown',
        email: 'bob@example.com',
        password: 'password123',
        role: UserRole.guest,
      ),
    });
  }

  void _initializeRooms() {
    _rooms.addAll([
      Room(
        id: 'room_1',
        name: 'Standard Room',
        image: 'assets/room1.jpg',
        price: 150,
        rating: 4.5,
        description: 'Comfortable room with all basic amenities',
        status: RoomStatus.available,
        capacity: 2,
        amenities: ['WiFi', 'AC', 'TV'],
        zoneId: 'zone_1',
      ),
      Room(
        id: 'room_2',
        name: 'Deluxe Room',
        image: 'assets/room2.jpg',
        price: 250,
        rating: 4.7,
        description: 'Spacious deluxe room with premium amenities',
        status: RoomStatus.occupied,
        capacity: 2,
        amenities: ['WiFi', 'AC', 'TV', 'Mini Bar'],
        zoneId: 'zone_2',
      ),
      Room(
        id: 'room_3',
        name: 'Suite',
        image: 'assets/room3.jpg',
        price: 200,
        rating: 4.3,
        description: 'Elegant suite with separate living area',
        status: RoomStatus.available,
        capacity: 2,
        amenities: ['WiFi', 'AC', 'TV'],
        zoneId: 'zone_1',
      ),
      Room(
        id: 'room_4',
        name: 'Ocean View Suite',
        image: 'assets/room4.jpg',
        price: 350,
        rating: 4.9,
        description: 'Beautiful ocean view suite',
        status: RoomStatus.available,
        capacity: 3,
        amenities: ['WiFi', 'AC', 'TV', 'Balcony'],
        zoneId: 'zone_3',
      ),
    ]);
  }

  void _initializeZones() {
    _zones.addAll([
      Zone(
        id: 'zone_1',
        name: 'Downtown',
        description: 'City center location',
        image: 'assets/zone1.jpg',
        restriction: 'no_restriction',
        roomIds: ['room_1', 'room_3'],
      ),
      Zone(
        id: 'zone_2',
        name: 'Seafront',
        description: 'Beachfront luxury',
        image: 'assets/zone2.jpg',
        restriction: 'adults_only',
        roomIds: ['room_2'],
      ),
      Zone(
        id: 'zone_3',
        name: 'Resort',
        description: 'All-inclusive resort',
        image: 'assets/zone3.jpg',
        restriction: 'couples_only',
        roomIds: ['room_4'],
      ),
    ]);
  }
}
