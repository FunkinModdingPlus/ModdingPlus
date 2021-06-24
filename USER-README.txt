THIS IS FOR YOU LITTLE CUNTS WHO KEEP SUGGESTING IT IN THE DISCORD
FUCK YOU

outsiders who haven't seen the chaos in the discord server deserve this more then you, and i'm writing this for 3 reasons
1. bulby literally won't
2. to shut the little cunts up
3. to make it easier for people to actually use this shit

CUSTOM CHARACTERS:
1. Go to the "custom_chars" folder in the images folder
2. Create a folder named whatever you want your character named
3. Put the character's png and xml in the folder, and rename them to "char". Also put in a dead.png and xml for BF_Pixel (you can also throw in icons and portraits)
4. Open up "custom_chars.jsonc" and put in the new character
5. Profit

refer to bf for how to do Cool Custom Portraits

FULLY CUSTOM CHARACTERS
1. Do all the shit above
2. Make an hscript or json for the character and edit it to your liking (IF YOU AREN'T EXPERIENCED IN HAXE CODING REFER TO ANOTHER HSCRIPT OR JSON!!)
3. Set the character as that hscript/json

TEMPLATE FOR CUSTOM CHARACTERS:

  "INSERT CHARACTER NAME HERE": {
    "like": "INSERT WHAT THE CHARACTER IS A RESKIN OF HERE",
    "icons": [0,1,1],
    "colors": ["#149DFF"]

The icons part is for character icons (of course)
Colors is for Freeplay

You could just make your own colors in the Freeplay Menu by searching Color Picker at Google.
-Alex Director

CUSTOM STAGES:
1. Go to the "custom_stages" folder in images
2. Create a folder named whatever you want the stage to be named
3. Put the stages files in the folder
4. Open up "custom_stages.json" and put in the new stage
5. Profit

FULLY CUSTOM STAGES:
1. Do all the shit above
2. Make an hscript for the stage
3. Edit to your liking (REFER TO ANOTHER HSCRIPT IF YOU AREN'T EXPERIENCED IN HAXE!!)

TEMPLATE FOR CUSTOM STAGES:
"INSERT STAGE NAME HERE": "WHAT STAGE IS RESKIN OF HERE"


CUSTOM SONGS:
1. Go to the data folder and create a folder named whatever you want your song to be named
2. Put in the jsons for the song
3. Go to the music folder
3. Put in the Inst and Voices for the song
4. Go to "freeplaySongJson.jsonc" and put in the new song

TEMPLATE FOR CUSTOM SONGS IN FREEPLAY:

      "week" : 1
     ,"name" : "INSERT SONG NAME HERE"
     ,"character" : "INSERT CHARACTER NAME HERE"

FOR DIALOG:
1. Create a "dialog.txt" file in the songs data folder
2. Edit (refer to another dialog file for reference)
3. Set the cutscene in the debug menu for that song to "normal"
4. Profit

FOR CUSTOM RECORDS IN FREEPLAY:
1. Go to "campaign-ui-week" in images
2. Put in the record files, refer to other records for file names
3. MAKE SURE IT SAYS "week(insert number here)" AT THE START OF THE FILE NAME
4. Profit

MODCHARTS ARE SUPPORTED HOWEVER THEY HAVE TO BE AN HSCRIPT!! (no renaming the extension of a lua modchart to hscript will not work)

Look for the HScript Commands for both Modcharts & Stages in the Wiki: https://github.com/TheDrawingCoder-Gamer/Funkin/wiki/HScript-Commands
-Alex Director

CUSTOM WEEKS:
1. Go to "storySonglist.json"
2. Scroll to the bottom and put in your new week
3. Go to the "campaign-ui-week" folder in images
4. Put in the week files (Mods that use Kade Engine likely won't have this so you'll have to edit it onto an existing png)
5. Rename them to the week you are making, so for instance "week8.png" and "week8.xml"
6. Profit

TEMPLATE FOR CUSTOM WEEKS:

      "songs": ["INSERT", "SONG", "NAMES", "HERE"],
      "name": "INSERT WEEK TITLE HERE",
      "animation": "INSERT WEEK ANIMATION NAME HERE",
      "dad": "INSERT ENEMY HERE"
      "bf": "INSERT BF HERE"
      "gf": "INSERT GF HERE"
      "flags": [OPTIONAL, BUT YOU CAN USE THIS TO LOCK WEEKS. PUT IN THE WEEK NAME"


FOR CUSTOM UI CHARACTERS:
1. Go to the "campaign-ui-char" folder in images
2. Put in your characters "campaign-ui-char" files
3. Open up "custom_ui_chars.json"
4. Put in your character
5. Profit

FOR FULLY CUSTOM UI CHARACTERS:
1. Follow the above
2. Create a json with your character name
3. Edit
4. Profit

TEMPLATE FOR UI CHARACTERS:

  "INSERT CHARACTER NAME HERE": {
    "like": "INSERT WHAT THE CHARACTER IS A RESKIN OF HERE",
    "defaultGraphics": false


FOR CUSTOM CUTSCENES:
1. Create an hscript with your cutscene name
2. Edit (refer to another hscript for help)
3. Open up "cutscenes.json" and put in your cutscene
4. Profit

TEMPLATE FOR CUSTOM CUTSCENES:

"INSERT CUTSCENE NAME HERE" : "INSERT CUTSCENE HSCRIPT HERE"

If you really wanna make stuff using HScripts, Go learn it yourself.
-Alex Director

FOR CUSTOM NOTES/UI:
1. Go to "custom_ui" in the images folder, then "ui_packs"
2. Create a new folder with your UI name
3. Put in all the shit
4. Open up "ui.json" and put in your UI
5. Profit

TEMPLATE FOR UI:
   "(UI NAME)": {
        "isPixel": (TRUE OR FALSE),
        "builtInJudgement": (TRUE OR FALSE),
        "uses": "(UI FOLDER)"


FOR CUSTOM DIALOG BOXES:
1. Go to "custom_ui" yet again and then "dialog_boxes"
2. Create a new folder with your Dialog Box name
3. Put in the shit
4. Open "dialog_boxes.json" and put in your dialog box
5. Profit

TEMPLATE FOR CUSTOM DIALOG:

  "INSERT DIALOG NAME HERE": {
    "like": "INSERT WHAT DIALOG IS A RESKIN OF HERE"


FOR JUDGEMENTS:
1. Go to the "judgements" folder and create a folder with the name of your judgement
2. Put in the files (check other judgements for formats)
3. Go to data and open up "judgements.txt"
4. Put in your judgement name
5. Profit


IF YOU NEED ANY OTHER HELP JOIN THE FNF M+ DISCORD!!


-DaPootisBird