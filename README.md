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
1. Run the program by double-clicking.

## Basic Usage

### Hotstring Editing

- To create a new Hotstring:
    1. Run `BAD Hotstrings.exe` then right-click the tray icon that appears.
    1. Select **Edit Hotstrings** from the popup menu list to open the *Hotstring Editor*.
    1. There won't be any Hotstrings yet so make your first one by clicking the **Text Box** to the right of *New Hotstring*.
    1. Now fill in the box with a Hotstring eg. `nasa`, then click the box below and type `National Aeronautics and Space Administration` or anything of your choice.
    1. When you are happy with the result click the **Apply** button and you will see the Hotstring you entered appear in the **List Box** to the left.
    1. Your Hotstring will become active immediately and you can start using it wherever you type 
- To delete a Hotstring:
    1. Select the Hotstring in the **List Box** on the left the click **Delete Hotstring**.
    1. The Hotstring will be removed from the list and will no longer be active. However, the **Edit Fields** on the right will still contain the original values for the Hotstring in case you would like to undo the action.
- To Edit a Hotstring:
    1. Select the Hotstring from the **List Box** and simply edit the resulting text.
    1. Once you are happy with the result click the **Apply** button and the effect will become active immediately.

### Hotstring Entry

- Entering Hotstrings:
    1. Once you have created some Hotstrings you can begin using them by typing the Hotstring then pressing the **Space Bar** twice. This will erase the Hotstring (*including the two spaces*) and replace it with the matching text for that Hotstring.
- Formatting output:
    1. There are three different versions for every Hotstring you create and they are all triggered by how you type them.
    1. The three version are:
        - **Normal**: Text will be entered in exactly the way you entered it when you created the Hotstring.  
        Trigger this by entering the Hotstring in **all lowercase letters**.
        - **Sentence Case**: Text will be entered with the first letter captitalized.  
        Trigger this by entering the Hotstring with the **First letter capitalized**.
        - **Title Case**: Text will be entered with the first letter of every word capitalized.  
        Trigger this by entering the Hotstring with **All Letters Capitalized**.
- Selecting Hotstrings from a list:
    1. To enter Hotstrings from a searchable list (*especially useful if you have a very large number of hotstrings*) simply **Hold down the Windows key &#8862; and press H**.
    1. Simply click a Hotstring in the **List Box** and you will be shown a preview of the result below.
    1. Select a Hotstring then click **Okay** to have it entered at the cursor position when you opened the window.
    1. You can use the **Search Bar** at the top to find a Hotstring. Searching supports ***Fuzzy Finding*** which means the letters you type only have to show up in sequence in a text, so you can search part of the beginning and some at the end but the search will still find what you are looking for.
    1. You can also select the formatting of the Hotstring result by selecting one of the options to the right.
        - **Paste Without Changes** will enter your text exactly as you entered it when creating your Hotstrings.
        - **Capitalize First** will enter your text as if it is at the start of a sentence (*Sentence Case*).
        - **Title Case Entire Phrase** will capitalize every word of the sentence.
- Converting Multiple Hotstrings:
    1. To Convert a block of text containing Hotstrings all at once by simply holding down the **Windows key &#8862;** and **Right Clicking** anywhere. In the **Menu** that appears select **Convert Text**.
    1. You will be prompted to **select a block of text** then press the **Okay** button to have the text you selected scanned for any Hotstrings and replaced with their correct results.
