enum PrincipalKind { anonymous, account }

enum PrincipalStatus { active, merging, merged, disabled }

class Principal {
  const Principal({
    required this.id,
    required this.kind,
    required this.status,
    required this.homeRegion,
    required this.dataResidency,
    required this.createdAt,
    required this.upgradedAt,
  });

  final String id;
  final PrincipalKind kind;
  final PrincipalStatus status;
  final String homeRegion;
  final String dataResidency;
  final DateTime createdAt;
  final DateTime? upgradedAt;
}
