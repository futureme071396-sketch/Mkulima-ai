// mobile-app/lib/src/models/plant_model.dart

class Plant {
  final String id;
  final String name;
  final String scientificName;
  final String category; // 'cereal', 'vegetable', 'fruit', 'cash_crop'
  final String growthStage; // 'seedling', 'vegetative', 'flowering', 'fruiting'
  final List<String> commonDiseases;
  final String imageUrl;
  final String description;

  Plant({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.category,
    this.growthStage = 'vegetative',
    this.commonDiseases = const [],
    required this.imageUrl,
    required this.description,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      scientificName: json['scientific_name'] ?? '',
      category: json['category'] ?? 'cereal',
      growthStage: json['growth_stage'] ?? 'vegetative',
      commonDiseases: List<String>.from(json['common_diseases'] ?? []),
      imageUrl: json['image_url'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scientific_name': scientificName,
      'category': category,
      'growth_stage': growthStage,
      'common_diseases': commonDiseases,
      'image_url': imageUrl,
      'description': description,
    };
  }

  // Display name with emoji based on category
  String get displayName {
    switch (category) {
      case 'cereal':
        return '🌾 $name';
      case 'vegetable':
        return '🥦 $name';
      case 'fruit':
        return '🍎 $name';
      case 'cash_crop':
        return '💰 $name';
      default:
        return '🌱 $name';
    }
  }

  // Localized names for Kenyan context
  String get localName {
    switch (name.toLowerCase()) {
      case 'maize':
        return 'Mahindi';
      case 'coffee':
        return 'Kahawa';
      case 'tea':
        return 'Chai';
      case 'banana':
        return 'Ndizi';
      case 'tomato':
        return 'Nyanya';
      default:
        return name;
    }
  }
}

class PlantDisease {
  final String id;
  final String name;
  final String scientificName;
  final String plantType;
  final String severity;
  final List<String> symptoms;
  final List<String> causes;
  final List<String> treatments;
  final List<String> preventions;
  final String imageUrl;
  final String season; // 'rainy', 'dry', 'all'
  final String affectedPart; // 'leaves', 'stem', 'roots', 'fruit'

  PlantDisease({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.plantType,
    required this.severity,
    required this.symptoms,
    required this.causes,
    required this.treatments,
    required this.preventions,
    required this.imageUrl,
    required this.season,
    required this.affectedPart,
  });

  factory PlantDisease.fromJson(Map<String, dynamic> json) {
    return PlantDisease(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      scientificName: json['scientific_name'] ?? '',
      plantType: json['plant_type'] ?? 'maize',
      severity: json['severity'] ?? 'Medium',
      symptoms: List<String>.from(json['symptoms'] ?? []),
      causes: List<String>.from(json['causes'] ?? []),
      treatments: List<String>.from(json['treatments'] ?? []),
      preventions: List<String>.from(json['preventions'] ?? []),
      imageUrl: json['image_url'] ?? '',
      season: json['season'] ?? 'all',
      affectedPart: json['affected_part'] ?? 'leaves',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scientific_name': scientificName,
      'plant_type': plantType,
      'severity': severity,
      'symptoms': symptoms,
      'causes': causes,
      'treatments': treatments,
      'preventions': preventions,
      'image_url': imageUrl,
      'season': season,
      'affected_part': affectedPart,
    };
  }

  // Localized treatment recommendations for Kenyan farmers
  List<String> get localizedTreatments {
    return treatments.map((treatment) {
      // Convert generic treatments to localized, practical advice
      if (treatment.contains('fungicide')) {
        return 'Tumia dawa ya kuvu kama vile Copper-based fungicide (Pata kwenye duka la pembejeo za kilimo)';
      } else if (treatment.contains('pesticide')) {
        return 'Tumia dawa ya wadudu inayoidhinishwa (Omba ushauri kwa afisa kilimo)';
      } else if (treatment.contains('organic')) {
        return 'Tumia mbinu za kilimo hai: majani ya neem, mboji au changanya maji na sabuni';
      }
      return treatment;
    }).toList();
  }
}
