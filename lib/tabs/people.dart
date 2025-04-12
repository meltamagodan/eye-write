import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../const.dart';
import '../database/database_helper.dart';
import '../database/models.dart';
import '../pages/comments.dart';
import '../widgets/delete.dart';
import '../widgets/dialog.dart';
import '../widgets/fields.dart';
import '../widgets/format_date.dart';
import '../widgets/text_color_changer.dart';

class PeopleListView extends StatefulWidget {
  const PeopleListView({super.key});

  @override
  State<PeopleListView> createState() => _PeopleListViewState();
}

class _PeopleListViewState extends State<PeopleListView> {
  List<Person> allPeople = [];
  List<Person> animatedPeople = [];
  late List<Trait> allTraits;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    allPeople = DatabaseHelper.getAllPeople();
    allTraits = DatabaseHelper.getAllTraits();

    int animatedCount = allPeople.length < 10 ? allPeople.length : 10;

    for (int i = 0; i < animatedCount; i++) {
      await Future.delayed(Duration(milliseconds: 20*i));
      setState(() {
        animatedPeople.add(allPeople[i]);
      });
    }

    if (allPeople.length > animatedCount) {
      setState(() {
        animatedPeople.addAll(allPeople.sublist(animatedCount));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        allPeople.isEmpty
            ? const Center(child: Text("No People Available", style: TextStyle(color: Colors.white)))
            : AnimatedReorderableListView<Person>(
              items: animatedPeople,
              isSameItem: (a, b) => a.id == b.id,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  final moved = animatedPeople.removeAt(oldIndex);
                  animatedPeople.insert(newIndex, moved);
                  DatabaseHelper.updatePersonOrder(animatedPeople);
                });
              },
              itemBuilder: (context, index) {
                final person = animatedPeople[index];
                final personTraits = person.traits;

                return Padding(
                  key: ValueKey(person.id),
                  padding: const EdgeInsets.symmetric(vertical: 1.0),
                  child: Slidable(
                    key: Key(person.id.toString()),
                    startActionPane: ActionPane(extentRatio: 0.25, motion: const StretchMotion(), children: [SlidableAction(onPressed: (_) => _showPersonDialog(context, person), backgroundColor: Colors.blue.shade800, foregroundColor: Colors.white, icon: Icons.edit, label: "Edit", borderRadius: BorderRadius.horizontal(right: Radius.circular(15)))]),
                    endActionPane: ActionPane(
                      extentRatio: 0.25,
                      motion: const StretchMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (_) async {
                            final shouldDelete = await showNosDeleteDialog(context);
                            if (shouldDelete) {
                              DatabaseHelper.personBox.remove(person.id);
                              setState(() {
                                animatedPeople.removeAt(index);
                              });
                              if(animatedPeople.isEmpty) {
                                await Future.delayed(Duration(milliseconds: 200));
                                setState(() {
                                  allPeople.clear();
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
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: OpenContainer<String>(
                        transitionDuration: const Duration(milliseconds: 200),
                        middleColor: Colors.black,
                        openColor: Colors.black,
                        closedColor: Colors.grey.shade800,
                        closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        closedBuilder: (_, openContainer) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(person.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)), Text(formatDate(person.lastModified), style: const TextStyle(color: Colors.white70, fontSize: 12))]),
                                const SizedBox(height: 12),
                                if (personTraits.isNotEmpty)
                                  Wrap(
                                    spacing: 8.0,
                                    runSpacing: 4.0,
                                    children:
                                        personTraits.map((trait) {
                                          final color = Color.from(alpha: trait.alpha, red: trait.red, green: trait.green, blue: trait.blue);
                                          return Chip(backgroundColor: color, label: Text(trait.name, style: TextStyle(color: getTextColorBasedOnBackground(color))));
                                        }).toList(),
                                  ),
                              ],
                            ),
                          );
                        },
                        openBuilder: (_, __) => GenericCommentsPage(item: person, type: ListType.people, title: person.name),
                      ),
                    ),
                  ),
                );
              },
          enterTransition: [FadeIn(), Landing()],
          exitTransition: [FadeIn(duration: Duration(milliseconds: 200)), SlideInLeft(duration: Duration(milliseconds: 150))],
            ),
        Align(alignment: Alignment.bottomRight, child: Padding(padding: const EdgeInsets.all(28.0), child: FloatingActionButton(backgroundColor: Colors.blueAccent, child: const Icon(Icons.person_add, color: Colors.white), onPressed: () => _showPersonDialog(context, null)))),
      ],
    );
  }

  void _showPersonDialog(BuildContext context, Person? person) {
    TextEditingController nameController = TextEditingController();
    List<Trait> selectedTraits = [];

    if (person != null) {
      nameController.text = person.name;
      selectedTraits = person.traits.toList();
    }

    showNosDialog(
      context,
      person == null ? "New Person" : "Edit Person",
      StatefulBuilder(
        builder: (context, setState) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NosTextField(controller: nameController, hintText: 'Person Name'),
                const SizedBox(height: 16),
                const Text("Select Traits:", style: TextStyle(color: Colors.white)),
                Wrap(
                  children:
                      allTraits.map((trait) {
                        final isSelected = selectedTraits.any((t) => t.id == trait.id);
                        final color = Color.from(alpha: trait.alpha, red: trait.red, green: trait.green, blue: trait.blue);
                        return FilterChip(
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedTraits.add(trait);
                              } else {
                                selectedTraits.removeWhere((t) => t.id == trait.id);
                              }
                            });
                          },
                          label: Text(trait.name),
                          backgroundColor: color,
                          labelStyle: TextStyle(color: getTextColorBasedOnBackground(color)),
                          selectedColor: color,
                          checkmarkColor: getTextColorBasedOnBackground(color),
                        );
                      }).toList(),
                ),
              ],
            ),
          );
        },
      ),
      [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.red))),
        TextButton(
          onPressed: () async {
            if (nameController.text.isNotEmpty) {
              if (person == null) {
                final newPerson = Person(name: nameController.text)..traits.addAll(selectedTraits);
                if (animatedPeople.isNotEmpty) newPerson.sortOrder = animatedPeople.first.sortOrder - 1;
                if (allTraits.isEmpty) {
                  setState(() {
                    allPeople.add(newPerson);
                  });
                  await Future.delayed(Duration(milliseconds: 100));
                }
                animatedPeople.insert(0, newPerson);
                DatabaseHelper.personBox.put(newPerson);
              } else {
                person.name = nameController.text;
                person.traits
                  ..clear()
                  ..addAll(selectedTraits);
                DatabaseHelper.personBox.put(person);
              }

              setState(() {});
              if(context.mounted) Navigator.pop(context);
            }
          },
          child: Text(person == null ? "Add" : "Update", style: const TextStyle(color: Colors.blueAccent)),
        ),
      ],
    );
  }
}
