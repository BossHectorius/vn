# INTRODUCTION

###  This is a project where I try to figure out how to make a language scripting system in godot for a dialogue/visual novel system. It's very easily modifiable, so it's quite flexible. Huge shoutout to GDQuest and Dialogic (most things here are based off of their code)

#  CURRENT COMMANDS:

###  (EVERYTHING IN BRACKETS IS OPTIONAL AND DOESN'T HAVE A SET ORDER)

##  Character:
### Syntax
It's written as: chara [character_id][side][expression][animation]
###  Parameters
####  Sides: 
left, right, center
####  Default expressions: 
neutral, angry, sad, happy
####  Default animations: 
enter, leave


## Dialogue:
###  Syntax
It's written as [character name. If it matches an id, it will show the Display_Name attached to that id. Else, it'll just display the name written] + "[dialogue. Must be in quotes]"
### Text effects
All of those available through BBCode plus slower typing speed, written as: [slow] dialogue [/slow]
(the effects must be inside the quotes too)

## Background:
###  Syntax
Written as: background [background_id] [animation]
### Animations
Yet to be implemented
