/*************************************************************************


**************************************************************************/


function Startup()
{
  for (var i = 0; i < HelpIndex.length; i++)
  {
    var e = document.createElement("OPTION");
    e.text = HelpIndex[i][0];
    e.value = i;
    document.forms[0].indexlist[document.forms[0].indexlist.length] = e;
  }
}

var oldS = "";

function SelectMatch(str)
{
  chmtop.c2wtopf.indexquery=str;

  var s = str.toUpperCase();
  
  if ((s == "") || (s == oldS))
    return false;

  oldS = s;
 
  var re = new RegExp("^"+s, "i");

  var h = Math.floor(document.forms[0].indexlist.length/100);
  var start = h*100;
  var end = document.forms[0].indexlist.length - 1;

  if (h > 0)
    for (var i = 0; i <= h; i++)
      if (s < document.forms[0].indexlist[i*100].text.toUpperCase())
      {
        start = (i - 1)*100;
        if (start < 0)
          start = 0;
        end = i*100;
        break;
      }

  for (var i = start; i <= end; i++) 
    if (document.forms[0].indexlist[i].text.match(re))
    {
      document.forms[0].indexlist[i].selected = true;
      return true;
    }
 
  return false;
}

function ShowMatch()
{
  var str = HelpIndex[document.forms[0].indexlist[document.forms[0].indexlist.selectedIndex].value][1];
  if (str.substr(0, 3) == "@@@") {
     str = str.substr(3); oldS = "";
     SelectMatch(str);
     return true;
  };

  if (document.forms[0].indexlist.selectedIndex >= 0) {
    open(str, "content");
    return true;
  } else 
    return false;
}
