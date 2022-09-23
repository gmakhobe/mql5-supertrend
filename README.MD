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

*** After being able to obtain the ATR we need to start with execution in order to start executing consider the below cases  ***

## Understanding the implementation
In order to be able to start drawing the SuperTrend bands we need to be able to calculate the bands postions below and above the cadel sticks.
### Upper Band
To calculate the position of an upperband the following calculations are needed.
```

Upperband = HLA + [Multiplier * ATR 10]
Lowerband = HLA - [Multiplier * ATR 10]

```
1. HLA - High Low Average is calculated as [(High + Low)/2]
2. Multiplier - Is usually 3. Not sure why however you can change it to suit your needs.
3. ATR 10 - Is an Average True Range with a lookback period of 10

That's it after doing the above calculation in relation with the bands it is then you can start coding you MQL5 indicator!
