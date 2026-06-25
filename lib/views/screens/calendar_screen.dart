import 'package:flutter/material.dart';
import 'package:justdoit/models/todo.dart';
import 'package:justdoit/viewmodels/todo_viewmodel.dart';
import 'package:provider/provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _displayedMonth = DateTime.now();

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = _displayedMonth;
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final startWeekday = firstDayOfMonth.weekday % 7; 

    // 현재 달이 총 몇 주(행)인지 동적 계산 (5주 또는 6주)
    final totalCells = daysInMonth + startWeekday;
    final rowCount = (totalCells / 7).ceil();

    return Scaffold(
      backgroundColor: Colors.grey[200], // 그리드 테두리 경계선용 배경색
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
          onPressed: () => Navigator.pop(context), 
        ),
        title: Text(
          '${now.year}년 ${now.month.toString().padLeft(2, '0')}월',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.chevron_left, size: 28, color: Colors.black87), onPressed: _previousMonth),
          IconButton(icon: const Icon(Icons.chevron_right, size: 28, color: Colors.black87), onPressed: _nextMonth),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 요일 헤더 (높이 고정)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: _buildWeekHeader(),
            ),
            
            // ⭐ 1. 남아있는 전체 바디 높이를 감지하여 꽉 채우는 영역
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth;
                  final maxHeight = constraints.maxHeight;

                  // 셀 하나의 가로/세로 길이를 기기 사이즈에 맞게 동적 분할
                  final cellWidth = maxWidth / 7;
                  final cellHeight = maxHeight / rowCount;
                  final dynamicAspectRatio = cellWidth / cellHeight;

                  return StreamBuilder<List<Todo>>(
                    stream: Provider.of<TodoViewModel>(context, listen: false).todoStream,
                    builder: (context, snapshot) {
                      final todos = snapshot.data ?? [];

                      // 날짜별로 Todo 리스트 묶기
                      final Map<String, List<Todo>> tasksByDate = {};
                      for (var todo in todos) {
                        final date = todo.dueDate;
                        if (date == null) continue;
                        final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                        tasksByDate.putIfAbsent(key, () => []).add(todo);
                      }

                      return GridView.builder(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(), // 전체 맞춤형이므로 스크롤 완벽 차단
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          childAspectRatio: dynamicAspectRatio, // 동적 계산된 비율 적용
                          mainAxisSpacing: 1, 
                          crossAxisSpacing: 1,
                        ),
                        itemCount: totalCells,
                        itemBuilder: (context, index) {
                          if (index < startWeekday) {
                            return Container(color: Colors.white);
                          }
                          
                          final day = index - startWeekday + 1;
                          final key = '${now.year}-${now.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
                          final dayTasks = tasksByDate[key] ?? [];

                          final today = DateTime.now();
                          final isToday = today.year == now.year && today.month == now.month && today.day == day;

                          return Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(2.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 날짜 숫자 표시
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: isToday ? Colors.deepPurple : Colors.transparent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '$day',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isToday
                                            ? Colors.white
                                            : (index % 7 == 0 ? Colors.red : (index % 7 == 6 ? Colors.blue : Colors.black87)),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                
                                // ⭐ 2. 일정을 스크롤 없이 초압축 고정형으로 보여주는 영역
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: dayTasks.take(4).map((todo) { // 최대 4개로 제한하여 오버플로우 방지
                                      return Container(
                                        margin: const EdgeInsets.symmetric(vertical: 0.5),
                                        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: todo.isCompleted ? Colors.grey[100] : Colors.deepPurple[50],
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                        child: Text(
                                          todo.title,
                                          style: TextStyle(
                                            fontSize: 8.5, // 압축 가독성을 극대화한 폰트 사이즈
                                            fontWeight: FontWeight.w500,
                                            color: todo.isCompleted ? Colors.grey[500] : Colors.deepPurple[900],
                                            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1, // 절대 줄바꿈 금지
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekHeader() {
    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((day) {
        Color textColor = Colors.grey[600]!;
        if (day == '일') textColor = Colors.red[400]!;
        if (day == '토') textColor = Colors.blue[400]!;
        return SizedBox(
          width: 40,
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
          ),
        );
      }).toList(),
    );
  }
}