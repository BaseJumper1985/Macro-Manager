# Macro-Manager

A program in AutoHotKey v2 for the creation and management of dynamic macros and Hotstrings

## Description

Create and manage Hotstrings using a simple user interface. Hotstring triggers are unambiguous requiring input of a **Double-Space** (*or space + punctuation*) to trigger. Thus eliminating the problem many other programs share of accidental triggers.

Hotstrings can also be entered via **GUI** with a simple search system supporting fuzzy searching and selection casing (*normal/sentence/title*).

You can also select blocks of text and this program can parse it for all known hotstrings and replace them with the correct text.

## Issue Reporting

Please let me know of any bugs you encounter. In addition, if you have any ideas/additions to the program you would like to see, please post an issue about it. I am always looking for ways to make this as simple, fast, intuitive, and useful as possible.

## Installation

1. Place `BAD-Hotstrings.exe` into a folder of your choice.
2. A configuration `macros.ini` file will be created in `C:\Users\<UserName>\macro-manager\`
3. Run the program by double-clicking `BAD-Hotstrings.exe`.

## Basic Usage

### Creating Standard Hotstrings

1. Run `BAD Hotstrings.exe` then right-click the tray icon that appears.
2. Select **Edit Hotstrings** from the popup menu list to open the *Hotstring Editor*.
3. There won't be any Hotstrings yet so make your first one by clicking the **Text Box** to the right of *New Hotstring*.
4. Now fill in the box with a Hotstring eg. `nasa`, then click the box below and type `National Aeronautics and Space Administration` or anything of your choice.
5. Now you can choose the type of your Hotstring. In this case you choose **Standard** From the list box.
6. You will notice that after filling in all the fields correctly, the **Apply** button will no longer be greyed out and you will see the Hotstring you entered appear in the **List Box** to the left.
7. Your Hotstring will become active immediately and you can start using it wherever you type.

### Deleting Hotstrings

1. Select the Hotstring in the **List Box** on the left the click **Delete Hotstring**.
2. The Hotstring will be removed from the list and will no longer be active. However, the **Edit Fields** on the right will still contain the original values for the Hotstring in case you would like to undo the action.
3. kdf

### Editing Hotstrings

1. Select the Hotstring from the **List Box** and simply edit the resulting text.
2. Once you are happy with the result click the **Apply** button and the effect will become active immediately.

### Hotstring Entry

- Entering Hotstrings:
    1. Once you have created some Hotstrings you can begin using them by typing the Hotstring then pressing the **Space Bar** twice. This will erase the Hotstring and replace it with the matching text for that Hotstring.

- Selecting Hotstrings from a list:
    1. To enter Hotstrings from a searchable list (*especially useful if you have a very large number of hotstrings*) simply **Hold down the Windows key &#8862; and press H**.
    2. Simply click a Hotstring in the **List Box** and you will be shown a preview of the result below.
    3. Select a Hotstring then click **Okay** to have it entered at the cursor position when you opened the window.
    4. You can use the **Search Bar** at the top to find a Hotstring. Searching supports ***Fuzzy Finding*** which means the letters you type only have to show up in sequence in a text, so you can search part of the beginning and some at the end but the search will still find what you are looking for.
    5. You can also select the formatting of the Hotstring result by selecting one of the options to the right.
        - **Paste Without Changes** will enter your text exactly as you entered it when creating your Hotstrings.
        - **Capitalize First** will enter your text as if it is at the start of a sentence (*Sentence Case*).
        - **Title Case Entire Phrase** will capitalize every word of the sentence.
- Converting Multiple Hotstrings:
    1. To Convert a block of text containing Hotstrings all at once by simply holding down the **Windows key &#8862;** and **Right Clicking** anywhere. In the **Menu** that appears select **Convert Text**.
    2. You will be prompted to **select a block of text** then press the **Okay** button to have the text you selected scanned for any Hotstrings and replaced with their correct results.
