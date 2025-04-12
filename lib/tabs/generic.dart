import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:objectbox/objectbox.dart';

import '../const.dart';
import '../database/database_helper.dart';
import '../database/models.dart';
import '../pages/comments.dart';
import '../widgets/delete.dart';
import '../widgets/dialog.dart';
import '../widgets/fields.dart';
import '../widgets/format_date.dart';

class GenericListView extends StatefulWidget {
  final ListType type;

  const GenericListView({super.key, required this.type});

  @override
  State<GenericListView> createState() => _GenericListViewState();
}

class _GenericListViewState extends State<GenericListView> {
  late List<dynamic> allItems;
  List<dynamic> animatedItems = [];
  late Box<dynamic> itemBox;

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void didUpdateWidget(GenericListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type != widget.type) {
      load();
    }
  }

  void load() async {
    if (widget.type == ListType.daily) {
      allItems = DatabaseHelper.getAllDailies();
      itemBox = DatabaseHelper.dailyBox;
    } else {
      allItems = DatabaseHelper.getAllCategories();
      itemBox = DatabaseHelper.categoryBox;
    }

    animatedItems = [];

    int animatedCount = allItems.length < 10 ? allItems.length : 10;

    for (int i = 0; i < animatedCount; i++) {
      await Future.delayed(Duration(milliseconds: 20 * i));
      if (mounted) {
        setState(() {
          animatedItems.add(allItems[i]);
        });
      }
    }

    if (allItems.length > animatedCount) {
      setState(() {
        animatedItems.addAll(allItems.sublist(animatedCount));
      });
    }
  }

  void _updateItemOrder(List<dynamic> updatedItems) {
    dynamic typedItems = widget.type == ListType.daily ? updatedItems.cast<Daily>() : updatedItems.cast<Category>();

    for (int i = 0; i < typedItems.length; i++) {
      typedItems[i].sortOrder = i + 1;
    }

    itemBox.putMany(typedItems);
  }

  String get title => widget.type == ListType.daily ? 'Daily' : 'Category';

  String get emptyMessage => widget.type == ListType.daily ? 'No Dailies Available' : 'No Categories Available';

  String get addButtonText => widget.type == ListType.daily ? 'Add Daily' : 'Add Category';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        allItems.isEmpty
            ? Center(child: Text(emptyMessage, style: const TextStyle(color: Colors.white)))
            : widget.type == ListType.daily
            ? _buildAnimatedList<Daily>(animatedItems.cast<Daily>())
            : _buildAnimatedList<Category>(animatedItems.cast<Category>()),
        Align(alignment: Alignment.bottomRight, child: Padding(padding: const EdgeInsets.all(28.0), child: FloatingActionButton(backgroundColor: Colors.blueAccent, child: Icon(widget.type == ListType.daily ? Icons.add_alarm_outlined : Icons.add_box_rounded, color: Colors.white), onPressed: () => _showItemDialog(context, null)))),
      ],
    );
  }

  Widget _buildAnimatedList<T extends Object>(List<T> items) {
    return AnimatedReorderableListView<T>(
      items: items,
      isSameItem: (a, b) => (a as dynamic).id == (b as dynamic).id,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          final moved = items.removeAt(oldIndex);
          items.insert(newIndex, moved);
          _updateItemOrder(animatedItems);
        });
      },
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.0),
          key: Key('${widget.type}_${(item as dynamic).id}'),
          child: Slidable(
            key: Key('${widget.type}_${(item as dynamic).id}'),
            startActionPane: ActionPane(extentRatio: 0.25, motion: const StretchMotion(), children: [SlidableAction(onPressed: (_) => _showItemDialog(context, item), backgroundColor: Colors.blue.shade800, foregroundColor: Colors.white, icon: Icons.edit, label: "Edit", borderRadius: BorderRadius.horizontal(right: Radius.circular(15)))]),
            endActionPane: ActionPane(
              extentRatio: 0.25,
              motion: const StretchMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) async {
                    final shouldDelete = await showNosDeleteDialog(context);
                    if (shouldDelete) {
                      setState(() {
                        animatedItems.removeAt(index);
                      });
                      if(animatedItems.isEmpty) {
                        await Future.delayed(Duration(milliseconds: 200));
                        setState(() {
                          allItems.clear();
                        });
                      }
                      itemBox.remove((item as dynamic).id);
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
            child: _buildItemCard(item),
          ),
        );
      },
      enterTransition: [FadeIn(), Landing()],
      exitTransition: [FadeIn(duration: Duration(milliseconds: 200)), SlideInLeft(duration: Duration(milliseconds: 150))],
    );
  }

  Widget _buildItemCard(dynamic item) {
    final title = widget.type == ListType.daily ? (item as Daily).title : (item as Category).title;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: OpenContainer<String>(
        middleColor: Colors.black,
        openColor: Colors.black,
        closedColor: Colors.grey.shade800,
        closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        transitionDuration: const Duration(milliseconds: 200),
        closedBuilder: (_, openContainer) {
          return Padding(padding: const EdgeInsets.all(16.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)), Text(formatDate(item.lastModified), style: const TextStyle(color: Colors.white70, fontSize: 12))]));
        },
        openBuilder: (_, __) => GenericCommentsPage(item: item, type: widget.type, title: title),
      ),
    );
  }

  void _showItemDialog(BuildContext context, dynamic item) {
    TextEditingController titleController = TextEditingController();

    if (item != null) {
      titleController.text = widget.type == ListType.daily ? (item as Daily).title : (item as Category).title;
    }

    showNosDialog(context, item == null ? "New $title" : "Edit $title", NosTextField(controller: titleController, hintText: '$title Name'), [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.red))),
      TextButton(
        onPressed: () async {
          if (titleController.text.isNotEmpty) {
            if (item == null) {
              if (widget.type == ListType.daily) {
                Daily newDaily = Daily(title: titleController.text);
                if (animatedItems.isNotEmpty) newDaily.sortOrder = animatedItems.first.sortOrder - 1;
                if (allItems.isEmpty) {
                  setState(() {
                    allItems.add(newDaily);
                  });
                  await Future.delayed(Duration(milliseconds: 100));
                }
                animatedItems.insert(0, newDaily);
                DatabaseHelper.dailyBox.put(newDaily);
              } else {
                Category newCat = Category(title: titleController.text);
                newCat.sortOrder = animatedItems.first.sortOrder - 1;
                if (allItems.isEmpty) {
                  setState(() {
                    allItems.add(newCat);
                  });
                  await Future.delayed(Duration(milliseconds: 100));
                }
                animatedItems.insert(0, newCat);
                DatabaseHelper.categoryBox.put(newCat);
              }
            } else {
              if (widget.type == ListType.daily) {
                (item as Daily).title = titleController.text;
                DatabaseHelper.dailyBox.put(item);
              } else {
                (item as Category).title = titleController.text;
                DatabaseHelper.categoryBox.put(item);
              }
            }
            setState(() {});
            if(context.mounted)Navigator.pop(context);
          }
        },
        child: Text(item == null ? "Add" : "Update", style: const TextStyle(color: Colors.blueAccent)),
      ),
    ]);
  }
}
