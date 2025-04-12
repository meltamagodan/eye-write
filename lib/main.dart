import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:eyewrite/tabs/generic.dart';
import 'package:eyewrite/tabs/people.dart';
import 'package:eyewrite/tabs/traits.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';

import 'const.dart';
import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData.dark().copyWith(textTheme: TextTheme(labelMedium: TextStyle(color: Colors.blue))), home: DatabaseScreen());
  }
}

class DatabaseScreen extends StatefulWidget {
  const DatabaseScreen({super.key});

  @override
  State<DatabaseScreen> createState() => _DatabaseScreenState();
}

class _DatabaseScreenState extends State<DatabaseScreen> with TickerProviderStateMixin {
  bool _loading = true;
  int selectedIndex = 0;
  int oldIndex = -1;
  List<Widget> _pages = [SizedBox(), SizedBox(), SizedBox(), SizedBox()];
  late AnimationController _controller;
  bool checking = true;
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 7));
    _controller.repeat();
    authAndLoad();
  }

  Future<void> authAndLoad() async {
    final bool didAuthenticate = await auth.authenticate(localizedReason: 'WHO ARE YOU?');
    if (didAuthenticate) {
      setState(() {
        _pages = [TraitsListView(), PeopleListView(), GenericListView(type: ListType.daily), GenericListView(type: ListType.category)];
        _loading = false;
        checking = false;
      });
    }
  }

  String removeDuplicatedPath(String fullPath) {
    // Split the path into segments
    List<String> segments = fullPath.split('/');
    segments.removeAt(0);

    // Determine the head (e.g., 'storage/emulated/0' or 'sdcard')
    int headLength = 0;
    if (segments.length >= 3 && segments[0] == 'storage' && segments[1] == 'emulated') {
      headLength = 3;
    } else if (segments.isNotEmpty && segments[0] == 'sdcard') {
      headLength = 1;
    } else {
      return fullPath;
    }

    final path = segments.sublist(headLength);

    int mid = path.length ~/ 2;
    List<String> firstHalf = path.sublist(0, mid);
    List<String> secondHalf = path.sublist(mid);

    for (int i = 0; i < mid; i++) {
      if (firstHalf[i] != secondHalf[i]) return fullPath;
    }

    String newPath = "";
    for (int i = 0; i < headLength + mid; i++) {
      newPath += "/${segments[i]}";
    }

    return newPath;
  }

  Future<void> backupDatabase() async {
    if(checking) return;
    Directory storePath = await getApplicationDocumentsDirectory();
    final path = "${storePath.path}/objectbox/data.mdb";

    try {
      final directory = "/storage/emulated/0/Documents/Eye Write";

      Directory(directory).create();

      await File(path).copy("$directory/${DateTime.now().toIso8601String().replaceAll(":", "-")}.mdb");
      const snackBar = SnackBar(content: Text("Backup completed to: Documents/Eye Write", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      const eS = SnackBar(content: Text("Error: Check Storage Permissions", style: TextStyle(color: Colors.white)), backgroundColor: Colors.red);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(eS);
    }
  }

  Future<void> restoreDatabase() async {
    if(checking) return;
    try {
      final file = await FilePicker.platform.pickFiles();
      if (file == null) return;

      setState(() {
        _pages = [SizedBox(), SizedBox(), SizedBox(), SizedBox()];
      });

      Directory storePath = await getApplicationDocumentsDirectory();
      final path = "${storePath.path}/objectbox/data.mdb";

      // Close the current store before replacing
      DatabaseHelper.close();

      // Delete existing files
      await File(path).delete();

      await File(file.files.first.path ?? "").copy(path);

      await DatabaseHelper.init();

      Future.delayed(Duration(milliseconds: 250));

      setState(() {
        _pages = [TraitsListView(), PeopleListView(), GenericListView(type: ListType.daily), GenericListView(type: ListType.category)];
      });

      const snackBar = SnackBar(content: Text("Restore Completed Successfully", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      const snackBar = SnackBar(content: Text("Something Went Wrong", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Always dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                if (checking) {
                  authAndLoad();
                }
              },
              onDoubleTap: backupDatabase,
              onLongPress: restoreDatabase,
              child: Lottie.asset("assets/lottie/eye3.json", controller: _controller, width: 50),
            ),
            Flexible(
              child: AnimatedTextKit(
                totalRepeatCount: 1,
                animatedTexts: [
                  if (selectedIndex == 0) TypewriterAnimatedText('Being chill is my best trait... until WiFi stops working', textStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), speed: Duration(milliseconds: 100)),
                  if (selectedIndex == 1) TypewriterAnimatedText("I'm not saying I dislike people, but my favorite place is 'Do Not Disturb' mode", textStyle: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), speed: Duration(milliseconds: 100)),
                  if (selectedIndex == 2) TypewriterAnimatedText('I have a daily routine. It’s called ‘trying to survive’', textStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), speed: Duration(milliseconds: 100)),
                  if (selectedIndex == 3) TypewriterAnimatedText('I believe in organized chaos... that’s a category, right?', textStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), speed: Duration(milliseconds: 100)),
                ],
                key: ValueKey(selectedIndex),
              ),
            ),
          ],
        ),
      ),
      body: _loading ? SizedBox() : _pages[selectedIndex],
      bottomNavigationBar: GNav(
        backgroundColor: Colors.black,
        color: Colors.white,
        activeColor: Colors.white,
        tabBackgroundColor: Colors.grey.shade800,
        gap: 8,
        iconSize: 25,
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(10),
        tabMargin: EdgeInsets.all(15),
        onTabChange: (i) {
          setState(() {
            selectedIndex = i;
          });
        },
        tabs: [GButton(icon: Icons.psychology, text: 'Traits'), GButton(icon: Icons.group, text: 'People'), GButton(icon: Icons.autorenew, text: 'Daily'), GButton(icon: Icons.category, text: 'Categories')],
      ),
    );
  }
}
