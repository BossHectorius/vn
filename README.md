# INTRODUCTION

###  This is a project where I try to figure out how to make a language scripting system in godot for a dialogue/visual novel system. Huge shoutout to GDQuest and Dialogic (most things here are based off of their code)

#  TO DO

Turn it into a godot plugin with maybe syntax correction (unnecessary, but I will try nonetheless) or something to make editing the .txt files a bit less tedious


#  CURRENT COMMANDS

###  (EVERYTHING IN BRACKETS IS OPTIONAL AND DOES NOT HAVE A SET ORDER)

##  Character
Displays a character on the screen.
### Syntax
It's written as: chara (character_id)[side][expression][animation]
###  Parameters
####  Sides: 
left, right, center
####  Default expressions: 
neutral, angry, sad, happy
####  Default animations: 
enter, leave


## Dialogue
Displays text and a speaker name.
###  Syntax
It's written as [character name. If it matches an id, it will show the Display_Name attached to that id. Else, it'll just display the name written] + "[dialogue. Must be in quotes]"
### Text effects
All of those available through BBCode plus some custom effects.
### Custom effects
They must be written between brackets and inside dialogue

#### Speed
Written as [speed = (number)]. Changes the time it takes to show a character (in seconds)

#### Pause
Written as [pause = (number)] pauses the reveal of the text (in seconds)

#### Speed multiplier
Written as [mspeed = (number)] multiplies the reveal speed by (number)

#### Slow
Written as [slow]. Halves the reveal speed

#### Fast
Written as [fast]. Multiplies the speed by 50%

## Background
Displays a background.
###  Syntax
Written as: background (background_id) [animation]
### Animations
#### Fade in
Written as fade_in
#### Fade out
Written as fade_out

## Jumps
Jumps the dialogue to a specified jump point.
To set a jump point, you must first do 'mark (point name)'
### Syntax
It's written as 'jump (point name)'

## Wait commands
### Syntax
There are two types of wait commands:
#### Wait input
Written as wait_input. Will pause everything until an input is detected.
#### Wait animation
Written as wait_anim. Will wait until an animation is finished.

## Choices
### Syntax
Written as 'choice:' followed by the names of each choice with indents. For example:
Choice:
  Choice1:
    contents1
  Choice2:
    contents2
  Choice3:
    contents3
