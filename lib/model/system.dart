
enum ToastType {
  info,
  success,
  warning,
  error
}

class Toast {
  late final ToastType type;
  final String message;
  late bool isNew;
  late final DateTime createTime;
  late final int autoDismissMills;

  Toast(
    this.message, {
    ToastType? type,
    int? autoDismissMills,
  }) {
    this.type = type ?? ToastType.info;
    isNew = true;
    createTime = DateTime.now();
    this.autoDismissMills = autoDismissMills ?? 0;
  }
}

class Pair<L, R> {
  Pair(this.left, this.right);

  final L? left;
  final R? right;

  @override
  String toString() => 'Pair[$left, $right]';
}

class Triple<L, M, R> {
  Triple(this.left, this.middle, this.right);

  final L? left;
  final M? middle;
  final R? right;

  @override
  String toString() => 'Triple[$left, $middle, $right]';
}