#' Transform the query character to raw character
#' Take in query and city, return the informations
#' @param a character
#' @return raw character with %. It's used in getPlace.
#' @examples 
#' 
#' \dontrun{
#' url_character('北京')
#' # "%e5%8c%97%e4%ba%ac"
#' }
url_character = function(x){
    raw = as.character(charToRaw(x))
    paste0('%', raw, collapse='')
}

#' Get place from query
#' Take in query and city, return the informations
#' @param place the place you want to search
#' @param city define the city
#' @return a data frame contains name, longtitude, latitude and address, as well as teleplhone number, if exist.
#' @export getPlace
#' @importFrom RCurl getURL
#' @importFrom rjson fromJSON
#' @examples
#' \dontrun{
#' ## colleges in beijing
#' bj_college = getPlace('大学', '北京')
#' ## Mcdonald's in shanghai
#' sh_mcdonald = getPlace('麦当劳', '上海')
#' }
getPlace = function(place = NULL, city = '北京'){
    ### character
    place = url_character(place)
    city = url_character(city)
    
    ### url
    url_head = paste0('http://api.map.baidu.com/place/v2/search?ak=', map_ak)
    url = function(page) {
        paste0(url_head, '&output=json&query=', place, "&page_size=20&",
               '&page_num=', page, '&scope=1&region=', city)
    }
    
    ### formate the result   
    formate = function(x){
        info = sapply(x, function(y) c(ifelse(is.null(y$name), NA, y$name),
                                       ifelse(is.null(y$address), NA, y$address),
                                       ifelse(is.null(y$location$lat), NA, y$location$lat),
                                       ifelse(is.null(y$location$lng), NA, y$location$lng),
                                       ifelse(is.null(y$telephone), NA, y$telephone)))
        info = as.data.frame(t(info), stringsAsFactors = FALSE)
        if (nrow(info) > 0 & ncol(info) > 0) {
            colnames(info) = c('name', 'address', 'lat', 'lon', 'telephone')
        }
        return(info)
    }
    
    ### get result
    getResult = function(page_num = 1){
        result = getURL(url(page_num), .encoding = 'UTF8')
        result = fromJSON(result)
        total = result$total
        result_formate = formate(result$results)
        return(list(total = total, result = result_formate))
    }
    
    ###
    result = getResult(1)
    address = result$result
    total_page = ceiling(result$total / 20)
#     cat('Get',  result$total, 'records,', total_page, 'page.', '\n')
    cat('    Getting ', 1, 'th page', '\n')
    if (total_page > 1){
        for (i in 2:total_page){
            cat('    Getting ', i, 'th page', '\n')
            address_i = getResult(i)$result
            if (nrow(address_i) < 20) break;
            address = rbind(address, address_i)
        }
        cat('Done!', '\n')
    }
    address$lat = as.numeric(address$lat)
    address$lon = as.numeric(address$lon)
    return(address)
}