class CalliCharacter {
  final String char;
  final String meaning;
  final bool isEnabled;

  const CalliCharacter({
    required this.char,
    required this.meaning,
    this.isEnabled = true,
  });

  CalliCharacter copyWith({String? char, String? meaning, bool? isEnabled}) {
    return CalliCharacter(
      char: char ?? this.char,
      meaning: meaning ?? this.meaning,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  // The default characters pool mapped from the web application
  static const List<CalliCharacter> defaultCharacters = [
    CalliCharacter(char: "Tâm", meaning: "Sự chân thành, lòng tốt và sự tử tế"),
    CalliCharacter(char: "Phúc", meaning: "May mắn, hạnh phúc và bình an"),
    CalliCharacter(char: "Đức", meaning: "Phẩm chất tốt đẹp của con người"),
    CalliCharacter(char: "Trí", meaning: "Tri thức, hiểu biết và sáng tạo"),
    CalliCharacter(char: "Nhẫn", meaning: "Kiên trì, bình tĩnh trước khó khăn"),
    CalliCharacter(char: "An", meaning: "Bình an, nhẹ nhàng và ổn định"),
    CalliCharacter(char: "Lộc", meaning: "Tài lộc, may mắn và thịnh vượng"),
    CalliCharacter(
      char: "Hiếu",
      meaning: "Lòng biết ơn và kính trọng gia đình",
    ),
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalliCharacter &&
          runtimeType == other.runtimeType &&
          char == other.char &&
          meaning == other.meaning;

  @override
  int get hashCode => char.hashCode ^ meaning.hashCode;
}
