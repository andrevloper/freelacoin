// lib/screens/products_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class ProductsEditScreen extends StatefulWidget {
  final FreelanceService? service;

  const ProductsEditScreen({super.key, this.service});

  @override
  State<ProductsEditScreen> createState() => _ProductsEditScreenState();
}

class _ProductsEditScreenState extends State<ProductsEditScreen> {
  late final _name = TextEditingController(text: widget.service?.name ?? '');
  late final _emoji =
      TextEditingController(text: widget.service?.emoji ?? '💼');
  late final _description =
      TextEditingController(text: widget.service?.description ?? '');
  late final _techCtrl = TextEditingController(
      text: widget.service?.technologies.join(', ') ?? '');
  late final _basePrice = TextEditingController(
      text: widget.service?.basePrice.toStringAsFixed(2) ?? '0.00');

  late String _category = widget.service?.category ?? 'Desenvolvimento';
  late bool _available = widget.service?.available ?? true;
  late bool _openPrice = widget.service?.openPrice ?? false;

  static const _categories = [
    'Desenvolvimento',
    'Design',
    'Infraestrutura',
    'Consultoria',
    'Outro',
  ];

  @override
  void dispose() {
    for (final c in [_name, _emoji, _description, _techCtrl, _basePrice]) {
      c.dispose();
    }
    super.dispose();
  }

  List<String> get _technologies => _techCtrl.text
      .split(',')
      .map((t) => t.trim())
      .where((t) => t.isNotEmpty)
      .toList();

  void _save() {
    if (_name.text.trim().isEmpty) {
      showSnack(context, '❌ Nome é obrigatório!', isError: true);
      return;
    }

    try {
      final state = context.read<AppState>();
      final basePrice =
          double.tryParse(_basePrice.text.replaceAll(',', '.')) ?? 0;

      if (widget.service == null) {
        state.addService(
          name: _name.text.trim(),
          emoji: _emoji.text.trim().isEmpty ? '💼' : _emoji.text.trim(),
          description: _description.text.trim(),
          category: _category,
          technologies: _technologies,
          basePrice: basePrice,
          available: _available,
          openPrice: _openPrice,
        );
        showSnack(context,
            '✅ Serviço "${_name.text.trim()}" cadastrado com sucesso!');
      } else {
        state.updateService(
          widget.service!.id,
          name: _name.text.trim(),
          emoji: _emoji.text.trim().isEmpty ? '💼' : _emoji.text.trim(),
          description: _description.text.trim(),
          category: _category,
          technologies: _technologies,
          basePrice: basePrice,
          available: _available,
          openPrice: _openPrice,
        );
        showSnack(context, '✅ Serviço "${_name.text.trim()}" atualizado!');
      }

      Navigator.pop(context);
    } catch (e) {
      showSnack(context, '❌ Erro ao salvar: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.service == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? 'Novo Serviço' : 'Editar Serviço'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome
                const SectionLabel('NOME DO SERVIÇO *'),
                const SizedBox(height: 8),
                AppTextField(
                  hint: 'Ex: Desenvolvimento Web',
                  controller: _name,
                ),
                const SizedBox(height: 12),

                // Emoji + Categoria
                Row(children: [
                  SizedBox(
                    width: 90,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionLabel('EMOJI'),
                          const SizedBox(height: 8),
                          AppTextField(
                            hint: '💼',
                            controller: _emoji,
                            maxLength: 5,
                          ),
                        ]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionLabel('CATEGORIA'),
                          const SizedBox(height: 8),
                          DropdownMenu<String>(
                            width: MediaQuery.of(context).size.width - 146,
                            initialSelection: _category,
                            dropdownMenuEntries: _categories
                                .map((c) =>
                                    DropdownMenuEntry(value: c, label: c))
                                .toList(),
                            onSelected: (v) => setState(
                                () => _category = v ?? 'Desenvolvimento'),
                          ),
                        ]),
                  ),
                ]),
                const SizedBox(height: 12),

                // Descrição
                const SectionLabel('DESCRIÇÃO'),
                const SizedBox(height: 8),
                AppTextField(
                  hint: 'Descreva o que este serviço inclui...',
                  controller: _description,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),

                // Tecnologias
                const SectionLabel('TECNOLOGIAS'),
                const SizedBox(height: 4),
                const Text(
                  'Separe com vírgulas: React, Node.js, Flutter...',
                  style:
                      TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                AppTextField(
                  hint: 'React, TypeScript, Node.js',
                  controller: _techCtrl,
                  maxLines: 2,
                ),

                // Preview das tecnologias
                if (_techCtrl.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _technologies
                        .map((t) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.3),
                                    width: 0.8),
                              ),
                              child: Text(t,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500)),
                            ))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 12),

                // Preço base
                const SectionLabel('PREÇO BASE (R\$)'),
                const SizedBox(height: 8),
                AppTextField(
                  hint: '0,00',
                  controller: _basePrice,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),

                // Disponível
                Row(children: [
                  Checkbox(
                    value: _available,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _available = v ?? true),
                  ),
                  const Text('Serviço ativo',
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textPrimary)),
                ]),

                // Preço aberto
                Row(children: [
                  Checkbox(
                    value: _openPrice,
                    activeColor: AppColors.accent,
                    onChanged: (v) => setState(() => _openPrice = v ?? false),
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Preço aberto',
                            style: TextStyle(
                                fontSize: 14, color: AppColors.textPrimary)),
                        Text(
                          'Permite alterar o valor ao adicionar ao projeto',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 16),

                PrimaryButton(
                  label: isNew ? 'Criar Serviço' : 'Salvar Alterações',
                  icon: Icons.save_outlined,
                  onTap: _save,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
