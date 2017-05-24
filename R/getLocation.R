getLocation.core = function(location, output='json', formatted = F, 
                            pois=0, map_ak){    
    ##### URL
    if (!class(location) %in% c('matrix', 'data.frame')){
        location = matrix(location, ncol=2, byrow=T)
    }
    lon = location[, 1]
    lat = location[, 2]
	url_head = paste0("http://api.map.baidu.com/geocoder/v2/?ak=", map_ak, "&location=")
	url_tail = paste0("&output=", output, "&", "pois=", pois, collapse='')
	url = paste0(url_head, lat, ",", lon, url_tail)
	
    ##### result
	result = tryCatch(getURL(url),error = function(e) {getURL(url, timeout = 200)})
	names(result) = paste0("lon=", lon, ";lat=", lat)
    
    ##### if formatted, return a nice result but loss some information
    if (formatted){
        if (output == 'json'){
            result = gsub('.*"formatted_address":"(.*?)".*', '\\1', result)
        } else if (output == 'xml') {
            result = gsub(".*<formatted_address>(.*?)</formatted_address>.*", '\\1', result)
        }
    }
    
    #### final
	return(result)
}   
#' Get location from coordinate
#' Take in coordiantes and return the location
#' @param location longtitude and latitude
#' @param output should be "json" or "xml", the type of the result
#' @param formatted logical. whether to return a nice result
#' @param pois whether to return the POI around the location
#' @param limit integer value.If the number of row exceeded limit, function will run in parallel
#' @return the corresponding locations
#' @export getLocation
#' @importFrom RCurl getURL
#' @examples
#' 
#' \dontrun{  
#' ## get one location 
#' location_one = getLocation(c(118.12845, 24.57742))
#' 
#' ## vectorization
#' loc = matrix(c(117.93780, 24.55730, 117.93291, 24.57745, 117.23530, 24.64210, 117.05890, 24.74860), byrow=T, ncol=2)
#' ### json 
#' location_json = getLocation(loc, output='json')
#' ### get district
#' library(rjson)
#' getDistrict = function(x_json){
#'     x_list = fromJSON(x_json)
#'     x_list$result$addressComponent$district
#' }
#' location_district = sapply(location_json, getDistrict)
#' 
#' ### xml
#' location_xml = getLocation(loc, output='xml')
#' 
#' ## formatted
#' location = getLocation(loc, formatted = T) 
#' }
#' 
getLocation = function (location, output = "json", formatted = F, 
                        pois = 0, limit=600, map_ak = '') {
        if (map_ak == '' && is.null(getOption('baidumap.key'))){
            stop(Notification)
        }else{
            map_ak = ifelse(map_ak == '', getOption('baidumap.key'), map_ak)
        }
        if(NROW(location)<limit){
            res<-getLocation.core(location, output, formatted , pois, map_ak = map_ak)
        }else if(require(parallel)){
            cl <- makeCluster(getOption("cl.cores", detectCores()*0.8))
            res<-parApply(cl,X = location,MARGIN = 1,FUN = function(x){
                getLocation.core(x, output, formatted , pois)
            })
            stopCluster(cl)
        }else{
            warning('can not run in parallel mode without package parallel')
            res<-getLocation.core(location, output, formatted , pois)
        }
        res
}
