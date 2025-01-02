import 'dart:convert';

class Address {
	int? id;
	String? addressName;
	String? roadNo;
	String? houseNo;
	dynamic houseName;
	String? flatNo;
	String? block;
	String? area;
	dynamic subDistrictId;
	dynamic districtId;
	String? addressLine;
	String? addressLine2;
	String? deliveryNote;
	String? postCode;
	String? latitude;
	String? longitude;

	Address({
		this.id, 
		this.addressName, 
		this.roadNo, 
		this.houseNo, 
		this.houseName, 
		this.flatNo, 
		this.block, 
		this.area, 
		this.subDistrictId, 
		this.districtId, 
		this.addressLine, 
		this.addressLine2, 
		this.deliveryNote, 
		this.postCode, 
		this.latitude, 
		this.longitude, 
	});

	factory Address.fromMap(Map<String, dynamic> data) => Address(
				id: data['id'] as int?,
				addressName: data['address_name'] as String?,
				roadNo: data['road_no'] as String?,
				houseNo: data['house_no'] as String?,
				houseName: data['house_name'] as dynamic,
				flatNo: data['flat_no'] as String?,
				block: data['block'] as String?,
				area: data['area'] as String?,
				subDistrictId: data['sub_district_id'] as dynamic,
				districtId: data['district_id'] as dynamic,
				addressLine: data['address_line'] as String?,
				addressLine2: data['address_line2'] as String?,
				deliveryNote: data['delivery_note'] as String?,
				postCode: data['post_code'] as String?,
				latitude: data['latitude'] as String?,
				longitude: data['longitude'] as String?,
			);

	Map<String, dynamic> toMap() => {
				'id': id,
				'address_name': addressName,
				'road_no': roadNo,
				'house_no': houseNo,
				'house_name': houseName,
				'flat_no': flatNo,
				'block': block,
				'area': area,
				'sub_district_id': subDistrictId,
				'district_id': districtId,
				'address_line': addressLine,
				'address_line2': addressLine2,
				'delivery_note': deliveryNote,
				'post_code': postCode,
				'latitude': latitude,
				'longitude': longitude,
			};

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Address].
	factory Address.fromJson(String data) {
		return Address.fromMap(json.decode(data) as Map<String, dynamic>);
	}
  /// `dart:convert`
  ///
  /// Converts [Address] to a JSON string.
	String toJson() => json.encode(toMap());
}
