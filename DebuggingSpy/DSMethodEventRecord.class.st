"
I register when a method event is generated, that is added, modified or removed.
I just store the signature of the method.
"
Class {
	#name : 'DSMethodEventRecord',
	#superclass : 'DSAbstractEventRecord',
	#instVars : [
		'methodName',
		'methodSource'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'instance creation' }
DSMethodEventRecord class >> added: aMethod [

	^ (self for: aMethod)
		  eventName: 'Method added';
		  yourself
]

{ #category : 'instance creation' }
DSMethodEventRecord class >> modified: aMethod [

	^ (self for: aMethod)
		  eventName: 'Method modified';
		  yourself
]

{ #category : 'instance creation' }
DSMethodEventRecord class >> removed: aMethod [

	^ (self for: aMethod)
		  eventName: 'Method removed';
		  yourself
]

{ #category : 'accessing' }
DSMethodEventRecord >> methodName [

	^ methodName
]

{ #category : 'accessing' }
DSMethodEventRecord >> methodName: anObject [

	methodName := anObject
]

{ #category : 'accessing' }
DSMethodEventRecord >> methodSource [

	^ methodSource
]

{ #category : 'accessing' }
DSMethodEventRecord >> methodSource: anObject [

	methodSource := anObject
]

{ #category : 'actions api' }
DSMethodEventRecord >> record: aCompiledMethod [

	methodName := aCompiledMethod name.
	methodSource := DSSpy recordSourceCode
		                ifTrue: [ 
			                [ aCompiledMethod sourceCode ]
				                on: Error
				                do: [ :e | 
					                String streamContents: [ :s | 
						                s << 'Impossible to obtain source:'.
						                s space.
						                s << e printString ] ] ]
		                ifFalse: [ 
		                DSSpy recordSourceCodeDisabledErrorMessage ]
]
