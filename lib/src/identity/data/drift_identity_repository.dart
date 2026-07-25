import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../database/cognote_database.dart';
import '../domain/device_identity.dart' as domain;
import '../domain/identity_repository.dart';
import '../domain/principal.dart' as domain;

class DriftIdentityRepository implements IdentityRepository {
  DriftIdentityRepository(this._database, {DateTime Function()? now})
    : _now = now ?? _utcNow;

  final CognoteDatabase _database;
  final DateTime Function() _now;

  static String _secureUuidV4() => const Uuid().v4();
  static DateTime _utcNow() => DateTime.now().toUtc();

  @override
  Future<LocalIdentity> initialize() {
    return _database.transaction(() async {
      final existing = await _readExisting();
      if (existing != null) {
        final now = _now();
        await (_database.update(_database.deviceIdentities)
              ..where((table) => table.id.equals(existing.device.id)))
            .write(DeviceIdentitiesCompanion(lastSeenAt: Value(now)));
        return LocalIdentity(
          principal: existing.principal,
          device: domain.DeviceIdentity(
            id: existing.device.id,
            principalId: existing.device.principalId,
            publicInstallId: existing.device.publicInstallId,
            createdAt: existing.device.createdAt,
            lastSeenAt: now,
          ),
        );
      }

      final now = _now();
      final principalId = _secureUuidV4();
      final deviceId = _secureUuidV4();
      final publicInstallId = _secureUuidV4();

      await _database
          .into(_database.principals)
          .insert(
            PrincipalsCompanion.insert(
              id: principalId,
              kind: domain.PrincipalKind.anonymous.name,
              status: domain.PrincipalStatus.active.name,
              homeRegion: 'cn-mainland',
              dataResidency: 'cn',
              createdAt: now,
              upgradedAt: const Value(null),
            ),
          );
      await _database
          .into(_database.deviceIdentities)
          .insert(
            DeviceIdentitiesCompanion.insert(
              id: deviceId,
              principalId: principalId,
              publicInstallId: publicInstallId,
              createdAt: now,
              lastSeenAt: now,
            ),
          );

      return LocalIdentity(
        principal: domain.Principal(
          id: principalId,
          kind: domain.PrincipalKind.anonymous,
          status: domain.PrincipalStatus.active,
          homeRegion: 'cn-mainland',
          dataResidency: 'cn',
          createdAt: now,
          upgradedAt: null,
        ),
        device: domain.DeviceIdentity(
          id: deviceId,
          principalId: principalId,
          publicInstallId: publicInstallId,
          createdAt: now,
          lastSeenAt: now,
        ),
      );
    });
  }

  Future<LocalIdentity?> _readExisting() async {
    final query =
        _database.select(_database.principals).join([
            innerJoin(
              _database.deviceIdentities,
              _database.deviceIdentities.principalId.equalsExp(
                _database.principals.id,
              ),
            ),
          ])
          ..where(
            _database.principals.kind.equals(
                  domain.PrincipalKind.anonymous.name,
                ) &
                _database.principals.status.equals(
                  domain.PrincipalStatus.active.name,
                ),
          )
          ..limit(1);

    final row = await query.getSingleOrNull();
    if (row == null) {
      return null;
    }

    final principal = row.readTable(_database.principals);
    final device = row.readTable(_database.deviceIdentities);
    return LocalIdentity(
      principal: domain.Principal(
        id: principal.id,
        kind: domain.PrincipalKind.values.byName(principal.kind),
        status: domain.PrincipalStatus.values.byName(principal.status),
        homeRegion: principal.homeRegion,
        dataResidency: principal.dataResidency,
        createdAt: principal.createdAt.toUtc(),
        upgradedAt: principal.upgradedAt?.toUtc(),
      ),
      device: domain.DeviceIdentity(
        id: device.id,
        principalId: device.principalId,
        publicInstallId: device.publicInstallId,
        createdAt: device.createdAt.toUtc(),
        lastSeenAt: device.lastSeenAt.toUtc(),
      ),
    );
  }
}
