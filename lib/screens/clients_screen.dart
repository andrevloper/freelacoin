// lib/screens/clients_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'clients_edit_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});
  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  String _search = '';
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _confirmDelete(Client c) => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('Excluir cliente'),
          content: Text('Deseja excluir "${c.name}" permanentemente?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar')),
            TextButton(
              style:
                  TextButton.styleFrom(foregroundColor: AppColors.cancelledFg),
              onPressed: () {
                context.read<AppState>().deleteClient(c.id);
                Navigator.pop(context);
                showSnack(context, '✅ Cliente "${c.name}" excluído');
              },
              child: const Text('Excluir'),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final list = state.clients
        .where((c) =>
            c.name.toLowerCase().contains(_search.toLowerCase()) ||
            c.phone.contains(_search) ||
            c.cpfCnpj.contains(_search))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ClientsEditScreen())),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Novo Cliente',
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(children: [
        Container(
          color: AppColors.bg,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: TextField(
            controller: _ctrl,
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Buscar por nome, telefone, CPF...',
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
        const Divider(),
        Expanded(
          child: list.isEmpty
              ? EmptyState(
                  icon: Icons.people_outline,
                  title: _search.isEmpty
                      ? 'Nenhum cliente cadastrado'
                      : 'Nenhum resultado',
                  subtitle: _search.isEmpty
                      ? 'Toque em "Novo" para cadastrar o primeiro cliente'
                      : null,
                  action: _search.isEmpty
                      ? SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ClientsEditScreen())),
                            icon: const Icon(Icons.person_add_outlined, size: 20),
                            label: const Text('Cadastrar Cliente',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        )
                      : null,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _ClientTile(
                      client: list[i],
                      onEdit: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  ClientsEditScreen(client: list[i]))),
                      onDelete: () => _confirmDelete(list[i])),
                ),
        ),
      ]),
    );
  }
}

class _ClientTile extends StatelessWidget {
  final Client client;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _ClientTile(
      {required this.client, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.all(14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClientAvatar(client.name),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(client.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                if (client.cpfCnpj.isNotEmpty)
                  InfoRow(
                      icon: Icons.badge_outlined,
                      label: 'CPF/CNPJ',
                      value: client.cpfCnpj),
                if (client.phone.isNotEmpty)
                  InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Tel',
                      value: client.phone),
                if (client.email.isNotEmpty)
                  InfoRow(
                      icon: Icons.email_outlined,
                      label: 'E-mail',
                      value: client.email),
                if (client.address.isNotEmpty)
                  InfoRow(
                      icon: Icons.location_on_outlined,
                      label: 'End.',
                      value:
                          '${client.address}${client.city.isNotEmpty ? ", ${client.city}" : ""}${client.state.isNotEmpty ? "/${client.state}" : ""}'),
                if (client.notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: AppColors.bg2,
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(client.notes,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic)),
                  ),
                ],
              ])),
          Column(children: [
            IconButton(
                icon: const Icon(Icons.edit_outlined,
                    size: 20, color: AppColors.primary),
                onPressed: onEdit,
                padding: EdgeInsets.zero),
            IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 20, color: AppColors.cancelledFg),
                onPressed: onDelete,
                padding: EdgeInsets.zero),
          ]),
        ]),
      );
}
