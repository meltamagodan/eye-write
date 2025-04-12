

/*void _commentDialog(int? index) {
    TextEditingController controller = TextEditingController();

    if (index != null) {
      controller.text = comments[index];
    }

    showNosDialog(
      context,
      index == null ? "Add Comment" : "Edit Comment",
      StatefulBuilder(
        builder: (context, setState) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Markdown Toolbar
                Wrap(
                  spacing: 8,
                  children: [
                    _buildMarkdownButton("B", "**", controller, setState), // Bold
                    _buildMarkdownButton("I", "_", controller, setState), // Italic
                    _buildMarkdownButton("H1", "# ", controller, setState), // Header
                    _buildMarkdownButton("~~", "~~", controller, setState),
                    _buildMarkdownButton("Link", "[Text](url)", controller, setState), // Link
                    _buildMarkdownButton("Code", "`", controller, setState), // Code
                  ],
                ),
                const SizedBox(height: 8),

                // Input Field
                NosTextField(
                  controller: controller,
                  hintText: 'Write a comment...',
                  multiline: true,
                  onChanged: (_){
                    setState(() {
                      controller.text;
                    });
                  },
                ),

                const SizedBox(height: 8),

                // Markdown Preview
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: MarkdownBody(data: controller.text), // Live preview
                ),
              ],
            ),
          );
        },
      ),
      [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: () {
            if (controller.text.isNotEmpty) {
              setState(() {
                if (index == null) {
                  comments.add(controller.text);
                } else {
                  comments[index] = controller.text;
                }
                _saveChanges();
              });
              Navigator.pop(context);
            }
          },
          child: Text(
            index == null ? "Add" : "Update",
            style: const TextStyle(color: Colors.blueAccent),
          ),
        ),
      ],
    );
  }

  Widget _buildMarkdownButton(String label, String markdown, TextEditingController controller, StateSetter setState) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade800),
      onPressed: () {
        final selection = controller.selection;
        final text = controller.text;

        // Insert markdown at the cursor position
        String newText;
        if (selection.start == selection.end) {
          newText = text.replaceRange(selection.start, selection.start, markdown);
        } else {
          newText = text.replaceRange(selection.start, selection.end, "$markdown${text.substring(selection.start, selection.end)}$markdown");
        }

        setState(() => controller.text = newText);
        controller.selection = TextSelection.collapsed(offset: selection.start + markdown.length);
      },
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }*/


/*
void _openCommentEditor(int? index) async {
  final String? result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CommentEditorPage(
        initialText: index != null ? comments[index] : null,
      ),
    ),
  );

  if (result != null) {
    setState(() {
      if (index == null) {
        comments.add(result);
      } else {
        comments[index] = result;
      }
      _saveChanges();
    });
  }
}*/
