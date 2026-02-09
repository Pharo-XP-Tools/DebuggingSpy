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

	| selectedTab |

	selectedTab := ((aTabMorphSelector submorphs select: [:morph | morph class = TabLabelMorph]) select: #isSelected).
	
	tabName := selectedTab isEmpty ifTrue: [ nil ] ifFalse: [ selectedTab first asString ]
]
