import 'dart:convert';

class Service {
	int? id;
	String? name;
	dynamic nameBn;
	String? description;
	dynamic descriptionBn;
	String? imagePath;

	Service({
		this.id, 
		this.name, 
		this.nameBn, 
		this.description, 
		this.descriptionBn, 
		this.imagePath, 
	});

	factory Service.fromMap(Map<String, dynamic> data) => Service(
				id: data['id'] as int?,
				name: data['name'] as String?,
				nameBn: data['name_bn'] as dynamic,
				description: data['description'] as String?,
				descriptionBn: data['description_bn'] as dynamic,
				imagePath: data['image_path'] as String?,
			);

	Map<String, dynamic> toMap() => {
				'id': id,
				'name': name,
				'name_bn': nameBn,
				'description': description,
				'description_bn': descriptionBn,
				'image_path': imagePath,
			};

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Service].
	factory Service.fromJson(String data) {
		return Service.fromMap(json.decode(data) as Map<String, dynamic>);
	}
  /// `dart:convert`
  ///
  /// Converts [Service] to a JSON string.
	String toJson() => json.encode(toMap());
}
