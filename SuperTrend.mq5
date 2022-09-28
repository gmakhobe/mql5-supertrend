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
int multiplier = 3;
int atrHandler;
datetime prevousCandleTime;
double previousUpperBand = 0;
double previousLowerBand = 0;

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
   
   //onEventSetTimeHandler();
   
   return(INIT_SUCCEEDED);
}

/*
   Perform calculations
*/
int OnCalculate(
   const int rates_total,
   const int prev_calculated,
   const datetime& time[],
   const double& open[],
   const double& high[],
   const double& low[],
   const double& close[],
   const long& tick_volume[],
   const long& volume[],
   const int& spread[])
{
   uint dataPoints = 2;
   double averageTrueRangeData[];
   double lowerBand;
   double upperBand;
   bool asSeries = true;
   
   /* Convert Price Data to Price series */
   ArraySetAsSeries(time,asSeries);
   ArraySetAsSeries(high,asSeries);
   ArraySetAsSeries(low,asSeries);
   
   if (prevousCandleTime != time[1])
   {
      averageTrueRangeIndicatorData(averageTrueRangeData, atrHandler, dataPoints);
      upperBand = getBasicUpperBand(high[0], low[0], multiplier, averageTrueRangeData[0]);
      lowerBand = getBasicLowerBand(high[0], low[0], multiplier, averageTrueRangeData[0]);
      prevousCandleTime = time[1];
      
      if (previousUpperBand != 0 && previousLowerBand != 0)
      {
         string upperBandName = TimeToString(time[1]) + "_" + TimeToString(time[0]) + "Upperband";
         string lowerBandName = TimeToString(time[1]) + "-"+TimeToString(time[0]) + "Lowerband";
         Print("Draw upper band, ", 
            drawBand(previousUpperBand, 
               time[1], upperBand,
               time[0], upperBandName, clrCornflowerBlue), 
            ", Price=", upperBand, 
            " time=", time[0]);
         
         Print("Draw lower band, ", 
            drawBand(previousLowerBand, 
               time[1], lowerBand,
               time[0], lowerBandName, clrLemonChiffon), 
            ", Price=", upperBand, 
            " time=", time[0]);
      }
      
      previousUpperBand = upperBand;
      previousLowerBand = lowerBand;
   }

   return(rates_total);
}
/*
   Draw band and give it a color
*/
bool drawBand(
   double _previousBandValue,
   datetime _fromDatetime,
   double _currentBandValue, 
   datetime _toDatetime,
   string _bandName,
   color _bandColor)
{
   int _chartId = 0; // current chart
   
   bool _isRendered = ObjectCreate(
      _chartId,
      _bandName,
      OBJ_TREND,
      0,
      _fromDatetime,
      _previousBandValue,
      _toDatetime,
      _currentBandValue
   );
   
   ObjectSetInteger(_chartId, _bandName, OBJPROP_COLOR, _bandColor);
   
   return _isRendered;
}

/*
   Basic Upper Band
   Formula: BASIC UPPER BAND = HLA + [ MULTIPLIER * 10-DAY ATR ]
*/
double getBasicUpperBand(
   double _high,
   double _low,
   int _multiplier,
   double _averageTrueRange)
{
   double _highLowAverage = (_high + _low) / 2;
   double _basicBand = _highLowAverage + (multiplier * _averageTrueRange);
   
   return _basicBand;
}
/*
   Basic Lower Band
   Formula: BASIC LOWER BAND = HLA - [ MULTIPLIER * 10-DAY ATR ]
*/
double getBasicLowerBand(
   double _high, 
   double _low, 
   int _multiplier, 
   double _averageTrueRange)
{
   double _highLowAverage = (_high + _low) / 2;
   double _basicBand = _highLowAverage - (multiplier * _averageTrueRange);
   
   return _basicBand;
}
/*
   Initialize the ATR indicator
*/
void averageTrueRangeIndicatorInit(
   int& _atrHandler, 
   int _lookbackPeriod, 
   string& _pairSymbol)
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
void averageTrueRangeIndicatorData(
   double& _averageTrueRangeData[], 
   int& _atrHandler, 
   uint _dataPoints = 1)
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