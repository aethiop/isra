import 'package:flutter/material.dart';

import 'const/colors.dart';
import 'components/button.dart';

class About extends StatelessWidget {
  const About({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(21),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ButtonWidget(
                      icon: Icons.arrow_back,
                      onPressed: () {
                        //Undo the round.
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 24,
                ),
                Text(
                  'መረጃ',
                  style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 20),
                Text(
                  'የጨዋታው ግብ ፳ እስክትደርሱ ድረስ ተመሳሳይ ቁጥሮችን ማጣመር ነው።',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
                SizedBox(height: 20),
                Text(
                  '፩ - ጨዋታው ሲጀመር ሁለት በዘፈቀደ ሰሌዳው ላይ በግእዝ ቁጥር ይሞላል፣ ብዙ ጊዜ "፩" እና "፪" ይሆናል።',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
                SizedBox(height: 20),
                Text(
                  '፪ - ቁጥሮቹን ለማንቀሳቀስ ወደ ማንኛውም አቅጣጫ ያንሸራትቱ (ወይም በኮምፒዩተር ላይ የሚጫወቱ ከሆነ የቀስት ቁልፎችን ይጠቀሙ)። ተመሳሳይ የቁጥር ንክኪ ያላቸው ሁለት ቁጥሮች ወደ አንድ ይዋሃዳሉ ማለትም ወደ ቀጣዩ ቁጥር። ',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
                SizedBox(height: 20),
                Text(
                  '፫ - አንድ አይነት ቁጥር ያላቸው ሁለት ንጣፎች በአንድ ረድፍ ውስጥ ካሉ እና ወደዚያ ረድፍ አቅጣጫ ከተንቀሳቀሱ፣ ሁለቱ ንጣፎች ወደ አንድ ንጣፍ ይቀላቀላሉ። ለምሳሌ፣  "፩" የሚያሳይ ሁለት ንጣፎች በአንድ ረድፍ ውስጥ ከሆኑ እና ወደዚያ ረድፍ አቅጣጫ ካንሸራተቱ፣ እነሱ ይዋሃዳሉ ፪\'ን ይፈጥራሉ። በተመሳሳይ ፪ አንድ ላይ ፫ ይሰራሉ እያለ እስከ ፳ ማለትም ሁለት ፲\'ሮች።',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
                SizedBox(height: 20),
                Text(
                  '፬ - ከእያንዳንዱ እንቅስቃሴ በኋላ አዲስ ንጣፍ በዘፈቀደ በሰሌዳው ላይ ባዶ ቦታ ላይ ይፈጠራል። አዲሱ ንጣፍ ፩ (90%) ወይም ፪ (10%) ይሆናል። ባዶ ቦታዎች እና ተመሳሳይ ቁጥሮች እስከሌሉ ድረስ ንጣፎችን ማንቀሳቀስ እና ማዋሃድ ይቀጥሉ። ምንም እንቅስቃሴ ማድረግ ካልተቻለ ጨዋታው አልቋል። ',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
                SizedBox(height: 20),
                Text(
                  '፭ - የጨዋታው አላማ (፳) የሚያሳይ ንጣፍ ማግኘት ነው። ይህ የሚገኘው ሁለት (፲) ንጣፎችን በማዋሃድ ነው። ሆኖም፣ እዚህ ደረጃ ላይ ከደረሱ በኋላም ቢሆን ከፍ ያለ ነጥብ ለማግኘት ጨዋታውን መጫወቱን መቀጠል ይችላሉ።',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
                SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: numeralList.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          numeralList[index],
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
                Center(
                  child: Text(
                    '፨  በ ❤️ ከአሪዮብ  ፨',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white54),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const numeralList = [
  '፩ (1) - አሐዱ  ',
  '፪ (2) - ክልኤቱ',
  '፫ (3) - ሠለስቱ',
  '፬ (4) - አርባዕቱ',
  '፭ (5) - ኀምስቱ',
  '፮ (6) - ስድስቱ',
  '፯ (7) - ሰብዐቱ',
  '፰ (8) - ሰማንቱ',
  '፱ (9) - ተስዐቱ',
  '፲ (10) - ዐሠርቱ',
  '፳ (20) - ዕሥራ',
];
