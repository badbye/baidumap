.onAttach <- function(libname, pkgname) {
    # Runs when attached to search() path such as by library() or require()
    if (interactive()) {
        v = packageVersion("baidumap")
        message('baidumap ', v)
        message(Notification)
    }
}

Notification <- paste('Apply an application from here: http://lbsyun.baidu.com/apiconsole/key',
                       "Then register you key by running `options(baidumap.key = 'xxx')`",
                      sep = '\n')

