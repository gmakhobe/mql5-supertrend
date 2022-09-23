//+------------------------------------------------------------------+
//|                                                   SuperTrend.mq5 |
//|                                                         gmakhobe |
//|                      https://github.com/gmakhobe/mql5-supertrend |
//+------------------------------------------------------------------+
#property version   "1.00"
 
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//---- plot MA
#property indicator_label1  "SuperTrend"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
// Global Variables
MqlParam indicatorParameters[];

string pairSymbol = Symbol();

int lookbackPeriod = 10;
int multiplier = 0;
int atrHandler;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   
   int parameterCount = 1;
   ArrayResize(indicatorParameters, parameterCount);

   if (pairSymbol == NULL) Symbol();

   indicatorParameters[0].type = TYPE_INT;
   indicatorParameters[0].integer_value = atrHandler; //lookback period
   
   atrHandler = IndicatorCreate(pairSymbol, PERIOD_CURRENT, IND_ATR, parameterCount, indicatorParameters);

   if (atrHandler == INVALID_HANDLE)
   {
      Print("EA Failed to create a moving average!");
      return (INIT_FAILED);
   }
   
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
//---
   Print("Current Open: ", open[0]);
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+
