"
I am recording the MorphTab in which the user is.
"
Class {
	#name : 'DSMorphTabRecord',
	#superclass : 'DSAbstractEventRecord',
	#instVars : [
		'tabName'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSMorphTabRecord >> eventName [

	^ 'Changing in tab'
]

{ #category : 'actions api' }
DSMorphTabRecord >> record: aTabMorphSelector [

	tabName := (aTabMorphSelector submorphs select: #isSelected) first 
]
