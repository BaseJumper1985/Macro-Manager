#persistent
coordmode "mouse", "screen"

mousegetpos sx, sy
msgbox(sx " " sy)

settimer "check", 250
return

check() {
    global
    mousegetpos cx, cy
    if (cx != sx or cy != sy)
    {
        ; mouse has moved, calculate by how much
        if (cx > (sx+50) or cx < (sx-50) or cy > (sy+50) or cy < (sy-50))
        {
            msgbox "mouse has moved more than 50 pixels"
            mousegetpos sx, sy ; get new mouse position
        }  
    }      
    return
}