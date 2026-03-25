"
I am recording events linked to scrolling.
"
Class {
	#name : 'DSScrollingRecord',
	#superclass : 'DSAbstractEventRecord',
	#instVars : [
		'toolName'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSScrollingRecord >> eventName [
	^ 'Scrolling'
]

{ #category : 'actions api' }
DSScrollingRecord >> record: aMorph [

	toolName := aMorph asString.
	super record: aMorph window
]
