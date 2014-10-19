baidumap
========

R interface of baidu map api，just like ggmap but get map from baidu api instead of google or openstreet.

### install
```
library(devtools)
install_github('badbye/baidumap')
library(baidumap)
```

### getLocation
Get location from coordinates data.
```
lon = matrix(c(117.93780, 24.55730, 117.93291, 24.57745, 117.23530, 24.64210, 117.05890, 24.74860), byrow=T, ncol=2)
### json 
location_json = getLocation(lon[, 1], lon[, 2], output='json')

### xml
location_xml = getLocation(lon[, 1], lon[, 2], output='xml')

## formatted
location = getLocation(lon[, 1], lon[, 2], formatted = T) 
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
p <- getBaiduMap(lon=116.354431, lat=39.942333)
library(ggmap)
ggmap(p)
```
