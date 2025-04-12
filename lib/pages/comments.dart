import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../const.dart';
import '../database/database_helper.dart';
import '../widgets/delete.dart';
import 'editor.dart';

class GenericCommentsPage extends StatefulWidget {
  final dynamic item;
  final ListType type;
  final String title;

  const GenericCommentsPage({super.key, required this.item, required this.type, required this.title});

  @override
  State<GenericCommentsPage> createState() => _GenericCommentsPageState();
}

class _GenericCommentsPageState extends State<GenericCommentsPage> {
  late List<String> allComments;
  List<String> displayedComments = [];

  @override
  void initState() {
    super.initState();
    allComments = List.from(widget.item.comments);
    animateInitialComments();
  }

  Future<void> animateInitialComments() async {
    int animatedCount = allComments.length < 10 ? allComments.length : 10;

    for (int i = 0; i < animatedCount; i++) {
      await Future.delayed(Duration(milliseconds: 20 * i));
      setState(() {
        displayedComments.add(allComments[i]);
      });
    }

    // Add the rest without animation
    if (allComments.length > animatedCount) {
      setState(() {
        displayedComments.addAll(allComments.sublist(animatedCount));
      });
    }
  }

  void _saveChanges() {
    widget.item.comments = displayedComments;
    if (widget.type == ListType.daily) {
      DatabaseHelper.dailyBox.put(widget.item);
    } else if (widget.type == ListType.people) {
      DatabaseHelper.personBox.put(widget.item);
    } else {
      DatabaseHelper.categoryBox.put(widget.item);
    }
  }

  void _reorderComments(int oldIndex, int newIndex) {
    setState(() {
      final item = displayedComments.removeAt(oldIndex);
      displayedComments.insert(newIndex, item);
      _saveChanges();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: AnimatedTextKit(totalRepeatCount: 1, animatedTexts: [TypewriterAnimatedText(widget.title, textStyle: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), speed: const Duration(milliseconds: 100))]),
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
        actions: [
          OpenContainer<String>(
            transitionDuration: const Duration(milliseconds: 200),
            middleColor: Colors.black,
            openColor: Colors.black,
            closedColor: Colors.transparent,
            closedBuilder: (_, openContainer) {
              return IconButton(icon: const Icon(Icons.add_comment_rounded, color: Colors.white), onPressed: openContainer);
            },
            openBuilder: (_, __) => CommentEditorPage(initialText: null),
            onClosed: (result) async {
              if (result != null) {
                if (allComments.isEmpty) {
                  setState(() {
                    allComments.add(result);
                  });
                  await Future.delayed(Duration(milliseconds: 100));
                }

                setState(() {
                  displayedComments.add(result);
                  _saveChanges();
                });
              }
            },
          ),
        ],
      ),
      body:
          allComments.isEmpty
              ? const Center(child: Text('No comments yet', style: TextStyle(color: Colors.white)))
              : AnimatedReorderableListView(
                items: displayedComments,
                onReorder: _reorderComments,
                isSameItem: (a, b) => a == b,
                itemBuilder: (context, index) {
                  final comment = displayedComments[index];
                  return Padding(
                    key: ValueKey(comment),
                    padding: const EdgeInsets.symmetric(vertical: 1.0),
                    child: Slidable(
                      key: Key(comment),
                      endActionPane: ActionPane(
                        extentRatio: 0.25,
                        motion: const StretchMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (_) async {
                              final shouldDelete = await showNosDeleteDialog(context);
                              if (shouldDelete) {
                                setState(() {
                                  displayedComments.removeAt(index);
                                });

                                if(displayedComments.isEmpty) {
                                  await Future.delayed(Duration(milliseconds: 200));
                                  allComments.clear();
                                }

                                setState(() {
                                  _saveChanges();
                                });
                              }
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
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
                            return ListTile(title: MarkdownBody(data: comment));
                          },
                          openBuilder: (_, __) => CommentEditorPage(initialText: comment),
                          onClosed: (result) {
                            if (result != null) {
                              setState(() {
                                displayedComments[index] = result;
                                _saveChanges();
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  );
                },
                enterTransition: [FadeIn(), Landing()],
                exitTransition: [FadeIn(duration: Duration(milliseconds: 200)), SlideInLeft(duration: Duration(milliseconds: 150))],
              ),
    );
  }
}
