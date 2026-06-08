import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordModal extends StatefulWidget {
  const RecordModal({super.key});

  @override
  State<RecordModal> createState() => _RecordModalState();
}

class _RecordModalState extends State<RecordModal> {
  
  // 💾 SharedPreferences에서 완료된 기록 리스트를 읽어오는 비동기 함수
  Future<List<Map<String, dynamic>>> _loadRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? jsonList = prefs.getStringList('completedTodos');
      
      if (jsonList == null || jsonList.isEmpty) {
        return [];
      }
      
      // 저장된 JSON 문자열들을 다시 Dart의 Map(딕셔너리) 형태로 변환합니다.
      return jsonList.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint("Error loading records: $e");
      return [];
    }
  }

  // 🕒 ISO8601 시간 문자열을 보기 편한 "방금 전", "X분 전" 형식으로 바꿔주는 간단한 팁 함수
  String _convertToRelativeTime(String? isoString) {
    if (isoString == null) return '완료됨';
    try {
      final completedTime = DateTime.parse(isoString);
      final difference = DateTime.now().difference(completedTime);

      if (difference.inMinutes < 1) return '방금 전 완료';
      if (difference.inMinutes < 60) return '${difference.inMinutes}분 전 완료';
      if (difference.inHours < 24) return '${difference.inHours}시간 전 완료';
      return '${difference.inDays}일 전 완료';
    } catch (_) {
      return '완료됨';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF1E1E1E), // 맥북 다크모드 스타일 배경
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 사이드바 헤더 영역 ──────────────────────────────────
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF2D2D2D)),
              margin: EdgeInsets.zero,
              child: Center(
                child: Text(
                  '최근 완료한 기록',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            
            // ── 진짜 데이터 바인딩 영역 ──────────────────────────────
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _loadRecords(), // 비동기 함수 호출
                builder: (context, snapshot) {
                  // 로딩 중일 때
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  // 에러가 나거나 데이터가 없을 때
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        '아직 완료한 기록이 없습니다.\n할 일을 밀어서 완료해 보세요! 🔥',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
                      ),
                    );
                  }

                  final records = snapshot.data!;

                  // 기록 목록 뿌려주기
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final item = records[index];
                      return RecordTile(
                        title: item['title'] ?? '제목 없음',
                        time: _convertToRelativeTime(item['completedAt']), // 저장했던 시간 변환
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
}

// 📌 사이드바에 들어갈 개별 기록 컴포넌트 (기존 코드 유지)
class RecordTile extends StatelessWidget {
  final String title;
  final String time;

  const RecordTile({super.key, required this.title, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }
}