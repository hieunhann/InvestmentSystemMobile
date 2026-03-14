/// Supabase Configuration
/// 
/// IMPORTANT: Replace these values with your actual Supabase project credentials
/// Get them from: https://app.supabase.com/project/YOUR_PROJECT/settings/api
class SupabaseConfig {
  // TODO: Replace with your Supabase project URL
  static const String supabaseUrl = 'https://your-project-id.supabase.co';
  
  // TODO: Replace with your Supabase anon/public key
  static const String supabaseAnonKey = 'your-anon-key-here';

  // REST API endpoints
  static const String exchangeRatesEndpoint = '/rest/v1/exchange_rates';
  static const String marketPriceEndpoint = '/rest/v1/market_price_raw';

  // Headers for Supabase REST API
  static Map<String, String> get headers => {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Content-Type': 'application/json',
      };
}
