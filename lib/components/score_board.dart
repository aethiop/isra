import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../const/colors.dart';
import '../const/constants.dart';
import '../managers/board.dart';

class ScoreBoard extends ConsumerWidget {
  final int boardSize;
  final double gapSize;
  const ScoreBoard({super.key, required this.boardSize, this.gapSize = 8.0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score =
        ref.watch(boardManager(boardSize).select((board) => board.score));
    final best =
        ref.watch(boardManager(boardSize).select((board) => board.best));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Score(label: 'ውጤት', score: '$score'),
        SizedBox(
          width: gapSize,
        ),
        Score(
            label: 'ከፍተኛ',
            score: '$best',
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)),
      ],
    );
  }
}

class Score extends StatelessWidget {
  const Score(
      {Key? key, required this.label, required this.score, this.padding})
      : super(key: key);

  final String label;
  final String score;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
          color: scoreColor, borderRadius: BorderRadius.circular(16.0)),
      child: Column(children: [
        Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 18.0, color: textColor),
            ),
          ],
        ),
        Column(
          children: [
            Text(
              _geezTranslator(int.parse(score)),
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0),
            ),
            Text(
              score,
              style: const TextStyle(color: Colors.white, fontSize: 12.0),
            ),
          ],
        ),
      ]),
    );
  }

  String _geezTranslator(int num) {
    if (num < 1) {
      return num.toString();
    }

    final asciiNumber = num.toString().padLeft(
        num.toString().length % 2 == 0
            ? num.toString().length
            : num.toString().length + 1,
        '0');
    final asciiNumberGrouped = RegExp(r'[\d]{2}')
        .allMatches(asciiNumber)
        .map((match) => match.group(0))
        .toList();
    final asciiNumberExpanded = asciiNumberGrouped
        .map((group) => [
              group?[0] == '0' ? '0' : '${int.parse(group![0]) * 10}',
              '${group?[1]}'
            ])
        .toList();

    final ethiopic = asciiNumberExpanded
        .map((group) => [geezMap[group[0]], geezMap[group[1]]])
        .toList();

    final ethiopicPrefixed = asciiNumberExpanded.asMap().entries.map((entry) {
      final reverseIndex = asciiNumberExpanded.length - (entry.key + 1);

      if (reverseIndex > 0) {
        if (reverseIndex % 2 == 1) {
          return '${ethiopic[entry.key].join('')}፻';
        } else if (reverseIndex % 4 == 0) {
          return '${ethiopic[entry.key].join('')}፼';
        }
      }

      return ethiopic[entry.key].join('');
    }).toList();

    return ethiopicPrefixed
        .join('')
        .replaceAll(RegExp(r'00፻|0'), '')
        .replaceFirst(RegExp(r'፩(?=፻|፼)'), '');
  }
}
