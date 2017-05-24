baidumap
========

R interface of baidu map api，just like ggmap but get map from baidu api instead of google or openstreet.

## Installation
```
library(devtools)
install_github('badbye/baidumap')
```

## Usage

Apply an application from [lbsyun.baidu.com](http://lbsyun.baidu.com/apiconsole/key). Then register you key here.
```
library(baidumap)
options(baidumap.key = 'XXX fill your key here XXX')
```


### getLocation
Get location from coordinates data.
```
lon = matrix(c(117.93780, 24.55730, 117.93291, 24.57745, 117.23530, 24.64210, 117.05890, 24.74860), byrow=T, ncol=2)
### json 
location_json = getLocation(lon[1,], output='json')

### xml
location_xml = getLocation(lon[1, ], output='xml')

## formatted
location = getLocation(lon[1, ], formatted = T) 
```

### GetCoordinate
Given a address, return the corresponding coordinates
```
getCoordinate('北京大学') # json
getCoordinate('北京大学', output='xml') # xml
getCoordinate('北京大学', formatted = T) # character
getCoordinate(c('北京大学', '清华大学'), formatted = T) # matrix
```


### getBaiduMap

```
p <- getBaiduMap(c(116.354431, lat=39.942333))
library(ggmap)
ggmap(p)
```
