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
DSMorphTabRecord class >> link [ 

	^ DSMetaLink new
		  metaObject: self;
		  selector: #for:;
		  arguments: #( arguments );
		  control: #before
]

{ #category : 'accessing' }
DSMorphTabRecord >> eventName [

	^ 'Changing in tab'
]

{ #category : 'actions api' }
DSMorphTabRecord >> record: anArrayOfArguments [

	| newTabMorph |
	
	newTabMorph := anArrayOfArguments second.

	tabName := newTabMorph asString
]
