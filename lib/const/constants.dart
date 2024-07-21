const String firstTime = 'firstTimeUser2';
const String soundEnabled = 'soundEnabled';
const List<int> boardSizes = [3, 4, 5]; // 3x3, 4x4, 5x5, 6x6 boards
const Map<int, num> targetScores = {
  3: 1024,
  4: 2048,
  5: 4096,
}; // Target scores

const String boardSizeKey = 'boardSize';

const geezWords = {
  2: 'አሐዱ',
  4: 'ክልኤቱ',
  8: 'ሠለስቱ',
  16: 'አርባዕቱ',
  32: 'ኀምስቱ',
  64: 'ስድስቱ',
  128: 'ሰብዐቱ',
  256: 'ሰማንቱ',
  512: 'ተስዐቱ',
  1024: 'ዐሠርቱ',
  2048: 'ዕስራ',
  4096: 'ሠላሳ',
};

const Map<int, String> geezSymbols = {
  2: '፩',
  4: '፪',
  8: '፫',
  16: '፬',
  32: '፭',
  64: '፮',
  128: '፯',
  256: '፰',
  512: '፱',
  1024: '፲',
  2048: '፳',
  4096: '፴',
};

const geezMap = {
  '0': '0',
  '1': '፩',
  '2': '፪',
  '3': '፫',
  '4': '፬',
  '5': '፭',
  '6': '፮',
  '7': '፯',
  '8': '፰',
  '9': '፱',
  '10': '፲',
  '20': '፳',
  '30': '፴',
  '40': '፵',
  '50': '፶',
  '60': '፷',
  '70': '፸',
  '80': '፹',
  '90': '፺'
};
