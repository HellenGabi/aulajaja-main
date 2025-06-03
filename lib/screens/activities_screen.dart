import 'package:flutter/material.dart';
import '../screens/ActivityDetailsScreen.dart';

class ActivitiesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> activities = [
    {
      "title": "Automação Industrial",
      "subtitle": "Hoje • 13:40 – 17:00",
      "color": const Color.fromARGB(255, 157, 179, 228),
      "description": "Automação industrial é o uso de sistemas controlados por computadores, robôs e tecnologia para otimizar, monitorar e controlar processos de fabricação, aumentando a eficiência, precisão e segurança na produção.",
    },
    {
      "title": "IOT",
      "subtitle": "Hoje • 18:00 – 22:00",
      "color": const Color.fromARGB(255, 231, 182, 108),
      "description": "Internet das Coisas (IoT) é a interconexão de dispositivos e sensores à internet, permitindo a coleta, troca e análise de dados em tempo real para otimizar processos e melhorar a eficiência em diversos setores.",
    },
    {
      "title": "Programação de Aplicativos Mobile",
      "subtitle": "Amanhã • 18:00 – 22:00",
      "color": const Color.fromARGB(255, 78, 165, 70),
      "description": "Programação de aplicativo mobile é o processo de criar apps para dispositivos móveis, utilizando linguagens e frameworks específicos para Android e iOS.",
    },
  ];

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
          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: activity['color'],
              ),
              title: Text(activity['title']),
              subtitle: Text(activity['subtitle']),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ActivityDetailsScreen(activity: activity),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
