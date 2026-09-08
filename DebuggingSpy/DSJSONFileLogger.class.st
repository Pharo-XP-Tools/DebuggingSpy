"
I logs DSRecords objects into a JSON file.
"
Class {
	#name : 'DSJSONFileLogger',
	#superclass : 'Object',
	#category : 'DebuggingSpy-Loggers',
	#package : 'DebuggingSpy',
	#tag : 'Loggers'
}

{ #category : 'utilities' }
DSJSONFileLogger class >> dictToObject: aDictionary [

	| instanceVariables new_object |
	
	new_object := Smalltalk at: (aDictionary at: 'name') asSymbol new. 
	
	instanceVariables := aDictionary at: 'attributes'.
	
]

{ #category : 'utilities' }
DSJSONFileLogger class >> objectToDict: anObject [

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
