import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb; 
import 'dart:convert';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBD_maEZsl-ETQEE5n4SsN8ihRnOyeaNio", 
        authDomain: "smart-parking-kampus.firebaseapp.com",
        projectId: "smart-parking-kampus",
        storageBucket: "smart-parking-kampus.firebasestorage.app",
        messagingSenderId: "89412940976",
        appId: "1:89412940976:web:d3a606f7e3f110c0c6b775",
        measurementId: "G-F81L2Q6BP1",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  
  runApp(const SmartParkingApp());
}

class SmartParkingApp extends StatelessWidget {
  const SmartParkingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Parking Unila',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const LoginScreen(),
    );
  }
}

// ==========================================
// 1. HALAMAN LOGIN (SISTEM DATABASE NYATA)
// ==========================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _npmController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_npmController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      setState(() => _isLoading = true);
      
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(_npmController.text).get();
        
        if (userDoc.exists) {
          if (userDoc.get('password') == _passwordController.text) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('logged_in_npm', _npmController.text);
            
            if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password salah!'), backgroundColor: Colors.red));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Akun tidak ditemukan. Silakan Daftar dulu!'), backgroundColor: Colors.orange));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal terhubung ke server.')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap isi NPM dan Password!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.blue[400]!, Colors.indigo[600]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
              ),
              child: const Opacity(opacity: 0.1),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 110, height: 110,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.blue[600]!, Colors.indigo[500]!]),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
                    ),
                    child: const Icon(Icons.local_parking, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  const Text('Smart Parking', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const Text('Universitas Lampung', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 48),
                  
                  TextField(controller: _npmController, decoration: InputDecoration(labelText: 'NPM Mahasiswa', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), prefixIcon: const Icon(Icons.badge, color: Colors.blue)), keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  TextField(controller: _passwordController, obscureText: true, decoration: InputDecoration(labelText: 'Password', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), prefixIcon: const Icon(Icons.lock, color: Colors.blue))),
                  const SizedBox(height: 24),
                  
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo[600], padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 5),
                    child: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Masuk Sekarang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Belum punya akun? ", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                        },
                        child: Text("Daftar di sini", style: TextStyle(color: Colors.blue[600], fontWeight: FontWeight.bold)),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. HALAMAN REGISTRASI (SISTEM DATABASE NYATA)
// ==========================================
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _namaController = TextEditingController();
  final _npmController = TextEditingController();
  final _platController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    if (_namaController.text.isNotEmpty && _npmController.text.isNotEmpty && _platController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        await FirebaseFirestore.instance.collection('users').doc(_npmController.text).set({
          'nama': _namaController.text,
          'npm': _npmController.text,
          'plat': _platController.text,
          'password': _passwordController.text,
          'fakultas': 'Fakultas Teknik',
        });
        
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pendaftaran Berhasil! Silakan masuk.'), backgroundColor: Colors.green));
        if (mounted) Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mendaftar: $e'), backgroundColor: Colors.red));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua kolom wajib diisi!'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.indigo[500]!, Colors.blue[600]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
              ),
              child: const Opacity(opacity: 0.1),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Buat Akun Baru', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const Text('Lengkapi data untuk akses parkir', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 40),
                  
                  TextField(controller: _namaController, decoration: InputDecoration(labelText: 'Nama Lengkap', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), prefixIcon: const Icon(Icons.person, color: Colors.blue))),
                  const SizedBox(height: 16),
                  TextField(controller: _npmController, decoration: InputDecoration(labelText: 'NPM Mahasiswa', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), prefixIcon: const Icon(Icons.badge, color: Colors.blue)), keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  TextField(controller: _platController, decoration: InputDecoration(labelText: 'Plat Kendaraan (Cth: BE 1234 XX)', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), prefixIcon: const Icon(Icons.motorcycle, color: Colors.blue))),
                  const SizedBox(height: 16),
                  TextField(controller: _passwordController, obscureText: true, decoration: InputDecoration(labelText: 'Buat Password', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), prefixIcon: const Icon(Icons.lock, color: Colors.blue))),
                  const SizedBox(height: 32),
                  
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 5),
                    child: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Daftar Akun', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Sudah punya akun? ", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text("Masuk di sini", style: TextStyle(color: Colors.blue[600], fontWeight: FontWeight.bold)),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. HALAMAN INDUK (BOTTOM NAV BAR)
// ==========================================
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [const MapScreen(), const HistoryScreen(), const ReportScreen(), const ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))]),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, backgroundColor: Colors.white, currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: Colors.blue[600], unselectedItemColor: Colors.grey[400],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11), unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Peta'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
            BottomNavigationBarItem(icon: Icon(Icons.report_problem), label: 'Lapor'),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 4. HALAMAN PETA
// ==========================================
class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  static const LatLng _unilaCoord = LatLng(-5.364303, 105.243467);

  LatLng _currentCoord = _unilaCoord;
  bool _isParked = false;
  LatLng? _parkedLocation;
  
  String _statusMessage = "Mencari lokasi...";
  IconData _statusIcon = Icons.gps_fixed;
  Color _statusColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndGetLocation();
    _loadSavedParking();
  }

  Future<void> _checkPermissionsAndGetLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    _updateCurrentLocation();
  }

  Future<void> _updateCurrentLocation() async {
    setState(() { _statusMessage = "Melacak lokasi..."; _statusIcon = Icons.hourglass_empty; });
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          _currentCoord = LatLng(position.latitude, position.longitude);
          if (!_isParked) { _statusMessage = "Akurat. Siap memarkir."; _statusIcon = Icons.location_on; _statusColor = Colors.blue[600]!; }
        });
        _mapController.move(_currentCoord, 18.0);
      }
    } catch (e) {}
  }

  Future<void> _saveParking() async {
    final prefs = await SharedPreferences.getInstance();
    LatLng parkedPoint = LatLng(_currentCoord.latitude + 0.0005, _currentCoord.longitude - 0.0005);
    Map<String, dynamic> parkingData = {'lat': parkedPoint.latitude, 'lng': parkedPoint.longitude};
    await prefs.setString('active_parking', jsonEncode(parkingData));

    await _saveToFirebaseDatabase(parkedPoint);

    setState(() {
      _isParked = true; _parkedLocation = parkedPoint;
      _statusMessage = "Kendaraan aman terparkir."; _statusIcon = Icons.security; _statusColor = Colors.indigo[600]!;
    });
  }

  Future<void> _saveToFirebaseDatabase(LatLng point) async {
    final prefs = await SharedPreferences.getInstance();
    String loggedInNpm = prefs.getString('logged_in_npm') ?? 'Guest';
    
    DateTime now = DateTime.now();
    String dateStr = "${now.day}-${now.month}-${now.year}";
    String timeStr = "${now.hour}:${now.minute.toString().padLeft(2, '0')}";

    await FirebaseFirestore.instance.collection('riwayat_parkir').add({
      'npm': loggedInNpm,
      'location': "Titik Parkir: ${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}",
      'date': dateStr,
      'time': timeStr,
      'lat': point.latitude,
      'lng': point.longitude,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _loadSavedParking() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedDataString = prefs.getString('active_parking');
    if (savedDataString != null) {
      Map<String, dynamic> data = jsonDecode(savedDataString);
      setState(() {
        _isParked = true; _parkedLocation = LatLng(data['lat'], data['lng']);
        _statusMessage = "Kendaraan aman terparkir."; _statusIcon = Icons.security; _statusColor = Colors.indigo[600]!;
      });
      _mapController.move(_parkedLocation!, 18.0);
    } else {
       setState(() { _statusMessage = "Akurat. Siap memarkir."; _statusIcon = Icons.location_on; _statusColor = Colors.blue[600]!; });
    }
  }

  void _findVehicle() {
    if (_parkedLocation == null) return;
    LatLng center = LatLng((_currentCoord.latitude + _parkedLocation!.latitude) / 2, (_currentCoord.longitude + _parkedLocation!.longitude) / 2);
    _mapController.move(center, 17.0);
    setState(() { _statusMessage = "Ikuti rute ke kendaraan."; _statusIcon = Icons.directions_walk; _statusColor = Colors.indigo[600]!; });
  }

  Future<void> _clearParking() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('active_parking');
    setState(() { _isParked = false; _parkedLocation = null; _statusMessage = "Akurat. Siap memarkir."; _statusIcon = Icons.location_on; _statusColor = Colors.blue[600]!; });
    _mapController.move(_currentCoord, 18.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: _unilaCoord, initialZoom: 16.0),
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
              if (_isParked && _parkedLocation != null) PolylineLayer(polylines: [Polyline(points: [_currentCoord, _parkedLocation!], color: Colors.indigo[500]!, strokeWidth: 5.0, isDotted: true)]),
              MarkerLayer(
                markers: [
                  Marker(point: _currentCoord, width: 60, height: 60, child: Container(decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), shape: BoxShape.circle), child: Center(child: Container(width: 20, height: 20, decoration: BoxDecoration(color: Colors.blue, border: Border.all(color: Colors.white, width: 3), shape: BoxShape.circle))))),
                  if (_isParked && _parkedLocation != null) Marker(point: _parkedLocation!, width: 50, height: 50, child: const Icon(Icons.location_on, color: Colors.indigo, size: 50)),
                ],
              ),
            ],
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 16),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.9)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Peta Parkir", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle), child: Icon(Icons.notifications, color: Colors.blue[700], size: 20))
                ],
              ),
            ),
          ),
          Positioned(bottom: 250, right: 20, child: FloatingActionButton(backgroundColor: Colors.white, foregroundColor: Colors.blue[600], onPressed: _updateCurrentLocation, child: const Icon(Icons.my_location))),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(40)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -10))]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)), margin: const EdgeInsets.only(bottom: 24)),
                  Row(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(16)), child: Icon(_statusIcon, color: _statusColor, size: 24)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("STATUS LOKASI", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)), Text(_statusMessage, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))]))]),
                  const SizedBox(height: 24),
                  if (!_isParked) ...[
                    SizedBox(width: double.infinity, child: ElevatedButton.icon(icon: const Icon(Icons.anchor), label: const Text("Simpan Lokasi Parkir", style: TextStyle(fontSize: 16)), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[600], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), onPressed: _saveParking))
                  ] else ...[
                    SizedBox(width: double.infinity, child: ElevatedButton.icon(icon: const Icon(Icons.route), label: const Text("Arahkan ke Kendaraan", style: TextStyle(fontSize: 16)), style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo[600], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), onPressed: _findVehicle)),
                    const SizedBox(height: 12),
                    SizedBox(width: double.infinity, child: TextButton(onPressed: _clearParking, style: TextButton.styleFrom(backgroundColor: Colors.grey[100], foregroundColor: Colors.grey[700], padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: const Text("Selesai Parkir", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))))
                  ]
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// ==========================================
// 5. HALAMAN RIWAYAT
// ==========================================
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  void _showDetailModal(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Detail Parkir", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))]),
            const SizedBox(height: 16),
            Container(height: 120, width: double.infinity, decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(24)), child: Icon(Icons.map, size: 60, color: Colors.blue[200])),
            const SizedBox(height: 24),
            _buildDetailRow("Pemilik NPM", item['npm'] ?? '-'), const Divider(),
            _buildDetailRow("Lokasi", item['location'] ?? '-'), const Divider(),
            _buildDetailRow("Tanggal", item['date'] ?? '-'), const Divider(),
            _buildDetailRow("Waktu", item['time'] ?? '-'), const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Status", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(8)), child: const Text("SELESAI", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10)))]),
            ),
            const SizedBox(height: 32),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: const Text("Tutup Detail", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          ],
        ),
      )
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)), Flexible(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right, overflow: TextOverflow.ellipsis))]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('riwayat_parkir').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.folder_open, size: 80, color: Colors.grey[300]), const SizedBox(height: 16), const Text("Belum Ada Riwayat", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)), const Text("Anda belum pernah menyimpan\nlokasi parkir kendaraan.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))]));
          }

          final docs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final item = docs[index].data() as Map<String, dynamic>;
              return GestureDetector(
                onTap: () => _showDetailModal(context, item),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey[200]!)),
                  child: Row(
                    children: [
                      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(16)), child: Icon(Icons.history, color: Colors.blue[600])),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item['location'] ?? 'Lokasi', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis), const SizedBox(height: 4), Text("${item['date']} • NPM: ${item['npm']}", style: const TextStyle(color: Colors.grey, fontSize: 12))])),
                      const Icon(Icons.chevron_right, color: Colors.grey)
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ==========================================
// 6. HALAMAN LAPORAN
// ==========================================
class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String _selectedIssue = "Area Parkir Penuh";
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();

  Future<void> _submitReportToFirebase() async {
    FocusScope.of(context).unfocus();
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mengirim laporan...')));

    final prefs = await SharedPreferences.getInstance();
    String loggedInNpm = prefs.getString('logged_in_npm') ?? 'Guest';

    await FirebaseFirestore.instance.collection('laporan_masalah').add({
      'npm': loggedInNpm,
      'jenis_masalah': _selectedIssue,
      'lokasi_kejadian': _locationController.text,
      'detail': _detailController.text,
      'status': 'Menunggu Respon',
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Laporan berhasil dikirim ke Admin!'), backgroundColor: Colors.green));
    _locationController.clear(); _detailController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lapor Masalah", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pilih Kendala", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)), child: DropdownButtonHideUnderline(child: DropdownButton<String>(isExpanded: true, value: _selectedIssue, items: <String>['Area Parkir Penuh', 'Kendaraan Terhalang', 'Fasilitas Rusak', 'Indikasi Kehilangan', 'Lainnya'].map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(), onChanged: (newValue) => setState(() => _selectedIssue = newValue!)))),
            const SizedBox(height: 24),
            
            const Text("Lokasi / Area Kejadian", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(controller: _locationController, decoration: InputDecoration(hintText: "Contoh: Parkiran Gedung C", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)))),
            const SizedBox(height: 24),

            const Text("Detail Laporan", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(controller: _detailController, maxLines: 4, decoration: InputDecoration(hintText: "Ceritakan detail masalah...", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)))),
            const SizedBox(height: 32),
            
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _submitReportToFirebase, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('Kirim Laporan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)))),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 7. HALAMAN PROFIL (MENGGUNAKAN STREAM BUILDER)
// ==========================================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _loggedInNpm = '';

  @override
  void initState() {
    super.initState();
    _loadUserNpm();
  }

  Future<void> _loadUserNpm() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _loggedInNpm = prefs.getString('logged_in_npm') ?? '';
    });
  }

  void _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_in_npm');
    if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loggedInNpm.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(_loggedInNpm).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text("Data pengguna tidak ditemukan."));
                }

                // Ambil data langsung dari Firebase secara real-time
                var userData = snapshot.data!.data() as Map<String, dynamic>;
                String nama = userData['nama'] ?? 'Pengguna';
                String npm = userData['npm'] ?? _loggedInNpm;
                String plat = userData['plat'] ?? '-';
                String fakultas = userData['fakultas'] ?? 'Fakultas Teknik';

                return Column(
                  children: [
                    Container(padding: const EdgeInsets.only(top: 80, bottom: 40), width: double.infinity, decoration: BoxDecoration(color: Colors.blue[600], borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40))), child: const Center(child: Text("Profil Akun", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)))),
                    Transform.translate(
                      offset: const Offset(0, -50),
                      child: Column(
                        children: [
                          Container(width: 110, height: 110, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 6), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]), child: Container(decoration: BoxDecoration(color: Colors.blue[100], shape: BoxShape.circle), child: Icon(Icons.person, size: 60, color: Colors.blue[600]))),
                          const SizedBox(height: 16),
                          Text(nama, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          Text("NPM: $npm", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.indigo[100]!), borderRadius: BorderRadius.circular(20)), child: Text(fakultas, style: TextStyle(color: Colors.indigo[600], fontWeight: FontWeight.bold, fontSize: 12))),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0), 
                      child: Container(
                        padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey[200]!)), 
                        child: Row(
                          children: [
                            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.indigo[50], borderRadius: BorderRadius.circular(16)), child: Icon(Icons.motorcycle, color: Colors.indigo[400], size: 30)), 
                            const SizedBox(width: 16), 
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text("KENDARAAN AKTIF", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)), 
                              Text(plat, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), 
                              const Text("Terdaftar di Sistem", style: TextStyle(fontSize: 12, color: Colors.grey))
                            ])
                          ]
                        )
                      )
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(24.0), 
                      child: SizedBox(
                        width: double.infinity, 
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.logout, color: Colors.red), 
                          label: const Text("Keluar Akun", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), 
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), side: BorderSide(color: Colors.red[200]!)), 
                          onPressed: _handleLogout
                        )
                      )
                    )
                  ],
                );
              },
            ),
    );
  }
}