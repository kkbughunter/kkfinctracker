import 'package:flutter/material.dart';
import 'package:kkfinctracker/pages/user_details/user_details_view.dart';
import 'home_controller.dart';
import 'home_tools.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController _controller = HomeController();
  final HomeTools _homeTools = HomeTools();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[300],
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: () {
              _homeTools.addNewGroup(context);
            },
          ),
        ],
      ),
      body: StreamBuilder<Map<dynamic, dynamic>>(
        stream: _controller.fetchUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data != null) {
            var groups = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: groups.keys.length,
              itemBuilder: (context, index) {
                var groupName = groups.keys.elementAt(index);
                var groupUsers = groups[groupName] as Map<dynamic, dynamic>;

                var filteredUsers = Map.from(groupUsers);
                filteredUsers.remove('number_of_users');

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                          groupName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22.0,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.person_add),
                          onPressed: () {
                            _homeTools.addNewUser(context, groupName);
                          },
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          childAspectRatio: 3 / 2,
                        ),
                        itemCount: filteredUsers.length,
                        padding: const EdgeInsets.all(8.0),
                        itemBuilder: (context, index) {
                          var user = filteredUsers.entries.elementAt(index);
                          var userName = user.key;
                          var userData = user.value as Map;

                          Color cardColor = Colors.blue[100]!;

                          if (userData['role'] == 'admin') {
                            cardColor = Colors.red[100]!;
                          } else if (userData['role'] == 'user') {
                            cardColor = Colors.green[100]!;
                          }

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserDetailsView(
                                    groupName: groupName,
                                    userName: userName,
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              color: cardColor,
                              margin: const EdgeInsets.all(8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
