class PredictModel {
  Estilo? estilo;
  String? imagePath;
  String? imageUrl;
  String? createdAt;

  PredictModel({this.estilo, this.imagePath, this.imageUrl, this.createdAt});

  PredictModel.fromJson(Map<String, dynamic> json) {
    estilo = json['estilo'] != null ? Estilo.fromJson(json['estilo']) : null;
    imagePath = json['image_path'];
    imageUrl = json['image_url'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (estilo != null) {
      data['estilo'] = estilo!.toJson();
    }
    data['image_path'] = imagePath;
    data['image_url'] = imageUrl;
    data['created_at'] = createdAt;
    return data;
  }
}

class Estilo {
  String? nombre;
  String? descripcion;
  String? tecnicas;
  int? id;

  Estilo({this.nombre, this.descripcion, this.tecnicas, this.id});

  Estilo.fromJson(Map<String, dynamic> json) {
    nombre = json['nombre'];
    descripcion = json['descripcion'];
    tecnicas = json['tecnicas'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nombre'] = nombre;
    data['descripcion'] = descripcion;
    data['tecnicas'] = tecnicas;
    data['id'] = id;
    return data;
  }
}
