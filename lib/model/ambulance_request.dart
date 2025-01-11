class AmbulanceRequest {
     final int id;
     final double latitude;
     final double longitude;
     final String description;
     final String hospitalName;

     AmbulanceRequest({
       required this.id,
       required this.latitude,
       required this.longitude,
       required this.description,
       required this.hospitalName,
     });

     factory AmbulanceRequest.fromJson(Map<String, dynamic> json) {
       return AmbulanceRequest(
         id: json['id'],
         latitude: json['latitude'],
         longitude: json['longitude'],
         description: json['description'],
         hospitalName: json['hospital']['name'],
       );
     }
   }