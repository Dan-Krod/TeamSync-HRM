import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CabinetScreen extends StatefulWidget {
  const CabinetScreen({super.key});

  @override
  State<CabinetScreen> createState() => _CabinetScreenState();
}

class _CabinetScreenState extends State<CabinetScreen> {
  String userName = 'Співробітник';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? 'Співробітник';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Вітаємо, $userName!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Card(
                child: Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: const Text('Тут буде Тайм-трекер (Clock-in / Clock-out)'),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: Card(
                child: Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: const Text('Тут буде Розрахунковий лист (Зарплата)'),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Expanded(
          child: Card(
            child: Center(child: Text('Тут буде таблиця заявок на відпустку та кнопка "Створити"')),
          ),
        ),
      ],
    );
  }
}