"
I record the inspection of an inspected object's attribute
"
Class {
	#name : 'DSInspectAttributeRecord',
	#superclass : 'DSInspectorRecord',
	#instVars : [
		'attributeName',
		'attributeValue',
		'attributeHash'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSInspectAttributeRecord >> attributeHash [

	^ attributeHash
]

{ #category : 'accessing' }
DSInspectAttributeRecord >> attributeHash: anObject [

	attributeHash := anObject
]

{ #category : 'accessing' }
DSInspectAttributeRecord >> attributeName [

	^ attributeName
]

{ #category : 'accessing' }
DSInspectAttributeRecord >> attributeName: anObject [

	attributeName := anObject
]

{ #category : 'accessing' }
DSInspectAttributeRecord >> attributeValue [

	^ attributeValue
]

{ #category : 'accessing' }
DSInspectAttributeRecord >> attributeValue: anObject [

	attributeValue := anObject
]

{ #category : 'accessing' }
DSInspectAttributeRecord >> eventName [
	^'Inspect object'
]

{ #category : 'actions api' }
DSInspectAttributeRecord >> record: inspectorNodeWithInspectedObjectWithWindow [

	| inspectorNode window |
	inspectorNode := inspectorNodeWithInspectedObjectWithWindow first.
	inspectedObject := inspectorNodeWithInspectedObjectWithWindow second.
	window := inspectorNodeWithInspectedObjectWithWindow third.
	super record: { 
			inspectedObject.
			window }.
	attributeName := inspectorNode key.
	attributeValue := inspectorNode stringValue.
	attributeHash := inspectorNode value identityHash
]
