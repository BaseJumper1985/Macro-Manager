# Macro-Manager

A program in AutoHotKey v2 for the creation and management of dynamic macros and hotstrings

## Description

Create and manage hotstrings using a simple user interface. Hotstring triggers are unambiguous requiring input of a **Double-Space** to activate. Thus eliminating the problem many other programs share of accidental hotstring firing.

Hotstrings can also be entered via **GUI** with a simple search system supporting fuzzy searching.

You can also select blocks of text and this program can parse it for all known Triggers and replace them with the correct hotstring.

## Issue Reporting

Please let me know of any bugs you encounter. In addition, if you have any ideas/additions to the program you would like to see, please post an issue about it. I am always looking for ways to make this as simple, fast, intuitive, and useful as possible.

## Installation

1. Place `BAD-Hotstrings.exe` into a folder of your choice.
2. A configuration `macros.ini` file will be created in `C:\Users\<UserName>\macro-manager\`
3. Run the program by double-clicking `BAD-Hotstrings.exe`.

## Basic Usage

There are two types of hotstrings this program can output, **Standard** and **Dynamic**.

- Standard hotstrings are your typical hotstrings where you type some trigger word or series of letters and it gets replaced with the correct phrase, sentence, or paragraph.
- Dynamic hotstrings act as a template. You trigger them the same way, but in addition you will be prompted to fill in the text that will appear in the defined areas of the hotstring when you created it.

### Creating Standard Hotstrings

1. Run `BAD Hotstrings.exe` then right-click the tray icon that appears.
2. Select **Edit Hotstrings** from the popup menu list to open the **Hotstring Editor**.
3. There won't be any hotstrings yet so make your first one by clicking the **Text Box** to the right of **New Hotstring**.
4. Now fill in the box with a **Trigger** string eg. `nasa`; this will be what you type when you want to use the hotstring.
5. In the box below, enter a **Name** for the hotstring. Can be some descriptive. This will be very useful when you are searching for the hotstring in a potentially large
6. then click the box below and type `National Aeronautics and Space Administration` or anything of your choice.
7. Now you can choose the **Type** of your hotstring. In this case you choose **Standard** From the list box.
8. You will notice that after filling in all the fields correctly, the **Apply** button will no longer be greyed out and you will see the hotstring you entered appear in the **List Box** to the left.
9. Your hotstring will become active immediately and you can start using it wherever you type.

### Creating Dynamic Hotstrings

Follow the same steps as above for creating a standard hotstring, only this time you will need to follow some special rules when creating the hotstring itself.

1. Select **Dynamic** from the **Type** drop-down list.
2. Now you can create the template that will be used for creating the hotstring text.
    - Words that you want to have replaced look like this `{word}`. That is any **word** of your choice enclosed in braces `{}`.
    - Each unique word will be used to create a GUI with empty input boxes for you to fill in. You many use the same word as many times as you would like throughout the hotstring.
    - To handle capitalization you can simply change any `{word}` to fit it's context.
      - `{animal}` would mean entering **dog** will result in **dog** being placed where the text is.
      - `{Animal}` would result in **Dog** being place there instead.
      - Note the capitalization of `{Animal}`: This tells the program what to do with the text you enter.
      - You can also override the behavior by simply capitalizing any words you enter upon using the hotstring. This tells the program to ignore these special rules and simply input the text as is.
3. After filling in all the text, click **Apply** to make the dynamic hotstring active. This will now work just like any other hotstring, but you will prompted to enter the text will be used to replace any `{word}` sections in the resulting text.

### Deleting Hotstrings

1. Select the hotstring in the **List Box** on the left the click **Delete Hotstring**.
2. The hotstring will be removed from the list and will no longer be active. However, the **Edit Fields** on the right will still contain the original values for the hotstring in case you would like to undo the action.

### Editing Hotstrings

1. Select the hotstring from the **List Box** and edit any fields you would like changed. Remember that if you change the trigger for the hotstring a new one will be created instead of editing.
2. Once you are happy with the result click the **Apply** button and the effect will become active immediately.

### Hotstring Entry

#### Entering Hotstrings

- Once you have created some hotstrings you can begin using them by typing the hotstring then pressing the **Space Bar** twice. This will erase the hotstring and replace it with the matching text for that hotstring.
- In the case of a dynamic hotstring being used, you will be prompted to fill in the blanks that will be placed in the resulting text.

#### Selecting Hotstrings From a List

 1. First, make sure to click the location where you will want the hotstring to be inserted.
 2. To enter hotstrings from a searchable list (*especially useful if you have a very large number of hotstrings*) simply **Hold down the Windows key &#8862; and press H**.
 3. You may select a hotstring from the **List Box** to be shown a preview of the result to the side.
 4. You can use the **Search Bar** at the top to find a hotstring. Searching supports ***Fuzzy Finding*** which means the letters you type only have to show up in sequence in a text, so you can search for part of the beginning, some of the end, and the search will still find what you are looking for.
 5. After you find the hotstring you want, you can select it and click **Okay**, or double click the item, to have it entered at the last position of the text cursor when you opened the window.

#### Converting Multiple Hotstrings

If you have a block of text containing multiple trigger words, you can covert all of them at once.

 1. First hold down the **Windows key &#8862;** and **Right Click** anywhere.
 2. In the **Menu** that appears select **Convert Text**.
 3. You will be prompted to **select a block of text** then press the **Okay** button to have the text you selected scanned for any Hotstrings and replaced with their correct results.

Note: this will not work as expected with dynamic hotstrings. I will work on a solution to this in the future.

#### Importing and Exporting

The **Import/Export** Window is for the easy transfer of hotstrings between computers. This will allow you to send you config as plain text via email and then import it into an active instance of the program.

1. First hold down the **Windows key &#8862;** and **Right Click** anywhere.
2. IN the **Menu** that appears select **Import/Export**.
3. Click the **Export** button to have your current list of hotstring appear preformatted and ready for import into another program.
4. After clicking **Export** the button will change to **Copy**. Click this to copy the contents to the clipboard.
5. To Import, simply paste the exported contents into the box on the left and click **Parse**. The import button will change to **Import**
6. Click the **Import** button and the box on the left will turn into a list of hotstrings with check boxes.
7. Any hotstring that are not already in your current config will have their checkbox activated, while any conflicts will be unchecked.
8. Click on any items in the list on the left to see the match that is already in you config. Any items you check will overwrite your current items.
9. When you are satisfied your selections click the **Import** button.

#### Things to Note

- Writes to the config file only happen when you are inactive at the computer for about 10 seconds. This is to keep that chance errors to a minimum. after the 10 seconds, all changes made are written at once. I will add a manual way to save should there be some reason the program needs to be closed right a way.
