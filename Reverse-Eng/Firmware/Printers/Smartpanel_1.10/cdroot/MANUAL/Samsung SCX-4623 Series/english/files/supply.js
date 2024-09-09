/*************************************************************************

               
**************************************************************************/

function FindTop(start)
{
 if (start==top) return top;
 try { t = start.parent.name; } catch (e) { return start; }    
 return FindTop(start.parent);
}
var chmtop = FindTop(self);


function FindFrame(frameName, start)
{
 if(start==null) return null;

 var resframe = null;
 var frames = start.frames;
 if(frames.length==0) return null;


 for(var i=0; i<frames.length; i++)
 {
    tmpFrame = frames[i];

    try { tmpFrameName = tmpFrame.name; }
    catch (e) { continue; }    

    if(tmpFrameName.toUpperCase() == frameName.toUpperCase())
    {
      resframe = frames[i];
    } else {
      resframe = FindFrame(frameName, tmpFrame);
    }
    if (resframe != null) return resframe;
 } return null;
}

function navDelta(incr) 
{ 
  next = pagenum; 
  if (incr < 0) {
   for (i=pagenum-1; i>=0; i--)
    if (FITEMS[i] != null) {
     next = i;
     break;
     }
  } else {
   for (i=pagenum+1; i<FITEMS.length; i++)
    if (FITEMS[i] != null) {
     next = i;
     break;
    }
  }
  if (next == pagenum) return;
  var url = FITEMS[next];
  try {
   jstree.dOpenTreeNode(next);
  } catch (e) {
      pagenum = next;
  };
  window.open(url, "content");
}

function conPrint()
{
    var frame = FindFrame("content", top);
    if (frame && frame.focus && frame.print && !window.opera) {
      frame.focus();
      frame.print();
    } else {
      alert("Sorry, your browser does not support the print feature.");
    }
}

