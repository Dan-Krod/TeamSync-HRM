import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; 
import '../../auth/cubit/auth_cubit.dart'; 
import '../../auth/cubit/auth_state.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_client.dart';

class CabinetScreen extends StatefulWidget {
  const CabinetScreen({super.key});

  @override
  State<CabinetScreen> createState() => _CabinetScreenState();
}

class _CabinetScreenState extends State<CabinetScreen> {
  String userName = 'Співробітник';
  double salary = 0.0;
  bool isWorking = false;
  bool isLoading = false;

  // Стан форми відпустки
  String leaveType = 'annual';
  DateTime? startDate;
  DateTime? endDate;
  bool isSubmittingLeave = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? 'Співробітник';
      salary = prefs.getDouble('salary') ?? 0.0;
    });
  }

  Future<void> _toggleClock() async {
    setState(() => isLoading = true);
    try {
      if (!isWorking) {
        await ApiClient.post('/time/clock-in', {});
        setState(() => isWorking = true);
        _showSnackBar('Зміну розпочато!', Colors.green);
      } else {
        await ApiClient.put('/time/clock-out', {});
        setState(() => isWorking = false);
        _showSnackBar('Зміну завершено!', Colors.orange);
      }
    } catch (e) {
      _showSnackBar(e.toString().replaceAll('Exception: ', ''), Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _submitLeave() async {
    if (startDate == null || endDate == null) {
      _showSnackBar('Оберіть дати відпустки', Colors.orange);
      return;
    }
    setState(() => isSubmittingLeave = true);
    try {
      await ApiClient.post('/leaves/', {
        'type': leaveType,
        'start_date': startDate!.toIso8601String().split('T')[0],
        'end_date': endDate!.toIso8601String().split('T')[0],
      });
      _showSnackBar('Заявку успішно подано', Colors.green);
      setState(() {
        startDate = null;
        endDate = null;
      });
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      _showSnackBar(errorMsg, Colors.red);
      
      // Автоматично виправляємо розсинхрон UI, якщо зміна вже триває
      if (errorMsg.contains('вже розпочато')) {
        setState(() => isWorking = true);
      }
    } finally {
      setState(() => isSubmittingLeave = false);
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Вітаємо, $userName!',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildTimeTracker()),
              const SizedBox(width: 16),
              Expanded(flex: 1, child: _buildSalaryCard()),
            ],
          ),
          const SizedBox(height: 16),
          _buildLeaveForm(),
        ],
      ),
    );
  }

  Widget _buildTimeTracker() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Облік робочого часу',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: 220,
                height: 54,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _toggleClock,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isWorking ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isWorking ? 'Завершити зміну' : 'Почати зміну',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Зарплата',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text('Поточний оклад:', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              '₴ ${salary.toStringAsFixed(2)}', // Використовуємо локальну змінну
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Оформити відпустку',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: leaveType,
                    decoration: const InputDecoration(
                      labelText: 'Тип відпустки',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'annual', child: Text('Щорічна')),
                      DropdownMenuItem(
                        value: 'sick',
                        child: Text('Лікарняний'),
                      ),
                      DropdownMenuItem(
                        value: 'unpaid',
                        child: Text('За свій рахунок'),
                      ),
                    ],
                    onChanged: (val) => setState(() => leaveType = val!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_month),
                    label: Text(
                      startDate == null
                          ? 'Обрати дати'
                          : '${startDate!.toLocal().toString().split(' ')[0]} - ${endDate!.toLocal().toString().split(' ')[0]}',
                    ),
                    onPressed: _pickDateRange,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: isSubmittingLeave ? null : _submitLeave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                  ),
                  child: isSubmittingLeave
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Подати заявку'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
