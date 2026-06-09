// lib/screens/order_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});
  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();
  Client? _client;
  PaymentMethod _payment = PaymentMethod.pix;
  DateTime? _dueDate;
  bool _busy = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    _discountCtrl.dispose();
    super.dispose();
  }

  double get _discount =>
      double.tryParse(_discountCtrl.text.replaceAll(',', '.')) ?? 0;

  void _resetForm() => setState(() {
        _titleCtrl.clear();
        _notesCtrl.clear();
        _discountCtrl.clear();
        _client = null;
        _payment = PaymentMethod.pix;
        _dueDate = null;
      });

  void _loadPendingDraft() {
    if (!mounted) return;
    final state = context.read<AppState>();
    if (!state.hasPendingDraft) return;
    setState(() {
      _titleCtrl.text = state.pendingTitle;
      _client = state.pendingClient;
      _payment = state.pendingPayment;
      _notesCtrl.text = state.pendingNotes;
      _discountCtrl.text = state.pendingDiscount?.toStringAsFixed(2) ?? '';
      _dueDate = state.pendingDueDate;
    });
    state.consumePendingDraft();
  }

  void _saveDraft(AppState state) {
    if (state.cartEmpty) {
      _snack('Adicione serviços antes de salvar o rascunho');
      return;
    }
    final title = _titleCtrl.text.trim();
    state.saveProject(
      title: title.isEmpty ? 'Projeto sem título' : title,
      client: _client,
      notes: _notesCtrl.text,
      paymentMethod: _payment,
      discount: _discount > 0 ? _discount : null,
      dueDate: _dueDate,
      status: ProjectStatus.pending,
    );
    _resetForm();
    _snack('Rascunho salvo! Finalize quando quiser na aba Projetos.');
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      helpText: 'Prazo de entrega',
      confirmText: 'Confirmar',
      cancelText: 'Cancelar',
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _saveProject(AppState state) async {
    if (state.cartEmpty) {
      _snack('Adicione ao menos um serviço ao projeto');
      return;
    }
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      _snack('Informe o título do projeto');
      return;
    }

    setState(() => _busy = true);
    try {
      state.saveProject(
        title: title,
        client: _client,
        notes: _notesCtrl.text,
        paymentMethod: _payment,
        discount: _discount > 0 ? _discount : null,
        dueDate: _dueDate,
        status: ProjectStatus.inProgress,
      );
      _resetForm();
      _snack('Projeto salvo com sucesso!');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String msg, {bool isError = false}) =>
      showSnack(context, msg, isError: isError);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (state.hasPendingDraft) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadPendingDraft());
    }

    final items = state.cartItems;
    final subtotal = state.cartTotal;
    final total = subtotal - _discount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Projeto'),
        actions: [
          if (!state.cartEmpty) ...[
            TextButton.icon(
              onPressed: _busy ? null : () => _saveDraft(state),
              icon: const Icon(Icons.bookmark_outline,
                  color: Colors.white70, size: 18),
              label: const Text('Rascunho',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
            ),
            TextButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Limpar projeto'),
                  content: const Text('Deseja remover todos os serviços?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar')),
                    TextButton(
                        onPressed: () {
                          state.clearCart();
                          Navigator.pop(context);
                          _snack('Projeto limpo');
                        },
                        child: const Text('Limpar',
                            style: TextStyle(color: Colors.red))),
                  ],
                ),
              ),
              icon: const Icon(Icons.delete_outline,
                  color: Colors.white70, size: 18),
              label: const Text('Limpar',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
            ),
          ],
        ],
      ),
      body: state.cartEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                          color: AppColors.bg3, shape: BoxShape.circle),
                      child: const Icon(Icons.add_circle_outline_rounded,
                          size: 44, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    const Text('Projeto vazio',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    const Text(
                        'Adicione serviços no Catálogo para montar o projeto',
                        style: TextStyle(
                            fontSize: 14, color: AppColors.textSecondary),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.read<AppState>().setTab(1),
                        icon: const Icon(Icons.design_services_outlined,
                            size: 20),
                        label: const Text('Ir para Serviços',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Título do projeto ──────────────────
                AppCard(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const SectionLabel('TÍTULO DO PROJETO *'),
                      const SizedBox(height: 10),
                      AppTextField(
                        hint: 'Ex: Site institucional para empresa X',
                        controller: _titleCtrl,
                      ),
                    ])),
                const SizedBox(height: 12),

                // ── Serviços selecionados ──────────────
                AppCard(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SectionLabel('SERVIÇOS'),
                            Text(
                                '${items.length} serviço${items.length == 1 ? "" : "s"}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600)),
                          ]),
                      const SizedBox(height: 12),
                      ...items.map((item) => _ServiceRow(item: item)),
                      const Divider(height: 20),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary)),
                            Text(fmtMoney(subtotal),
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary)),
                          ]),
                    ])),
                const SizedBox(height: 12),

                // ── Cliente ────────────────────────────
                AppCard(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const SectionLabel('CLIENTE'),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<Client?>(
                        initialValue: _client,
                        decoration: const InputDecoration(
                            hintText: 'Selecionar cliente (opcional)',
                            prefixIcon: Icon(Icons.person_outline, size: 20)),
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('Sem cliente')),
                          ...state.clients.map((c) =>
                              DropdownMenuItem(value: c, child: Text(c.name))),
                        ],
                        onChanged: (v) => setState(() => _client = v),
                      ),
                      if (_client != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(children: [
                            ClientAvatar(_client!.name, size: 36),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(_client!.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13)),
                                  if (_client!.phone.isNotEmpty)
                                    Text(_client!.phone,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary)),
                                ])),
                          ]),
                        ),
                      ],
                    ])),
                const SizedBox(height: 12),

                // ── Prazo ──────────────────────────────
                AppCard(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const SectionLabel('PRAZO DE ENTREGA'),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _pickDueDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.bg,
                            borderRadius: BorderRadius.circular(10),
                            border:
                                Border.all(color: AppColors.border, width: 0.8),
                          ),
                          child: Row(children: [
                            const Icon(Icons.calendar_today_outlined,
                                size: 18, color: AppColors.textSecondary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _dueDate != null
                                    ? DateFormat('dd/MM/yyyy', 'pt_BR')
                                        .format(_dueDate!)
                                    : 'Sem prazo definido',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: _dueDate != null
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary),
                              ),
                            ),
                            if (_dueDate != null)
                              GestureDetector(
                                onTap: () => setState(() => _dueDate = null),
                                child: const Icon(Icons.clear,
                                    size: 18, color: AppColors.textSecondary),
                              ),
                          ]),
                        ),
                      ),
                    ])),
                const SizedBox(height: 12),

                // ── Pagamento ──────────────────────────
                AppCard(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const SectionLabel('FORMA DE PAGAMENTO'),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<PaymentMethod>(
                        initialValue: _payment,
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.payment_outlined, size: 20)),
                        items: PaymentMethod.values
                            .map((m) => DropdownMenuItem(
                                value: m, child: Text(m.label)))
                            .toList(),
                        onChanged: (v) => setState(() => _payment = v!),
                      ),
                    ])),
                const SizedBox(height: 12),

                // ── Desconto ───────────────────────────
                AppCard(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const SectionLabel('DESCONTO'),
                      const SizedBox(height: 10),
                      AppTextField(
                          label: 'Desconto (R\$)',
                          controller: _discountCtrl,
                          keyboardType: TextInputType.number),
                    ])),
                const SizedBox(height: 12),

                // ── Observações ────────────────────────
                AppCard(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const SectionLabel('OBSERVAÇÕES'),
                      const SizedBox(height: 10),
                      AppTextField(
                          hint:
                              'Detalhes do projeto, requisitos, tecnologias específicas...',
                          controller: _notesCtrl,
                          maxLines: 3),
                    ])),
                const SizedBox(height: 16),

                // ── Total ──────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('VALOR DO PROJETO',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5)),
                        Text(fmtMoney(total < 0 ? 0 : total),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5)),
                      ]),
                ),
                const SizedBox(height: 12),

                // ── Ações ──────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _busy ? null : () => _saveProject(state),
                    icon: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check_circle_outline),
                    label: const Text('Salvar Projeto'),
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }
}

// ── Linha de serviço no projeto ───────────────────────
class _ServiceRow extends StatefulWidget {
  final ProjectService item;
  const _ServiceRow({required this.item});
  @override
  State<_ServiceRow> createState() => _ServiceRowState();
}

class _ServiceRowState extends State<_ServiceRow> {
  late final _priceCtrl = TextEditingController(
      text: widget.item.customValue?.toStringAsFixed(2) ??
          widget.item.service.basePrice.toStringAsFixed(2));
  bool _editing = false;

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
  }

  void _applyPrice() {
    final v = double.tryParse(_priceCtrl.text.replaceAll(',', '.'));
    if (v != null && v >= 0) {
      context.read<AppState>().setServicePrice(widget.item.service.id, v);
    }
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final catColor = AppTheme.categoryColor(widget.item.service.category);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8)),
          child: Center(
              child: Text(widget.item.service.emoji,
                  style: const TextStyle(fontSize: 20))),
        ),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.item.service.name,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis),
          Text(widget.item.service.category,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
          if (_editing) ...[
            const SizedBox(height: 6),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _priceCtrl,
                  autofocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    prefixText: 'R\$ ',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _applyPrice(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.check_circle_rounded,
                    color: AppColors.secondary, size: 22),
                onPressed: _applyPrice,
                padding: EdgeInsets.zero,
              ),
            ]),
          ],
        ])),
        const SizedBox(width: 8),
        if (!_editing) ...[
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(fmtMoney(widget.item.value),
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.textPrimary)),
            Row(mainAxisSize: MainAxisSize.min, children: [
              GestureDetector(
                onTap: () => setState(() => _editing = true),
                child: const Icon(Icons.edit_outlined,
                    size: 14, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () =>
                    context.read<AppState>().toggleService(widget.item.service),
                child: const Icon(Icons.close_rounded,
                    size: 16, color: AppColors.cancelledFg),
              ),
            ]),
          ]),
        ],
      ]),
    );
  }
}
