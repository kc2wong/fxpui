
bool isNullOrEmpty(String? str) {
  return str == null || str.isEmpty;
}

String interpolate(String string, List<String> token) {
  final exp = RegExp(r'{}');
  Iterable<RegExpMatch> matches = exp.allMatches(string);

  assert(token.length == matches.length);

  var i = -1;
  return string.replaceAllMapped(exp, (match) {
    i = i + 1;
    return token[i];
  });
}