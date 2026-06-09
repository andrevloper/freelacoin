// lib/screens/catalog_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'products_edit_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});
  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String _search   = '';
  String _category = 'Todos';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _confirmDelete(FreelanceService s) => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('Excluir serviço'),
          content: Text('Deseja excluir "${s.name}" permanentemente?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar')),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.cancelledFg),
              onPressed: () {
                context.read<AppState>().deleteService(s.id);
                Navigator.pop(context);
                showSnack(context, '✅ Serviço "${s.name}" excluído');
              },
              child: const Text('Excluir'),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final cats = ['Todos', ...{for (final s in state.services) s.category}];
    final list = state.services.where((s) =>
        (_category == 'Todos' || s.category == _category) &&
        (s.name.toLowerCase().contains(_search.toLowerCase()) ||
         s.description.toLowerCase().contains(_search.toLowerCase()) ||
         s.technologies.any((t) => t.toLowerCase().contains(_search.toLowerCase())))).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Serviços'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProductsEditScreen())),
              icon: const Icon(Icons.add_outlined, color: Colors.white, size: 18),
              label: const Text('Novo',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: Column(children: [
        // ── Busca ──────────────────────────────────────
        Container(
          color: AppColors.bg,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Buscar por nome, tecnologia...',
              prefixIcon: const Icon(Icons.search,
                  color: AppColors.textSecondary, size: 20),
              suffixIcon: _search.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _search = '');
                      })
                  : null,
            ),
          ),
        ),

        // ── Categorias ─────────────────────────────────
        Container(
          color: AppColors.bg,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: cats.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final c = cats[i];
                return CategoryChip(
                  label: c,
                  selected: _category == c,
                  onTap: () => setState(() => _category = c),
                  color: c == 'Todos'
                      ? AppColors.primary
                      : AppTheme.categoryColor(c),
                );
              },
            ),
          ),
        ),
        const Divider(),

        // ── Lista de serviços ──────────────────────────
        Expanded(
          child: list.isEmpty
              ? const EmptyState(
                  icon: Icons.search_off,
                  title: 'Nenhum serviço encontrado',
                  subtitle: 'Tente outro termo de busca')
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _ServiceCard(
                    service: list[i],
                    onEdit: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                ProductsEditScreen(service: list[i]))),
                    onDelete: () => _confirmDelete(list[i]),
                  ),
                ),
        ),
      ]),
    );
  }
}

class _ServiceCard extends StatefulWidget {
  final FreelanceService service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ServiceCard({
    required this.service,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  FreelanceService get service => widget.service;

  Future<void> _handleAdd(BuildContext context, AppState state) async {
    if (service.openPrice) {
      final ctrl = TextEditingController(
          text: service.basePrice > 0
              ? service.basePrice.toStringAsFixed(2)
              : '');
      final price = await showDialog<double>(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          title: Text('Valor para ${service.name}'),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              prefixText: 'R\$ ',
              hintText: '0,00',
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                final v = double.tryParse(
                    ctrl.text.replaceAll(',', '.'));
                Navigator.pop(context, v);
              },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      );
      ctrl.dispose();
      if (price == null || price <= 0) return;
      if (!context.mounted) return;
      state.toggleService(service);
      state.setServicePrice(service.id, price);
    } else {
      state.toggleService(service);
    }
    if (!context.mounted) return;
    showSnack(context, '✅ ${service.name} adicionado ao projeto!');
    state.setTab(2);
  }

  @override
  Widget build(BuildContext context) {
    final state    = context.watch<AppState>();
    final added    = state.inCart(service.id);
    final catColor = AppTheme.categoryColor(service.category);

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        // ── Cabeçalho ──────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: catColor.withValues(alpha: 0.08),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(14)),
            border: Border(
                bottom: BorderSide(
                    color: catColor.withValues(alpha: 0.15), width: 0.8)),
          ),
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10)),
              child: Center(
                  child: Text(service.emoji,
                      style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(service.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 3),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(service.category,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: catColor)),
                    ),
                    if (service.openPrice) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: AppColors.accentLight,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Text('Preço livre',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                    if (!service.available) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: AppColors.cancelledBg,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Text('Inativo',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.cancelledFg,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ]),
                ])),
            Column(children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    size: 18, color: AppColors.primary),
                onPressed: widget.onEdit,
                padding: EdgeInsets.zero,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 18, color: AppColors.cancelledFg),
                onPressed: widget.onDelete,
                padding: EdgeInsets.zero,
              ),
            ]),
          ]),
        ),

        // ── Descrição e tecnologias ─────────────────
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            Text(service.description,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4)),
            const SizedBox(height: 12),

            // Tecnologias
            if (service.technologies.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: service.technologies
                      .map((t) => _TechChip(label: t, color: catColor))
                      .toList(),
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Preço + botão
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                        service.openPrice ? 'Preço livre' : 'Preço base',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                    service.openPrice
                        ? Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accentLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: AppColors.accent.withValues(alpha: 0.4),
                                  width: 0.8),
                            ),
                            child: const Text('A negociar',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accent)),
                          )
                        : Text(fmtMoney(service.basePrice),
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                letterSpacing: -0.5)),
                  ]),
                  GestureDetector(
                    onTap: service.available
                        ? () {
                            if (added) {
                              state.toggleService(service);
                              showSnack(context,
                                  '❌ ${service.name} removido do projeto');
                            } else {
                              _handleAdd(context, state);
                            }
                          }
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: added
                            ? AppColors.secondaryLight
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(
                          added
                              ? Icons.check_circle_rounded
                              : Icons.add_circle_outline_rounded,
                          color: added ? AppColors.secondary : Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          added ? 'Adicionado' : 'Ao projeto',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: added
                                  ? AppColors.secondary
                                  : Colors.white),
                        ),
                      ]),
                    ),
                  ),
                ]),
          ]),
        ),
      ]),
    );
  }
}

class _TechChip extends StatelessWidget {
  final String label;
  final Color color;
  const _TechChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 0.8),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color.withValues(alpha: 0.85))),
      );
}
