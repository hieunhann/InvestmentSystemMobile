// 📰 FAKE NEWS DATA
// Dữ liệu tin tức giả lập cho NewsScreen

class FakeNewsItem {
  final String id;
  final String title;
  final String summary;
  final String imageUrl;
  final String source;
  final String category;
  final DateTime publishedAt;
  final int readTime; // minutes

  FakeNewsItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.imageUrl,
    required this.source,
    required this.category,
    required this.publishedAt,
    required this.readTime,
  });
}

class FakeNewsData {
  static final List<FakeNewsItem> newsItems = [
    FakeNewsItem(
      id: '1',
      title: 'Giá vàng SJC tăng mạnh, đạt mức cao nhất trong tháng',
      summary: 'Giá vàng miếng SJC tăng 200.000 đồng/lượng trong phiên giao dịch sáng nay, lên mức 78,5 triệu đồng/lượng.',
      imageUrl: 'https://via.placeholder.com/400x250/FFD700/000000?text=Gold+Price',
      source: 'VnExpress',
      category: 'Vàng',
      publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
      readTime: 3,
    ),
    FakeNewsItem(
      id: '2',
      title: 'USD tăng giá so với VND, đạt 24.500 đồng',
      summary: 'Tỷ giá USD/VND tiếp tục tăng do áp lực lạm phát và chính sách tiền tệ của FED.',
      imageUrl: 'https://via.placeholder.com/400x250/4CAF50/FFFFFF?text=USD+Exchange',
      source: 'CafeF',
      category: 'Ngoại tệ',
      publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
      readTime: 4,
    ),
    FakeNewsItem(
      id: '3',
      title: 'Chuyên gia dự báo giá vàng sẽ tiếp tục tăng trong quý 2/2026',
      summary: 'Các nhà phân tích cho rằng vàng sẽ vượt ngưỡng 5.000 USD/ounce trong 3 tháng tới do căng thẳng địa chính trị.',
      imageUrl: 'https://via.placeholder.com/400x250/FF9800/FFFFFF?text=Gold+Forecast',
      source: 'Bloomberg',
      category: 'Phân tích',
      publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
      readTime: 6,
    ),
    FakeNewsItem(
      id: '4',
      title: 'Thị trường bạc tăng trưởng mạnh, XAG đạt 105 USD/ounce',
      summary: 'Giá bạc tăng 3% trong tuần qua nhờ nhu cầu công nghiệp cao và nguồn cung hạn chế.',
      imageUrl: 'https://via.placeholder.com/400x250/9E9E9E/FFFFFF?text=Silver+Price',
      source: 'Investing',
      category: 'Bạc',
      publishedAt: DateTime.now().subtract(const Duration(days: 1)),
      readTime: 5,
    ),
    FakeNewsItem(
      id: '5',
      title: 'NHNN can thiệp để ổn định tỷ giá USD/VND',
      summary: 'Ngân hàng Nhà nước bán ra 500 triệu USD để kiểm soát tỷ giá và hạn chế đô la hóa.',
      imageUrl: 'https://via.placeholder.com/400x250/2196F3/FFFFFF?text=NHNN',
      source: 'Thanh Niên',
      category: 'Chính sách',
      publishedAt: DateTime.now().subtract(const Duration(days: 2)),
      readTime: 4,
    ),
    FakeNewsItem(
      id: '6',
      title: 'Vàng PNJ giảm giá 100.000 đồng/lượng',
      summary: 'PNJ công bố giảm giá vàng nhẫn tròn trơn nhằm kích cầu tiêu dùng dịp cuối tháng.',
      imageUrl: 'https://via.placeholder.com/400x250/E91E63/FFFFFF?text=PNJ+Gold',
      source: 'VietnamNet',
      category: 'Vàng',
      publishedAt: DateTime.now().subtract(const Duration(days: 3)),
      readTime: 3,
    ),
    FakeNewsItem(
      id: '7',
      title: 'Kinh tế Mỹ phục hồi mạnh, ảnh hưởng đến giá vàng',
      summary: 'FED dự kiến giữ nguyên lãi suất, gây áp lực lên giá vàng quốc tế trong ngắn hạn.',
      imageUrl: 'https://via.placeholder.com/400x250/673AB7/FFFFFF?text=US+Economy',
      source: 'Reuters',
      category: 'Kinh tế',
      publishedAt: DateTime.now().subtract(const Duration(days: 4)),
      readTime: 7,
    ),
    FakeNewsItem(
      id: '8',
      title: 'Nhu cầu mua vàng tăng cao dịp Tết Nguyên Đán',
      summary: 'Người dân tích cực mua vàng cất trữ và làm quà tặng, giao dịch tăng 40% so với tháng trước.',
      imageUrl: 'https://via.placeholder.com/400x250/FF5722/FFFFFF?text=Tet+Gold',
      source: 'Tuổi Trẻ',
      category: 'Thị trường',
      publishedAt: DateTime.now().subtract(const Duration(days: 5)),
      readTime: 4,
    ),
  ];

  static List<FakeNewsItem> getNewsByCategory(String category) {
    if (category == 'All') return newsItems;
    return newsItems.where((item) => item.category == category).toList();
  }

  static List<String> get categories => [
        'All',
        'Vàng',
        'Bạc',
        'Ngoại tệ',
        'Phân tích',
        'Chính sách',
        'Kinh tế',
        'Thị trường',
      ];
}
