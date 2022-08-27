//+------------------------------------------------------------------+
//|                                                          RCI.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_minimum -150
#property indicator_maximum 150
#property indicator_buffers 1
#property indicator_plots   1
//--- plot RCI
#property indicator_label1  "RCI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrOrange
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input int      InpRCIPeriod=9; // Period
input ENUM_APPLIED_PRICE      InpRCIPrice=PRICE_HIGH;
//--- indicator buffers
double         RCIBuffer[];
double high_array[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,RCIBuffer,INDICATOR_DATA);
   
   ArrayResize(high_array,InpRCIPeriod);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(rates_total<InpRCIPeriod) {
      return(0);
   }

   //--- calculate position
   int start;
   if(prev_calculated==0) {
      start=0;
   } else {
      start=prev_calculated-1;
   }

   
   //--- main cycle
   for(int i=start; i<rates_total && !IsStopped(); i++) {
   
      ArrayCopy(high_array,open,i,i,InpRCIPeriod);
      //ArrayPrint(high_array);
         
      //--- 配列反転
      ArrayReverse(high_array);

      //double rci = (1.0 - 6.0 * d(high_array, InpRCIPeriod) / (InpRCIPeriod * (InpRCIPeriod * InpRCIPeriod - 1.0))) * 100.0;
      
      //Print("RCI: "+rci);
      RCIBuffer[i] = rci2(InpRCIPeriod,i,high);
   }
    
   //--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

double d(const double &rsrc[], const int itv) {

    double sum = 0.0;
    
    for(int i=0; i <= itv-1; i++){
      sum = sum + pow((i + 1) - ord(rsrc, i, itv), 2);
    }
        
    return sum;
}

double ord(const double &seq[], const int idx, const int itv) {

    double p = seq[idx];
    int o = 1;
    int s = 0;
    
    for(int i=0; i <= itv-1; i++) {
      if (p < seq[i]) {
         o = o + 1;
      } 
      else
      {   
         if (p == seq[i]) {
            s = s + 1;
         }
      }
    }
              
    return o + (s - 1) / 2.0;
}

//関数定義MQL5　過去分の取得計算が異なるだけ
double rci2(int period, int index,const double &targetArray[]){
   //---価格順位取得準備、配列に取得後ソートする
   double sortArray[];
   ArrayResize(sortArray, period); 
   for(int i=index; index-period < i ; i--){
      //indexから期間の範囲の価格を保存
      if(i < 0){
         //範囲外は計算できないので終了する
         return 0;
      }else{
         //i-index は 0番地から順に代入するため
         sortArray[index-i] = targetArray[i];
      }
   }
   //ソート
   //ArraySort：昇順（0番地が最小）
   ArraySort(sortArray);
   double d = 0.0;
   for(int day=1; day<=period; day++){
      d += MathPow(day - getRank(sortArray, targetArray[index-(day-1)]), 2);
   }
   //RCI計算式
   return((1 - 6*d/(period*(period*period - 1))) * 100);
}

//array 降順　、同値を考慮した順位、同値の考慮不要ならArrayBsearchで良い

//同値の発生はほぼないので、大きな違いはありません

//target 探す値
double getRank(double &array[],double target){
   double rank = 0;
   int cnt = 0;
   int size = ArraySize(array);
   for(int i=0;i<size;i++){
      if(array[i]==target){//見つかったなら
         rank+=(size-i);//番地を順位に変換
         cnt++;//同値を考慮して見つかった個数を加算
      }
   }
   return(rank/cnt);
}
