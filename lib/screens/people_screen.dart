import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({Key? key}) : super(key: key);

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  List<Map<String, dynamic>> allUsers = [];
  List<Map<String, dynamic>> displayedUsers = [];
  bool loading = true;

  String currentUsername = '';
  String currentUserId = '';

  @override
  void initState() {
    super.initState();
    getCurrentUserInfo();
  }

  Future<void> getCurrentUserInfo() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      currentUserId = user.id;

      final data = await Supabase.instance.client
          .from('Perfis')
          .select('username')
          .eq('id', user.id)
          .maybeSingle();

      setState(() {
        currentUsername = data?['username'] ?? user.email ?? 'Usuário';
      });

      await fetchUsersFromSupabase();
    }
  }

  Future<void> fetchUsersFromSupabase() async {
    try {
      final response = await Supabase.instance.client
          .from('Perfis')
          .select('username, email, id');

      if (response != null && response is List) {
        final List<Map<String, dynamic>> usersList = List<Map<String, dynamic>>.from(response);

        final filteredUsers = usersList
            .where((user) => user['id'] != currentUserId)
            .toList();

        setState(() {
          allUsers = filteredUsers;
          displayedUsers = filteredUsers;
          loading = false;
        });
      } else {
        setState(() {
          allUsers = [];
          displayedUsers = [];
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        allUsers = [];
        displayedUsers = [];
        loading = false;
      });
    }
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
                      final filtered = allUsers.where((user) {
                        final username = user['username'] ?? '';
                        return username.toString().toLowerCase().contains(value.toLowerCase());
                      }).toList();

                      setState(() => displayedUsers = filtered);
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: displayedUsers.length,
                    itemBuilder: (_, index) {
                      final user = displayedUsers[index];
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(user['username'] ?? 'Sem nome'),
                        subtitle: Text(user['email'] ?? 'Sem email'),
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
