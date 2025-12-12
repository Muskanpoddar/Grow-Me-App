import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryRepository {
  final CollectionReference categoriesRef = FirebaseFirestore.instance.collection('categories');

  Stream<List<String>> streamAllCategories() {
    return categoriesRef.snapshots().map((snap) => snap.docs.map((d) {
          final m = d.data()! as Map<String, dynamic>;
          return (m['name'] ?? '').toString();
        }).toList());
  }

  Future<void> addCategoryIfNotExists(String name) async {
    final q = await categoriesRef.where('name', isEqualTo: name).limit(1).get();
    if (q.docs.isEmpty) {
      await categoriesRef.add({'name': name});
    }
  }
}
