#' Convert geocode
#' Take in geocode from the other source to baidu's geocode
#' @param geocde geocode from the other source
#' @param from takes intergers from 1 to 8. 1：GPS设备获取的角度坐标; 2：GPS获取的米制坐标、sogou地图所用坐标; 3：google地图、soso地图、aliyun地图、mapabc地图和amap地图所用坐标; 4：3中列表地图坐标对应的米制坐标; 5：百度地图采用的经纬度坐标; 6：百度地图采用的米制坐标; 7：mapbar地图坐标; 8：51地图坐标
#' @param to 5 or 6. 5：bd09ll(百度经纬度坐标); 6：bd09mc(百度米制经纬度坐标);
#' @importFrom rjson fromJSON
#' @importFrom RCurl getURL
geoconv = function(geocode, from=3, to=5){
    if (class(geocode) %in% c('data.frame', 'matrix')){
        geocode = as.matrix(geocode)
        code = apply(geocode, 1, function(x) paste0(x[1], ',', x[2]))
        code_url = paste0(code, ';', collapse = '')
        code_url = substr(code_url, 1, nchar(code_url)-1)
    } else if(length(geocode) == 2){
        code_url = paste0(geocode[1], ',', geocode[2])
    } else{
        stop('格式错误')
    }
    
    url_header = 'http://api.map.baidu.com/geoconv/v1/?coords='
    url = paste0(url_header, code_url, '&from=', from, '&to=', to, '&ak=', map_ak, 
                 collapse='')
    url
    result = fromJSON(getURL(url))
    result_matrix = sapply(result$result, function(t) c(t$x, t$y))
    t(result_matrix)
}