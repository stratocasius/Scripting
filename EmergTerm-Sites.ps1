$urls = @(
    "https://admin.exchange.microsoft.com/#/",
    "https://director.jacksonlewis.com/Director/LogOn.aspx?ReturnUrl=%2fDirector%2f%3flocale%3den_US&locale=en_US&cc=true#HELP_DESK&S-1-5-21-1292428093-1454471165-1801674531-160893&CIS%20Test%20User",
    "https://admin-85a5eb34.duosecurity.com/login?next=%2F",
    "https://access.brivo.com/events",
    "https://www.lastpass.com/features/password-generator",
    "https://jacksonlewis.service-now.com/kb_view.do?sysparm_article=KB0011387"
)

foreach ($url in $urls) {
    Start-Process "msedge.exe" $url
}