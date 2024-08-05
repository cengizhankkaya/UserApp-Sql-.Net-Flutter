import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:form_builder_validators/form_builder_validators.dart';

import '../../model/model.dart';
import '../api/api_handler.dart';

class AddUser extends StatefulWidget {
  const AddUser({super.key});

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final _formKey = GlobalKey<FormBuilderState>();
  ApiHandler apiHandler = ApiHandler();

  void addUser() async {
    if (_formKey.currentState!.saveAndValidate()) {
      final data = _formKey.currentState!.value;

      final user = User(
        userId: 0,
        name: data['name'],
        address: data['address'],
      );

      print('User Data: $user');

      try {
        final response = await apiHandler.addUser(user: user);
        print('API Response: ${response.statusCode} - ${response.body}');
        if (response.statusCode == 200) {
          if (!mounted) return;
          Navigator.pop(context);

          print('Failed to add user: ${response.body}');
        }
      } catch (e) {
        print('Error adding user: $e');
      }
    } else {
      print('Form is not valid');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add User"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: MaterialButton(
        color: Colors.teal,
        textColor: Colors.white,
        padding: const EdgeInsets.all(20),
        onPressed: addUser,
        child: const Text('Add'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              FormBuilderTextField(
                name: 'name',
                decoration: const InputDecoration(labelText: 'Name'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),
              const SizedBox(
                height: 10,
              ),
              FormBuilderTextField(
                name: 'address',
                decoration: const InputDecoration(labelText: 'Address'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}
