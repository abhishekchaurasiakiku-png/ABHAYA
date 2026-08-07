import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class PoliceStation {
  final LatLng location;
  final String name;
  final double distance;

  PoliceStation(this.location, this.name, this.distance);
}

class MapService {
  // Fetch nearby police stations using Overpass API (top 3, max 4km)
  Future<List<PoliceStation>> getNearbyPoliceStations(double lat, double lon) async {
    const double radius = 4000; // 4km
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
        
        List<PoliceStation> stations = [];
        final distance = const Distance();
        final currentLoc = LatLng(lat, lon);

        for (var el in elements) {
          LatLng loc;
          if (el['type'] == 'node') {
            loc = LatLng(el['lat'], el['lon']);
          } else if (el['center'] != null) {
            loc = LatLng(el['center']['lat'], el['center']['lon']);
          } else {
            continue;
          }
          
          String name = 'Police Station';
          if (el['tags'] != null && el['tags']['name'] != null) {
            name = el['tags']['name'];
          }

          final dist = distance.as(LengthUnit.Meter, currentLoc, loc);
          stations.add(PoliceStation(loc, name, dist));
        }

        // Sort by distance and return top 3
        stations.sort((a, b) => a.distance.compareTo(b.distance));
        return stations.take(3).toList();
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
