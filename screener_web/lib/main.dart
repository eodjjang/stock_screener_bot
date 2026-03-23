import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // 도구 불러오기

void main() => runApp(const ScreenerApp());

class ScreenerApp extends StatelessWidget {
  const ScreenerApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home: const ScreenerHomePage(),
  );
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
    _loadFromCloud(); // 이제 컴퓨터 파일이 아닌 클라우드에서 읽습니다!
  }

  Future<void> _loadFromCloud() async {
    try {
      // ⭐ 여기에 회원님의 깃허브 아이디(eodjjang)가 들어간 주소를 넣었습니다.
      final url = Uri.parse('https://raw.githubusercontent.com/eodjjang/stock_screener_bot/main/screener_web/assets/result.json');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _stocks = json.decode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print("연결 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🚀 실시간 클라우드 스크리너')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _stocks.isEmpty 
          ? const Center(child: Text('오늘 조건에 맞는 종목이 없습니다.\n(로봇은 정상 작동 중!)'))
          : ListView.builder(
              itemCount: _stocks.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(_stocks[index]['name']),
                subtitle: Text("RSI: ${_stocks[index]['rsi']}"),
              ),
            ),
    );
  }
}