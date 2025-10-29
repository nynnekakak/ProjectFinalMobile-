import 'package:flutter/material.dart';

/// ================================================================
/// ===============  ONLY-UI VERSION (Mock + TODOs)  ===============
/// Mọi xử lý (thêm/xoá/tìm/đăng xuất...) đã được vô hiệu hoá.
/// Để tích hợp backend, tìm các phần `// TODO:` bên dưới.
/// ================================================================

// ======================== Utilities (no intl) ========================
String fmMoney(num v) {
  final n = v.abs().toInt();
  final s = n.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final posFromEnd = s.length - i;
    buf.write(s[i]);
    if (posFromEnd > 1 && posFromEnd % 3 == 1) buf.write('.');
  }
  return '${buf.toString()} ₫';
}

String fmDate(DateTime d) {
  String two(int x) => x.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year}';
}

// ======================== Data models ========================
enum TxCategory { food, coffee, fuel, shopping, home, other }

extension TxCatX on TxCategory {
  String get label => switch (this) {
    TxCategory.food => 'Ăn uống',
    TxCategory.coffee => 'Cà phê',
    TxCategory.fuel => 'Xăng xe',
    TxCategory.shopping => 'Mua sắm',
    TxCategory.home => 'Nhà cửa',
    TxCategory.other => 'Khác',
  };
  IconData get icon => switch (this) {
    TxCategory.food => Icons.restaurant,
    TxCategory.coffee => Icons.local_cafe,
    TxCategory.fuel => Icons.local_gas_station,
    TxCategory.shopping => Icons.shopping_bag,
    TxCategory.home => Icons.home_outlined,
    TxCategory.other => Icons.category,
  };
}

class Tx {
  final String id;
  final String title;
  final int amount; // VND, luôn âm cho chi tiêu
  final DateTime date;
  final TxCategory category;
  const Tx({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });
}

// ======================== Mock data (UI only) ========================
final List<Tx> kMockTxs = [
  Tx(
    id: 't1',
    title: 'Ăn trưa',
    amount: -45_000,
    date: DateTime.now(),
    category: TxCategory.food,
  ),
  Tx(
    id: 't2',
    title: 'Xăng xe',
    amount: -80_000,
    date: DateTime.now().subtract(const Duration(days: 1)),
    category: TxCategory.fuel,
  ),
  Tx(
    id: 't3',
    title: 'Cà phê',
    amount: -30_000,
    date: DateTime.now().subtract(const Duration(days: 2)),
    category: TxCategory.coffee,
  ),
  Tx(
    id: 't4',
    title: 'Mua áo phông',
    amount: -220_000,
    date: DateTime.now().subtract(const Duration(days: 3)),
    category: TxCategory.shopping,
  ),
];

// ======================== Periods ========================
enum Period { week, month, year }

extension PeriodX on Period {
  String get label => switch (this) {
    Period.week => 'Tuần này',
    Period.month => 'Tháng này',
    Period.year => 'Năm này',
  };
}

class _Range {
  final DateTime start;
  final DateTime end; // exclusive
  const _Range(this.start, this.end);
}

_Range _rangeFor(Period p, DateTime now) {
  switch (p) {
    case Period.week:
      final d = DateTime(now.year, now.month, now.day);
      final start = d.subtract(Duration(days: d.weekday - 1)); // Mon
      return _Range(start, start.add(const Duration(days: 7)));
    case Period.month:
      final start = DateTime(now.year, now.month, 1);
      final end = (now.month == 12)
          ? DateTime(now.year + 1, 1, 1)
          : DateTime(now.year, now.month + 1, 1);
      return _Range(start, end);
    case Period.year:
      return _Range(DateTime(now.year, 1, 1), DateTime(now.year + 1, 1, 1));
  }
}

// ======================== HomeScreen (Black & Yellow theme) ========================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  static const _titles = ['Tổng quan', 'Chi tiêu', 'Hồ sơ'];

  @override
  Widget build(BuildContext context) {
    final darkYellow = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: Colors.amber,
            brightness: Brightness.dark,
          ).copyWith(
            primary: Colors.amber,
            onPrimary: Colors.black,
            surface: const Color(0xFF0D0D0D),
            background: const Color(0xFF0A0A0A),
          ),
      navigationBarTheme: const NavigationBarThemeData(
        indicatorColor: Colors.amber,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      appBarTheme: const AppBarTheme(centerTitle: true),
    );

    final body = IndexedStack(
      index: _tabIndex,
      children: const [
        _OverviewTab(key: PageStorageKey('overview')),
        _TransactionsTab(key: PageStorageKey('tx')),
        _ProfileTab(key: PageStorageKey('profile')),
      ],
    );

    return Theme(
      data: darkYellow,
      child: Scaffold(
        appBar: AppBar(title: Text(_titles[_tabIndex])),
        body: SafeArea(child: body),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tabIndex,
          onDestinationSelected: (i) => setState(() => _tabIndex = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Tổng quan',
            ),
            NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(Icons.list_alt),
              label: 'Chi tiêu',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Hồ sơ',
            ),
          ],
        ),
        floatingActionButton: _tabIndex == 1
            ? FloatingActionButton.extended(
                onPressed: () => _showAddTxSheet(context),
                icon: const Icon(Icons.add),
                label: const Text('Thêm'),
              )
            : null,
      ),
    );
  }

  Future<void> _showAddTxSheet(BuildContext context) async {
    final titleCtl = TextEditingController();
    final amountCtl = TextEditingController();
    TxCategory cat = TxCategory.food;
    DateTime when = DateTime.now();

    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        final bottom = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottom + 16),
          child: StatefulBuilder(
            builder: (ctx, set) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Thêm chi tiêu',
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtl,
                  decoration: const InputDecoration(
                    labelText: 'Tiêu đề',
                    prefixIcon: Icon(Icons.edit_note),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: amountCtl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Số tiền (chi tiêu, nhập số dương)',
                    prefixIcon: Icon(Icons.payments_outlined),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: TxCategory.values.map((c) {
                    final selected = c == cat;
                    return ChoiceChip(
                      label: Text(c.label),
                      avatar: Icon(c.icon, size: 18),
                      selected: selected,
                      onSelected: (_) => set(() => cat = c),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: when,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      helpText: 'Chọn ngày',
                    );
                    if (picked != null) set(() => when = picked);
                  },
                  child: Text('Ngày: ${fmDate(when)}'),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Lưu'),
                  onPressed: () {
                    // TODO: Gọi API tạo chi tiêu & cập nhật state
                    // print('createExpense(title, amount, date, category)');
                    Navigator.pop(ctx, true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('TODO: Lưu chi tiêu (chưa gắn backend)'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    // LƯU Ý: Không thêm vào danh sách — UI-only.
  }
}

// ======================== Overview (period switch + chart) ========================
class _OverviewTab extends StatefulWidget {
  const _OverviewTab({super.key});
  @override
  State<_OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<_OverviewTab> {
  Period period = Period.week;

  @override
  Widget build(BuildContext context) {
    // Lọc theo khoảng thời gian chỉ để hiển thị UI (vẫn dùng mock data)
    final r = _rangeFor(period, DateTime.now());
    final expenses = kMockTxs
        .where((t) => t.amount < 0)
        .where((t) => !t.date.isBefore(r.start) && t.date.isBefore(r.end))
        .toList();

    final total = expenses.fold<int>(0, (p, e) => p + (-e.amount));
    final series = _buildSeries(expenses, period, r);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<Period>(
            segments: const [
              ButtonSegment(value: Period.week, label: Text('Tuần')),
              ButtonSegment(value: Period.month, label: Text('Tháng')),
              ButtonSegment(value: Period.year, label: Text('Năm')),
            ],
            selected: {period},
            onSelectionChanged: (s) => setState(() => period = s.first),
          ),
          const SizedBox(height: 12),
          _ExpenseCard(total: total, period: period),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Biểu đồ theo ${period.label.toLowerCase()}',
            child: _ExpenseChart(series: series),
          ),
          const SizedBox(height: 16),
          const _SectionCard(
            title: 'Giao dịch gần đây',
            child: _RecentTransactions(),
          ),
        ],
      ),
    );
  }

  List<int> _buildSeries(List<Tx> items, Period p, _Range r) {
    if (p == Period.week) {
      // 7 ngày (Mon..Sun)
      final List<int> buckets = List.filled(7, 0);
      for (final t in items) {
        final idx = t.date.weekday - 1; // 0..6
        buckets[idx] += -t.amount;
      }
      return buckets;
    } else if (p == Period.month) {
      final days = DateUtils.getDaysInMonth(r.start.year, r.start.month);
      final List<int> buckets = List.filled(days, 0);
      for (final t in items) {
        final idx = t.date.day - 1; // 0..days-1
        buckets[idx] += -t.amount;
      }
      return buckets;
    } else {
      // year: 12 months
      final List<int> buckets = List.filled(12, 0);
      for (final t in items) {
        final idx = t.date.month - 1;
        buckets[idx] += -t.amount;
      }
      return buckets;
    }
  }
}

class _ExpenseCard extends StatelessWidget {
  final int total;
  final Period period;
  const _ExpenseCard({required this.total, required this.period});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.primary.withOpacity(0.14),
              cs.primary.withOpacity(0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.trending_down, color: cs.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tổng chi • ${period.label}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '-${fmMoney(total)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseChart extends StatelessWidget {
  final List<int> series; // số tiền mỗi bucket
  const _ExpenseChart({required this.series});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: CustomPaint(painter: _BarsPainter(color, series)),
    );
  }
}

class _BarsPainter extends CustomPainter {
  final Color color;
  final List<int> series;
  _BarsPainter(this.color, this.series);

  @override
  void paint(Canvas canvas, Size size) {
    final maxV = series.isEmpty ? 0 : series.reduce((a, b) => a > b ? a : b);
    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    final paddingH = 16.0;
    final availW = size.width - paddingH * 2;
    final n = series.isEmpty ? 1 : series.length;
    final gap = (n <= 12) ? 8.0 : 2.0;
    final barW = (availW - gap * (n - 1)) / n;

    for (int i = 0; i < n; i++) {
      final v = series.isEmpty ? 0 : series[i];
      // NOTE: scale 0.1 giữ bars thấp để hợp UI mẫu; có thể chỉnh lại sau.
      final h = (maxV == 0 ? 0 : (v / maxV) * (size.height - 24)) * 0.1;
      final x = paddingH + i * (barW + gap);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, size.height - h - 12, barW, h),
        const Radius.circular(6),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarsPainter old) =>
      old.color != color || old.series != series;
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({super.key, required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _RecentTransactions extends StatelessWidget {
  const _RecentTransactions();
  @override
  Widget build(BuildContext context) {
    final items = kMockTxs.take(4).toList(growable: false);
    if (items.isEmpty) {
      return const _EmptyState(
        icon: Icons.receipt_long,
        title: 'Chưa có chi tiêu',
        message: 'Nhấn “Thêm” để ghi lại khoản đầu tiên',
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 8),
      itemBuilder: (c, i) {
        final t = items[i];
        final cs = Theme.of(c).colorScheme;
        return ListTile(
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: cs.primary.withOpacity(0.15),
            child: Icon(t.category.icon, color: cs.primary),
          ),
          title: Text(t.title),
          subtitle: Text(fmDate(t.date)),
          trailing: Text(
            '-${fmMoney((-t.amount).abs())}',
            style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const _EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: cs.outline),
          const SizedBox(height: 10),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: cs.outline),
          ),
        ],
      ),
    );
  }
}

// ======================== Transactions Tab (expenses only, UI) ========================
class _TransactionsTab extends StatefulWidget {
  const _TransactionsTab({super.key});
  @override
  State<_TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<_TransactionsTab> {
  final _searchCtl = TextEditingController();
  final _searchFocus = FocusNode();
  TxCategory?
  _selectedCat; // Chỉ để highlight chip, không lọc dữ liệu (UI-only)

  @override
  void dispose() {
    _searchCtl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _todoSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('TODO: $msg')));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottom = MediaQuery.paddingOf(context).bottom;

    final chips = [
      FilterChip(
        label: const Text('Tất cả'),
        selected: _selectedCat == null,
        onSelected: (_) {
          setState(() => _selectedCat = null);
          _todoSnack(context, 'áp dụng bộ lọc (chưa gắn backend)');
        },
      ),
      ...TxCategory.values.map(
        (c) => FilterChip(
          label: Text(c.label),
          avatar: Icon(c.icon, size: 18),
          selected: _selectedCat == c,
          onSelected: (_) {
            setState(() => _selectedCat = c);
            _todoSnack(context, 'áp dụng bộ lọc (${c.label})');
          },
        ),
      ),
    ];

    // NOTE: Không lọc theo search / category — danh sách vẫn là mock kMockTxs.
    final items = kMockTxs;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                SearchBar(
                  controller: _searchCtl,
                  focusNode: _searchFocus,
                  onChanged: (v) {
                    // TODO: kết nối logic search để gọi API hoặc lọc local
                    _todoSnack(context, 'tìm kiếm "$v" (chưa gắn backend)');
                  },
                  hintText: 'Tìm chi tiêu (ví dụ: cà phê)',
                  leading: const Icon(Icons.search),
                  trailing: [
                    if (_searchCtl.text.isNotEmpty)
                      IconButton(
                        onPressed: () {
                          _searchCtl.clear();
                          _searchFocus.unfocus();
                          _todoSnack(context, 'xoá từ khoá tìm kiếm');
                        },
                        icon: const Icon(Icons.clear),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(spacing: 8, runSpacing: 8, children: chips),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        if (items.isEmpty)
          const SliverToBoxAdapter(
            child: _EmptyState(
              icon: Icons.receipt_long,
              title: 'Không có chi tiêu',
              message: 'Thêm chi tiêu để theo dõi',
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottom),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((c, idx) {
                final tileCount = items.length * 2 - 1;
                if (idx.isOdd) return const Divider(height: 8);
                final i = idx ~/ 2;
                final t = items[i];
                return ListTile(
                  // NOTE: Không Dismissible để tránh xoá dữ liệu ở UI-only
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: cs.primary.withOpacity(0.12),
                    child: Icon(t.category.icon, color: cs.primary),
                  ),
                  title: Text(t.title),
                  subtitle: Text('${fmDate(t.date)} • ${t.category.label}'),
                  trailing: Text(
                    '-${fmMoney((-t.amount).abs())}',
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: () {
                    // TODO: mở màn chi tiết giao dịch
                    _todoSnack(context, 'mở chi tiết "${t.title}"');
                  },
                );
              }, childCount: items.isEmpty ? 0 : items.length * 2 - 1),
            ),
          ),
      ],
    );
  }
}

// ======================== Profile ========================
class _ProfileTab extends StatelessWidget {
  const _ProfileTab({super.key});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: cs.primary.withOpacity(0.12),
                child: Icon(Icons.person, size: 36, color: cs.primary),
              ),
              const SizedBox(height: 12),
              Text(
                'Xin chào, User',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Cài đặt'),
          onTap: () {
            // TODO: điều hướng sang màn Cài đặt
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('TODO: Mở Cài đặt')));
          },
        ),
        ListTile(
          leading: const Icon(Icons.lock_outline),
          title: const Text('Đổi mật khẩu'),
          onTap: () {
            // TODO: điều hướng sang màn Đổi mật khẩu
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('TODO: Đổi mật khẩu')));
          },
        ),
        const Divider(),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: () {
            // TODO: Thực hiện đăng xuất + điều hướng
            // Navigator.of(context).pushNamedAndRemoveUntil('/signin', (route) => false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('TODO: Đăng xuất (chưa gắn backend)'),
              ),
            );
          },
          icon: const Icon(Icons.logout),
          label: const Text('Đăng xuất'),
        ),
      ],
    );
  }
}
