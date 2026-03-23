import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const ScreenerApp());
}

class ScreenerApp extends StatelessWidget {
  const ScreenerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Screener Bot',
      debugShowCheckedModeBanner: false, // 오른쪽 위 DEBUG 띠 제거
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const ScreenerHomePage(),
    );
  }
}

class ScreenerHomePage extends StatefulWidget {
  const ScreenerHomePage({super.key});

  @override
  State<ScreenerHomePage> createState() => _ScreenerHomePageState();
}

class _ScreenerHomePageState extends State<ScreenerHomePage> {
  List<dynamic> _stocks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStockData(); // 앱이 켜질 때 자동으로 데이터를 불러옵니다.
  }

  // 파이썬이 만든 result.json 파일을 읽어오는 마법의 함수
  Future<void> _loadStockData() async {
    try {
      final String response = await rootBundle.loadString('assets/result.json');
      final data = await json.decode(response);
      setState(() {
        _stocks = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('데이터 로드 실패: $e'); // 파일이 없거나 에러가 나면 터미널에 알려줍니다.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('🚀 데드캣 바운스 스크리너', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blueAccent),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadStockData(); // 새로고침 버튼을 누르면 데이터를 다시 읽어옵니다.
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // 로딩 빙글빙글
          : _stocks.isEmpty
              ? const Center(child: Text('조건에 맞는 종목이 없습니다.\n방패가 튼튼하게 작동 중입니다!', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)))
              : ListView.builder(
                  itemCount: _stocks.length,
                  itemBuilder: (context, index) {
                    final stock = _stocks[index];
                    final step = stock['step'];
                    
                    // 스텝에 따라 동그라미 색상 변경 (3단계는 빨간색으로 경고!)
                    Color stepColor = step >= 3 ? Colors.redAccent : Colors.orangeAccent;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: stepColor,
                          child: Text(
                            '단계\n$step',
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        title: Text(
                          '${stock['name']} (${stock['ticker']})',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'RSI: ${stock['rsi']}  |  현재가: ${stock['price']}원',
                            style: TextStyle(color: Colors.grey[700], fontSize: 14),
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        onTap: () {
                          // 나중에 이 부분을 누르면 네이버 금융 차트로 이동하게 만들 수 있습니다!
                        },
                      ),
                    );
                  },
                ),
    );
  }
}