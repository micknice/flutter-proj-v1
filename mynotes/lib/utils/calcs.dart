String calculateNaturalFlow(
    roomArea, roomHeight, openingArea, typicalWindSpeed) {
  final rmAr = double.parse(roomArea);
  final rmHght = double.parse(roomArea);
  final opngAr = double.parse(openingArea);
  final wndSpd = double.parse(typicalWindSpeed);
  double volume = rmAr * rmHght;
  double flowRate = opngAr * wndSpd;
  double result = volume / flowRate;
  final resultString = result.toString();
  return resultString;
}
