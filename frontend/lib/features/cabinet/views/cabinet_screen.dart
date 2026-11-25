// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';

class CabinetScreen extends StatefulWidget {
  const CabinetScreen({super.key});

  @override
  State<CabinetScreen> createState() => _CabinetScreenState();
}

class _CabinetScreenState extends State<CabinetScreen> {
  int? userId;
  String userName = 'Співробітник';
  double salary = 0.0;
  bool isWorking = false;
  bool isLoading = false;

  String leaveType = 'annual';
  DateTime? startDate;
  DateTime? endDate;
  bool isSubmittingLeave = false;

  List<dynamic> myLeaves = [];
  List<dynamic> myReviews = [];

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
          userId = profile['id'];
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

      await Future.wait([_loadMyLeaves(), _loadMyReviews()]);
    } catch (e) {
      _showSnackBar('Помилка синхронізації даних', Colors.redAccent);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadMyLeaves() async {
    try {
      final data = await ApiClient.get('/leaves/');
      if (data is List) {
        final filtered = userId != null
            ? data.where((l) => l['employee_id'] == userId).toList()
            : data;
        setState(() => myLeaves = filtered.reversed.toList());
      }
    } catch (_) {}
  }

  Future<void> _loadMyReviews() async {
    if (userId == null) return;
    try {
      final data = await ApiClient.get('/reviews/employee/$userId');
      if (data != null && data['reviews'] is List) {
        setState(() => myReviews = data['reviews']);
      }
    } catch (_) {}
  }

  Future<void> _downloadContract() async {
    if (userId == null) return;
    _showSnackBar('Генерація контракту...', Colors.blue);
    try {
      final response = await ApiClient.getFile(
        '/documents/generate/$userId?type=contract',
      );
      if (response.statusCode == 200) {
        final blob = html.Blob([response.bodyBytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', 'contract_$userId.pdf')
          ..click();
        html.Url.revokeObjectUrl(url);
        _showSnackBar('Контракт завантажено', Colors.green);
      } else {
        _showSnackBar('Помилка ${response.statusCode}', Colors.redAccent);
      }
    } catch (e) {
      _showSnackBar('Помилка завантаження: $e', Colors.redAccent);
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
      await _loadMyLeaves();
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      _showSnackBar(errorMsg, Colors.redAccent);
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

  String _getLeaveTypeName(String type) {
    switch (type.toLowerCase()) {
      case 'annual':
      case 'vacation':
        return 'Щорічна';
      case 'sick':
        return 'Лікарняний';
      case 'unpaid':
        return 'За свій рахунок';
      case 'business_trip':
        return 'Відрядження';
      default:
        return type.toUpperCase();
    }
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'approved':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        label = 'Погоджено';
        break;
      case 'rejected':
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        label = 'Відхилено';
        break;
      case 'pending':
      default:
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade800;
        label = 'Очікує';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
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
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildMyLeavesCard()),
              const SizedBox(width: 24),
              Expanded(child: _buildMyReviewsCard()),
            ],
          ),
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
                'Зарплата та документи',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 24),
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
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: userId == null ? null : _downloadContract,
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
              label: const Text('Завантажити мій контракт (PDF)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: BorderSide(color: Colors.grey.shade400),
              ),
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

  Widget _buildMyLeavesCard() {
    return Container(
      padding: const EdgeInsets.all(24.0),
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
              Icon(Icons.history_outlined, color: Colors.black87),
              SizedBox(width: 8),
              Text(
                'Мої заявки на відпустку',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (myLeaves.isEmpty)
            const Text(
              'У вас ще немає поданих заявок',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: myLeaves.length,
              separatorBuilder: (_, __) => const Divider(height: 20),
              itemBuilder: (_, index) {
                final req = myLeaves[index];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getLeaveTypeName(req['type'] ?? ''),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${req['start_date']} — ${req['end_date']}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    _buildStatusBadge(req['status'] ?? 'pending'),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMyReviewsCard() {
    return Container(
      padding: const EdgeInsets.all(24.0),
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
              Icon(Icons.star_outline_rounded, color: Colors.amber),
              SizedBox(width: 8),
              Text(
                'Мої оцінки (KPI)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (myReviews.isEmpty)
            const Text(
              'Керівник ще не залишав оцінок',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: myReviews.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final rev = myReviews[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            rev['reviewer_name'] ?? 'Керівник',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${rev['score']} / 5',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if ((rev['comments'] ?? '').toString().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          rev['comments'],
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
