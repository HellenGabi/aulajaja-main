import 'package:flutter/material.dart';
import 'ActivityDetailsScreen.dart'; 

class ActivitiesScreen extends StatefulWidget {
  @override
  _ActivitiesScreenState createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  List<Map<String, dynamic>> activities = [
    {
      "title": "Automação Industrial",
      "subtitle": "Hoje • 13:40 – 17:00",
      "color": const Color.fromARGB(255, 157, 179, 228),
      "description": "Automação industrial é o uso de sistemas controlados por computadores, robôs e tecnologia para otimizar, monitorar e controlar processos de fabricação.",
      "completed": false,
    },
    {
      "title": "IOT",
      "subtitle": "Hoje • 18:00 – 22:00",
      "color": const Color.fromARGB(255, 231, 182, 108),
      "description": "Internet das Coisas (IoT) é a interconexão de dispositivos e sensores à internet.",
      "completed": false,
    },
    {
      "title": "Programação de Aplicativos Mobile",
      "subtitle": "Amanhã • 18:00 – 22:00",
      "color": const Color.fromARGB(255, 78, 165, 70),
      "description": "Programação de apps para dispositivos móveis, como Android e iOS.",
      "completed": false,
    },
  ];

  void _showAddActivitySheet() {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    final descriptionController = TextEditingController();
    Color selectedColor = Colors.blueAccent;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Título'),
                ),
                TextField(
                  controller: subtitleController,
                  decoration: InputDecoration(labelText: 'Data e horário'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Descrição'),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Text("Cor: "),
                    SizedBox(width: 10),
                    DropdownButton<Color>(
                      value: selectedColor,
                      items: [
                        DropdownMenuItem(
                          value: Colors.blueAccent,
                          child: Text("Azul"),
                        ),
                        DropdownMenuItem(
                          value: Color.fromARGB(255, 231, 182, 108),
                          child: Text("Laranja"),
                        ),
                        DropdownMenuItem(
                          value: Color.fromARGB(255, 78, 165, 70),
                          child: Text("Verde"),
                        ),
                        DropdownMenuItem(
                          value: Color.fromARGB(255, 157, 179, 228),
                          child: Text("Azul Claro"),
                        ),
                        DropdownMenuItem(
                          value: Color.fromARGB(255, 238, 44, 212),
                          child: Text("Rosa"),
                        ),
                        DropdownMenuItem(
                          value: Color.fromARGB(255, 121, 4, 145),
                          child: Text("Roxo"),
                        ),
                      ],
                      onChanged: (color) {
                        if (color != null) {
                          setState(() {
                            selectedColor = color;
                          });
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isEmpty) return;
                    setState(() {
                      activities.add({
                        "title": titleController.text,
                        "subtitle": subtitleController.text,
                        "description": descriptionController.text,
                        "color": selectedColor,
                        "completed": false,
                      });
                    });
                    Navigator.pop(context);
                  },
                  child: Text("Adicionar"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleCompleted(int index) {
    setState(() {
      activities[index]['completed'] = !(activities[index]['completed'] ?? false);
    });
  }

  void _deleteActivity(int index) {
    setState(() {
      activities.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Minhas Atividades"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          final isCompleted = activity['completed'] == true;

          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: activity['color'] ?? Colors.grey,
                child: isCompleted
                    ? Icon(Icons.check, color: Colors.white)
                    : null,
              ),
              title: Text(
                activity['title'] ?? '',
                style: TextStyle(
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Text(activity['subtitle'] ?? ''),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ActivityDetailsScreen(activity: activity),
                  ),
                );
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.check_circle,
                        color: isCompleted ? Colors.green : Colors.grey),
                    tooltip: 'Concluir',
                    onPressed: () => _toggleCompleted(index),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Excluir',
                    onPressed: () => _deleteActivity(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddActivitySheet,
        icon: Icon(Icons.add),
        label: Text("Adicionar atividade"),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
