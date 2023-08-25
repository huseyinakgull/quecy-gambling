shared_script 'library_ad.lua'
fx_version "cerulean"
game "gta5"
client_script {
    "client/*.lua"
}
server_script {
    "server/*.lua",
     '@mysql-async/lib/MySQL.lua',
}
files {
    "html/index.html",
    "html/*.js",
    "html/css/*.css",
    "html/fonts/ChaletComprime.ttf",
    "html/img/*.png",
}
ui_page "html/index.html"
