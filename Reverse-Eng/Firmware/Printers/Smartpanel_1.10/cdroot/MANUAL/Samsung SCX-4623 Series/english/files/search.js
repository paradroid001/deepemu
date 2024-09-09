/*************************************************************************

   
               
**************************************************************************/

$minchars = 3;


function ValidateRequest(s)
{
  regexp = /[^\*\w\s\u0080-\uFFFF]/g;
    
  res = s.match(regexp);
  if (res)
  {
    alert("Invalid character \"" + (res[0]) + "\" !");
    return false;
  }

  return true;
}

function Search(s)
{
  document.forms['searchform'].founddocslist.length = 0;

  if (!s || !ValidateRequest(s))
    return false;

  request = PrepareRequest(s).split("\x20");
  
  /*
  var strTmp;
  
  for (i=0; i<request.length; i++) 
  {
    if( request[i].charAt(0) != '*')  strTmp = ' ' + request[i];
    else                              strTmp = request[i].substr(1, request[i].length-1);
    
    if( request[i].charAt(request[i].length-1) != '*')  request[i] = strTmp + ' ';
    else                                                request[i] = strTmp.substr(0, strTmp.length-1)
  }
  
  /* for (i=0; i<request.length; i++) {
   if (request[i].length<$minchars)
   {
     alert("Your search term \"" + request[i] + "\" was too short, please select one that is greater than " + $minchars + " character(s).");
     return false;
   }
  }*/
  
  var docs = RecursiveSearch(0, true, []);
  if (!docs.length) { 
    var e = document.createElement("OPTION");
    e.text = "";
    e.value = "";
    document.forms['searchform'].founddocslist[0] = e;
  } else
    for (var i = 0; i < docs.length; i++)
    {
      var e = document.createElement("OPTION");
      e.text = SearchTitles[docs[i]];
      e.value = SearchFiles[docs[i]];
      document.forms['searchform'].founddocslist[document.forms['searchform'].founddocslist.length] = e;
    }

  return true;
}


var request = [];

var browser = "ie";
var bn=window.navigator.appName;
var ver=navigator.appVersion;

ver = parseFloat(ver.indexOf('MSIE') > 0 ? ver.split(';')[1].split(' ')[2] : ver.split(' ')[0]);

if (navigator.userAgent.indexOf('Opera') != -1 && ver >= 4)
  browser = "opera";
else
  if (bn.indexOf('Netscape') != -1)
    browser = "netscape";

function PrepareRequest(req)
{
  var regexp = /(\x20\x20)/g;
  while (req.match(regexp))
    req = req.replace(regexp, "\x20");
  
  regexp = /(^\x20)|(\x20$)/g;
  while (req.match(regexp))
    req = req.replace(regexp, "");
  return req;
}

function ANDarrays(a, b)
{
  var c = [];
  for (var i = 0; i < a.length; i++)
    for (var j = 0; j < b.length; j++)
      if (a[i] == b[j])
        c[c.length] = a[i];
  return c;
}

function ORarrays(a, b)
{
  var c = [];
  for (var i = 0; i < b.length; i++)
    c[i] = b[i];

  var f;
  for (var i = 0; i < a.length; i++)
  {
    f = false;
    for (var j = 0; j < b.length; j++)
    {
      if (a[i] == b[j])
      {
        f = true;
        break;
      }
    }
    if (!f)
      c[c.length] = a[i];
  }
  return c;
}

function RecursiveSearch(indx, action, resultsarr)
{
  if (indx == request.length)
    return resultsarr;

  if (request[indx] == "OR")
    return RecursiveSearch(indx + 1, false, resultsarr);
  else
    if (request[indx] == "AND")
      return RecursiveSearch(indx + 1, true, resultsarr);
    else {
      ok = false;
      temparr = [];
      for (var i = 0; i < SearchIndexes.length; i++) 
      {
        /*if (SearchIndexes[i][0].substr(0, request[indx].length) == request[indx].toUpperCase())
        {
          temparr = ORarrays(temparr, SearchIndexes[i][1]);
        }*/      
        
        for(var j = 0; j < SearchIndexes[i].length; j++)
        {
            if( SearchIndexes[i][j].indexOf(request[indx]) != -1 )
            {
                var arTmp = new Array(1);
                arTmp[0] = i;
                temparr = ORarrays(arTmp, temparr);
                break;
            }
        }
       }

      if (temparr.length>0) {
          ok = true;
          if (action) // AND
            if (indx>0)  
              resultsarr = ANDarrays(resultsarr, temparr); 
             else
              resultsarr = ORarrays(resultsarr, temparr); 
          else // OR                     
            resultsarr = ORarrays(resultsarr, temparr); 
      }

      if (ok) return RecursiveSearch(indx + 1, true, resultsarr);
    }

  if (action) // AND
    return RecursiveSearch(indx + 1, true, resultsarr);
  else // OR
    return resultsarr;
}

var w = null;

function Hilight() {
 if( document.forms['searchform'].founddocslist[document.forms['searchform'].founddocslist.length-1].text != "No matches found!" )
 {
      if ((w.document.readyState != 'complete') && (w.document.readyState != 'loaded'))
          var t = setTimeout('Hilight()', 100);
      else {
        var dbody = w.document.body;
        var dbodyt = dbody.innerText;
        rngoff = 0;
        for (var r = 0; r < request.length; r++)
        if ((request[r] != "OR") && (request[r] != "AND"))
        {
           var rng = dbody.createTextRange();
           if (rng!=null) {
             for(var i=0; i<100; i++) {
               if (!rng.findText(request[r])) break;
               rng2 = rng.duplicate();
               rng2.moveStart("character", -1);

               charf = rng2.text.charAt(0);
               re = /[ \s\<\>\(\)\]\[\.\,\-\!\?]+/m; 
               //if (charf.search(re)==0 || rng2.text==rng.text) 
                 rng.pasteHTML("<span style='background-color:#FFFF00'>" + 
                   rng.text + "</span>");
               rng.moveStart("word", 1);
             }
           } 
        }
      }
   }
}

function OpenFoundDoc()
{
  w = open(document.forms['searchform'].founddocslist.options[document.forms['searchform'].founddocslist.selectedIndex].value, 'content');
  if(browser=='ie') 
    Hilight();
}

