import 'dart:convert';

import 'service.dart';

class Data {
	List<Service>? services;

	Data({this.services});

	factory Data.fromMap(Map<String, dynamic> data) => Data(
				services: (data['services'] as List<dynamic>?)
						?.map((e) => Service.fromMap(e as Map<String, dynamic>))
						.toList(),
			);

	Map<String, dynamic> toMap() => {
				'services': services?.map((e) => e.toMap()).toList(),
			};

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Data].
	factory Data.fromJson(String data) {
		return Data.fromMap(json.decode(data) as Map<String, dynamic>);
	}
  /// `dart:convert`
  ///
  /// Converts [Data] to a JSON string.
	String toJson() => json.encode(toMap());
}
