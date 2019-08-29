#persistent
coordmode "mouse", "screen"

mousegetpos sx, sy

settimer "check", 250
return

check() {
    global
    mousegetpos cx, cy
    if (cx != sx or cy != sy)
    {
        ; mouse has moved, calculate by how much
        if (Abs(cx-sx) > 50 or Abs(cy-sy) > 50)
        {
            msgbox "mouse has moved more than 50 pixels"
            mousegetpos sx, sy ; get new mouse position
        }  
    }      
    return
}