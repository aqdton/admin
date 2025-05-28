import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountManagementPage extends StatefulWidget {
  @override
  _AccountManagementPageState createState() => _AccountManagementPageState();
}

class _AccountManagementPageState extends State<AccountManagementPage> {
  // Added name controllers for teacher and cashier
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController suffixController = TextEditingController();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];

  String selectedRole = 'teacher';
  String filterRole = 'all';

  @override
  void initState() {
    super.initState();
    fetchUsers();

    searchController.addListener(() {
      filterUserList();
    });

    // For auto-generating username on name changes
    firstNameController.addListener(_updateUsername);
    middleNameController.addListener(_updateUsername);
    lastNameController.addListener(_updateUsername);
    suffixController.addListener(_updateUsername);
  }

  void _updateUsername() {
    if (selectedRole == 'teacher' || selectedRole == 'cashier') {
      String first = firstNameController.text.trim().toLowerCase();
      String last = lastNameController.text.trim().toLowerCase();
      String suffix = suffixController.text.trim().toLowerCase();

      String generatedUsername = first + last;
      if (suffix.isNotEmpty) {
        generatedUsername += suffix;
      }

      setState(() {
        usernameController.text = generatedUsername;
      });
    }
  }

  Future<void> fetchUsers() async {
    final supabase = Supabase.instance.client;

    try {
      var query = supabase.from('users').select();

      if (filterRole != 'all') {
        query = query.eq('role', filterRole);
      }

      final response = await query;

      setState(() {
        users = List<Map<String, dynamic>>.from(response);
        filterUserList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching users: $e")),
      );
    }
  }

  void filterUserList() {
    final query = searchController.text.toLowerCase();

    setState(() {
      filteredUsers = users.where((user) {
        final username = (user['username'] ?? '').toString().toLowerCase();
        final email = (user['email'] ?? '').toString().toLowerCase();
        return username.contains(query) || email.contains(query);
      }).toList();
    });
  }

  Future<void> createAccount() async {
    final supabase = Supabase.instance.client;
    
    // For teacher and cashier, use generated username from names
    String username;
    if (selectedRole == 'teacher' || selectedRole == 'cashier') {
      username = usernameController.text.trim();
    } else {
      username = usernameController.text.trim(); // for students, editable username
    }

    String password = passwordController.text.trim();
    String email = emailController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Username and password are required.")),
      );
      return;
    }

    if (selectedRole == 'teacher' && email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email is required for teachers.")),
      );
      return;
    }

    try {
      // Check if username already exists
      final existing = await supabase
          .from('users')
          .select()
          .eq('username', username)
          .limit(1)
          .single();

      if (existing != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Username already exists.")),
        );
        return;
      }
    } catch (_) {
      // No existing user found, proceed
    }

    try {
      await supabase.from('users').insert({
        'username': username,
        'password': password, // Ideally hash password before storing
        'role': selectedRole,
        'email': selectedRole == 'teacher' ? email : null,
        'first_name': firstNameController.text.trim(),
        'middle_name': middleNameController.text.trim(),
        'last_name': lastNameController.text.trim(),
        'suffix': suffixController.text.trim(),
      });
      final authResponse = await supabase.auth.admin.createUser(
  AdminUserAttributes(
    email: email,
    password: password,
    emailConfirm: true,
  ),
);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Account created successfully!")),
      );

      // Clear all controllers
      firstNameController.clear();
      middleNameController.clear();
      lastNameController.clear();
      suffixController.clear();

      usernameController.clear();
      passwordController.clear();
      emailController.clear();
      fetchUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }

  Future<void> deleteUser(String id) async {
    final supabase = Supabase.instance.client;
    try {
      await supabase.from('users').delete().eq('id', id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User deleted.")),
      );
      fetchUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Delete failed: $e")),
      );
    }
  }

  Future<void> editUserDialog(Map<String, dynamic> user) async {
    final TextEditingController editUsernameController =
        TextEditingController(text: user['username']);
    final TextEditingController editPasswordController =
        TextEditingController(text: user['password']);
    final TextEditingController editEmailController =
        TextEditingController(text: user['email'] ?? '');
    String editRole = user['role'];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text('Edit User'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: editUsernameController,
                    decoration: InputDecoration(labelText: 'Username'),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: editPasswordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: editRole,
                    items: ['teacher', 'student', 'cashier']
                        .map((role) => DropdownMenuItem(
                              value: role,
                              child: Text(role.capitalize()),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setStateDialog(() {
                          editRole = value;
                        });
                      }
                    },
                    decoration: InputDecoration(labelText: 'Role'),
                  ),
                  if (editRole == 'teacher') ...[
                    SizedBox(height: 12),
                    TextField(
                      controller: editEmailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context), child: Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  String newUsername = editUsernameController.text.trim();
                  String newPassword = editPasswordController.text.trim();
                  String newEmail = editEmailController.text.trim();

                  if (newUsername.isEmpty || newPassword.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Username and password cannot be empty')),
                    );
                    return;
                  }

                  if (editRole == 'teacher' && newEmail.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Email is required for teachers')),
                    );
                    return;
                  }

                  try {
                    await Supabase.instance.client.from('users').update({
                      'username': newUsername,
                      'password': newPassword,
                      'role': editRole,
                      'email': editRole == 'teacher' ? newEmail : null,
                    }).eq('id', user['id']);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('User updated successfully!')),
                    );
                    Navigator.pop(context);
                    fetchUsers();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Update failed: $e')),
                    );
                  }
                },
                child: Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    suffixController.dispose();

    usernameController.dispose();
    passwordController.dispose();
    emailController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isTeacherOrCashier = selectedRole == 'teacher' || selectedRole == 'cashier';

    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text("Account Management"),
        backgroundColor: Colors.teal.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Input Form
                    Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        child: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              value: selectedRole,
                              items: ['teacher', 'student', 'cashier']
                                  .map((role) => DropdownMenuItem(
                                        value: role,
                                        child: Text(role.capitalize()),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    selectedRole = value;
                                    // Clear relevant fields when role changes
                                    firstNameController.clear();
                                    middleNameController.clear();
                                    lastNameController.clear();
                                    suffixController.clear();
                                    emailController.clear();
                                    usernameController.clear();
                                    passwordController.clear();
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                labelText: 'Role',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 16),

                            if (isTeacherOrCashier) ...[
                              // Name fields for teacher or cashier
                              TextField(
                                controller: firstNameController,
                                decoration: InputDecoration(
                                  labelText: 'First Name',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              SizedBox(height: 10),
                              TextField(
                                controller: middleNameController,
                                decoration: InputDecoration(
                                  labelText: 'Middle Name',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              SizedBox(height: 10),
                              TextField(
                                controller: lastNameController,
                                decoration: InputDecoration(
                                  labelText: 'Last Name',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              SizedBox(height: 10),
                              TextField(
                                controller: suffixController,
                                decoration: InputDecoration(
                                  labelText: 'Suffix (optional)',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              SizedBox(height: 10),
                            ],

                            if (selectedRole == 'teacher') ...[
                              TextField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              SizedBox(height: 10),
                            ],

                            // Username field (auto-generated for teacher/cashier)
                            TextField(
                              controller: usernameController,
                              decoration: InputDecoration(
                                labelText: 'Username',
                                border: OutlineInputBorder(),
                              ),
                              readOnly: isTeacherOrCashier,
                            ),
                            SizedBox(height: 10),

                            TextField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 16),

                            ElevatedButton(
                              onPressed: createAccount,
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 50),
                                backgroundColor: Colors.teal.shade700,
                              ),
                              child: Text(
                                'Create Account',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Search and filter
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              labelText: 'Search by username or email',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        DropdownButton<String>(
                          value: filterRole,
                          items: ['all', 'teacher', 'student', 'cashier']
                              .map((role) => DropdownMenuItem(
                                    value: role,
                                    child: Text(role.capitalize()),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                filterRole = value;
                                fetchUsers();
                              });
                            }
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Users List
                    filteredUsers.isEmpty
                        ? Center(child: Text('No users found'))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = filteredUsers[index];
                              return Card(
                                elevation: 1,
                                margin: EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  leading: Icon(Icons.person),
                                  title: Text(user['username'] ?? ''),
                                  subtitle: Text(
                                      "Role: ${user['role']?.toString().capitalize() ?? ''}\nEmail: ${user['email'] ?? 'N/A'}"),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => editUserDialog(user),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text('Confirm Delete'),
                                              content: Text(
                                                  'Are you sure you want to delete this user?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context).pop(),
                                                  child: Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    deleteUser(user['id'].toString());
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
