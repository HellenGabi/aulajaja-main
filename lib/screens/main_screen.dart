import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'home_screen.dart';
import 'activities_screen.dart';
import 'people_screen.dart';
import 'login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;
  late final List<Widget> _screens;

  String currentUsername = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();

    // ✅ Inicialize aqui
    _screens = [
      ActivitiesScreen(),
      HomeScreen(),
      PeopleScreen(),
    ];

    fetchCurrentUsername();
  }

  Future<void> fetchCurrentUsername() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final profile = await Supabase.instance.client
          .from('Perfis')
          .select('username')
          .eq('id', user.id)
          .maybeSingle();

      setState(() {
        currentUsername = profile?['username'] ?? user.email ?? 'Usuário';
        loading = false;
      });
    } else {
      setState(() {
        currentUsername = 'Usuário';
        loading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Atividades',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Pessoas',
          ),
        ],
      ),
    );
  }
}
