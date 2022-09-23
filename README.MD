# Super Trend Indicator
SuperTrend is an indicator that is used to determine the direction of the market. It uses the ATR and its multiplier to be able to plot bends below for a bullish market and above for a bearish makert the candle sticks.

## Understanding the ATR (Average True Range)
This is lagging indicator used to calculate the volatility of the market and it is not a directional indicator.

Before being able to calculate the Average True Range we need to be able to calculate a True Range.

### True Range (TR)
A true range is calculated using the following standard formula.
```
MAX = [{ High - Low}, {High - p.Close}, {p.Close - Low}]

High = Current High
Low = Current Low
p.Close = Previous Close

MAX = Maximum Values
```
### Average True Range (ATR)
I am not going to specifically calculate the True Range and the Average True Range since we have it built for us [MQL Docs](https://www.mql5.com/en/docs/indicators/iatr)
In order to obtain the ATR from TR we need to smooth the TR for an example using a Simple Moving Average, we can use any other moving average since there are no fundamentals rules into smoothing the TR

