#' Get map from Baidu API
#' 
#' Take in coordiantes and return the location
#' 
#' @param lon longtitude of the center of the map
#' @param lat latitude of the center of the map
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
#' ## default map: Beijing
#' p <- getBaiduMap()
#' ggmap(p)
#' 
#' ## black-and-white
#' p <- getBaiduMap(color='bw')
#' ggmap(p)
#' 
#' ## do not print messages
#' p <- getBaiduMap(messaging = F)
#' }
getBaiduMap = function(lon=116.354431, lat=39.942333, width=400, height = 400, zoom=10, scale=2, color = "color", messaging = TRUE){
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
    attr(map, "bb") <- data.frame(
        ll.lat = ll[1], ll.lon = ll[2],
        ur.lat = ur[1], ur.lon = ur[2]
    )
    
    # transpose
    out <- t(map)
    out
}
