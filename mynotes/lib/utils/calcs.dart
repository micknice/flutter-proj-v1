String calculateNaturalFlow(
    roomArea, roomHeight, openingArea, typicalWindSpeed) {
  final rmAr = double.parse(roomArea);
  final rmHght = double.parse(roomHeight);
  final opngAr = double.parse(openingArea);
  final wndSpd = double.parse(typicalWindSpeed);
  double volume = rmAr * rmHght;
  double flowRate = opngAr * wndSpd;
  double result = volume / flowRate;
  final resultString = result.toStringAsFixed(2);
  return resultString;
}

String sumFlowForAllRooms(allResults) {
  final allResultsDoubles = allResults.map((e) => double.parse(e.result));
  double sum = allResultsDoubles.fold(0, (p, c) => p + c);
  final resultString = sum.toStringAsFixed(2);
  return resultString;
}

String getTotalNaturalFlowForJob(allJobNotes) {
  final doubleIterable = allJobNotes.map((e) => double.parse(e.result));
  double sum = doubleIterable.fold(0, (p, c) => p + c);
  final sumString = sum.toStringAsFixed(2);
  return sumString;
}
