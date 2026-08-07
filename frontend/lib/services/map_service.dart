import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapService {
  // Fetch nearby police stations using Overpass API
  Future<List<LatLng>> getNearbyPoliceStations(double lat, double lon) async {
    const double radius = 5000; // 5km
    final String query = '''
      [out:json];
      (
        node["amenity"="police"](around:$radius,$lat,$lon);
        way["amenity"="police"](around:$radius,$lat,$lon);
        relation["amenity"="police"](around:$radius,$lat,$lon);
      );
      out center;
    ''';
    
    final uri = Uri.parse('https://overpass-api.de/api/interpreter');
    try {
      final response = await http.post(uri, body: {'data': query});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final elements = data['elements'] as List;
        
        List<LatLng> stations = [];
        for (var el in elements) {
          if (el['type'] == 'node') {
            stations.add(LatLng(el['lat'], el['lon']));
          } else if (el['center'] != null) {
            stations.add(LatLng(el['center']['lat'], el['center']['lon']));
          }
        }
        return stations;
      }
    } catch (e) {
      // Return empty list on failure
    }
    return [];
  }

  // Fetch route using OSRM (Open Source Routing Machine)
  Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    final uri = Uri.parse('http://router.project-osrm.org/route/v1/foot/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson');
    
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final routes = data['routes'] as List;
        if (routes.isNotEmpty) {
          final geometry = routes[0]['geometry']['coordinates'] as List;
          return geometry.map((coord) => LatLng((coord[1] as num).toDouble(), (coord[0] as num).toDouble())).toList();
        }
      }
    } catch (e) {
      // Handle error
    }
    return [];
  }
}
