"
I record the inspection of an inspected object's attribute
"
Class {
	#name : #DSInspectAttributeRecord,
	#superclass : #DSInspectorRecord,
	#instVars : [
		'attributeName',
		'attributeValue',
		'attributeHash'
	],
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSInspectAttributeRecord >> attributeHash [

	^ attributeHash
]

{ #category : #accessing }
DSInspectAttributeRecord >> attributeHash: anObject [

	attributeHash := anObject
]

{ #category : #accessing }
DSInspectAttributeRecord >> attributeName [

	^ attributeName
]

{ #category : #accessing }
DSInspectAttributeRecord >> attributeName: anObject [

	attributeName := anObject
]

{ #category : #accessing }
DSInspectAttributeRecord >> attributeValue [

	^ attributeValue
]

{ #category : #accessing }
DSInspectAttributeRecord >> attributeValue: anObject [

	attributeValue := anObject
]

{ #category : #accessing }
DSInspectAttributeRecord >> eventName [
	^'Inspect object'
]

{ #category : #'actions - api' }
DSInspectAttributeRecord >> record: aFTTableItem [
	super record: {aFTTableItem data hostObject.  aFTTableItem dataSource model window}.
	attributeName := aFTTableItem data key.
	attributeValue := aFTTableItem data stringValue.
	attributeHash := aFTTableItem data value hash
]
