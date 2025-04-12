import 'dart:math';

import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../database/database_helper.dart';
import '../database/models.dart';
import '../widgets/button.dart';
import '../widgets/color.dart';
import '../widgets/delete.dart';
import '../widgets/dialog.dart';
import '../widgets/fields.dart';
import '../widgets/format_date.dart';
import '../widgets/text_color_changer.dart';

class TraitsListView extends StatefulWidget {
  const TraitsListView({super.key});

  @override
  State<TraitsListView> createState() => _TraitsListViewState();
}

class _TraitsListViewState extends State<TraitsListView> {
  List<Trait> allTraits = [];
  List<Trait> animatedTraits = [];
  TextEditingController descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    allTraits = DatabaseHelper.getAllTraits();

    int animatedCount = allTraits.length < 10 ? allTraits.length : 10;

    for (int i = 0; i < animatedCount; i++) {
      await Future.delayed(Duration(milliseconds: 20 * i));
      setState(() {
        animatedTraits.add(allTraits[i]);
      });
    }

    if (allTraits.length > animatedCount) {
      setState(() {
        animatedTraits.addAll(allTraits.sublist(animatedCount));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        allTraits.isEmpty
            ? const Center(child: Text("No Traits Available", style: TextStyle(color: Colors.white)))
            : AnimatedReorderableListView(
              items: animatedTraits,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  final movedItem = animatedTraits.removeAt(oldIndex);
                  animatedTraits.insert(newIndex, movedItem);
                  DatabaseHelper.updateTraitOrder(animatedTraits);
                });
              },
              isSameItem: (a, b) => a.id == b.id,
              itemBuilder: (context, index) {
                final trait = animatedTraits[index];
                final bgColor = Color.from(alpha: trait.alpha, red: trait.red, green: trait.green, blue: trait.blue);
                final textColor = getTextColorBasedOnBackground(bgColor);
                return Padding(
                  key: ValueKey(trait.id),
                  padding: const EdgeInsets.symmetric(vertical: 1.0),
                  child: Slidable(
                    key: Key(trait.id.toString()),
                    startActionPane: ActionPane(extentRatio: 0.25, motion: const StretchMotion(), children: [SlidableAction(onPressed: (_) => _showTraitDialog(context, trait), backgroundColor: Colors.blue.shade800, foregroundColor: Colors.white, icon: Icons.edit, label: "Edit", borderRadius: BorderRadius.horizontal(right: Radius.circular(15)))]),
                    endActionPane: ActionPane(
                      extentRatio: 0.25,
                      motion: const StretchMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (_) async {
                            final shouldDelete = await showNosDeleteDialog(context);
                            if (shouldDelete) {
                              setState(() {
                                animatedTraits.removeAt(index);
                              });
                              DatabaseHelper.traitBox.remove(trait.id);
                              if (animatedTraits.isEmpty) {
                                await Future.delayed(Duration(milliseconds: 200));
                                setState(() {
                                  allTraits.clear();
                                });
                              }
                            }
                          },
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: "Delete",
                          borderRadius: BorderRadius.horizontal(left: Radius.circular(15)),
                        ),
                      ],
                    ),
                    child: Card(color: bgColor, child: ExpansionTile(title: Text(trait.name, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)), trailing: Text(formatDate(trait.lastModified), style: TextStyle(color: textColor)), children: [Padding(padding: const EdgeInsets.all(10), child: DefaultTextStyle(style: TextStyle(color: textColor, fontSize: 15), child: MarkdownBody(data: trait.description)))])),
                  ),
                );
              },
              enterTransition: [FadeIn(), Landing()],
              exitTransition: [FadeIn(duration: Duration(milliseconds: 200)), SlideInLeft(duration: Duration(milliseconds: 150))],
            ),
        Align(alignment: Alignment.bottomRight, child: Padding(padding: const EdgeInsets.all(28.0), child: FloatingActionButton(backgroundColor: Colors.blueAccent, child: const Icon(Icons.add_reaction_outlined, color: Colors.white), onPressed: () => _showTraitDialog(context, null)))),
      ],
    );
  }

  void _showTraitDialog(BuildContext context, Trait? trait) {
    TextEditingController nameController = TextEditingController();

    Color? color;

    if (trait != null) {
      nameController.text = trait.name;
      descController.text = trait.description;
      color = Color.from(alpha: trait.alpha, red: trait.red, green: trait.green, blue: trait.blue);
    }

    showNosDialog(
      context,
      trait == null ? "New Trait" : "Edit Trait",
      StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: NosTextField(controller: nameController, hintText: 'Trait Name')),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: NosButton(
                      color: color,
                      text: "Pick a Color",
                      onPressed: () async {
                        Color? dColor = await showColorPickerDialog(context);
                        setState(() {
                          color = dColor;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: NosButton(
                      color: color,
                      text: "Random Color",
                      onPressed: () async {
                        setState(() {
                          color = Color.from(alpha: Random().nextDouble(), red: Random().nextDouble(), green: Random().nextDouble(), blue: Random().nextDouble());
                        });
                      },
                    ),
                  ),
                ],
              ),
              NosTextField(controller: descController, hintText: "Description", multiline: true),
              Wrap(spacing: 8, children: [_buildMarkdownButton("B", "**"), _buildMarkdownButton("I", "_"), _buildMarkdownButton("H1", "# "), _buildMarkdownButton("~~", "~~")]),
            ],
          );
        },
      ),
      [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancel", style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: () async {
            if (nameController.text.isNotEmpty && color != null) {
              if (trait == null) {
                Trait newTrait = Trait(name: nameController.text, description: descController.text, red: color!.r, green: color!.g, blue: color!.b, alpha: color!.a);
                if (animatedTraits.isNotEmpty) newTrait.sortOrder = animatedTraits.first.sortOrder - 1;
                if (allTraits.isEmpty) {
                  setState(() {
                    allTraits.add(newTrait);
                  });
                  await Future.delayed(Duration(milliseconds: 100));
                }
                animatedTraits.insert(0, newTrait);
                DatabaseHelper.traitBox.put(newTrait);
              } else {
                trait.name = nameController.text;
                trait.red = color!.r;
                trait.green = color!.g;
                trait.blue = color!.b;
                trait.alpha = color!.a;
                trait.description = descController.text;

                DatabaseHelper.traitBox.put(trait);
              }

              setState(() {});
              if (context.mounted) Navigator.pop(context);
            }
          },
          child: Text(trait == null ? "Add" : "Update", style: TextStyle(color: Colors.blueAccent)),
        ),
      ],
    );
  }

  Widget _buildMarkdownButton(String label, String markdown) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade800),
      onPressed: () {
        final selection = descController.selection;
        final text = descController.text;

        String newText;
        if (selection.start == selection.end) {
          newText = text.replaceRange(selection.start, selection.start, markdown);
        } else {
          newText = text.replaceRange(selection.start, selection.end, "$markdown${text.substring(selection.start, selection.end)}$markdown");
        }

        setState(() {
          descController.text = newText;
        });
        descController.selection = TextSelection.collapsed(offset: selection.start + markdown.length);
      },
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}
