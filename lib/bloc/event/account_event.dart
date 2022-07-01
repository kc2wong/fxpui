import '../../model/client.dart';

abstract class BaseFxAccountEvent {
}

class FxAccountSearchEvent extends BaseFxAccountEvent {
  String extAccountRef1;
  String extAccountRef2;

  FxAccountSearchEvent(
    this.extAccountRef1,
    this.extAccountRef2,
  );
}

class FxAccountSelectEvent extends BaseFxAccountEvent {
  final FxAccount? selectedFxAccount;

  FxAccountSelectEvent(this.selectedFxAccount);
}
