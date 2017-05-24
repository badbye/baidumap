#' Get map from Baidu API
#' 
#' Take in coordiantes and return the location
#' 
#' @param location a vector a or matrix contains longtitude and latitude of the center of the map, or a character refers to the address
#' @param width width of the map
#' @param height height of the map
#' @param zoom map zoom, an integer from 3 (continent) to 21 (building), default value 10 (city)
#' @param scale multiplicative factor for the number of pixels returned. possible values are 2 or anything else.
#' @param color "color" or "bw", color or black-and-white
#' @param messaging logical. whether to print the download messages.
#' @return A ggmap object. a map image as a 2d-array of colors as hexadecimal strings representing pixel fill values.
#' @export 
#' @importFrom png readPNG
#' @importFrom RgoogleMaps XY2LatLon
#' @importFrom ggmap ggmap
#' @examples
#' 
#' \dontrun{
#' library(ggmap)  
#' ## Beijing
#' p <- getBaiduMap(c(116.39565, 39.92999))
#' ggmap(p)
#' 
#' p <- getBaiduMap('beijing') # the same
#' ggmap(p)
#' 
#' ## black-and-white
#' p <- getBaiduMap(color='bw')
#' ggmap(p)
#' 
#' ## do not print messages
#' p <- getBaiduMap(messaging = F)
#' }
getBaiduMap = function(location, width=400, height = 400, zoom=10, 
                       scale=2, color = "color", messaging = TRUE,
                       map_ak = ''){
    if (map_ak == '' && is.null(getOption('baidumap.key'))){
        stop(Notification)
    }else{
        map_ak = ifelse(map_ak == '', getOption('baidumap.key'), map_ak)
    }
    ## location
    if (is.character(location) && length(location) == 1){
        location_cor = getCoordinate(location, formatted=T)
    } else if (length(location == 2)){
        location_cor = location
    } else{
        stop('Wrong address!')
    }
    lon = location_cor[1];
    lat = location_cor[2];
    
    ## set url
    url_head = "http://api.map.baidu.com/staticimage?"
    url = paste0(url_head, "width=", width, "&height=", height, "&center=",
                 lon, ",", lat, "&zoom=", zoom)
    if (scale == 2) url = paste0(url, "&scale=2")
    
    ## download image
    if  (!'baiduMapFileDrawer' %in% list.dirs(full.names= F, recursive=F)) {
        dir.create('baiduMapFileDrawer')
    }
    destfile = paste0(lon, ";", lat, ".png")
    download.file(url, destfile = paste0("baiduMapFileDrawer/", destfile), 
                  quiet = !messaging, mode = "wb")
    if (messaging) message(paste0("Map from URL : ", url))
    
    ## read image and transform to ggmap obejct 
    map = readPNG(paste0("baiduMapFileDrawer/", destfile))
    # format file
    if(color == "color"){
        map <- apply(map, 2, rgb)
    } else if(color == "bw"){
        mapd <- dim(map)
        map <- gray(.30 * map[,,1] + .59 * map[,,2] + .11 * map[,,3])
        dim(map) <- mapd[1:2]
    }
    class(map) <- c("ggmap","raster")
    
    # map spatial info
    ll <- XY2LatLon(
        list(lat = lat, lon = lon, zoom = zoom),
        -width/2 + 0.5,
        -height/2 - 0.5
    )
    ur <- XY2LatLon(
        list(lat = lat, lon = lon, zoom = zoom),
        width/2 + 0.5,
        height/2 - 0.5
    )
    
#     ll = as.numeric(rev(geoconv(rev(ll))))
#     ur = as.numeric(rev(geoconv(rev(ur))))
    attr(map, "bb") <- data.frame(
        ll.lat = ll[1], ll.lon = ll[2],
        ur.lat = ur[1], ur.lon = ur[2]
    )
    
    # transpose
    out <- t(map)
    out
}

