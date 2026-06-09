// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final _name      = TextEditingController(text: context.read<AppState>().freelancerName);
  late final _phone     = TextEditingController(text: context.read<AppState>().freelancerPhone);
  late final _email     = TextEditingController(text: context.read<AppState>().freelancerEmail);
  late final _specialty = TextEditingController(text: context.read<AppState>().freelancerSpecialty);
  late final _cpf       = TextEditingController(text: context.read<AppState>().freelancerCpf);

  @override
  void dispose() {
    for (final c in [_name, _phone, _email, _specialty, _cpf]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    context.read<AppState>().updateFreelancerInfo(
          name: _name.text.trim().isEmpty ? 'Meu Perfil' : _name.text.trim(),
          phone: _phone.text.trim(),
          email: _email.text.trim(),
          specialty: _specialty.text.trim(),
          cpf: _cpf.text.trim(),
        );
    showSnack(context, '✅ Perfil salvo!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Perfil ────────────────────────────────
          AppCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.person_outline_rounded,
                        color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text('Perfil do Freelancer',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                ]),
                const SizedBox(height: 16),

                const SectionLabel('SEU NOME / NOME DO NEGÓCIO'),
                const SizedBox(height: 8),
                AppTextField(
                    hint: 'Ex: João Silva Dev',
                    controller: _name),
                const SizedBox(height: 12),

                const SectionLabel('CPF / CNPJ'),
                const SizedBox(height: 8),
                AppTextField(
                    hint: 'XXX.XXX.XXX-XX',
                    controller: _cpf,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 12),

                const SectionLabel('ESPECIALIDADE'),
                const SizedBox(height: 8),
                AppTextField(
                    hint: 'Ex: Desenvolvedor Full Stack · Flutter · React',
                    controller: _specialty),
                const SizedBox(height: 12),

                const SectionLabel('TELEFONE / WHATSAPP'),
                const SizedBox(height: 8),
                AppTextField(
                    hint: '(XX) XXXXX-XXXX',
                    controller: _phone,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 12),

                const SectionLabel('E-MAIL'),
                const SizedBox(height: 8),
                AppTextField(
                    hint: 'seu@email.com',
                    controller: _email,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),

                PrimaryButton(
                    label: 'Salvar Perfil',
                    icon: Icons.save_outlined,
                    onTap: _save),
              ])),
          const SizedBox(height: 16),

          // ── Sobre ─────────────────────────────────
          AppCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: AppColors.accentLight,
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.info_outline,
                          color: AppColors.accent, size: 20)),
                  const SizedBox(width: 12),
                  const Text('Sobre o App',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                ]),
                const SizedBox(height: 12),
                _infoItem(Icons.work_outline_rounded, 'Freelas Fin',
                    'Controle financeiro para freelancers'),
                const SizedBox(height: 4),
                _infoItem(Icons.tag, 'Versão', '2.0.0'),
                const SizedBox(height: 4),
                _infoItem(Icons.storage_outlined, 'Armazenamento',
                    'Dados salvos localmente no dispositivo'),
              ])),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String title, String sub) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              Text(sub,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4)),
            ])),
      ]);
}
