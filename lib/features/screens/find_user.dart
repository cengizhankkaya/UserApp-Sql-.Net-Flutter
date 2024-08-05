import 'package:event_app/features/api/api_handler.dart';
import 'package:flutter/material.dart';
import '../../model/model.dart';

class FindUser extends StatefulWidget {
  const FindUser({super.key});

  @override
  State<FindUser> createState() => _FindState();
}

class _FindState extends State<FindUser> {
  ApiHandler apiHandler = ApiHandler();
  User? user;
  TextEditingController textEditingController = TextEditingController();

  void findUser(int userId) async {
    User? fetchedUser = await apiHandler.getUserById(userId: userId);
    setState(() {
      user = fetchedUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find User"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: MaterialButton(
        color: Colors.teal,
        textColor: Colors.white,
        padding: const EdgeInsets.all(20),
        onPressed: () {
          findUser(int.parse(textEditingController.text));
        },
        child: const Text('Find'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              controller: textEditingController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter User ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            if (user != null)
              ListTile(
                leading: Text("${user!.userId}"),
                title: Text(user!.name),
                subtitle: Text(user!.address),
              )
            else
              const Text('No user found'),
          ],
        ),
      ),
    );
  }
}
