//+------------------------------------------------------------------+
//|                                                   SuperTrend.mq5 |
//|                                                         gmakhobe |
//|                      https://github.com/gmakhobe/mql5-supertrend |
//+------------------------------------------------------------------+
#property version   "1.00"
 
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
// Input Variables
input int lookbackPeriod = 10;
// Global Variables
string pairSymbol = Symbol();
int multiplier = 0;
int atrHandler;

/*
   Initialize indicator
*/
int OnInit()
{
   
   averageTrueRangeIndicatorInit(atrHandler, lookbackPeriod, pairSymbol);

   if (atrHandler == INVALID_HANDLE)
   {
      Print("An error happened while copy indicator buffer data: ", GetLastError());
      return (INIT_FAILED);
   }
   
   onEventSetTimeHandler();
   
   return(INIT_SUCCEEDED);
}

/*
   Perform calculations
*/
int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double& price[])
{
   uint dataPoints = 1;
   double averageTrueRangeData[];
   
   averageTrueRangeIndicatorData(averageTrueRangeData, atrHandler, dataPoints);
   Print("Current ATR Value: ", averageTrueRangeData[0]);
   
   return(rates_total);
}

/*
   Initialize the ATR indicator
*/
void averageTrueRangeIndicatorInit(int& _atrHandler, int _lookbackPeriod, string& _pairSymbol)
{
   MqlParam _indicatorParameters[1];
   int _parameterCount = 1;
   
   if (_pairSymbol == NULL)
   {
      _pairSymbol = Symbol();
   }

   _indicatorParameters[0].type = TYPE_INT; // indicator parameter type (lookback period)
   _indicatorParameters[0].integer_value = _lookbackPeriod; //lookback period
   
   _atrHandler = IndicatorCreate(_pairSymbol, PERIOD_CURRENT, IND_ATR, _parameterCount, _indicatorParameters);
}

/*
   Get ATR Data from the buffer using a handler
*/
void averageTrueRangeIndicatorData(double& _averageTrueRangeData[], int& _atrHandler, uint _dataPoints = 1)
{
   bool _asSeries = true;
   
   if(_atrHandler != INVALID_HANDLE)
   {
      ArraySetAsSeries(_averageTrueRangeData, _asSeries);
      
      if (CopyBuffer(_atrHandler, 0, 0, _dataPoints, _averageTrueRangeData) == 0)
      {
         Print("An error happened while copy indicator buffer data: ", GetLastError());
      } 
   }
}

// Perform Action on Timer
void OnTimer()
{

}

/*
   Execute onTimer per the number of seconds in relation with the timeframe selected.
*/
void onEventSetTimeHandler()
{
   switch(Period())
     {
      case PERIOD_M1:
        EventSetTimer(60);
      break;
      case PERIOD_M2:
        EventSetTimer(120);
      break;
      case PERIOD_M4:
        EventSetTimer(240);
      break;
      case PERIOD_M5:
        EventSetTimer(300);
      break;
      case PERIOD_M6:
        EventSetTimer(360);
      break;
      case PERIOD_M10:
        EventSetTimer(600);
      break;
      case PERIOD_M12:
        EventSetTimer(720);
      break;
      case PERIOD_M15:
        EventSetTimer(900);
      break;
      case PERIOD_M20:
        EventSetTimer(1200);
      break;
      case PERIOD_M30:
        EventSetTimer(1800);
      break;
      case PERIOD_H1:
        EventSetTimer(3600);
      break;
      case PERIOD_H4:
         EventSetTimer(14400);  
      break;
      case PERIOD_D1:
         EventSetTimer(86400);  
      break;
      case PERIOD_W1:
        EventSetTimer(432000);
      break;
      default:
        break;
     }
}