"
I register when a method event is generated, that is added, modified or removed.
I just store the signature of the method and the type of the aforementiond method event.
"
Class {
	#name : #DSMethodEventRecord,
	#superclass : #DSAbstractEventRecord,
	#instVars : [
		'methodName',
		'eventName'
	],
	#category : #'DebuggingSpy-Records'
}

{ #category : #'instance creation' }
DSMethodEventRecord class >> added: aMethod [

	^ (self for: aMethod)
		  eventName: 'Method added';
		  yourself
]

{ #category : #'instance creation' }
DSMethodEventRecord class >> modified: aMethod [

	^ (self for: aMethod)
		  eventName: 'Method modified';
		  yourself
]

{ #category : #'instance creation' }
DSMethodEventRecord class >> removed: aMethod [

	^ (self for: aMethod)
		  eventName: 'Method removed';
		  yourself
]

{ #category : #accessing }
DSMethodEventRecord >> eventName [
	^eventName
]

{ #category : #accessing }
DSMethodEventRecord >> eventName: anObject [

	eventName := anObject
]

{ #category : #accessing }
DSMethodEventRecord >> methodName [

	^ methodName
]

{ #category : #accessing }
DSMethodEventRecord >> methodName: anObject [

	methodName := anObject
]

{ #category : #'actions api' }
DSMethodEventRecord >> record: aCompiledMethod [
	methodName := aCompiledMethod name
]
