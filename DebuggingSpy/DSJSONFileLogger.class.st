"
I logs DSRecords objects into a JSON file.

The format uses for translating object into JSON is: 

```json
{ 
	""name"": ""MyObject"",
	""attributes"":
		{
			""attribute1"": my_attribute_1,
			...
			""attributeN"": my_attribute_n,
		}
}
```

where attributes can be strings, arrays, numbers, dictionaries or object represented in the same format. 
"
Class {
	#name : 'DSJSONFileLogger',
	#superclass : 'Object',
	#category : 'DebuggingSpy-Loggers',
	#package : 'DebuggingSpy',
	#tag : 'Loggers'
}

{ #category : 'utilities' }
DSJSONFileLogger class >> dictToObject: anObject [
	"Convert a JSON like object into a Pharo object"

	anObject isArray ifTrue: [ ^ anObject collect: [ :element | self dictToObject: element ] ].

	anObject isDictionary ifTrue: [
			self isJSONObject
				ifTrue: [ self translateJSONObject: anObject ]
				ifFalse: [ ^ anObject collect: [ :element | self dictToObject: element ] ] ].

	^ anObject
]

{ #category : 'utilities' }
DSJSONFileLogger class >> isJSONObject: aDictionary [

	^ aDictionary keys = { 'name'. 'attributes' }
]

{ #category : 'utilities' }
DSJSONFileLogger class >> objectToDict: anObject [
	"Converts a Pharo object into a JSON like object"

	| instanceVariableNames dict_object |
	(anObject isString or: [ anObject isNumber ]) ifTrue: [ ^ anObject ].

	(anObject isArray or: [ anObject isDictionary ]) ifTrue: [ ^ anObject collect: [ :element | self objectToDict: element ] ].

	dict_object := {
		               ('name' -> anObject class asString).
		               ('attributes' -> Dictionary new) } asDictionary.
	(instanceVariableNames := anObject class stonAllInstVarNames) isEmpty ifFalse: [
			instanceVariableNames do: [ :each |
				(dict_object at: 'attributes') at: each asString put: (self objectToDict: (anObject instVarNamed: each)) ] ].
	^ dict_object
]

{ #category : 'utilities' }
DSJSONFileLogger class >> translateJSONObject: aJSONObject [

	| new_object attributes |
	new_object := Smalltalk at: (aJSONObject at: 'name') asSymbol new.

	attributes := aJSONObject at: 'attributes'.

	attributes keysAndValuesDo: [ :instVarName :value |
			new_object class
				slotNamed: instVarName asSymbol
				ifFound: [ :slot | slot write: (self dictToObject: value) to: new_object ]
				ifNone: [ InstanceVariableNotFound signalFor: instVarName asString ] ].

	^ new_object
]
