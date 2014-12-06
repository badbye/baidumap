map_ak = 'wwZFCIqxIqjRGMVsZ0qgTh7D'
#' Get location from coordinate
#' Take in coordiantes and return the location
#' @param lon longtitude
#' @param lat latitude
#' @param output should be "json" or "xml", the type of the result
#' @param formatted logical. whether to return a nice result
#' @param pois whether to return the PIO around the location
#' @return the corresponding locations
#' @export getLocation
#' @importFrom RCurl getURL
#' @examples
#' 
#' \dontrun{  
#' ## get one location 
#' location_one = getLocation(118.12845, 24.57742)
#' 
#' ## vectorization
#' lon = matrix(c(117.93780, 24.55730, 117.93291, 24.57745, 117.23530, 24.64210, 117.05890, 24.74860), byrow=T, ncol=2)
#' ### json 
#' location_json = getLocation(lon[, 1], lon[, 2], output='json')
#' ### get district
#' library(rjson)
#' getDistrict = function(x_json){
#'     x_list = fromJSON(x_json)
#'     x_list$result$addressComponent$district
#' }
#' location_district = sapply(location_json, getDistrict)
#' 
#' ### xml
#' location_xml = getLocation(lon[, 1], lon[, 2], output='xml')
#' 
#' ## formatted
#' location = getLocation(lon[, 1], lon[, 2], formatted = T) 
#' }
getLocation = function(lon, lat, output='json', formatted = F, pois=0){    
    ##### URL
	url_head = paste0("http://api.map.baidu.com/geocoder/v2/?ak=", map_ak, "&location=")
	url_tail = paste0("&output=", output, "&", "pois=", pois, collapse='')
	url = paste0(url_head, lat, ",", lon, url_tail)
	
    ##### result
    result = getURL(url)
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