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

There are two types of hotstrings this program can output, Standard and Dynamic.

- Standard hotstrings are your typical hotstrings where you type some trigger word or series of letters and it gets replaced with the correct phrase, sentence, or paragraph.
- Dynamic hotstrings act as a template. You trigger them the same way, but in addition you will be prompted to fill in the text that will appear in the defined areas of the hotstring when you created it.

### Creating Standard Hotstrings

1. Run `BAD Hotstrings.exe` then right-click the tray icon that appears.
2. Select **Edit Hotstrings** from the popup menu list to open the *Hotstring Editor*.
3. There won't be any hotstrings yet so make your first one by clicking the **Text Box** to the right of *New Hotstring*.
4. Now fill in the box with a trigger string eg. `nasa`; this will be what you type when you want to use the hotstring.
5. In the box below, enter a name for the hotstring. Can be some descriptive. This will be very useful when you are searching for the hotstring in a potentially large
6. then click the box below and type `National Aeronautics and Space Administration` or anything of your choice.
7. Now you can choose the type of your hotstring. In this case you choose **Standard** From the list box.
8. You will notice that after filling in all the fields correctly, the **Apply** button will no longer be greyed out and you will see the hotstring you entered appear in the **List Box** to the left.
9. Your hotstring will become active immediately and you can start using it wherever you type.

### Creating Dynamic Hotstrings

<!-- Complete this -->

### Deleting Hotstrings

1. Select the hotstring in the **List Box** on the left the click **Delete Hotstring**.
2. The hotstring will be removed from the list and will no longer be active. However, the **Edit Fields** on the right will still contain the original values for the hotstring in case you would like to undo the action.
3. kef

### Editing Hotstrings

1. Select the hotstring from the **List Box** and simply edit the resulting text.
2. Once you are happy with the result click the **Apply** button and the effect will become active immediately.

### Hotstring Entry

#### Entering Hotstrings:

 1. Once you have created some hotstrings you can begin using them by typing the hotstring then pressing the **Space Bar** twice. This will erase the hotstring and replace it with the matching text for that hotstring.

#### Selecting Hotstrings From a List:

 1. First, make sure to click the location where you will want the hotstring to be inserted.
 2. To enter hotstrings from a searchable list (*especially useful if you have a very large number of hotstrings*) simply **Hold down the Windows key &#8862; and press H**.
 3. Simply click a hotstring in the **List Box** and you will be shown a preview of the result below.
 4. Select a hotstring then click **Okay** to have it entered at the cursor position when you opened the window.
 5. You can use the **Search Bar** at the top to find a hotstring. Searching supports ***Fuzzy Finding*** which means the letters you type only have to show up in sequence in a text, so you can search part of the beginning and some at the end but the search will still find what you are looking for.

#### Converting Multiple Hotstrings:

 1. To Convert a block of text containing Hotstrings all at once by simply holding down the **Windows key &#8862;** and **Right Clicking** anywhere. In the **Menu** that appears select **Convert Text**.
 2. You will be prompted to **select a block of text** then press the **Okay** button to have the text you selected scanned for any Hotstrings and replaced with their correct results.
