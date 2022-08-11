class Address
{
  String? placeFormattedAddress;
  String? placeCityName;
  String? placeCountryName;
  String? placeCountryCode;
  String? placeId;
  double? latitude;
  double? longitude;

  Address({this.placeFormattedAddress, this.placeCityName, this.placeCountryName, this.placeCountryCode, this.placeId, this.latitude, this.longitude});

  Address.fromJson(Map<String, dynamic> json){
    for (var component in json['address_components']) {
      var componentType = component["types"][0];
      switch (componentType) {
        case "street_number":
          //address = component['long_name'];
          break;
        case "route":
          //street = component['long_name'];
          break;
        case "neighborhood":
          //neighborhood = component['long_name'];
          break;
        case "postal_town":
          placeCityName = component['long_name'];
          break;
        case "postal_code":
          //postcode = component['long_name'];
          break;
        case "formatted_address":
          placeFormattedAddress = component['long_name'];
          break;
      }
    }
  }
}