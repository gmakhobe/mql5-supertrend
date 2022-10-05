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
double previousFinalUpperBand = 0;
double previousFinalLowerBand = 0;
double previousSuperTrend = 0;

bool isFirstExecution = true;
bool isUpTrend = NULL;
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
   /* Convert Price Data to Price series */
   bool asSeries = true;

   ArraySetAsSeries(time,asSeries);
   ArraySetAsSeries(high,asSeries);
   ArraySetAsSeries(low,asSeries);
   ArraySetAsSeries(close,asSeries);

   superTrend(time[0], time[1], prevousCandleTime, high[1], low[1], close[1], previousUpperBand, previousLowerBand, 
   previousFinalUpperBand, previousFinalLowerBand, atrHandler, isFirstExecution, isUpTrend);

   return(rates_total);
}
/*
   SuperTrend: Main function handling SuperTrend fuctionality
*/
void superTrend(datetime _time_0, datetime _time_1, datetime& _prevousCandleTime, double _high_1, double _low_1, double _close_1,
   double& _previousUpperBand, double& _previousLowerBand, double& _previousFinalUpperBand, double& _previousFinalLowerBand,
   int& _atrHandler, bool& _isFirstExecution, bool& _isUpTrend)
{
   uint dataPoints = 2;
   double averageTrueRangeData[];
   double lowerBand;
   double upperBand;
   double finalLowerBand;
   double finalUpperBand;
   double superTrend = 0;
   
   if (prevousCandleTime != _time_1)
   {
      averageTrueRangeIndicatorData(averageTrueRangeData, _atrHandler, dataPoints);
      upperBand = getBasicUpperBand(_high_1, _low_1, multiplier, averageTrueRangeData[1]);
      lowerBand = getBasicLowerBand(_high_1, _low_1, multiplier, averageTrueRangeData[1]);
      finalUpperBand = getFinalUpperBand(upperBand, previousFinalUpperBand, _close_1);
      finalLowerBand = getFinalLowerBand(lowerBand, previousFinalLowerBand, _close_1);
      superTrend = getSuperTrend(previousSuperTrend, previousFinalUpperBand,previousFinalLowerBand,
      finalUpperBand,finalLowerBand,_close_1);
      _prevousCandleTime = _time_1;
      
      if (finalUpperBand != 0 && finalLowerBand != 0 && previousFinalUpperBand != 0 && previousFinalLowerBand != 0)
      {   
         if (_close_1 > upperBand && !_isFirstExecution)
         {
            _isUpTrend = true;
         }
 
         if (_close_1 < lowerBand && !_isFirstExecution)
         {
            _isUpTrend = false;
         }
         Print("Is Close > Upper = ", _close_1 > upperBand, "\n Close= ", _close_1, " - UpperBand= ", upperBand);
         Print("Is Close > Lower = ", _close_1 > lowerBand, "\n Close= ", _close_1, " - UpperBand= ", lowerBand);
         
         //Print("_isFirstExecution = ", _isFirstExecution);
         if (_isFirstExecution)
         {
            checkFirstExecutionXOver(_isFirstExecution, _isUpTrend, finalUpperBand, finalLowerBand, previousFinalUpperBand, previousFinalLowerBand);
         }
         printSuperTrend(_isFirstExecution, _isUpTrend, finalUpperBand, finalLowerBand, previousFinalUpperBand, previousFinalLowerBand, 
         _time_0, _time_1); 
      }
      
      _previousUpperBand = upperBand;
      _previousLowerBand = lowerBand;
      _previousFinalUpperBand = finalUpperBand;
      _previousFinalLowerBand = finalLowerBand;
   }
}
/*
   Print our super trend
*/
void printSuperTrend(bool& _isFirstExecution, bool& _isUpTrend, double _finalUpperBand, double _finalLowerBand, 
   double _previousFinalUpperBand, double _previousFinalLowerBand, datetime _time_0, datetime _time_1)
{
   string _upperBandName = TimeToString(_time_1) + "-" + TimeToString(_time_0) + "Upperband";
   string _lowerBandName = TimeToString(_time_1) + "-"+TimeToString(_time_0) + "Lowerband";
   //_isFirstExecution = true;
   //_isUpTrend = NULL;

   if (_isFirstExecution && _isUpTrend == NULL)
   {
      drawBand(_previousFinalUpperBand, _time_1, _finalUpperBand, _time_0, _upperBandName, clrCornflowerBlue);
      drawBand(_previousFinalLowerBand, _time_1, _finalLowerBand, _time_0, _lowerBandName, clrLemonChiffon);
      Print("Is Neutral Trend!");
   }

   if (!_isFirstExecution && _isUpTrend)
   {
      drawBand(_previousFinalLowerBand, _time_1, _finalLowerBand, _time_0, _lowerBandName, clrLemonChiffon);
   }
   
   if (!_isFirstExecution && !_isUpTrend)
   {
      drawBand(_previousFinalUpperBand, _time_1, _finalUpperBand, _time_0, _upperBandName, clrCornflowerBlue);
   }
}
/*
   Check if it the program has been recently run and the crossover has not occured
*/
void checkFirstExecutionXOver(bool& _isFirstExecution, bool& _isUpTrend, double _finalUpperBand, double _finalLowerBand, 
   double _previousFinalUpperBand, double _previousFinalLowerBand)
{
   if (_isFirstExecution && (_previousFinalUpperBand >= _finalUpperBand) && (_previousFinalLowerBand <= _finalLowerBand))
   {
      _isFirstExecution = true;
      return ;
   }
   else
   {
      _isFirstExecution = false;
   }
   
   // We are trending down
   if (!_isFirstExecution && (_previousFinalUpperBand >= _finalUpperBand) && _isUpTrend == NULL)
   {
      _isUpTrend = false;
      return ;
   }
   
   // We are trending up
   if (!_isFirstExecution && (_previousFinalLowerBand <= _finalLowerBand) && _isUpTrend == NULL)
   {
      _isUpTrend = true;
      return ;
   }
   
}
/*
   Get Super Trend
*/
double getSuperTrend(double _previousSuperTrend, 
   double _previousFinalUpperBand,double _previousFinalLowerBand,
   double _currentFinalUpperBand, double _currentFinalLowerBand,
   double _currentClose)
{
   // To-Do
   
   return (0);
}
/*
   Get Final Bands
*/
// Get Final Lower Band
/*
   Final Lowerband = If Current Basic Lowerband > Previous Final Lowerband OR
   Previous Close < Previous Final Lowerband Then Current Basic Lowerband Else Previous Final Lowerband
*/
double getFinalLowerBand(double _currentbasicLowerBand, double _previousFinalLowerBand, double _previousClose)
{
   double _currentBand;
   
   if (_currentbasicLowerBand > _previousFinalLowerBand || _previousClose < _previousFinalLowerBand)
   {
      _currentBand = _currentbasicLowerBand;
   }
   else
   {
      _currentBand = _previousFinalLowerBand;
   }

   return _currentBand;
}
// Get Final Upper Band
/*
   Final Upperband = If Current Basic Upperband < Previous Final Upperband OR
   Previous Close > Previous Final Upperband Then Current Basic Upperband Else Previous Final Upperband
*/
double getFinalUpperBand(double _currentbasicUpperBand, double _previousFinalUpperBand, double _previousClose)
{
   double _currentBand;
   
   if (_currentbasicUpperBand < _previousFinalUpperBand || _previousClose > _previousFinalUpperBand)
   {
      _currentBand = _currentbasicUpperBand;
   }
   else
   {
      _currentBand = _previousFinalUpperBand;
   }

   return _currentBand;
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