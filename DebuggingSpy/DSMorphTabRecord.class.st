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
DSMorphTabRecord class >> for: anObject [

	| rec |
	rec := self new record: anObject.
	rec ifNotNil: [ DSRecordRegistry current addRecord: rec ].
	^ rec
]

{ #category : 'accessing' }
DSMorphTabRecord >> eventName [

	^ 'Changing in tab'
]

{ #category : 'actions api' }
DSMorphTabRecord >> record: aTabGroupMorph [

	| tabTool|
	
	tabTool := aTabGroupMorph submorphs first submorphs.
	tabTool isEmpty ifTrue: [ ^ nil ].

	tabName := tabTool first asString
]
