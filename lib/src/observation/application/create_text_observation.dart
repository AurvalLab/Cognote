import 'package:uuid/uuid.dart';

import '../../identity/domain/identity_repository.dart';
import '../../outbox/domain/outbox_operation.dart';
import '../domain/observation.dart';
import '../domain/observation_exceptions.dart';
import '../domain/observation_id_generator.dart';
import '../domain/observation_outbox_mutation_repository.dart';
import '../domain/observation_repository.dart';

export '../domain/observation_exceptions.dart';

typedef UtcNow = DateTime Function();

class CreateTextObservationCommand {
  const CreateTextObservationCommand({
    required this.observationId,
    this.operationId = '',
    required this.rawText,
    required this.capturedAtUtc,
    required this.createdAt,
    required this.timezoneOffset,
  });

  final String observationId;
  final String operationId;
  final String rawText;
  final DateTime capturedAtUtc;
  final DateTime createdAt;
  final int timezoneOffset;
}

class CreateTextObservation {
  const CreateTextObservation({
    required ObservationRepository repository,
    ObservationOutboxMutationRepository? outboxMutationRepository,
    required LocalIdentity localIdentity,
    required ObservationIdGenerator idGenerator,
    required UtcNow utcNow,
  }) : this._(outboxMutationRepository, localIdentity, idGenerator, utcNow);

  const CreateTextObservation._(
    this._outboxMutationRepository,
    this._localIdentity,
    this._idGenerator,
    this._utcNow,
  );

  final ObservationOutboxMutationRepository? _outboxMutationRepository;
  final LocalIdentity _localIdentity;
  final ObservationIdGenerator _idGenerator;
  final UtcNow _utcNow;

  CreateTextObservationCommand prepare({
    required String rawText,
    required int timezoneOffset,
    DateTime? capturedAtUtc,
  }) {
    if (rawText.trim().isEmpty) {
      throw InvalidObservationTextException();
    }
    if (timezoneOffset < -840 || timezoneOffset > 840) {
      throw InvalidTimezoneOffsetException();
    }
    final capturedAt = capturedAtUtc ?? _utcNow();
    if (!capturedAt.isUtc) {
      throw InvalidCapturedAtException();
    }
    final createdAt = _utcNow();
    if (!createdAt.isUtc) {
      throw InvalidCapturedAtException();
    }

    return CreateTextObservationCommand(
      observationId: _idGenerator.generate(),
      operationId: _idGenerator.generate(),
      rawText: rawText,
      capturedAtUtc: capturedAt,
      createdAt: createdAt,
      timezoneOffset: timezoneOffset,
    );
  }

  Future<Observation> execute(CreateTextObservationCommand command) {
    _validateCommand(command);
    final observation = Observation(
      id: command.observationId,
      ownerId: _localIdentity.principal.id,
      inputType: ObservationInputType.text,
      rawText: command.rawText,
      capturedAt: command.capturedAtUtc,
      timezoneOffset: command.timezoneOffset,
      privacyLevel: PrivacyLevel.normal,
      cloudAiPolicy: CloudAiPolicy.localOnly,
      syncPolicy: SyncPolicy.localOnly,
      createdByDeviceId: _localIdentity.device.id,
      createdAt: command.createdAt,
      updatedAt: command.createdAt,
      deletedAt: null,
      serverRevision: null,
    );
    final mutationRepository = _outboxMutationRepository;
    if (mutationRepository == null) {
      throw StateError('Observation outbox mutation repository is required');
    }
    return mutationRepository.createTextWithOutbox(
      observation: observation,
      operation: OutboxOperation(
        operationId: command.operationId,
        ownerId: observation.ownerId,
        deviceId: observation.createdByDeviceId,
        aggregateType: 'observation',
        aggregateId: observation.id,
        operationKind: 'observation_upsert',
        createdAt: command.createdAt,
      ),
    );
  }

  void _validateCommand(CreateTextObservationCommand command) {
    if (command.rawText.trim().isEmpty) {
      throw InvalidObservationTextException();
    }
    if (command.timezoneOffset < -840 || command.timezoneOffset > 840) {
      throw InvalidTimezoneOffsetException();
    }
    if (!command.capturedAtUtc.isUtc) {
      throw InvalidCapturedAtException();
    }
    if (!command.createdAt.isUtc) {
      throw InvalidCapturedAtException();
    }
    final id = command.observationId;
    if (id.isEmpty ||
        !Uuid.isValidUUID(fromString: id) ||
        id.split('-').length != 5 ||
        !id.split('-')[2].startsWith('7')) {
      throw InvalidObservationIdException();
    }
    final operationId = command.operationId;
    if (operationId.isNotEmpty &&
        (!Uuid.isValidUUID(fromString: operationId) ||
            operationId.split('-').length != 5 ||
            !operationId.split('-')[2].startsWith('7'))) {
      throw InvalidObservationIdException();
    }
  }
}
