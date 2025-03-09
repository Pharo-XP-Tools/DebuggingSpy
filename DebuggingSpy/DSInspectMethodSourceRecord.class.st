"
I record inspections of the source of a method in the meta pane of an inspector
"
Class {
	#name : 'DSInspectMethodSourceRecord',
	#superclass : 'DSInspectMethodsRecord',
	#instVars : [
		'selectedMethod'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'actions api' }
DSInspectMethodSourceRecord >> record: inspectedObjectWithSelectedClassWithSelectedMethodWithWindow [

	super record: { 
			inspectedObjectWithSelectedClassWithSelectedMethodWithWindow first.
			inspectedObjectWithSelectedClassWithSelectedMethodWithWindow second.
			inspectedObjectWithSelectedClassWithSelectedMethodWithWindow last }.
	selectedMethod := inspectedObjectWithSelectedClassWithSelectedMethodWithWindow third name
]

{ #category : 'accessing' }
DSInspectMethodSourceRecord >> selectedMethod [

	^ selectedMethod
]

{ #category : 'accessing' }
DSInspectMethodSourceRecord >> selectedMethod: anObject [

	selectedMethod := anObject
]
