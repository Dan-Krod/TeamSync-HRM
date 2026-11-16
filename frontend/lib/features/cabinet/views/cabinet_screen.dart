import 'package:flutter/material.dart';
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
    setState(() => isLoading = true);
    try {
      final profile = await ApiClient.get('/auth/me');
      if (profile != null) {
        setState(() {
          userName = profile['name'] ?? 'Співробітник';
          salary = (profile['salary'] ?? 0).toDouble();
        });
      }

      final status = await ApiClient.get('/time/status');
      if (status != null) {
        setState(() {
          isWorking = status['is_working'] ?? false;
        });
      }
    } catch (e) {
      _showSnackBar('Помилка синхронізації даних', Colors.redAccent);
    } finally {
      setState(() => isLoading = false);
    }
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
      _showSnackBar(
        e.toString().replaceAll('Exception: ', ''),
        Colors.redAccent,
      );
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
      _showSnackBar(errorMsg, Colors.redAccent);

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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
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
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ваш персональний кабінет співробітника',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildTimeTracker()),
              const SizedBox(width: 24),
              Expanded(flex: 1, child: _buildSalaryCard()),
            ],
          ),
          const SizedBox(height: 24),
          _buildLeaveForm(),
        ],
      ),
    );
  }

  Widget _buildTimeTracker() {
    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.timer_outlined, color: Colors.black87),
              SizedBox(width: 8),
              Text(
                'Облік робочого часу',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: SizedBox(
              width: 260,
              height: 60,
              child: ElevatedButton(
                onPressed: isLoading ? null : _toggleClock,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isWorking
                      ? Colors.red.shade600
                      : Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isWorking
                                ? Icons.stop_circle_outlined
                                : Icons.play_circle_outline,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isWorking ? 'Завершити зміну' : 'Почати зміну',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryCard() {
    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.black87,
              ),
              SizedBox(width: 8),
              Text(
                'Зарплата',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Поточний оклад:',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            '₴ ${salary.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveForm() {
    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flight_takeoff_outlined, color: Colors.black87),
              SizedBox(width: 8),
              Text(
                'Оформити відпустку',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: leaveType,
                  decoration: InputDecoration(
                    labelText: 'Тип відпустки',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'annual', child: Text('Щорічна')),
                    DropdownMenuItem(value: 'sick', child: Text('Лікарняний')),
                    DropdownMenuItem(
                      value: 'unpaid',
                      child: Text('За свій рахунок'),
                    ),
                    DropdownMenuItem(
                      value: 'business_trip',
                      child: Text('Відрядження'),
                    ),
                  ],
                  onChanged: (val) => setState(() => leaveType = val!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    icon: const Icon(
                      Icons.calendar_month,
                      color: Colors.black87,
                    ),
                    label: Text(
                      startDate == null
                          ? 'Обрати дати'
                          : '${startDate!.toLocal().toString().split(' ')[0]} — ${endDate!.toLocal().toString().split(' ')[0]}',
                      style: const TextStyle(color: Colors.black87),
                    ),
                    onPressed: _pickDateRange,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: isSubmittingLeave ? null : _submitLeave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isSubmittingLeave
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Подати заявку',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
