// lib/screens/orders_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _search        = '';
  ProjectStatus? _filterStatus;
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final list = state.projects
        .where((p) =>
            (p.title.toLowerCase().contains(_search.toLowerCase()) ||
             (p.client?.name.toLowerCase().contains(_search.toLowerCase()) ?? false)) &&
            (_filterStatus == null || p.status == _filterStatus))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projetos'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${list.length} projeto${list.length == 1 ? "" : "s"}',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8)),
              ),
            ),
          ),
        ],
      ),
      body: Column(children: [
        Container(
          color: AppColors.bg,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            controller: _ctrl,
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Buscar por título ou cliente...',
              prefixIcon: const Icon(Icons.search,
                  color: AppColors.textSecondary, size: 20),
              suffixIcon: _search.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _ctrl.clear();
                        setState(() => _search = '');
                      })
                  : null,
            ),
          ),
        ),
        // Filtros de status
        Container(
          color: AppColors.bg,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: SizedBox(
            height: 34,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              CategoryChip(
                  label: 'Todos',
                  selected: _filterStatus == null,
                  onTap: () => setState(() => _filterStatus = null)),
              const SizedBox(width: 8),
              ...ProjectStatus.values.map((s) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CategoryChip(
                      label: s.label,
                      selected: _filterStatus == s,
                      onTap: () => setState(() => _filterStatus = s),
                      color: AppTheme.statusColors(s.label).$2,
                    ),
                  )),
            ]),
          ),
        ),
        const Divider(),
        Expanded(
          child: list.isEmpty
              ? const EmptyState(
                  icon: Icons.folder_outlined,
                  title: 'Nenhum projeto',
                  subtitle: 'Os projetos salvos aparecerão aqui')
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _ProjectCard(project: list[i]),
                ),
        ),
      ]),
    );
  }
}

class _ProjectCard extends StatefulWidget {
  final Project project;
  const _ProjectCard({required this.project});
  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _expanded = false;

  void _continueDraft(BuildContext context) {
    final state = context.read<AppState>();
    if (!state.cartEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Projeto em edição'),
          content: const Text(
              'Você tem serviços no projeto atual. Deseja descartá-los e continuar este rascunho?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar')),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.accent),
              onPressed: () {
                Navigator.pop(context);
                state.loadDraftProject(widget.project);
                state.setTab(2);
              },
              child: const Text('Descartar e continuar'),
            ),
          ],
        ),
      );
    } else {
      state.loadDraftProject(widget.project);
      state.setTab(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        // ── Linha principal ────────────────────────
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.folder_rounded,
                    size: 22, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(children: [
                      Flexible(
                          child: Text(p.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppColors.textPrimary),
                              overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 6),
                      StatusChip(p.status.label),
                    ]),
                    const SizedBox(height: 3),
                    Text(
                      [
                        if (p.client != null) p.client!.name,
                        fmtDateShort(p.date),
                        '${p.services.length} serviço${p.services.length == 1 ? "" : "s"}',
                      ].join(' · '),
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ])),
              const SizedBox(width: 4),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(fmtMoney(p.total),
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.primary)),
                const SizedBox(height: 2),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  if (p.status == ProjectStatus.pending)
                    GestureDetector(
                      onTap: () => _continueDraft(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: AppColors.accentLight,
                            borderRadius: BorderRadius.circular(6)),
                        child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_outlined,
                                  size: 14, color: AppColors.accent),
                              SizedBox(width: 3),
                              Text('Editar',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.accent)),
                            ]),
                      ),
                    ),
                  const SizedBox(width: 6),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.textSecondary, size: 20),
                ]),
              ]),
            ]),
          ),
        ),

        // ── Detalhes ──────────────────────────────
        if (_expanded) ...[
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // Serviços
              ...p.services.map((ps) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(children: [
                      Text(ps.service.emoji,
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(ps.service.name,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                            if (ps.service.technologies.isNotEmpty)
                              Text(
                                  ps.service.technologies
                                      .take(3)
                                      .join(', '),
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary)),
                          ])),
                      Text(fmtMoney(ps.value),
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                    ]),
                  )),

              // Financeiro
              const Divider(height: 16),
              if (p.discountAmt > 0)
                _financRow('Desconto',
                    '− ${fmtMoney(p.discountAmt)}'),
              _financRow('Pagamento', p.paymentMethod.label),
              if (p.dueDate != null)
                _financRow('Prazo',
                    DateFormat('dd/MM/yyyy', 'pt_BR').format(p.dueDate!)),
              const SizedBox(height: 4),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                const Text('Total',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                Text(fmtMoney(p.total),
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary)),
              ]),

              if (p.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: AppColors.bg2,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(p.notes,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic)),
                ),
              ],

              // Atualizar status
              const SizedBox(height: 12),
              const SectionLabel('ATUALIZAR STATUS'),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  ...ProjectStatus.values.map((s) {
                    final (bg, fg) = AppTheme.statusColors(s.label);
                    final sel = p.status == s;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          context
                              .read<AppState>()
                              .updateProjectStatus(p.id, s);
                          showSnack(context,
                              '✅ Status: ${s.label}');
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: sel ? bg : AppColors.bg3,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: sel
                                    ? fg.withValues(alpha: 0.4)
                                    : Colors.transparent,
                                width: 1.2),
                          ),
                          child: Text(s.label,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: sel
                                      ? fg
                                      : AppColors.textSecondary)),
                        ),
                      ),
                    );
                  }),
                ]),
              ),

              // Ações
              const SizedBox(height: 12),
              Row(children: [
                if (p.status == ProjectStatus.pending)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _continueDraft(context),
                      icon: const Icon(Icons.edit_outlined, size: 17),
                      label: const Text('Editar Projeto'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  )
                else
                  const Spacer(),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Excluir projeto'),
                      content: const Text(
                          'Deseja excluir este projeto permanentemente?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar')),
                        TextButton(
                          style: TextButton.styleFrom(
                              foregroundColor: AppColors.cancelledFg),
                          onPressed: () {
                            context
                                .read<AppState>()
                                .deleteProject(p.id);
                            Navigator.pop(context);
                            showSnack(context, '✅ Projeto excluído');
                          },
                          child: const Text('Excluir'),
                        ),
                      ],
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.cancelledFg),
                  style: IconButton.styleFrom(
                      backgroundColor: AppColors.cancelledBg,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
              ]),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _financRow(String l, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
              Text(v,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            ]),
      );
}
