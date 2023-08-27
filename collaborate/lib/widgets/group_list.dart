import 'package:collaborate/screens/filter_parameters.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collaborate/screens/group_tile.dart';

import '../resources/auth_methods.dart'; // Import the GroupTile widget

class GroupListingPage extends StatefulWidget {
  final FilterParameters filterParameters;

  const GroupListingPage({super.key, required this.filterParameters});

  @override
  State<GroupListingPage> createState() => _GroupListingPageState();
}

class _GroupListingPageState extends State<GroupListingPage> {
  late FilterParameters _currentFilters;

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.filterParameters;
  }

  @override
  void didUpdateWidget(covariant GroupListingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_currentFilters != oldWidget.filterParameters) {
      setState(() {
        _currentFilters = widget.filterParameters;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .doc('collaborate')
            .collection('groups')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final groups = snapshot.data!.docs;

          final filteredGroups = groups.where((group) {
            final categoryMatches = _currentFilters.category.isEmpty ||
                _currentFilters.category.any((element) {
                  return (group['category'] == element);
                });
            final domainsMatch = _currentFilters.domains.isEmpty ||
                _currentFilters.domains.every((domain) {
                  return (group['domains'] as List).contains(domain);
                });
            final isMemberMatch = _currentFilters.isMember == null ||
                (_currentFilters.isMember! &&
                    group['groupMembers']
                        .contains(AuthMethods().getUserId())) ||
                (!_currentFilters.isMember! &&
                    !group['groupMembers'].contains(AuthMethods().getUserId()));

            return categoryMatches && domainsMatch && isMemberMatch;
          }).toList();

          return ListView.builder(
            itemCount: filteredGroups.length,
            itemBuilder: (context, index) {
              final group = filteredGroups[index];

              return Column(
                children: [
                  SizedBox(
                    height: height * 0.01,
                  ),
                  GroupTile(
                    groupId: group["groupId"],
                    groupName: group["groupName"],
                    domains: group["domains"] ?? [],
                    profilePic: group['profilePic'],
                    category: group['category'],
                    currentUserUid: AuthMethods().getUserId(),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}