import 'device_identity.dart';
import 'principal.dart';

class LocalIdentity {
  const LocalIdentity({required this.principal, required this.device});

  final Principal principal;
  final DeviceIdentity device;
}

abstract interface class IdentityRepository {
  Future<LocalIdentity> initialize();
}
