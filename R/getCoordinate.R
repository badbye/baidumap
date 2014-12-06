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
#' 
#' http://api.map.baidu.com/geocoder/v2/?address=百度大厦&output=json&ak=E4805d16520de693a3fe707cdc962045&callback=showLocation
#' 
getCoordinate = function(address, city=NULL, output='json', formatted = F){
    ### address
    if (grepl(' ', address)) warning('address should have balnk character!')
    address = gsub(' ', '', address)
    
    ### url
    url_head = paste0('http://api.map.baidu.com/geocoder/v2/?address=', address)
    if (!is.null(city)) url_head = paste0(url_head, "&city=", city)
    url = paste0(url_head, "&output=", output, "&ak=", map_ak)
    
    ### result
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
    
    ### final
    return(result)
}