# 🚀 HƯỚNG DẪN SETUP SUPABASE + STATE MANAGEMENT

## ✅ Đã tạo các files sau:

### 📦 Models (lib/models/)
- `supabase_exchange_rate.dart` - Model tỷ giá ngoại tệ từ Supabase
- `supabase_market_price.dart` - Model giá vàng/bạc từ Supabase  
- `auth_models.dart` - Request/Response models cho Auth

### 🔧 Services (lib/services/)
- `supabase_service.dart` - **MarketDataService** - Lấy giá vàng, tỷ giá từ Supabase
- `auth_service.dart` - Xử lý Register/Login/Logout
- `user_service.dart` - Xử lý User Profile operations

### 🎯 Providers (lib/providers/) - State Management
- `auth_provider.dart` - Quản lý Auth state
- `market_data_provider.dart` - Quản lý Market Data state
- `user_provider.dart` - Quản lý User Profile state

### ⚙️ Config (lib/config/)
- `supabase_config.dart` - Supabase configuration

---

## 📋 BƯỚC 1: CÀI ĐẶT DEPENDENCIES

Chạy lệnh sau để install packages:

```powershell
cd D:\2026_SPR\SWD\my_flutter_app
flutter pub get
```

Package đã được thêm vào `pubspec.yaml`:
- ✅ `provider: ^6.1.1` - State Management
- ✅ `shared_preferences: ^2.2.2` - Lưu token và persistent data
- ✅ `http: ^1.2.0` - HTTP client (đã có sẵn)

---

## 📋 BƯỚC 2: CONFIG SUPABASE

1. Mở file `lib/config/supabase_config.dart`
2. Thay thế các giá trị sau bằng thông tin từ Supabase project của bạn:

```dart
class SupabaseConfig {
  // TODO: Thay thế bằng Supabase URL của bạn
  static const String supabaseUrl = 'https://your-project-id.supabase.co';
  
  // TODO: Thay thế bằng Supabase anon key của bạn
  static const String supabaseAnonKey = 'your-anon-key-here';
  ...
}
```

**Lấy credentials từ đâu?**
- Đăng nhập Supabase: https://app.supabase.com
- Chọn project của bạn
- Vào **Settings → API**
- Copy `Project URL` và `anon/public key`

---

## 📋 BƯỚC 3: SETUP PROVIDERS TRONG MAIN.DART

Mở file `lib/main.dart` và wrap `MaterialApp` bằng `MultiProvider`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_flutter_app/providers/auth_provider.dart';
import 'package:my_flutter_app/providers/market_data_provider.dart';
import 'package:my_flutter_app/providers/user_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MarketDataProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Investment System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(), // Hoặc screen khởi động của bạn
    );
  }
}
```

---

## 📋 BƯỚC 4: SỬ DỤNG TRONG SCREENS

### 🔐 Authentication Example

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_flutter_app/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Đăng nhập')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            
            // Hiển thị loading
            if (authProvider.isLoading)
              CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: () async {
                  final success = await authProvider.login(
                    username: _usernameController.text,
                    password: _passwordController.text,
                  );
                  
                  if (success) {
                    Navigator.pushReplacementNamed(context, '/home');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(authProvider.errorMessage ?? 'Đăng nhập thất bại')),
                    );
                  }
                },
                child: Text('Đăng nhập'),
              ),
              
            // Hiển thị error
            if (authProvider.errorMessage != null)
              Text(
                authProvider.errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
```

### 💰 Market Data Example (Tỷ giá + Giá vàng)

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_flutter_app/providers/market_data_provider.dart';

class MarketDataScreen extends StatefulWidget {
  @override
  _MarketDataScreenState createState() => _MarketDataScreenState();
}

class _MarketDataScreenState extends State<MarketDataScreen> {
  @override
  void initState() {
    super.initState();
    // Load data khi screen mở
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MarketDataProvider>(context, listen: false).loadAllMarketData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final marketData = Provider.of<MarketDataProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Thị trường')),
      body: RefreshIndicator(
        onRefresh: () => marketData.refreshAll(),
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // TỶ GIÁ NGOẠI TỆ
            Text('TỶ GIÁ NGOẠI TỆ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            
            if (marketData.isLoadingExchangeRates)
              CircularProgressIndicator()
            else if (marketData.exchangeRatesError != null)
              Text(marketData.exchangeRatesError!, style: TextStyle(color: Colors.red))
            else
              ...marketData.exchangeRates.map((rate) => Card(
                child: ListTile(
                  title: Text('${rate.currencyCode} - ${rate.currencyName}'),
                  subtitle: Text('Mua: ${rate.buyPriceFormatted} | Bán: ${rate.sellPriceFormatted}'),
                  trailing: Text(rate.baseCurrencyCode),
                ),
              )),
              
            SizedBox(height: 20),
            
            // GIÁ VÀNG VIỆT NAM
            Text('GIÁ VÀNG SJC', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            
            if (marketData.isLoadingVietnamGold)
              CircularProgressIndicator()
            else if (marketData.vietnamGoldError != null)
              Text(marketData.vietnamGoldError!, style: TextStyle(color: Colors.red))
            else
              ...marketData.vietnamGoldPrices.map((gold) => Card(
                child: ListTile(
                  title: Text('${gold.regionName} - ${gold.unitName}'),
                  subtitle: Text('Mua: ${gold.buyPriceFormatted} | Bán: ${gold.sellPriceFormatted}'),
                  trailing: Text(gold.sourceName),
                ),
              )),
              
            SizedBox(height: 20),
            
            // GIÁ VÀNG/BẠC QUỐC TẾ
            Text('GIÁ QUỐC TẾ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            
            if (marketData.isLoadingGlobalMetals)
              CircularProgressIndicator()
            else if (marketData.globalMetalsError != null)
              Text(marketData.globalMetalsError!, style: TextStyle(color: Colors.red))
            else ...[
              if (marketData.globalGoldPrice != null)
                Card(
                  child: ListTile(
                    title: Text('Gold (Global)'),
                    subtitle: Text('Buy: ${marketData.globalGoldPrice!.buyPriceFormatted} | Sell: ${marketData.globalGoldPrice!.sellPriceFormatted}'),
                  ),
                ),
              if (marketData.globalSilverPrice != null)
                Card(
                  child: ListTile(
                    title: Text('Silver (Global)'),
                    subtitle: Text('Buy: ${marketData.globalSilverPrice!.buyPriceFormatted} | Sell: ${marketData.globalSilverPrice!.sellPriceFormatted}'),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### 👤 User Profile Example

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_flutter_app/providers/user_provider.dart';
import 'package:my_flutter_app/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load profile khi screen mở
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Hồ sơ')),
      body: userProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : userProvider.profile == null
              ? Center(child: Text('Không có dữ liệu'))
              : ListView(
                  padding: EdgeInsets.all(16),
                  children: [
                    CircleAvatar(
                      radius: 50,
                      child: Text(
                        userProvider.profile!.username[0].toUpperCase(),
                        style: TextStyle(fontSize: 40),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      userProvider.profile!.fullName,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '@${userProvider.profile!.username}',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    ListTile(
                      leading: Icon(Icons.email),
                      title: Text('Email'),
                      subtitle: Text(userProvider.profile!.email),
                    ),
                    if (userProvider.profile!.phoneNumber != null)
                      ListTile(
                        leading: Icon(Icons.phone),
                        title: Text('Phone'),
                        subtitle: Text(userProvider.profile!.phoneNumber!),
                      ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        await authProvider.logout();
                        userProvider.clearProfile();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text('Đăng xuất'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ],
                ),
    );
  }
}
```

---

## 📋 BƯỚC 5: API ENDPOINTS

### Backend Spring Boot (http://10.0.2.2:8080)
- `POST /api/auth/register` - Đăng ký
- `POST /api/auth/login` - Đăng nhập
- `GET /api/users/profile` - Lấy profile (cần auth)
- `PUT /api/users/profile` - Cập nhật profile (cần auth)

### Supabase REST API (https://your-project.supabase.co/rest/v1/)
- `GET /exchange_rates` - Lấy tỷ giá ngoại tệ
- `GET /market_price_raw` - Lấy giá vàng/bạc

**Chi tiết API Supabase:** Xem file `SCRAPE_BRANCH_API_DOCUMENTATION.md`

---

## 🔥 BƯỚC 6: TEST FLOW

### Test Authentication:
1. Mở app → Login screen
2. Nhập `username` và `password`
3. Click "Đăng nhập"
4. Kiểm tra `AuthProvider.isLoggedIn == true`
5. Navigate to Home screen

### Test Market Data:
1. Mở Market screen
2. `MarketDataProvider` tự động load data
3. Kiểm tra hiển thị tỷ giá USD, EUR, JPY...
4. Kiểm tra giá vàng SJC các khu vực (HCM, HN, ĐN...)
5. Kiểm tra giá vàng/bạc quốc tế (Kitco)
6. Pull to refresh để reload data

### Test User Profile:
1. Kiểm tra `AuthProvider.isLoggedIn == true`
2. Mở Profile screen
3. `UserProvider.fetchProfile()` tự động chạy
4. Hiển thị fullName, email, phone
5. Click "Đăng xuất" → Clear state → Navigate to Login

---

## ⚠️ LƯU Ý QUAN TRỌNG

### 1. Giữ nguyên fake_data/ cho giáo viên review
```
lib/fake_data/
├── fake_market_data.dart  ← KHÔNG XÓA
├── fake_portfolio_data.dart  ← KHÔNG XÓA
└── ...
```
**CHỈ XÓA KHI BẠN RA LỆNH "hoàn thành"**

### 2. Network Configuration
- **Android Emulator:** `baseUrl = 'http://10.0.2.2:8080'` ✅
- **iOS Simulator:** `baseUrl = 'http://localhost:8080'`
- **Physical Device:** `baseUrl = 'http://192.168.1.7:8080'` (host IP)

### 3. Supabase Rate Limits
- Free tier: 500MB database, 1GB bandwidth/month
- REST API: Unlimited requests nhưng có timeout 30s
- Nếu lỗi 429 (Too Many Requests) → Giảm số lần call API

---

## 🐛 TROUBLESHOOTING

### Lỗi: "ClientException: Connection refused"
**Nguyên nhân:** Backend chưa chạy hoặc sai IP
**Giải pháp:**
```powershell
# Kiểm tra backend running
Test-NetConnection -ComputerName localhost -Port 8080 -InformationLevel Quiet

# Nếu False → Start backend
cd D:\2026_SPR\SWD\InvestmentSystemBE
# Run 3 services như trong README.md
```

### Lỗi: "Failed to load exchange rates: 401 Unauthorized"
**Nguyên nhân:** Sai Supabase API key
**Giải pháp:** Kiểm tra lại `supabaseAnonKey` trong `supabase_config.dart`

### Lỗi: "Provider not found"
**Nguyên nhân:** Chưa wrap MaterialApp bằng MultiProvider
**Giải pháp:** Xem lại BƯỚC 3

### Lỗi: "Failed to load profile: 401"
**Nguyên nhân:** Token hết hạn hoặc chưa login
**Giải pháp:** 
```dart
await authProvider.logout();
// Login lại
```

---

## 📚 TÀI LIỆU THAM KHẢO

- [Provider Package](https://pub.dev/packages/provider)
- [SharedPreferences](https://pub.dev/packages/shared_preferences)
- [Supabase REST API](https://supabase.com/docs/guides/api)
- Backend API: `SCRAPE_BRANCH_API_DOCUMENTATION.md`
- Backend Setup: `SETUP_AND_RUN_GUIDE.md`

---

## ✨ TÍNH NĂNG ĐÃ HOÀN THÀNH

✅ **Models:** Exchange Rates, Market Prices, Auth Models  
✅ **Services:** SupabaseService (MarketDataService), AuthService, UserService  
✅ **Providers:** AuthProvider, MarketDataProvider, UserProvider  
✅ **State Management:** Provider pattern  
✅ **Token Management:** SharedPreferences  
✅ **Error Handling:** Try-catch với error messages  
✅ **Loading States:** isLoading flags  
✅ **Auto-refresh:** Pull to refresh  

---

**Chúc bạn code vui vẻ! 🚀**
