# Just Do It — macOS Desktop Widget

> 바탕화면에 항상 떠 있는 **Todo 위젯**입니다.  
> 잠금/편집 모드를 전환하여 위치·크기를 자유롭게 조절하고, 잠근 뒤에는 바탕화면 보기(Mission Control)를 해도 밀려나지 않습니다.

---

## 주요 기능

| 기능 | 설명 |
|---|---|
| 🗂 **3컬럼 보드** | TODAY / WEEK / MONTH 세 가지 우선순위로 할 일 분류 |
| ➕ **빠른 추가** | 하단 FAB → 바텀 시트로 할 일 즉시 추가 |
| ✅ **완료 토글** | 카드 탭으로 완료/미완료 전환 (취소선 표시) |
| 🗑 **스와이프 삭제** | 카드를 왼쪽으로 스와이프하면 삭제 |
| 🔒 **잠금 모드** | 바탕화면 레벨에 고정, Mission Control에서 밀려나지 않음 |
| 🔓 **편집 모드** | 드래그로 위치 이동, 우측 하단 핸들로 크기 조절 |
| 💾 **상태 저장** | 할 일 목록·잠금 상태 모두 `SharedPreferences`에 영구 저장 |

---

## 아키텍처 — MVVM

```
lib/
├── main.dart                          # 진입점: 윈도우 초기화 + MultiProvider
│
├── models/
│   └── todo.dart                      # Todo 데이터 모델 (순수 데이터)
│
├── viewmodels/
│   ├── todo_viewmodel.dart            # Todo CRUD 로직 + SharedPreferences 저장/불러오기
│   └── window_viewmodel.dart          # 잠금 상태 관리 + MethodChannel + setResizable
│
└── views/
    ├── screens/
    │   └── dashboard_screen.dart      # 메인 화면 (StatelessWidget, UI만 담당)
    └── widgets/
        ├── add_todo_modal.dart        # 할 일 추가 바텀 시트
        ├── todo_card.dart             # 개별 할 일 카드 위젯
        └── todo_column.dart           # NOW / TODAY / WEEK 컬럼 위젯
```

### 레이어별 책임

| 레이어 | 파일 | 역할 |
|---|---|---|
| **Model** | `models/todo.dart` | 순수 데이터 구조만 정의 |
| **ViewModel** | `viewmodels/todo_viewmodel.dart` | 할 일 목록 상태 관리, 저장/불러오기 |
| **ViewModel** | `viewmodels/window_viewmodel.dart` | 창 잠금 상태, 네이티브 MethodChannel, Resizable 제어 |
| **View** | `views/screens/dashboard_screen.dart` | ViewModel을 `watch`해 UI만 렌더링 |
| **View** | `views/widgets/add_todo_modal.dart` | 할 일 입력 UI (StatefulWidget) |
| **View** | `views/widgets/todo_card.dart` | 재사용 가능한 카드 UI |
| **View** | `views/widgets/todo_column.dart` | 재사용 가능한 컬럼 UI |

---

## 네이티브 — macOS

```
macos/Runner/
└── MainFlutterWindow.swift   # NSWindow 레벨·collectionBehavior 제어
                              # MethodChannel: com.example.justdoit/window
```

### 잠금 모드 vs 편집 모드

| | 잠금 모드 🔒 | 편집 모드 🔓 |
|---|---|---|
| **Window Level** | `normal - 1` (모든 앱 뒤) | `.floating` (모든 앱 앞) |
| **CollectionBehavior** | `.canJoinAllSpaces` `.stationary` `.ignoresCycle` | `.managed` `.participatesInCycle` |
| **Resizable** | `false` | `true` |
| **Mission Control** | 밀려나지 않음 | 일반 창처럼 동작 |

---

## 시작하기

```bash
# 의존성 설치
flutter pub get

# macOS 디버그 실행
flutter run -d macos

# macOS 릴리즈 빌드
flutter build macos
```

### 요구 사항

- Flutter 3.x 이상
- macOS 12 Monterey 이상
- Xcode 14 이상
