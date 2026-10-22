import 'package:flutter/material.dart';

class Pet {
  const Pet({
    required this.id,
    required this.name,
    required this.category,
    required this.image,
    required this.color,
    this.price = 150,
    this.sex = 'Male',
    this.age = '1 year',
    this.location = 'California, Walk suite',
    this.distance = 2,
    this.description = 'A friendly little companion looking for a loving home. Playful, curious, and happiest by your side. Get in touch with the owner to learn about their personality, health, and care needs.',
    this.photo,
  });
  final String id, name, category, image, sex, age, location, description;
  final int price, distance;
  final Color color;
  final String? photo;
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'image': image,
    'price': price,
    'sex': sex,
    'age': age,
    'location': location,
    'distance': distance,
    'description': description,
    'color': color.toARGB32(),
    'photo': photo,
  };
  factory Pet.fromJson(Map<String, dynamic> j) => Pet(
    id: j['id'],
    name: j['name'],
    category: j['category'],
    image: j['image'],
    price: j['price'],
    sex: j['sex'],
    age: j['age'],
    location: j['location'],
    distance: j['distance'],
    description: j['description'],
    color: Color(j['color']),
    photo: j['photo'],
  );
}

const seedPets = [
  Pet(
    id: 'dog',
    name: 'Labrador Retriever',
    category: 'Dog',
    image: 'dog',
    color: Color(0xFFFFC4E6),
  ),
  Pet(
    id: 'cat',
    name: 'American Shorthair',
    category: 'Cat',
    image: 'cat',
    color: Color(0xFFCECFFF),
    location: '1061 Muveg Square',
    distance: 5,
  ),
  Pet(
    id: 'bird',
    name: 'Charadrinaee',
    category: 'Birds',
    image: 'bird',
    color: Color(0xFFFFE3CC),
    price: 120,
  ),
  Pet(
    id: 'turtle',
    name: 'Speckled Tortoise',
    category: 'Others',
    image: 'turtle',
    color: Color(0xFFAEEDAE),
    price: 90,
  ),
];

class Address {
  const Address(this.label, this.city, this.detail);
  final String label, city, detail;
  Map<String, dynamic> toJson() => {
    'label': label,
    'city': city,
    'detail': detail,
  };
  factory Address.fromJson(Map<String, dynamic> j) =>
      Address(j['label'], j['city'], j['detail']);
}

class PaymentMethod {
  const PaymentMethod(this.label, this.holder, this.last4);
  final String label, holder, last4;
  Map<String, dynamic> toJson() => {
    'label': label,
    'holder': holder,
    'last4': last4,
  };
  factory PaymentMethod.fromJson(Map<String, dynamic> j) =>
      PaymentMethod(j['label'], j['holder'], j['last4']);
}

class PetOrder {
  const PetOrder({
    required this.id,
    required this.pets,
    required this.address,
    required this.payment,
    required this.createdAt,
    this.status = 'On Process',
  });
  final String id, payment, status;
  final List<Pet> pets;
  final Address address;
  final DateTime createdAt;
  int get subtotal => pets.fold(0, (total, pet) => total + pet.price);
  int get total => subtotal + 10;
  Map<String, dynamic> toJson() => {
    'id': id,
    'pets': pets.map((p) => p.toJson()).toList(),
    'address': address.toJson(),
    'payment': payment,
    'createdAt': createdAt.toIso8601String(),
    'status': status,
  };
  factory PetOrder.fromJson(Map<String, dynamic> j) => PetOrder(
    id: j['id'],
    pets: (j['pets'] as List).map((p) => Pet.fromJson(p)).toList(),
    address: Address.fromJson(j['address']),
    payment: j['payment'],
    createdAt: DateTime.parse(j['createdAt']),
    status: j['status'],
  );
}
