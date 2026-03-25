class NewsArticle {
  final int id;
  final String title;
  final String category; // Gold, Silver, Exchange Rate, Oil
  final String source;
  final String author;
  final String date;
  final String? readTime;
  final String image;
  final String summary;
  final String link;

  const NewsArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.source,
    required this.author,
    required this.date,
    this.readTime,
    required this.image,
    required this.summary,
    required this.link,
  });
}
