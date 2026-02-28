enum RoundPreset {
  quick2(cycles: 2, label: '2 quick'),
  calm4(cycles: 4, label: '4 calm'),
  deep6(cycles: 6, label: '6 deep'),
  zen8(cycles: 8, label: '8 zen');

  const RoundPreset({
    required this.cycles,
    required this.label,
  });

  final int cycles;
  final String label;
}

