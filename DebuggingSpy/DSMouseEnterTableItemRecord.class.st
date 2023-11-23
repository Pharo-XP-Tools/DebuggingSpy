"
This record is generated when the mouse enters an item in a table.
"
Class {
	#name : 'DSMouseEnterTableItemRecord',
	#superclass : 'DSMouseEventRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSMouseEnterTableItemRecord >> eventName [
	^'Mouse on table item'
]
