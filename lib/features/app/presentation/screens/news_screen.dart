import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/features/app/presentation/widgets/app_card.dart';
import 'package:my_flutter_app/features/app/presentation/widgets/app_header.dart';
import 'package:my_flutter_app/fake_data/fake_news_data.dart';
import 'package:intl/intl.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final horizontal = (size.width * 0.05).clamp(16.0, 22.0);
    final vertical = (size.height * 0.02).clamp(12.0, 18.0);
    final newsItems = FakeNewsData.getNewsByCategory(_selectedCategory);

    return Column(
      children: [
        AppHeader(
          title: 'News',
          subtitle: '${newsItems.length} articles',
          trailing: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings, color: Colors.white),
          ),
          bottom: _CategoryTabs(
            categories: FakeNewsData.categories,
            selected: _selectedCategory,
            onChanged: (cat) => setState(() => _selectedCategory = cat),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1));
            },
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(horizontal, vertical, horizontal, vertical),
              itemCount: newsItems.length,
              itemBuilder: (context, index) {
                final news = newsItems[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _NewsCard(news: news),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onChanged;

  const _CategoryTabs({
    required this.categories,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == selected;
          return GestureDetector(
            onTap: () => onChanged(cat),
            child: Container(
              margin: EdgeInsets.only(right: 10.w),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Center(
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.deepOrange : Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final FakeNewsItem news;

  const _NewsCard({required this.news});

  @override
  Widget build(BuildContext context) {
    final timeAgo = _getTimeAgo(news.publishedAt);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  news.category,
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.deepOrange,
                  ),
                ),
              ),
              const Spacer(),
              Icon(Icons.access_time, size: 12.w, color: Colors.black45),
              SizedBox(width: 4.w),
              Text(
                timeAgo,
                style: TextStyle(fontSize: 9.sp, color: Colors.black45),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            news.title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            news.summary,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.black54,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(Icons.bookmark_border, size: 14.w, color: Colors.black45),
              SizedBox(width: 4.w),
              Text(
                news.source,
                style: TextStyle(fontSize: 10.sp, color: Colors.black45, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Icon(Icons.schedule, size: 14.w, color: Colors.black45),
              SizedBox(width: 4.w),
              Text(
                '${news.readTime} min read',
                style: TextStyle(fontSize: 10.sp, color: Colors.black45),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

