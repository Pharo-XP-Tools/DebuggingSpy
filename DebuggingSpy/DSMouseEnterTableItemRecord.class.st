"
This record is generated when the mouse enters an item in a table.
"
Class {
	#name : #DSMouseEnterTableItemRecord,
	#superclass : #DSMouseEventRecord,
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSMouseEnterTableItemRecord >> eventName [

	^ String streamContents: [ :str |
		  str << 'Mouse on table item:'.
		  str space.
		  str << itemElement ]
]

{ #category : #testing }
DSMouseEnterTableItemRecord >> isOverTestCase [

	^ itemElement isString and: [
		  itemElement size > 4 and: [
			  (itemElement copyFrom: 1 to: 4) = 'test' ] ]
]

{ #category : #accessing }
DSMouseEnterTableItemRecord >> windowName [
	^windowId
]
