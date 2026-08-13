import '../../domain/ports/clock.dart';

class GetCurrentTime {
  final Clock _clock;

  const GetCurrentTime(this._clock);

  DateTime call() => _clock.now();
}
