import 'package:flutter/material.dart';
import 'package:smartcampusadmin/createuser/createuser.dart';
import 'package:smartcampusadmin/createuser/manageuserRepo.dart';
import 'package:smartcampusadmin/mod/usersmodel.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> users = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    listUsers();
  }

  Future<void> listUsers() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<dynamic> response = await ManageuserMethod().listUsersInGroup();
      List<UserModel> usermodel = response[1];
      setState(() {
        users = usermodel;
      });
    } catch (e) {
      print("Error fetching users: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Management"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: listUsers,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateUserPage()),
          ).then((_) => listUsers());
        },
        child: Icon(Icons.add),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : users.isEmpty
              ? Center(child: Text("No users found"))
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(users[index].email),
                        subtitle: Text(users[index].sub),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {},
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
