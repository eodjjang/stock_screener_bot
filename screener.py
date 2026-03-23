import FinanceDataReader as fdr
import pandas as pd
import pandas_ta as ta
import json
import time

def get_top_500_stocks(market):
    df = fdr.StockListing(market)
    df_sorted = df.sort_values(by='Marcap', ascending=False)
    top500 = df_sorted.head(500)
    
    stock_list = []
    for idx, row in top500.iterrows():
        stock_list.append({"ticker": row['Code'], "name": row['Name']})
    return stock_list

def analyze_stock(ticker, name):
    try:
        df = fdr.DataReader(ticker)
        if len(df) < 60: return None
        df = df.tail(120).copy()

        # 1. RSI 계산
        df['RSI'] = ta.rsi(df['Close'], length=14)
        
        # 2. 볼린저 밴드 계산 (에러 안 나는 순수 공식으로 변경!)
        df['MA20'] = df['Close'].rolling(window=20).mean()
        df['STD20'] = df['Close'].rolling(window=20).std()
        df['BB_Lower'] = df['MA20'] - (df['STD20'] * 2)
        
        # 3. 캔들 패턴
        df['Is_Green'] = df['Close'] > df['Open']
        df['Is_Red'] = df['Close'] < df['Open']
        
        last_idx = -1
        last_row = df.iloc[last_idx]
        prev_row = df.iloc[last_idx - 1]
        
        step = 0
        
        # [실전 조건] RSI 30 이하 & 당일 종가가 밴드 중단선(MA20) 이하
        cond1_2 = (last_row['RSI'] <= 30) and (last_row['Close'] <= last_row['MA20'])
        
        # 상승 장악형 양봉
        cond3 = (prev_row['Is_Red'] and last_row['Is_Green'] and 
                 last_row['Open'] <= prev_row['Close'] and 
                 last_row['Close'] >= prev_row['Open'])

        if cond1_2: step = 2
        if cond3: step = 3
        
        if step >= 2:
            return {
                "ticker": ticker,
                "name": name,
                "step": step,
                "price": int(last_row['Close']),
                "rsi": round(last_row['RSI'], 2)
            }
    except Exception as e:
        print(f"[{name}] 에러: {e}")
        return None
    return None

if __name__ == "__main__":
    print("📊 한국거래소 서버에서 코스피/코스닥 최신 리스트를 불러옵니다...")
    kospi_500 = get_top_500_stocks('KOSPI')
    kosdaq_500 = get_top_500_stocks('KOSDAQ')
    target_stocks = kospi_500 + kosdaq_500

    print(f"🚀 총 {len(target_stocks)}개 우량주 스크리닝을 시작합니다. (약 1~2분 소요 예정)")
    
    final_list = []
    count = 0
    
    for s in target_stocks:
        count += 1
        if count % 20 == 0:
            print(f"진행 중... ({count}/{len(target_stocks)})")
            
        res = analyze_stock(s['ticker'], s['name'])
        if res:
            final_list.append(res)
            print(f"🚨 포착!!! {s['name']} (단계: {res['step']}, RSI: {res['rsi']})")

    with open('result.json', 'w', encoding='utf-8') as f:
        json.dump(final_list, f, ensure_ascii=False, indent=4)
    
    print(f"\n✅ 스크리닝 완전 종료! 총 {len(final_list)}개의 '찐바닥' 후보가 포착되었습니다.")