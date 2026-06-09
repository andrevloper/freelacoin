// lib/models/models.dart

// ─────────────────────────────────────────────────────
//  SERVIÇO FREELANCE
// ─────────────────────────────────────────────────────
class FreelanceService {
  final String id;
  String name;
  String description;
  String category;
  List<String> technologies;
  double basePrice;
  bool available;
  String emoji;
  bool openPrice; // permite editar o valor ao adicionar ao projeto

  FreelanceService({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.technologies,
    required this.basePrice,
    this.available = true,
    required this.emoji,
    this.openPrice = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'category': category,
        'technologies': technologies,
        'basePrice': basePrice,
        'available': available,
        'emoji': emoji,
        'openPrice': openPrice,
      };

  factory FreelanceService.fromMap(Map<String, dynamic> m) => FreelanceService(
        id: m['id'],
        name: m['name'],
        description: m['description'],
        category: m['category'],
        technologies: (m['technologies'] as List?)?.map((e) => e.toString()).toList() ?? [],
        basePrice: (m['basePrice'] as num).toDouble(),
        available: m['available'] ?? true,
        emoji: m['emoji'] ?? '💼',
        openPrice: m['openPrice'] ?? false,
      );

  FreelanceService copyWith({
    String? name,
    String? description,
    String? category,
    List<String>? technologies,
    double? basePrice,
    bool? available,
    String? emoji,
    bool? openPrice,
  }) =>
      FreelanceService(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        category: category ?? this.category,
        technologies: technologies ?? this.technologies,
        basePrice: basePrice ?? this.basePrice,
        available: available ?? this.available,
        emoji: emoji ?? this.emoji,
        openPrice: openPrice ?? this.openPrice,
      );
}

// ─────────────────────────────────────────────────────
//  CLIENTE
// ─────────────────────────────────────────────────────
class Client {
  final String id;
  String name;
  String cpfCnpj;
  String phone;
  String email;
  String address;
  String city;
  String state;
  String notes;
  final DateTime createdAt;

  Client({
    required this.id,
    required this.name,
    this.cpfCnpj = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'cpfCnpj': cpfCnpj,
        'phone': phone,
        'email': email,
        'address': address,
        'city': city,
        'state': state,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Client.fromMap(Map<String, dynamic> m) => Client(
        id: m['id'],
        name: m['name'],
        cpfCnpj: m['cpfCnpj'] ?? '',
        phone: m['phone'] ?? '',
        email: m['email'] ?? '',
        address: m['address'] ?? '',
        city: m['city'] ?? '',
        state: m['state'] ?? '',
        notes: m['notes'] ?? '',
        createdAt: m['createdAt'] != null ? DateTime.parse(m['createdAt']) : null,
      );

  Client copyWith({
    String? name,
    String? cpfCnpj,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? state,
    String? notes,
  }) =>
      Client(
        id: id,
        createdAt: createdAt,
        name: name ?? this.name,
        cpfCnpj: cpfCnpj ?? this.cpfCnpj,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        address: address ?? this.address,
        city: city ?? this.city,
        state: state ?? this.state,
        notes: notes ?? this.notes,
      );
}

// ─────────────────────────────────────────────────────
//  SERVIÇO NO PROJETO
// ─────────────────────────────────────────────────────
class ProjectService {
  final FreelanceService service;
  double? customValue;

  ProjectService({required this.service, this.customValue});

  double get value => customValue ?? service.basePrice;

  Map<String, dynamic> toMap() => {
        'service': service.toMap(),
        'customValue': customValue,
      };

  factory ProjectService.fromMap(Map<String, dynamic> m) => ProjectService(
        service: FreelanceService.fromMap(m['service']),
        customValue: m['customValue'] != null ? (m['customValue'] as num).toDouble() : null,
      );
}

// ─────────────────────────────────────────────────────
//  STATUS DO PROJETO
// ─────────────────────────────────────────────────────
enum ProjectStatus { pending, inProgress, review, delivered, paid, cancelled }

extension ProjectStatusX on ProjectStatus {
  String get label => switch (this) {
        ProjectStatus.pending    => 'Pendente',
        ProjectStatus.inProgress => 'Em andamento',
        ProjectStatus.review     => 'Revisão',
        ProjectStatus.delivered  => 'Entregue',
        ProjectStatus.paid       => 'Pago',
        ProjectStatus.cancelled  => 'Cancelado',
      };

  static ProjectStatus fromLabel(String l) => switch (l) {
        'Em andamento' => ProjectStatus.inProgress,
        'Revisão'      => ProjectStatus.review,
        'Entregue'     => ProjectStatus.delivered,
        'Pago'         => ProjectStatus.paid,
        'Cancelado'    => ProjectStatus.cancelled,
        _              => ProjectStatus.pending,
      };
}

// ─────────────────────────────────────────────────────
//  MÉTODO DE PAGAMENTO
// ─────────────────────────────────────────────────────
enum PaymentMethod { pix, bankTransfer, cash, creditCard, boleto }

extension PaymentMethodX on PaymentMethod {
  String get label => switch (this) {
        PaymentMethod.pix          => 'PIX',
        PaymentMethod.bankTransfer => 'Transferência Bancária',
        PaymentMethod.cash         => 'Dinheiro',
        PaymentMethod.creditCard   => 'Cartão de Crédito',
        PaymentMethod.boleto       => 'Boleto',
      };

  static PaymentMethod fromLabel(String l) => PaymentMethod.values
      .firstWhere((e) => e.label == l, orElse: () => PaymentMethod.pix);
}

// ─────────────────────────────────────────────────────
//  PROJETO
// ─────────────────────────────────────────────────────
class Project {
  final String id;
  String title;
  final DateTime date;
  DateTime? dueDate;
  final Client? client;
  final List<ProjectService> services;
  String notes;
  ProjectStatus status;
  PaymentMethod paymentMethod;
  double? discount;

  Project({
    required this.id,
    required this.title,
    required this.date,
    this.dueDate,
    this.client,
    required this.services,
    this.notes = '',
    this.status = ProjectStatus.pending,
    this.paymentMethod = PaymentMethod.pix,
    this.discount,
  });

  double get servicesTotal => services.fold(0.0, (s, i) => s + i.value);
  double get discountAmt   => discount ?? 0.0;
  double get total         => servicesTotal - discountAmt;

  List<String> get allTechnologies =>
      services.expand((s) => s.service.technologies).toSet().toList();

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'date': date.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'client': client?.toMap(),
        'services': services.map((s) => s.toMap()).toList(),
        'notes': notes,
        'status': status.label,
        'paymentMethod': paymentMethod.label,
        'discount': discount,
      };

  factory Project.fromMap(Map<String, dynamic> m) => Project(
        id: m['id'],
        title: m['title'] ?? 'Projeto sem título',
        date: DateTime.parse(m['date']),
        dueDate: m['dueDate'] != null ? DateTime.parse(m['dueDate']) : null,
        client: m['client'] != null ? Client.fromMap(m['client']) : null,
        services: (m['services'] as List).map((s) => ProjectService.fromMap(s)).toList(),
        notes: m['notes'] ?? '',
        status: ProjectStatusX.fromLabel(m['status'] ?? ''),
        paymentMethod: PaymentMethodX.fromLabel(m['paymentMethod'] ?? 'PIX'),
        discount: m['discount'] != null ? (m['discount'] as num).toDouble() : null,
      );
}

// ─────────────────────────────────────────────────────
//  SERVIÇOS PADRÃO
// ─────────────────────────────────────────────────────
final List<FreelanceService> kDefaultServices = [
  FreelanceService(
    id: 'freelancer',
    name: 'Freelancer',
    emoji: '👨‍💻',
    description: 'Serviço freelance genérico com valor a definir conforme o projeto.',
    category: 'Consultoria',
    technologies: [],
    basePrice: 0.00,
    openPrice: true,
  ),
  FreelanceService(
    id: 'web-dev',
    name: 'Desenvolvimento Web',
    emoji: '🌐',
    description: 'Desenvolvimento de sites, sistemas web e aplicações frontend responsivas.',
    category: 'Desenvolvimento',
    technologies: ['React', 'Vue.js', 'Next.js', 'TypeScript', 'HTML/CSS'],
    basePrice: 2500.00,
  ),
  FreelanceService(
    id: 'mobile-dev',
    name: 'Desenvolvimento Mobile',
    emoji: '📱',
    description: 'Aplicativos iOS e Android nativos ou híbridos com alta performance.',
    category: 'Desenvolvimento',
    technologies: ['Flutter', 'React Native', 'Dart', 'Kotlin', 'Swift'],
    basePrice: 4000.00,
  ),
  FreelanceService(
    id: 'backend-api',
    name: 'Backend e APIs',
    emoji: '⚙️',
    description: 'APIs REST/GraphQL, microsserviços, bancos de dados e integrações.',
    category: 'Desenvolvimento',
    technologies: ['Node.js', 'Python', 'Django', 'Laravel', 'PostgreSQL', 'MongoDB'],
    basePrice: 3000.00,
  ),
  FreelanceService(
    id: 'ui-ux',
    name: 'Design UI/UX',
    emoji: '🎨',
    description: 'Criação de interfaces, protótipos interativos e design system.',
    category: 'Design',
    technologies: ['Figma', 'Adobe XD', 'Photoshop', 'Illustrator', 'Prototyping'],
    basePrice: 1800.00,
  ),
  FreelanceService(
    id: 'landing-page',
    name: 'Landing Page',
    emoji: '🚀',
    description: 'Página de conversão otimizada para captação de leads e vendas.',
    category: 'Design',
    technologies: ['HTML', 'CSS', 'JavaScript', 'WordPress', 'Elementor'],
    basePrice: 800.00,
  ),
  FreelanceService(
    id: 'ecommerce',
    name: 'E-commerce',
    emoji: '🛒',
    description: 'Lojas virtuais completas com gestão de produtos, carrinho e pagamentos.',
    category: 'Desenvolvimento',
    technologies: ['WooCommerce', 'Shopify', 'VTEX', 'Stripe', 'PagSeguro'],
    basePrice: 5000.00,
  ),
  FreelanceService(
    id: 'devops',
    name: 'DevOps e Infra',
    emoji: '🔧',
    description: 'CI/CD, containers, deploy automatizado e infraestrutura em nuvem.',
    category: 'Infraestrutura',
    technologies: ['Docker', 'Kubernetes', 'AWS', 'GCP', 'GitHub Actions', 'Terraform'],
    basePrice: 2000.00,
  ),
];
