class LanguageModel {
  final String code;
  final String locale;
  final String name;
  final String? subName;
  final String flagEmoji;

  LanguageModel(this.code, this.locale, this.name, this.flagEmoji,
      {this.subName});
}
