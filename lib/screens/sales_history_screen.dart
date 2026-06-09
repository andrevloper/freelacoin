// lib/screens/sales_history_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

enum _FilterMode { day, month, year, all }

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});
  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  _FilterMode _mode = _FilterMode.month;
  DateTime _date    = DateTime.now();
  int _year         = DateTime.now().year;

  List<Project> _applyFilter(List<Project> all) => switch (_mode) {
        _FilterMode.day => all
            .where((p) =>
                p.date.year == _date.year &&
                p.date.month == _date.month &&
                p.date.day == _date.day)
            .toList(),
        _FilterMode.month => all
            .where((p) =>
                p.date.year == _date.year && p.date.month == _date.month)
            .toList(),
        _FilterMode.year  => all.where((p) => p.date.year == _year).toList(),
        _FilterMode.all   => all,
      };

  String get _filterLabel => switch (_mode) {
        _FilterMode.day =>
          DateFormat("dd 'de' MMMM 'de' yyyy", 'pt_BR').format(_date),
        _FilterMode.month =>
          DateFormat('MMMM yyyy', 'pt_BR').format(_date).capitalize(),
        _FilterMode.year  => 'Ano $_year',
        _FilterMode.all   => 'Todos os períodos',
      };

  Future<void> _openFilter() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FilterSheet(
        mode: _mode,
        date: _date,
        year: _year,
        onApply: (m, d, y) => setState(() {
          _mode = m;
          if (d != null) _date = d;
          if (y != null) _year = y;
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state    = context.watch<AppState>();
    final base     = state.projects
        .where((p) => p.status != ProjectStatus.cancelled)
        .toList();
    final projects = _applyFilter(base);
    final total    = projects.fold<double>(0, (s, p) => s + p.total);

    return Scaffold(
      backgroundColor: AppColors.bg2,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Histórico de Projetos',
            style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: 'Filtrar período',
            onPressed: _openFilter,
          ),
        ],
      ),
      body: Column(children: [
        // ── Resumo do período ──────────────────────────
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(_filterLabel,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(fmtMoney(total),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text(
                      '${projects.length} projeto${projects.length == 1 ? "" : "s"}',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12)),
                ]),
              ),
              GestureDetector(
                onTap: _openFilter,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.tune_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text('Filtrar',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ],
          ),
        ),

        // ── Lista de projetos ──────────────────────────
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.bg2,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: projects.isEmpty
                ? EmptyState(
                    icon: Icons.folder_open_outlined,
                    title: 'Nenhum projeto neste período',
                    subtitle: 'Tente selecionar outro intervalo de datas',
                    action: TextButton.icon(
                      onPressed: _openFilter,
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: const Text('Alterar filtro'),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: projects.length + 1,
                    itemBuilder: (_, i) {
                      if (i == projects.length) {
                        return Padding(
                          padding:
                              const EdgeInsets.only(top: 6, bottom: 32),
                          child: _SummaryCard(
                              projects: projects, total: total),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ProjectHistoryTile(project: projects[i]),
                      );
                    },
                  ),
          ),
        ),
      ]),
    );
  }
}

// ── Bottom Sheet de Filtro ────────────────────────────
class _FilterSheet extends StatefulWidget {
  final _FilterMode mode;
  final DateTime date;
  final int year;
  final void Function(_FilterMode, DateTime?, int?) onApply;

  const _FilterSheet({
    required this.mode,
    required this.date,
    required this.year,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late _FilterMode _mode;
  late DateTime _date;
  late int _year;
  late int _pickerYear;

  @override
  void initState() {
    super.initState();
    _mode        = widget.mode;
    _date        = widget.date;
    _year        = widget.year;
    _pickerYear  = widget.date.year;
  }

  Future<void> _pickDay() async {
    final now    = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(now) ? now : _date,
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'Selecionar dia',
      confirmText: 'Confirmar',
      cancelText: 'Cancelar',
    );
    if (picked != null) setState(() => _date = picked);
  }

  Widget _dayPicker() => Column(children: [
        InkWell(
          onTap: _pickDay,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  width: 1.5),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.primaryLight,
            ),
            child: Row(children: [
              const Icon(Icons.today_outlined, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text('Data selecionada',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary)),
                  Text(
                      DateFormat("dd 'de' MMMM 'de' yyyy", 'pt_BR')
                          .format(_date),
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                ]),
              ),
              const Icon(Icons.edit_calendar_outlined,
                  size: 18, color: AppColors.primary),
            ]),
          ),
        ),
        const SizedBox(height: 10),
        Text('Toque acima para abrir o calendário',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
      ]);

  Widget _monthPicker() {
    final now    = DateTime.now();
    final months = List.generate(
        12, (i) => DateFormat.MMM('pt_BR').format(DateTime(2020, i + 1)));

    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: _pickerYear > 2020
              ? () => setState(() => _pickerYear--)
              : null,
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20)),
          child: Text('$_pickerYear',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary)),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: _pickerYear < now.year
              ? () => setState(() => _pickerYear++)
              : null,
        ),
      ]),
      const SizedBox(height: 12),
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        childAspectRatio: 1.6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        children: List.generate(12, (i) {
          final month      = i + 1;
          final isSelected =
              _date.year == _pickerYear && _date.month == month;
          final isFuture =
              _pickerYear == now.year && month > now.month;
          return GestureDetector(
            onTap: isFuture
                ? null
                : () => setState(
                    () => _date = DateTime(_pickerYear, month)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : isFuture
                        ? AppColors.bg3
                        : AppColors.bg2,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.grey.shade200,
                    width: isSelected ? 1.5 : 1),
              ),
              child: Center(
                child: Text(
                  months[i].capitalize(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : isFuture
                            ? AppColors.textSecondary
                                .withValues(alpha: 0.4)
                            : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    ]);
  }

  Widget _yearPicker() {
    final now   = DateTime.now();
    final years = List.generate(now.year - 2020 + 1, (i) => now.year - i);
    return SizedBox(
      height: 200,
      child: ListView.builder(
        itemCount: years.length,
        itemBuilder: (_, i) {
          final y          = years[i];
          final isSelected = y == _year;
          return ListTile(
            onTap: () => setState(() => _year = y),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            tileColor: isSelected
                ? AppColors.primaryLight
                : Colors.transparent,
            leading: Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: 20),
            title: Text('$y',
                style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    fontSize: 15,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textPrimary)),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 32 + bottom),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: 16),
        const Text('Filtrar por período',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('Selecione o tipo e o intervalo desejado',
            style: TextStyle(
                fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 16),

        SegmentedButton<_FilterMode>(
          segments: const [
            ButtonSegment(
                value: _FilterMode.day,
                label: Text('Dia'),
                icon: Icon(Icons.today_outlined, size: 16)),
            ButtonSegment(
                value: _FilterMode.month,
                label: Text('Mês'),
                icon: Icon(Icons.calendar_month_outlined, size: 16)),
            ButtonSegment(
                value: _FilterMode.year,
                label: Text('Ano'),
                icon: Icon(Icons.calendar_today_outlined, size: 16)),
            ButtonSegment(
                value: _FilterMode.all,
                label: Text('Tudo'),
                icon: Icon(Icons.all_inclusive_rounded, size: 16)),
          ],
          selected: {_mode},
          onSelectionChanged: (s) => setState(() => _mode = s.first),
          style: ButtonStyle(
            textStyle: WidgetStateProperty.all(
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 20),

        if (_mode == _FilterMode.day)   _dayPicker(),
        if (_mode == _FilterMode.month) _monthPicker(),
        if (_mode == _FilterMode.year)  _yearPicker(),
        if (_mode == _FilterMode.all)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12)),
            child: const Row(children: [
              Icon(Icons.info_outline, color: AppColors.primary),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                    'Serão exibidos todos os projetos registrados.',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textPrimary)),
              ),
            ]),
          ),

        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              widget.onApply(
                _mode,
                (_mode == _FilterMode.day || _mode == _FilterMode.month)
                    ? _date
                    : null,
                _mode == _FilterMode.year ? _year : null,
              );
              Navigator.pop(context);
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Aplicar Filtro'),
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14)),
          ),
        ),
      ]),
    );
  }
}

// ── Tile de projeto ───────────────────────────────────
class _ProjectHistoryTile extends StatelessWidget {
  final Project project;
  const _ProjectHistoryTile({required this.project});

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.folder_rounded,
                  size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(project.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis),
                  Text(
                    [
                      if (project.client != null) project.client!.name,
                      fmtDateShort(project.date),
                    ].join(' · '),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ])),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(fmtMoney(project.total),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.primary)),
              const SizedBox(height: 2),
              StatusChip(project.status.label),
            ]),
          ]),
          if (project.allTechnologies.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: project.allTechnologies
                  .take(4)
                  .map((t) => Chip(
                        label: Text(t,
                            style: const TextStyle(fontSize: 11)),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ))
                  .toList(),
            ),
          ],
        ]),
      );
}

// ── Card de resumo ────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final List<Project> projects;
  final double total;
  const _SummaryCard({required this.projects, required this.total});

  @override
  Widget build(BuildContext context) => AppCard(
        color: AppColors.primaryLight,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Resumo do Período',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          _Row('Total de Projetos', '${projects.length}'),
          const SizedBox(height: 8),
          _Row(
              'Pagos',
              '${projects.where((p) => p.status == ProjectStatus.paid).length}'),
          const SizedBox(height: 8),
          _Row(
              'Em andamento',
              '${projects.where((p) => p.status == ProjectStatus.inProgress).length}'),
          const Divider(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Faturamento',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
            Text(fmtMoney(total),
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary)),
          ]),
        ]),
      );
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
        ],
      );
}

extension StringX on String {
  String capitalize() =>
      isEmpty ? this : this[0].toUpperCase() + substring(1);
}
