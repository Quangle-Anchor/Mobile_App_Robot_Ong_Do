import 'package:flutter/material.dart';
import '../models/calli_character.dart';

class CalligraphyProvider extends ChangeNotifier {
  // Pool of available characters
  List<CalliCharacter> _charactersPool = List.from(CalliCharacter.defaultCharacters);
  
  // Selected character, defaults to first enabled character
  CalliCharacter _selectedCharacter = CalliCharacter.defaultCharacters[0];

  List<CalliCharacter> get charactersPool => _charactersPool;
  CalliCharacter get selectedCharacter => _selectedCharacter;

  // Filter pool containing only active characters
  List<CalliCharacter> get activeCharacters => 
      _charactersPool.where((c) => c.isEnabled).toList();

  void selectCharacter(CalliCharacter character) {
    if (_charactersPool.contains(character)) {
      _selectedCharacter = character;
      notifyListeners();
    }
  }

  void toggleCharacter(String char) {
    _charactersPool = _charactersPool.map((c) {
      if (c.char == char) {
        return c.copyWith(isEnabled: !c.isEnabled);
      }
      return c;
    }).toList();
    
    // If the currently selected character got disabled, pick the first enabled one
    if (_selectedCharacter.char == char && !_selectedCharacter.isEnabled) {
      final enabled = activeCharacters;
      if (enabled.isNotEmpty) {
        _selectedCharacter = enabled.first;
      }
    }
    notifyListeners();
  }

  void resetDefaults() {
    _charactersPool = List.from(CalliCharacter.defaultCharacters);
    _selectedCharacter = _charactersPool[0];
    notifyListeners();
  }
}
