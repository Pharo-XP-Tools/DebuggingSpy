"
I record inspections of the methods of a class in the meta pane of an inspector.
"
Class {
	#name : 'DSInspectMethodsRecord',
	#superclass : 'DSInspectorRecord',
	#instVars : [
		'selectedClass'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSInspectMethodsRecord >> eventName [
	^'Inspect methods'
]

{ #category : 'actions api' }
DSInspectMethodsRecord >> record: inspectedObjectWithSelectedClassWithWindow [

	super record: { 
			inspectedObjectWithSelectedClassWithWindow first.
			inspectedObjectWithSelectedClassWithWindow last }.
	selectedClass := inspectedObjectWithSelectedClassWithWindow second name
]

{ #category : 'accessing' }
DSInspectMethodsRecord >> selectedClass [

	^ selectedClass
]

{ #category : 'accessing' }
DSInspectMethodsRecord >> selectedClass: anObject [

	selectedClass := anObject
]
