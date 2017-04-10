#!/usr/bin/env python
# -*- coding: utf-8 -*
import urllib,json
shijiazhuang = "CN101090101"
key = "5d0641df5e4f44529079756c79aeb3bd"
baseUrl = "https://free-api.heweather.com/v5/"
timeNow = "now?"
weatherUrl = baseUrl + timeNow + "city=" + shijiazhuang + "&key=" + key

def getHtml(url):
    page = urllib.urlopen(url)
    html = page.read()
    return html

def nowWeather():
    getStatus = True
    try:
        html = getHtml(weatherUrl)
    except Exception,e:
#        print e
        getStatus=False
    if getStatus:
        weatherDate = json.loads(html)
        print weatherDate["HeWeather5"][0]["now"]["tmp"]
    else:
        print 0

nowWeather()
