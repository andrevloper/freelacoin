// lib/services/app_state.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  static const _uuid = Uuid();

  // ── Navegação ─────────────────────────────────────────
  int _activeTab = 0;
  int get activeTab => _activeTab;
  void setTab(int index) {
    if (_activeTab == index) return;
    _activeTab = index;
    notifyListeners();
  }

  // ── Dados ─────────────────────────────────────────────
  List<FreelanceService> services = List.from(kDefaultServices);
  List<Client> clients = [];
  List<Project> projects = [];

  // ── Perfil do Freelancer ──────────────────────────────
  String freelancerName    = 'Meu Perfil';
  String freelancerPhone   = '';
  String freelancerEmail   = '';
  String freelancerSpecialty = '';
  String freelancerCpf     = '';
  double monthlyGoal       = 0.0;

  // ── Rascunho pendente ─────────────────────────────────
  String pendingTitle           = '';
  Client? pendingClient;
  PaymentMethod pendingPayment  = PaymentMethod.pix;
  String pendingNotes           = '';
  double? pendingDiscount;
  DateTime? pendingDueDate;
  bool hasPendingDraft          = false;

  // ── Carrinho (serviços do projeto em edição) ──────────
  final Map<String, ProjectService> _cart = {};

  AppState() {
    _load();
  }

  // ── Carrinho ──────────────────────────────────────────
  List<ProjectService> get cartItems => _cart.values.toList();
  int get cartCount    => _cart.length;
  double get cartTotal => _cart.values.fold(0, (s, i) => s + i.value);
  bool get cartEmpty   => _cart.isEmpty;
  bool inCart(String id) => _cart.containsKey(id);

  void toggleService(FreelanceService s) {
    if (_cart.containsKey(s.id)) {
      _cart.remove(s.id);
    } else {
      _cart[s.id] = ProjectService(service: s);
    }
    notifyListeners();
  }

  void setServicePrice(String id, double price) {
    _cart[id]?.customValue = price;
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // ── Clientes ──────────────────────────────────────────
  void addClient({
    required String name,
    String cpfCnpj = '',
    String phone = '',
    String email = '',
    String address = '',
    String city = '',
    String state = '',
    String notes = '',
  }) {
    clients.add(Client(
      id: _uuid.v4(),
      name: name,
      cpfCnpj: cpfCnpj,
      phone: phone,
      email: email,
      address: address,
      city: city,
      state: state,
      notes: notes,
    ));
    _save();
    notifyListeners();
  }

  void updateClient(
    String id, {
    String? name,
    String? cpfCnpj,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? state,
    String? notes,
  }) {
    final i = clients.indexWhere((c) => c.id == id);
    if (i >= 0) {
      clients[i] = clients[i].copyWith(
        name: name,
        cpfCnpj: cpfCnpj,
        phone: phone,
        email: email,
        address: address,
        city: city,
        state: state,
        notes: notes,
      );
      _save();
      notifyListeners();
    }
  }

  void deleteClient(String id) {
    clients.removeWhere((c) => c.id == id);
    _save();
    notifyListeners();
  }

  // ── Projetos ──────────────────────────────────────────
  Project saveProject({
    required String title,
    Client? client,
    String notes = '',
    ProjectStatus status = ProjectStatus.pending,
    PaymentMethod paymentMethod = PaymentMethod.pix,
    double? discount,
    DateTime? dueDate,
  }) {
    final project = Project(
      id: _uuid.v4(),
      title: title,
      date: DateTime.now(),
      dueDate: dueDate,
      client: client,
      services: List.from(cartItems),
      notes: notes,
      status: status,
      paymentMethod: paymentMethod,
      discount: discount,
    );
    projects.insert(0, project);
    clearCart();
    _save();
    notifyListeners();
    return project;
  }

  void updateProjectStatus(String id, ProjectStatus status) {
    final i = projects.indexWhere((p) => p.id == id);
    if (i >= 0) {
      projects[i].status = status;
      _save();
      notifyListeners();
    }
  }

  void deleteProject(String id) {
    projects.removeWhere((p) => p.id == id);
    _save();
    notifyListeners();
  }

  void loadDraftProject(Project draft) {
    _cart.clear();
    for (final ps in draft.services) {
      _cart[ps.service.id] = ProjectService(
        service: ps.service,
        customValue: ps.customValue,
      );
    }
    pendingTitle    = draft.title;
    pendingClient   = draft.client;
    pendingPayment  = draft.paymentMethod;
    pendingNotes    = draft.notes;
    pendingDiscount = draft.discount;
    pendingDueDate  = draft.dueDate;
    hasPendingDraft = true;
    projects.removeWhere((p) => p.id == draft.id);
    _save();
    notifyListeners();
  }

  void consumePendingDraft() {
    hasPendingDraft = false;
    pendingTitle    = '';
    pendingClient   = null;
    pendingPayment  = PaymentMethod.pix;
    pendingNotes    = '';
    pendingDiscount = null;
    pendingDueDate  = null;
    notifyListeners();
  }

  // ── Configurações ─────────────────────────────────────
  void updateFreelancerInfo({
    String? name,
    String? phone,
    String? email,
    String? specialty,
    String? cpf,
    double? monthlyGoalValue,
  }) {
    if (name != null)             freelancerName      = name;
    if (phone != null)            freelancerPhone     = phone;
    if (email != null)            freelancerEmail     = email;
    if (specialty != null)        freelancerSpecialty = specialty;
    if (cpf != null)              freelancerCpf       = cpf;
    if (monthlyGoalValue != null) monthlyGoal         = monthlyGoalValue;
    _save();
    notifyListeners();
  }

  // ── Serviços ──────────────────────────────────────────
  void addService({
    required String name,
    required String description,
    required String category,
    required List<String> technologies,
    required double basePrice,
    bool available = true,
    String emoji = '💼',
    bool openPrice = false,
  }) {
    services.add(FreelanceService(
      id: _uuid.v4(),
      name: name,
      description: description,
      category: category,
      technologies: technologies,
      basePrice: basePrice,
      available: available,
      emoji: emoji,
      openPrice: openPrice,
    ));
    _save();
    notifyListeners();
  }

  void updateService(
    String id, {
    String? name,
    String? description,
    String? category,
    List<String>? technologies,
    double? basePrice,
    bool? available,
    String? emoji,
    bool? openPrice,
  }) {
    final i = services.indexWhere((s) => s.id == id);
    if (i >= 0) {
      services[i] = services[i].copyWith(
        name: name,
        description: description,
        category: category,
        technologies: technologies,
        basePrice: basePrice,
        available: available,
        emoji: emoji,
        openPrice: openPrice,
      );
      _save();
      notifyListeners();
    }
  }

  void deleteService(String id) {
    services.removeWhere((s) => s.id == id);
    _save();
    notifyListeners();
  }

  // ── Relatórios ────────────────────────────────────────
  List<Project> getProjectsByMonth(int month, int year) => projects
      .where((p) =>
          p.date.month == month &&
          p.date.year == year &&
          p.status != ProjectStatus.cancelled)
      .toList();

  double getRevenueByMonth(int month, int year) =>
      getProjectsByMonth(month, year).fold(0, (s, p) => s + p.total);

  int get activeProjectsCount => projects
      .where((p) =>
          p.status == ProjectStatus.pending ||
          p.status == ProjectStatus.inProgress ||
          p.status == ProjectStatus.review)
      .length;

  double get totalRevenue => projects
      .where((p) => p.status == ProjectStatus.paid)
      .fold(0, (s, p) => s + p.total);

  double getReceivedByMonth(int month, int year) => projects
      .where((p) =>
          p.status == ProjectStatus.paid &&
          p.date.month == month &&
          p.date.year == year)
      .fold(0, (s, p) => s + p.total);

  double get pendingRevenue => projects
      .where((p) =>
          p.status != ProjectStatus.cancelled &&
          p.status != ProjectStatus.paid)
      .fold(0, (s, p) => s + p.total);

  // ── Persistência ──────────────────────────────────────
  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('clients',  jsonEncode(clients.map((c) => c.toMap()).toList()));
    await p.setString('projects', jsonEncode(projects.map((pr) => pr.toMap()).toList()));
    await p.setString('services', jsonEncode(services.map((s) => s.toMap()).toList()));
    await p.setString('freelancerName',      freelancerName);
    await p.setString('freelancerPhone',     freelancerPhone);
    await p.setString('freelancerEmail',     freelancerEmail);
    await p.setString('freelancerSpecialty', freelancerSpecialty);
    await p.setString('freelancerCpf',       freelancerCpf);
    await p.setDouble('monthlyGoal',         monthlyGoal);
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    freelancerName      = p.getString('freelancerName')      ?? 'Meu Perfil';
    freelancerPhone     = p.getString('freelancerPhone')     ?? '';
    freelancerEmail     = p.getString('freelancerEmail')     ?? '';
    freelancerSpecialty = p.getString('freelancerSpecialty') ?? '';
    freelancerCpf       = p.getString('freelancerCpf')       ?? '';
    monthlyGoal         = p.getDouble('monthlyGoal')         ?? 0.0;

    final cj = p.getString('clients');
    if (cj != null) {
      clients = (jsonDecode(cj) as List).map((m) => Client.fromMap(m)).toList();
    }

    final pj = p.getString('projects');
    if (pj != null) {
      projects = (jsonDecode(pj) as List).map((m) => Project.fromMap(m)).toList();
    }

    final sj = p.getString('services');
    if (sj != null) {
      services = (jsonDecode(sj) as List).map((m) => FreelanceService.fromMap(m)).toList();
    } else {
      services = List.from(kDefaultServices);
      _save();
    }

    notifyListeners();
  }
}
