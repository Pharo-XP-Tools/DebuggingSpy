"
I am representing a DSSpy record, which associates a color to be displayed.
"
Class {
	#name : 'DSColoredRecord',
	#superclass : 'Object',
	#instVars : [
		'record',
		'color'
	],
	#category : 'DebuggingSpy-Browser',
	#package : 'DebuggingSpy-Browser'
}

{ #category : 'initialization' }
DSColoredRecord class >> for: aRecord withColor: aColor [

	^ self new
		  record: aRecord;
		  color: aColor;
		  yourself
]

{ #category : 'accessing' }
DSColoredRecord >> color [

	^ color
]

{ #category : 'accessing' }
DSColoredRecord >> color: aColor [

	color := aColor
]

{ #category : 'accessing' }
DSColoredRecord >> record [

	^ record
]

{ #category : 'accessing' }
DSColoredRecord >> record: aRecord [

	record := aRecord
]
