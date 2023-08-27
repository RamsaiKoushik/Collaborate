import 'package:collaborate/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MemberSelectionDialog extends StatefulWidget {
  Map<String, String> availableMembers;
  Map<String, String> displayMembers;

  // ignore: use_key_in_widget_constructors
  MemberSelectionDialog(
      {required this.availableMembers, required this.displayMembers
      // required this.selectedMembers,
      });

  @override
  _MemberSelectionDialogState createState() => _MemberSelectionDialogState();
}

class _MemberSelectionDialogState extends State<MemberSelectionDialog> {
  List<String> selectedMembers = [];

  @override
  void initState() {
    // selectedMembers = List.from(widget.selectedMembers);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: collaborateAppBarBgColor,
      title: Text(
        'Select Members',
        style: GoogleFonts.raleway(color: color4),
      ),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    onChanged: filterMembers,
                    decoration: const InputDecoration(
                      labelText: 'Search Members',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.displayMembers.keys.map((userId) {
                    String userName = widget.displayMembers[userId]!;

                    bool isSelected = selectedMembers.contains(userId);

                    return CheckboxListTile(
                      value: isSelected,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(userName,
                          style: GoogleFonts.raleway(color: color4)),
                      onChanged: (value) {
                        setState(() {
                          if (isSelected) {
                            selectedMembers.remove(userId);
                          } else {
                            selectedMembers.add(userId);
                          }
                        });
                      },
                      activeColor: color4,
                      checkColor: collaborateAppBarBgColor,
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          onPressed: () {
            Navigator.pop(context, selectedMembers);
          },
          child: Text(
            'Submit',
            style: GoogleFonts.raleway(color: blackColor),
          ),
        ),
      ],
    );
  }

  void filterMembers(String query) {
    Map<String, String> filteredMembers = {};

    widget.availableMembers.forEach((userId, userName) {
      if (userName.toLowerCase().contains(query.toLowerCase())) {
        filteredMembers[userId] = userName;
      }
    });

    setState(() {
      widget.displayMembers = filteredMembers;
    });
  }
}
