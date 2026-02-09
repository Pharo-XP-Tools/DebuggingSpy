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

{ #category : 'instance creation' }
DSMorphTabRecord class >> for: aTabMorphSelector [

	| rec |
	rec := self new record: aTabMorphSelector.
	rec ifNotNil: [ DSRecordRegistry current addRecord: rec ].

	^ rec
]

{ #category : 'accessing' }
DSMorphTabRecord >> eventName [

	^ 'Changing in tab'
]

{ #category : 'actions api' }
DSMorphTabRecord >> record: aTabMorphSelector [

	| selectedTab |
	selectedTab := (aTabMorphSelector submorphs select: [ :morph | morph class = TabLabelMorph ]) select: #isSelected.
	selectedTab ifEmpty: [ ^ nil ].

	tabName := selectedTab first asString
]
