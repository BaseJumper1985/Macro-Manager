# Macro-Manager
A program in AutoHotKey for the creation and management of dynamic macros and hot strings


This is the first prototype of the macro program. It works, but there are still some bugs to work out. It does not have an interface yet as this is just a proof of concept.
Right now the only configuration is done through the ini file. The label ( line in [square brackets] ) can be anything, but later it will cause different behaviors based on which label a macro is under. I want to eventually have an interface that will handle the editing of this file and will check for duplicates and valid strings as well as some kind of provision for multi-line/paragraph macros.
I have provided a shortcut in the tray menu to open the ini file for easy editing. The program will automatically reload upon saving and closing the editing window so that changes will take effect right away.

Known issues:
- Only non-letters or numbers will cause the program to stop monitoring input for a string
  (eg. !, %, ., Space, Enter, etc).
- Punctuation is preserved and placed at the end of the resultant string, but spaces will not be kept.
- The program does not use mouse clicks or window changes as interrupts, so it is possible to start a macro in one window and have it finished in the next which will result in a section of text the length of the macro key being erased and the macro result being written into the new window.
- Backspace will cause the program to stop monitoring for input until the next letter is input; you will have to erase the macro and start over for it to see the first letters.
- Sometimes the program will stop working. This can be fixed by right-clicking the tray icon and selecting "Reload this program" from the menu. This is a known issue of the keyboard hook (keyboard input monitor) this program uses. There are some workarounds, but it will take further testing to find what works best for this program.

Let me know what you think and please tell me of any ideas or features you would like.

Installation:
1. Make sure the “macros.ini” file is in the same folder as “Shop Macros.exe”. The program will be looking in this folder for the “macros.ini” file.
Configuration:
1. To create a new macro:
    a. Run “Shop Macros.exe” then right-click the tray icon that appears.
    b. In the menu you will find “Open INI file for editing”. Clicking this will open “macros.ini” Notepad for editing.
    c. Insert a new line with the macro you want to use on the left, an equal sign in the middle, and the result of the macro on the right.
eg. “nasa = National Aeronautics and Space Administration” minus the quotes.
    d. Save, then close Notepad and the program will reload with your changes in effect.
2. To delete a macro:
    a. Simply remove the line from “macros.ini”. The changes will take effect when you save and close Notepad.
