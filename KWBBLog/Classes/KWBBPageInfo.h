//
//  APSPageInfo.h
//  Apollo
//
//  Created by cuixuerui on 2019/6/17.
//  Copyright © 2019 cuixuerui.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * pageContent = @"\
<!DOCTYPE html>\n\
<html lang=\"en\">\n\
<head>\n\
<meta charset=\"UTF-8\">\n\
<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n\
<meta http-equiv=\"X-UA-Compatible\" content=\"ie=edge\">\n\
<title>iOS日志查看工具</title>\n\
<script src=\"https://code.jquery.com/jquery-2.2.4.min.js\" integrity=\"sha256-BbhdlvQf/xTY9gja0Dq3HiwQF8LaCRTXxZKRutelT44=\" crossorigin=\"anonymous\"></script>\n\
<script type=\"text/javascript\">\n\
var lastData = ''\n\
$( document ).ready(function() {\n\
    setInterval(\"getLog()\", 1000)\n\
    $(\"#command-area\").width($(window).width() * 0.5);\n\
    $(\"#command-area\").height($(window).height());\n\
    $(\"#log-content\").height($(window).height())\n\
    $(\"#log-content\").width($(window).width() * 0.5);\n\
    $(window).resize(function(){\n\
        $(\"#command-area\").width($(window).width() * 0.5);\n\
        $(\"#command-area\").height($(window).height());\n\
        $(\"#log-content\").height($(window).height())\n\
        $(\"#log-content\").width($(window).width() * 0.5);\n\
    })\n\
    \n\
    $('#command-area').keypress(function(event){\n\
        if (event.which === 13) {\n\
            runCommand()\n\
        }\n\
    })\n\
    \n\
    $('#command-area').val('>')\n\
})\n\
\n\
function getLog() {\n\
    $.ajax({method: \"GET\", url: \"/getLog\"}).done(function( data ) {\n\
        if (data.data && data.data !== 'undefined') {\n\
            $( \"#log-content\" ).val(data.data)\n\
        }\n\
    }).fail(function (jqXHR, textStatus, errorThrown) {});\n\
}\n\
\n\
function runCommand() {\n\
    let inputData = $('#command-area').val()\n\
    let command = inputData.substring(lastData.length)\n\
    \n\
    if (command.replace('>', '') === \"clear\") {\n\
        $.ajax({method: \"GET\", url: \"/clear\", data: {value: command}}).done(function( data ) {\n\
            $('#command-area').val(data.terminator)\n\
            lastData = $('#command-area').val()\n\
        })\n\
    } else {\n\
        $.ajax({method: \"GET\", url: \"/command\", data: {value: command}}).done(function( data ) {\n\
            if (data.data && data.data !== 'undefined') {\n\
                \n\
                var str = $('#command-area').val() + ' ' + data.data + data.terminator\n\
                $('#command-area').val(str)\n\
            } else {\n\
                var str = $('#command-area').val() + data.terminator\n\
                $('#command-area').val(str)\n\
            }\n\
            \n\
            lastData = $('#command-area').val()\n\
        }).fail(function (jqXHR, textStatus, errorThrown) {});\n\
    }\n\
}\n\
\n\
</script>\n\
\n\
<style>\n\
#container {\n\
background-color: lightblue;\n\
}\n\
.left {\n\
width: 50%;\n\
    float: left;\n\
    overflow-y: auto;\n\
}\n\
\n\
.right {\n\
width: 50%;\n\
    float: left;\n\
}\n\
\n\
.log-data {\n\
display: block;\n\
    font-size: small;\n\
}\n\
\n\
#command-area {\n\
width: 100%;\n\
background-color: bisque;\n\
}\n\
</style>\n\
\n\
</head>\n\
<body>\n\
<div id=\"container\">\n\
<div class=\"left\">\n\
<textarea id=\"log-content\" style=\"line-height: 1.1\" ></textarea>\n\
</div>\n\
<div class=\"right\">\n\
<textarea id=\"command-area\" cols=\"30\" rows=\"10\"></textarea>\n\
</div>\n\
</div>\n\
</body>\n\
</html>\n\
";

