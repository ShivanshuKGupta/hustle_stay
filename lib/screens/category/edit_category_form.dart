import 'package:flutter/material.dart';
import 'package:hustle_stay/models/category/category.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/other/choose_icon.dart';
import 'package:hustle_stay/widgets/other/select_one.dart';
import 'package:hustle_stay/widgets/other/selection_vault.dart';
import 'package:hustle_stay/widgets/other/loading_elevated_button.dart';

// ignore: must_be_immutable
class EditCategoryForm extends StatefulWidget {
  Category? category;
  EditCategoryForm({super.key, this.category});

  @override
  State<EditCategoryForm> createState() => _EditCategoryFormState();
}

class _EditCategoryFormState extends State<EditCategoryForm> {
  bool get isParent {
    return widget.category!.parent == null;
  }

  late bool isNewCategory;

  final _idController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isNewCategory = widget.category == null;

    _idController.text =
        !isNewCategory ? widget.category!.id.replaceAll('_', ' ') : '';
  }

  Future<void> _save() async {
    _idController.text = _idController.text.trim();
    if (_idController.text.isEmpty) {
      showMsg(context, 'Please Enter the Name of the Category');
      return;
    }
    if (isParent) {
      if (widget.category!.allrecipients.isEmpty) {
        showMsg(
            context, 'Please select atleast one receipient for all recipients');
        return;
      }
      if (widget.category!.defaultReceipient.isEmpty) {
        showMsg(context, 'Please select atleast one default recipients');
        return;
      }
    }
    await updateCategory(widget.category!);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.category = widget.category ?? Category('');
    if (allParents.isEmpty) widget.category!.parent = null;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          ChooseIconWidget(
            chosenIcon: widget.category!.icon,
            onChange: (icon) {
              widget.category!.icon = icon;
            },
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _idController,
            enabled: isNewCategory,
            onChanged: (value) {
              setState(() {
                widget.category!.id = value.trim().replaceAll(' ', '_');
              });
            },
            decoration: InputDecoration(
              hintText: 'Name of Category',
              border: OutlineInputBorder(
                borderSide: const BorderSide(width: 1),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            maxLines: null,
            minLines: 1,
            keyboardType: TextInputType.multiline,
          ),
          if (isParent) const SizedBox(height: 20),
          if (isParent)
            UsersBuilder(
              provider: fetchComplainees,
              builder: (ctx, complainees) => SelectionVault(
                helpText: 'All Possible recipients',
                allItems: complainees.map((e) => e.email!).toSet(),
                onChange: (users) => setState(
                    () => widget.category!.allrecipients = users.toList()),
                chosenItems: widget.category!.allrecipients.toSet(),
              ),
            ),
          if (isParent) const SizedBox(height: 20),
          if (isParent)
            SelectionVault(
              helpText: 'Default recipients',
              allItems: widget.category!.allrecipients.toSet(),
              onChange: (users) => setState(
                  () => widget.category!.defaultReceipient = users.toList()),
              chosenItems: widget.category!.defaultReceipient.toSet(),
            ),
          const SizedBox(height: 20),
          SelectOne(
            title: 'Priority',
            allOptions: Priority.values.map((e) => e.name).toSet(),
            onChange: (value) {
              widget.category!.defaultPriority = Priority.values
                  .firstWhere((element) => element.name == value);
              return true;
            },
            selectedOption: widget.category!.defaultPriority.name,
          ),
          const SizedBox(height: 20),
          CategoriesBuilder(
              loadingWidget: SelectOne(
                expanded: true,
                selectedOption: widget.category!.parent,
                allOptions: allParents,
                onChange: (value) {
                  widget.category!.parent = value;
                  return true;
                },
              ),
              builder: (ctx, categories) {
                categories.removeWhere((element) => element.parent != null);
                categories.sort((a, b) {
                  if (a.parent == null || b.id == 'Other') return 0;
                  if (b.parent == null || a.id == 'Other') return 1;
                  return 2;
                });
                allParents = categories.map((e) => e.id).toSet();
                return SelectOne(
                  expanded: true,
                  title: 'Parent Category?',
                  subtitle: 'Group under which category?',
                  selectedOption: widget.category!.parent ?? 'None',
                  allOptions: allParents.map((e) => e).toSet()..add('None'),
                  onChange: (value) {
                    setState(() {
                      if (value == 'None') {
                        widget.category!.parent = null;
                      } else {
                        widget.category!.parent = value;
                      }
                    });
                    return true;
                  },
                );
              }),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final chosenColor = await showColorPicker(
                    context,
                    widget.category!.color,
                  );
                  setState(() {
                    widget.category!.color = chosenColor;
                  });
                },
                icon: Icon(
                  Icons.color_lens_rounded,
                  color: widget.category!.color,
                ),
                label: const Text("Change color"),
              ),
              LoadingElevatedButton(
                enabled: !(_idController.text.trim().isEmpty ||
                    (isParent &&
                        (widget.category!.allrecipients.isEmpty ||
                            widget.category!.defaultReceipient.isEmpty))),
                onPressed: _save,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// // ignore: must_be_immutable
// class EditCategoryForm extends StatefulWidget {
//   Category category;
//   final List<String> allRecepients;
//   EditCategoryForm(
//       {super.key, required this.category, required this.allRecepients});

//   @override
//   State<EditCategoryForm> createState() => _EditCategoryFormState();
// }

// class _EditCategoryFormState extends State<EditCategoryForm> {
//   final _formKey = GlobalKey<FormState>();

//   bool _loading = false;
//   String? enteredID;
//   File? img;

//   Future<void> _save() async {
//     if (!_formKey.currentState!.validate()) return; // if not validated, return
//     if (widget.category.defaultReceipient.isEmpty) {
//       showMsg(context, "A default receipient is required.");
//       return;
//     }
//     _formKey.currentState!.save(); // Saving
//     setState(() {
//       _loading = true;
//     });
//     try {
//       widget.category.id = enteredID ?? widget.category.id;
//       widget.category.icon = widget.category.icon ?? Icons.category_rounded;
//       await updateCategory(widget.category);
//       // ignore: use_build_context_synchronously
//       Navigator.of(context).pop();
//       return;
//     } catch (e) {
//       showMsg(context, e.toString());
//     }
//     setState(() {
//       _loading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(10.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               ChooseIconWidget(
//                 chosenIcon: widget.category.icon,
//                 onChange: (icon) {
//                   widget.category.icon = icon;
//                 },
//               ),
//               if (widget.category.id.isEmpty)
//                 TextFormField(
//                   key: UniqueKey(),
//                   maxLength: 50,
//                   enabled: widget.category.id.isEmpty,
//                   decoration: const InputDecoration(
//                     label: Text("Category Name/ID"),
//                   ),
//                   initialValue: enteredID,
//                   validator: (id) {
//                     return Validate.text(id, required: true);
//                   },
//                   onChanged: (id) {
//                     enteredID = id.trim();
//                   },
//                   onSaved: (id) {
//                     enteredID = id!.trim();
//                   },
//                 ),
//                 if(widget.category.parent!=null)
//               MultiChooser(
//                 hintTxt: "Select a receipient",
//                 allOptions: widget.allRecepients,
//                 chosenOptions: widget.category.allrecipients,
//                 onUpdate: (value) {
//                   setState(() {
//                     widget.category.allrecipients = value;
//                   });
//                 },
//                 label: 'All recipients',
//               ),
//               MultiChooser(
//                 hintTxt: "Select a receipient",
//                 key: UniqueKey(),
//                 allOptions: widget.category.allrecipients,
//                 chosenOptions: widget.category.defaultReceipient,
//                 onUpdate: (value) {
//                   widget.category.defaultReceipient = value;
//                 },
//                 label: 'Default recipients',
//               ),
//               TextFormField(
//                 key: UniqueKey(),
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(
//                   label: Text("Default Priority"),
//                 ),
//                 initialValue: widget.category.defaultPriority.toString(),
//                 validator: (value) {
//                   return Validate.integer(value, required: true);
//                 },
//                 onSaved: (value) {
//                   widget.category.defaultPriority = int.parse(value!.trim());
//                 },
//               ),
//               // TODO: Add a cooldown field for category
//               ElevatedButton.icon(
//                 onPressed: () async {
//                   final chosenColor = await showColorPicker(
//                     context,
//                     widget.category.color,
//                   );
//                   setState(() {
//                     widget.category.color = chosenColor;
//                   });
//                 },
//                 icon: Icon(
//                   Icons.color_lens_rounded,
//                   color: widget.category.color,
//                 ),
//                 label: const Text("Pick a color"),
//               ),
//               const SizedBox(height: 10),
//               CategoriesBuilder(
//                 builder: (ctx, categories) {
//                   for (var e in categories) {
//                     if (e.parent != null) allParents.add(e.parent!);
//                   }
//                   return SelectOne(
//                     title: 'Select a Parent Category',
//                     subtitle: 'This will be used for grouping categories',
//                     allOptions: allParents.map((e) => e).toSet()
//                       ..add('+ Create New'),
//                     selectedOption: widget.category.parent,
//                     onChange: (value) {
//                       if (value == '+ Create New') {
//                         promptUser(context, question: 'New Parent Category')
//                             .then((value) {
//                           if (value != null) {
//                             // Category category =
//                             //     Category(value.trim().replaceAll(' ', '_'));
//                             // updateCategory(category);
//                             setState(() => allParents.add(value));
//                           }
//                         });
//                         return false;
//                       }
//                       widget.category.parent = value;
//                       return true;
//                     },
//                   );
//                 },
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   ElevatedButton.icon(
//                     onPressed: _loading ? null : _save,
//                     icon: _loading
//                         ? circularProgressIndicator()
//                         : const Icon(Icons.save_rounded),
//                     label: const Text('Save'),
//                   ),
//                   TextButton.icon(
//                     onPressed: () {
//                       _formKey.currentState!.reset();
//                     },
//                     icon: const Icon(Icons.refresh),
//                     label: const Text('Reset'),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
