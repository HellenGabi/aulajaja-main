  import 'dart:convert';
  import 'package:flutter/material.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import 'package:supabase_flutter/supabase_flutter.dart';
  import 'package:table_calendar/table_calendar.dart';

  class HomeScreen extends StatefulWidget {
    @override
    _HomeScreenState createState() => _HomeScreenState();
  }

  class _HomeScreenState extends State<HomeScreen> {
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _descriptionController = TextEditingController();
    bool _showForm = false;

    DateTime _focusedDay = DateTime.now();
    DateTime _selectedDay = DateTime.now();

    Map<String, List<Map<String, String>>> _activities = {};

    String username = '';

    @override
    void initState() {
      super.initState();
      _loadActivities();
      _loadUsername();
    }

    Future<void> _loadUsername() async {
      final user = Supabase.instance.client.auth.currentUser;

      if (user != null) {
        final data = await Supabase.instance.client
            .from('Perfis')
            .select('username')
            .eq('id', user.id)
            .maybeSingle();

        setState(() {
          username = data?['username'] ?? user.email ?? 'Usuário';
        });
      }
    }

    void _toggleFormVisibility() {
      setState(() {
        _showForm = !_showForm;
      });
    }

    void _addActivity() async {
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      final key = _formatDate(_selectedDay);

      if (title.isNotEmpty && description.isNotEmpty) {
        final newActivity = {"title": title, "description": description};

        setState(() {
          if (_activities[key] == null) {
            _activities[key] = [newActivity];
          } else {
            _activities[key]!.add(newActivity);
          }
          _showForm = false;
          _titleController.clear();
          _descriptionController.clear();
        });

        await _saveActivities();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Atividade "$title" adicionada!')),
        );
      }
    }

    Future<void> _saveActivities() async {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(_activities);
      await prefs.setString('activities', data);
    }

    Future<void> _loadActivities() async {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('activities');
      if (data != null) {
        final Map<String, dynamic> decoded = jsonDecode(data);
        setState(() {
          _activities = decoded.map((key, value) => MapEntry(
                key,
                List<Map<String, String>>.from(value.map((e) => Map<String, String>.from(e))),
              ));
        });
      }
    }

    List<Map<String, String>> _getActivitiesForDay(DateTime day) {
      final key = _formatDate(day);
      return _activities[key] ?? [];
    }

    String _formatDate(DateTime date) {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }

    @override
    Widget build(BuildContext context) {
      final todayActivities = _getActivitiesForDay(_selectedDay);

      return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),

              const SizedBox(height: 20),
              const Text(
                'Seu Calendário Escolar',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                    selectedDecoration: BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(fontSize: 18, color: Colors.blue),
                    leftChevronIcon: Icon(Icons.chevron_left, color: Colors.blue),
                    rightChevronIcon: Icon(Icons.chevron_right, color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              if (todayActivities.isEmpty)
                Text(
                  'Nenhuma atividade marcada para este dia.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: todayActivities.map((activity) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: ListTile(
                          title: Text(activity['title'] ?? ''),
                          subtitle: Text(activity['description'] ?? ''),
                        ),
                      );
                    }).toList(),
                  ),
                ),

              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _toggleFormVisibility,
                child: Text(_showForm ? "Cancelar" : "Adicionar Atividade"),
              ),

              if (_showForm)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: "Título",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: "Descrição",
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _addActivity,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        child: const Text("Salvar Atividade"),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    }
  }
