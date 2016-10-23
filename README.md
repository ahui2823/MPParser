#MPParser
***
__MPParser is a MobileProvision Parser.__ <br /> <br /> <br />

##Download MPParser directly
***
__Download MPParser, and then change mode into excutable, run the command below in terminal:__
    
    chmod +x path_to_mpparser

Run `path_to_mpparser` for help.
<br /><br /><br />
##Build by source code
***

__Just run the command below in your terminal:__

    curl https://raw.githubusercontent.com/ahui2823/MPParser/master/main.m | clang -fobjc-arc -framework Foundation -framework Security -o /usr/local/bin/mpparser -x objective-c - 
    
This command would download the source, compile it and put resulting binary to `/usr/local/bin/mpparser`.

Run `mpparser` for help.
