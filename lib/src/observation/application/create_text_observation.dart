import 'package:uuid/uuid.dart';

import '../../identity/domain/identity_repository.dart';
import '../domain/observation.dart';
import '../domain/observation_exceptions.dart';
import '../domain/observation_id_generator.dart';
import '../domain/observation_repository.dart';

export '../domain/observation_exceptions.dart';

typedef UtcNow = DateTime Function();

class CreateTextObservationCommand {
  const CreateTextObservationCommand({
    required this.observationId,
    required this.rawText,
    required this.capturedAtUtc,
    required this.timezoneOffset,
  });

  final String observationId;
  final String rawText;
  final DateTime capturedAtUtc;
  final int timezoneOffset;
}

class CreateTextObservation {
  const CreateTextObservation({
    required ObservationRepository repository,
    required LocalIdentity localIdentity,
    required ObservationIdGenerator idGenerator,
    required UtcNow utcNow,
  }) : this._(repository, localIdentity, idGenerator, utcNow);

  const CreateTextObservation._(
    this._repository,
    this._localIdentity,
    this._idGenerator,
    this._utcNow,
  );

  final ObservationRepository _repository;
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

    return CreateTextObservationCommand(
      observationId: _idGenerator.generate(),
      rawText: rawText,
      capturedAtUtc: capturedAt,
      timezoneOffset: timezoneOffset,
    );
  }

  Future<Observation> execute(CreateTextObservationCommand command) {
    _validateCommand(command);
    final createdAt = _utcNow();
    if (!createdAt.isUtc) {
      throw InvalidCapturedAtException();
    }
    return _repository.create(
      Observation(
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
        createdAt: createdAt,
        updatedAt: createdAt,
        deletedAt: null,
        serverRevision: null,
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
    final id = command.observationId;
    if (id.isEmpty ||
        !Uuid.isValidUUID(fromString: id) ||
        id.split('-').length != 5 ||
        !id.split('-')[2].startsWith('7')) {
      throw InvalidObservationIdException();
    }
  }
}
