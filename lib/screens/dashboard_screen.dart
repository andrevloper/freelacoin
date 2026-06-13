// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'settings_screen.dart';
import 'sales_history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = _today;
  }

  static DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  bool get _isToday => _selected == _today;

  void _prevDay() =>
      setState(() => _selected = _selected.subtract(const Duration(days: 1)));

  void _nextDay() {
    final next = _selected.add(const Duration(days: 1));
    if (!next.isAfter(_today)) setState(() => _selected = next);
  }

  Future<void> _pickDay() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selected,
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'Selecionar data',
      confirmText: 'Ver projetos',
      cancelText: 'Cancelar',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context)
              .colorScheme
              .copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() =>
          _selected = DateTime(picked.year, picked.month, picked.day));
    }
  }

  String get _chipLabel {
    if (_isToday) {
      return 'Hoje · ${DateFormat("dd/MM", "pt_BR").format(_selected)}';
    }
    return DateFormat("dd 'de' MMM 'de' y", 'pt_BR').format(_selected);
  }

  String get _fullLabel {
    if (_isToday) return 'Projetos de hoje';
    return 'Projetos em ${DateFormat("dd/MM/yyyy", "pt_BR").format(_selected)}';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final dayProjects = state.projects
        .where((p) =>
            p.status != ProjectStatus.cancelled &&
            p.date.year == _selected.year &&
            p.date.month == _selected.month &&
            p.date.day == _selected.day)
        .toList();

    final recent      = dayProjects.take(5).toList();
    final totalDay    = dayProjects.fold<double>(0, (s, p) => s + p.total);
    final activeCount = state.activeProjectsCount;
    final now         = DateTime.now();
    final received    = state.getReceivedByMonth(now.month, now.year);
    final goal        = state.monthlyGoal;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Row(children: [
          const SizedBox(width: 16),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4), width: 1.5),
            ),
            child: const Center(
              child: Text('R\$',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Olá, bem vindo',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w400)),
                  Text(state.freelancerName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis),
                ]),
          ),
        ]),
        actions: [
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen())),
            child: Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle),
              child: const Icon(Icons.person_outline_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),

      body: CustomScrollView(slivers: [
        // ── Header do dia ──────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    GestureDetector(
                      onTap: _prevDay,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.chevron_left_rounded,
                            color: Colors.white.withValues(alpha: 0.85),
                            size: 24),
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: _pickDay,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 1),
                        ),
                        child:
                            Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.calendar_today_outlined,
                              color: Colors.white, size: 13),
                          const SizedBox(width: 6),
                          Text(
                            _chipLabel,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.95),
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.expand_more_rounded,
                              color: Colors.white.withValues(alpha: 0.7),
                              size: 16),
                        ]),
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: _isToday ? null : _nextDay,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.chevron_right_rounded,
                            color: _isToday
                                ? Colors.white.withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.85),
                            size: 24),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Text(_fullLabel,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 11,
                          fontWeight: FontWeight.w400)),
                  const SizedBox(height: 4),
                  Text(fmtMoney(totalDay),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5)),
                ]),
          ),
        ),

        // ── Conteúdo ──────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            decoration: const BoxDecoration(
              color: AppColors.bg2,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  // Cards de resumo
                  Row(children: [
                    Expanded(
                        child: SummaryTile(
                            label: 'Projetos ativos',
                            value: '$activeCount',
                            icon: Icons.work_outline_rounded,
                            color: AppColors.primary)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: SummaryTile(
                            label: 'A receber',
                            value: fmtMoney(state.pendingRevenue),
                            icon: Icons.hourglass_empty_rounded,
                            color: AppColors.accent)),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                        child: SummaryTile(
                            label: 'Clientes',
                            value: '${state.clients.length}',
                            icon: Icons.people_outline,
                            color: AppColors.secondary)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: SummaryTile(
                            label: 'Serviços',
                            value: '${state.services.length}',
                            icon: Icons.design_services_outlined,
                            color: AppColors.catConsult)),
                  ]),
                  const SizedBox(height: 12),
                  _MonthlyGoalCard(received: received, goal: goal),
                  const SizedBox(height: 24),

                  // Projetos do dia
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SectionLabel(
                            _isToday ? 'PROJETOS DE HOJE' : 'PROJETOS DO DIA'),
                        if (state.projects.isNotEmpty)
                          TextButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const SalesHistoryScreen())),
                            child: const Text('Ver histórico',
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.primary)),
                          ),
                      ]),
                  const SizedBox(height: 8),

                  if (dayProjects.isEmpty)
                    AppCard(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: EmptyState(
                          icon: Icons.folder_open_outlined,
                          title: _isToday
                              ? 'Nenhum projeto hoje'
                              : 'Nenhum projeto neste dia',
                          subtitle: _isToday
                              ? 'Os projetos criados hoje aparecerão aqui'
                              : 'Não há projetos em ${DateFormat("dd/MM/yyyy", "pt_BR").format(_selected)}'),
                    ))
                  else
                    ...recent.map((p) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _RecentProjectTile(project: p),
                        )),

                  const SizedBox(height: 80),
                ]),
          ),
        ),
      ]),
    );
  }
}

class _MonthlyGoalCard extends StatelessWidget {
  final double received;
  final double goal;
  const _MonthlyGoalCard({required this.received, required this.goal});

  @override
  Widget build(BuildContext context) {
    final hasGoal = goal > 0;
    final progress = hasGoal ? (received / goal).clamp(0.0, 1.0) : 0.0;

    final IconData statusIcon;
    final Color statusColor;
    final String statusText;

    if (!hasGoal) {
      statusIcon  = Icons.flag_outlined;
      statusColor = AppColors.textSecondary;
      statusText  = 'Meta não definida';
    } else if (received < goal - 0.01) {
      statusIcon  = Icons.trending_down_rounded;
      statusColor = AppColors.accent;
      statusText  = 'Abaixo da meta';
    } else if (received > goal + 0.01) {
      statusIcon  = Icons.trending_up_rounded;
      statusColor = AppColors.secondary;
      statusText  = 'Meta superada!';
    } else {
      statusIcon  = Icons.check_circle_rounded;
      statusColor = AppColors.secondary;
      statusText  = 'Meta atingida!';
    }

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(statusIcon, size: 18, color: statusColor),
          ),
          const SizedBox(width: 10),
          const Text('Meta Mensal',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(statusIcon, size: 12, color: statusColor),
              const SizedBox(width: 4),
              Text(statusText,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor)),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Recebido',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            Text(fmtMoney(received),
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: statusColor)),
          ]),
          if (hasGoal)
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const Text('Meta',
                  style:
                      TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text(fmtMoney(goal),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ]),
        ]),
        if (hasGoal) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.bg3,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${(progress * 100).toStringAsFixed(0)}% da meta',
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
            if (received < goal - 0.01)
              Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.arrow_upward_rounded,
                    size: 11, color: AppColors.accent),
                const SizedBox(width: 3),
                Text('Faltam ${fmtMoney(goal - received)}',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent)),
              ]),
          ]),
        ],
      ]),
    );
  }
}

class _RecentProjectTile extends StatelessWidget {
  final Project project;
  const _RecentProjectTile({required this.project});

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.folder_rounded,
                size: 20, color: AppColors.primary),
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
                      project.client?.name ?? 'Sem cliente',
                      '${project.services.length} serviço${project.services.length == 1 ? "" : "s"}',
                    ].join(' · '),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ])),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(fmtMoney(project.total),
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.primary)),
            const SizedBox(height: 4),
            StatusChip(project.status.label),
          ]),
        ]),
      );
}
