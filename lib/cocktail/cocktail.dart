class Cocktail {
  String name;
  String id;
  String type;
  String image;
  String glass;
  List<dynamic> ingredients = List();
  String instructions;
  List<dynamic> qty = List();


  Map<String, dynamic> toJson() => {
        'strDrink': name,
        'idDrink': id,
        'strCategory': type,
        'strDrinkThumb': image,
        'strGlass': glass,
        'strInstructions': instructions,
        'strIngredient': ingredients,
        'strMeasure': qty,
      };

  Cocktail.fromJsonFile(Map<String, dynamic> json) {
    name = json['strDrink'];
    id = json['idDrink'];
    type = json['strCategory'];
    image = json['strDrinkThumb'];
    glass = json['strGlass'];
    instructions = json['strInstructions'];
    ingredients = json['strIngredient'];
    qty = json['strMeasure'];
  }

  @override
  String toString() {
    // TODO: implement toString
    return this.name;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;
}
