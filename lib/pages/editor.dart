import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class CommentEditorPage extends StatefulWidget {
  final String? initialText;

  const CommentEditorPage({super.key, this.initialText});

  @override
  State<CommentEditorPage> createState() => _CommentEditorPageState();
}

class _CommentEditorPageState extends State<CommentEditorPage> {
  late TextEditingController _controller;
  List<String> _history = [];
  int _historyIndex = -1;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText ?? "");
    _saveToHistory();
  }

  void _saveToHistory() {
    if (_history.isEmpty || _history.last != _controller.text) {
      _history = _history.sublist(0, _historyIndex + 1);
      _history.add(_controller.text);
      _historyIndex++;
    }
    setState(() {

    });
  }

  void _undo() {
    if (_historyIndex > 0) {
      setState(() {
        _historyIndex--;
        _controller.text = _history[_historyIndex];
      });
    }
  }

  void _redo() {
    if (_historyIndex < _history.length - 1) {
      setState(() {
        _historyIndex++;
        _controller.text = _history[_historyIndex];
      });
    }
  }

  Widget _buildMarkdownButton(String label, String markdown) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade800),
      onPressed: () {
        final selection = _controller.selection;
        final text = _controller.text;

        String newText;
        if (selection.start == selection.end) {
          newText = text.replaceRange(selection.start, selection.start, markdown);
        } else {
          newText = text.replaceRange(
            selection.start,
            selection.end,
            "$markdown${text.substring(selection.start, selection.end)}$markdown",
          );
        }

        setState(() {
          _controller.text = newText;
          _saveToHistory();
        });
        _controller.selection = TextSelection.collapsed(offset: selection.start + markdown.length);
      },
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: AnimatedTextKit(
          totalRepeatCount: 1,
          animatedTexts: [
            TypewriterAnimatedText(
              widget.initialText == null ? "Add Comment" : "Edit Comment",
              textStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              speed: Duration(milliseconds: 100),
            ),
          ],
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo, color: Colors.white),
            onPressed: _undo,
          ),
          IconButton(
            icon: const Icon(Icons.redo, color: Colors.white),
            onPressed: _redo,
          ),
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                Navigator.pop(context, _controller.text);
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: (_) => _saveToHistory(),
                  cursorColor: Colors.white,
                  controller: _controller,
                  maxLines: null,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "Comment...",
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                    filled: true,
                    fillColor: Colors.black,
                    contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Preview:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                      MarkdownBody(data: _controller.text),
                    ],
                  ),
                ),
                SizedBox(height: 50,)
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Wrap(
              spacing: 8,
              children: [
                _buildMarkdownButton("B", "**"),
                _buildMarkdownButton("I", "_"),
                _buildMarkdownButton("H1", "# "),
                _buildMarkdownButton("~~", "~~"),
                _buildMarkdownButton("Code", "`"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}