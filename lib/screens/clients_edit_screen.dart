// lib/screens/clients_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../widgets/widgets.dart';

class ClientsEditScreen extends StatefulWidget {
  final Client? client;

  const ClientsEditScreen({super.key, this.client});

  @override
  State<ClientsEditScreen> createState() => _ClientsEditScreenState();
}

class _ClientsEditScreenState extends State<ClientsEditScreen> {
  late final _name = TextEditingController(text: widget.client?.name ?? '');
  late final _cpfCnpj = TextEditingController(text: widget.client?.cpfCnpj ?? '');
  late final _phone = TextEditingController(text: widget.client?.phone ?? '');
  late final _email = TextEditingController(text: widget.client?.email ?? '');
  late final _address = TextEditingController(text: widget.client?.address ?? '');
  late final _city = TextEditingController(text: widget.client?.city ?? '');
  late final _state = TextEditingController(text: widget.client?.state ?? '');
  late final _notes = TextEditingController(text: widget.client?.notes ?? '');

  @override
  void dispose() {
    for (final c in [_name, _cpfCnpj, _phone, _email, _address, _city, _state, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (_name.text.trim().isEmpty) {
      showSnack(context, '❌ Nome é obrigatório!', isError: true);
      return;
    }

    final state = context.read<AppState>();
    if (widget.client == null) {
      state.addClient(
        name: _name.text.trim(),
        cpfCnpj: _cpfCnpj.text.trim(),
        phone: _phone.text.trim(),
        email: _email.text.trim(),
        address: _address.text.trim(),
        city: _city.text.trim(),
        state: _state.text.trim(),
        notes: _notes.text.trim(),
      );
      showSnack(context, '✅ Cliente "${_name.text.trim()}" cadastrado com sucesso!');
    } else {
      state.updateClient(
        widget.client!.id,
        name: _name.text.trim(),
        cpfCnpj: _cpfCnpj.text.trim(),
        phone: _phone.text.trim(),
        email: _email.text.trim(),
        address: _address.text.trim(),
        city: _city.text.trim(),
        state: _state.text.trim(),
        notes: _notes.text.trim(),
      );
      showSnack(context, '✅ Cliente "${_name.text.trim()}" atualizado!');
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.client == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? 'Novo Cliente' : 'Editar Cliente'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('NOME *'),
                const SizedBox(height: 8),
                AppTextField(
                  hint: 'Ex: João Silva',
                  controller: _name,
                ),
                const SizedBox(height: 12),
                const SectionLabel('CPF/CNPJ'),
                const SizedBox(height: 8),
                AppTextField(
                  hint: 'XXX.XXX.XXX-XX',
                  controller: _cpfCnpj,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                const SectionLabel('TELEFONE / WHATSAPP'),
                const SizedBox(height: 8),
                AppTextField(
                  hint: '(XX) XXXXX-XXXX',
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                const SectionLabel('EMAIL'),
                const SizedBox(height: 8),
                AppTextField(
                  hint: 'exemplo@email.com',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                const SectionLabel('ENDEREÇO'),
                const SizedBox(height: 8),
                AppTextField(
                  hint: 'Rua, número',
                  controller: _address,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionLabel('CIDADE'),
                          const SizedBox(height: 8),
                          AppTextField(
                            hint: 'Cidade',
                            controller: _city,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 80,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionLabel('ESTADO'),
                          const SizedBox(height: 8),
                          AppTextField(
                            hint: 'UF',
                            controller: _state,
                            maxLength: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const SectionLabel('OBSERVAÇÕES'),
                const SizedBox(height: 8),
                AppTextField(
                  hint: 'Notas adicionais...',
                  controller: _notes,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: isNew ? 'Criar Cliente' : 'Salvar Alterações',
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
