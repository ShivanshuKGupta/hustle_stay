import 'package:flutter/material.dart';
import 'package:hustle_stay/models/category/category.dart';
import 'package:hustle_stay/screens/category/edit_category_form.dart';

class EditCategoryScreen extends StatefulWidget {
  final String? id;
  const EditCategoryScreen({super.key, this.id});

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id != null ? 'Edit Category' : 'Add a Category'),
      ),
      body: widget.id == null
          ? EditCategoryForm()
          : CategoryBuilder(
              id: widget.id!,
              builder: (ctx, category) => EditCategoryForm(category: category),
            ),
      // body: ComplaineeBuilder(
      //   loadingWidget: Center(child: circularProgressIndicator()),
      //   builder: (ctx, complainees) {
      //     final recepients = complainees.map((e) => e.email!).toList();
      //     return widget.id != null
      //         ? CategoryBuilder(
      //             loadingWidget: Center(child: circularProgressIndicator()),
      //             id: widget.id!,
      //             builder: ((ctx, category) {
      //               return EditCategoryForm(
      //                 category: category,
      //                 allRecepients: recepients,
      //               );
      //             }),
      //           )
      //         : EditCategoryForm(
      //             category: Category(''),
      //             allRecepients: recepients,
      //           );
      //   },
      // ),
    );
  }
}
