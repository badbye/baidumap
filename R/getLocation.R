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
	url_head = paste0("http://api.map.baidu.com/geocoder/v2/?ak=", map_ak, "&location=")
	url_tail = paste0("&output=", output, "&", "pois=", pois, collapse='')
	url = paste0(url_head, lat, ",", lon, url_tail)
	result = getURL(url)
	names(result) = paste0("lon=", lon, ";lat=", lat)
    ## if formatted, return a nice result but loss some information
    if (formatted){
        if (output == 'json'){
            result = gsub('.*"formatted_address":"(.*?)".*', '\\1', result)
        } else if (output == 'xml') {
            result = gsub(".*<formatted_address>(.*?)</formatted_address>.*", '\\1', result)
        }
    }
	return(result)
}

#' Get coordiante from address
#' Take in address and return the coordinate
#' @param address address
#' @param city the city of the address, optional
#' @param output should be "json" or "xml", the type of the result
#' @param formatted logical value, return the coordinates or the original results
#' @return A vector contains the  corresponding coordiante. If "formatted=TRUE", return the numeric coordinates, otherwise return json or xml type result, depents on the argument "output". If the length of address is larger than 1, the result is a matrix.
#' @export getCoordinate
#' @examples
#' 
#' \dontrun{ 
#' ## json output
#' getCoordinate('北京大学')
#' 
#' ## xml output
#' getCoordinate('北京大学', output='xml')
#' 
#' ## formatted
#' getCoordinate('北京大学', formatted = T)
#' 
#' ## vectorization, return a matrix
#' getCoordinate(c('北京大学', '清华大学'), formatted = T)
#' }
getCoordinate = function(address, city=NULL, output='json', formatted = F){
    url_head = paste0("http://api.map.baidu.com/geocoder/v2/?ak=", map_ak, "&")
    url = paste0(url_head, "output=", output, "&address=", address)
    if (!is.null(city)) url = paste0(url, "&city=", city)
    result = getURL(url)
    names(result) = address
    
    ### transform data from json/xml
    trans = function(x, out = output){
        if (out == 'xml') {
            lat = gsub('.*?<lat>([\\.0-9]*)</lat>.*', '\\1', x)
            long = gsub('.*?<lng>([\\.0-9]*)</lng>.*', '\\1', x)
        }else if (out == 'json'){
            lat = gsub('.*?"lat":([\\.0-9]*).*', '\\1', x)
            long = gsub('.*?"lng":([\\.0-9]*).*', '\\1', x)
        }
        long = as.numeric(long); lat = as.numeric(lat)
        return(c("longtitude" = long, "latitude" = lat))
    }
    if (formatted) {
        if (length(result) > 1) {
            result = t(sapply(result, trans))
        } else {
            result = trans(result)
        }
    }
    return(result)
}