import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PeopleScreen extends StatefulWidget {
  final String username;
  const PeopleScreen({required this.username});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  List<Map<String, dynamic>> users = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchUsersFromSupabase();
  }

  Future<void> fetchUsersFromSupabase() async {
    final data = await Supabase.instance.client
        .from('profiles')
        .select('username, email');

    setState(() {
      users = List<Map<String, dynamic>>.from(data)
          .where((user) => user['username'] != widget.username)
          .toList();
      loading = false;
    });
  }

  void showUserDetails(String username, String email) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(username),
        content: Text("Email: $email"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fechar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Buscar'),
                    onChanged: (value) {
                      final filtered = users.where((user) =>
                          user['username']
                              .toString()
                              .toLowerCase()
                              .contains(value.toLowerCase()));
                      setState(() => users = filtered.toList());
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (_, index) {
                      final user = users[index];
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(user['username'] ?? 'Sem nome'),
                        onTap: () => showUserDetails(
                          user['username'] ?? 'Sem nome',
                          user['email'] ?? 'Sem email',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
