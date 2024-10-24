class MealsListData {
  MealsListData({
    this.imagePath = '',
    this.titleTxt = '',
    this.startColor = '',
    this.endColor = '',
    this.goals,
  });

  String imagePath;
  String titleTxt;
  String startColor;
  String endColor;
  List? goals;

  static List<MealsListData> tabIconsList = <MealsListData>[
    MealsListData(
      imagePath: 'assets/a5.json',
      titleTxt: 'Fruits',
      startColor: '#FE95B6',
      endColor: '#FF5287',
    ),
    MealsListData(
      imagePath: 'assets/a4.json',
      titleTxt: 'Vegetables',
      startColor: '#FA7D82',
      endColor: '#FFB295',
    ),
    MealsListData(
      imagePath: 'assets/a1.json',
      titleTxt: 'Water',
      startColor: '#87CEEB',
      endColor: '#6F72CA',
    ),
    MealsListData(
      imagePath: 'assets/a2.json',
      titleTxt: 'Exercise',
      startColor: '#6F72CA',
      endColor: '#1E1466',
    ),
    MealsListData(
      imagePath: 'assets/a3.json',
      titleTxt: 'Cooked',
      startColor: '#FF9D9D',
      endColor: '#BB4E75',
    ),
  ];
}
