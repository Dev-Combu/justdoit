import 'package:flutter/material.dart';
import 'package:justdoit/viewmodels/auth_viewmodel.dart';
import 'package:justdoit/viewmodels/window_viewmodel.dart';
import 'package:justdoit/views/widgets/add_todo_modal.dart';
import 'package:justdoit/views/widgets/record_modal.dart';
import 'package:justdoit/views/widgets/todo_column.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('정말 로그아웃하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // 다이얼로그 닫기
                await context.read<AuthViewModel>().logout();
              },
              child: const Text(
                '로그아웃',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final windowVM = context.watch<WindowViewModel>();
    final isLocked = windowVM.isLocked;
    final colorScheme = Theme.of(context).colorScheme;

    final dragHandle = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: colorScheme.onSurface.withValues(
              alpha: isLocked ? 0.05 : 0.4,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.4),
      drawer: RecordModal(),
      body: SafeArea(
        child: Stack(
          children: [
            // ── Main Panel ──────────────────────────────────────────
            Container(
              decoration: isLocked
                  ? BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    )
                  : BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.primary,
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
              margin: isLocked ? EdgeInsets.zero : const EdgeInsets.all(6.0),
              child: Column(
                children: [
                  // Drag handle (only active when unlocked)
                  isLocked ? dragHandle : DragToMoveArea(child: dragHandle),
                  // ── Header ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 2.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Just Do It',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black87,
                                  ),
                            ),
                            if (!isLocked) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'EDITING',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Spacer(),
                        Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(Icons.history), // 기록 모양 아이콘
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        ),
                        IconButton(
                          onPressed: () => AddTodoModal.show(context),
                          icon: const Icon(Icons.add),
                        ),
                        IconButton(
                          onPressed: windowVM.toggleLock,
                          icon: Icon(
                            isLocked
                                ? Icons.lock_outline_rounded
                                : Icons.lock_open_rounded,
                            color: isLocked
                                ? colorScheme.onSurface.withValues(alpha: 0.4)
                                : colorScheme.primary,
                            size: 20,
                          ),
                          tooltip: isLocked
                              ? 'Unlock to move/resize'
                              : 'Lock widget on desktop',
                        ),
                        if (!isLocked)
                          IconButton(
                            onPressed: () => _showLogoutDialog(context),
                            icon: const Icon(
                              Icons.logout_rounded,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            tooltip: '로그아웃',
                          ),
                      ],
                    ),
                  ),

                  // ── Todo columns ──────────────────────────────────
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: TodoColumn(status: 'TODAY')),
                          SizedBox(width: 6),
                          Expanded(child: TodoColumn(status: 'WEEK')),
                          SizedBox(width: 6),
                          Expanded(child: TodoColumn(status: 'MONTH')),
                        ],
                      ),
                    ),
                  ),

                  // ── Edit-mode hint bar ────────────────────────────
                  if (!isLocked)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(18),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '💡 드래그하여 이동하고, 우측 하단 모서리를 끌어 크기를 조절하세요.',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Resize handle (unlocked only) ─────────────────────
            if (!isLocked)
              Positioned(
                right: 6,
                bottom: 6,
                child: GestureDetector(
                  onPanStart: (_) =>
                      windowManager.startResizing(ResizeEdge.bottomRight),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeDownRight,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomRight: Radius.circular(18),
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.open_in_full_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
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
}
