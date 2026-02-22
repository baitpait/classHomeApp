

class OverallRating {
  int? totalReview;
  double? averageRating;
  RatingGroupCount? ratingGroupCount;

  OverallRating({this.totalReview, this.averageRating, this.ratingGroupCount});

  OverallRating.fromJson(Map<String, dynamic> json) {
    totalReview = json['total_review'];
    averageRating = double.tryParse('${json['average_rating']}');
    ratingGroupCount = json['rating_group_count'] != null ? RatingGroupCount.fromJson(json['rating_group_count']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_review'] = totalReview;
    data['average_rating'] = averageRating;
    if (ratingGroupCount != null) {
      data['rating_group_count'] = ratingGroupCount!.toJson();
    }
    return data;
  }
}

class RatingGroupCount {
  int? oneStar;
  int? twoStar;
  int? threeStar;
  int? fourStar;
  int? fiveStar;

  RatingGroupCount({this.oneStar, this.twoStar, this.threeStar, this.fourStar, this.fiveStar});

  RatingGroupCount.fromJson(Map<String, dynamic> json) {
    oneStar = json['1'];
    twoStar = json['2'];
    threeStar = json['3'];
    fourStar = json['4'];
    fiveStar = json['5'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['1'] = oneStar;
    data['2'] = twoStar;
    data['3'] = threeStar;
    data['4'] = fourStar;
    data['5'] = fiveStar;
    return data;
  }
}