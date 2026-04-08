Extension { #name : 'DSAbstractEventRecord' }

{ #category : '*DebuggingSpy-Browser' }
DSAbstractEventRecord >> formattedEventName [
	"Returns the event name followed by the tool class, if applicable."

	| toolInfo formattedEventName |
	formattedEventName := self eventName.

	(self class hasSlotNamed: 'toolInfo') ifTrue: [
			toolInfo := self readSlotNamed: 'toolInfo'.
			toolInfo ifNotNil: [ formattedEventName := formattedEventName , ' (' , toolInfo toolClassName asString , ')' ] ].

	^ formattedEventName
]

{ #category : '*DebuggingSpy-Browser' }
DSAbstractEventRecord class >> getLeafSubClasses [
	"Returns a list of all non-abstract subclasses, representing all record classes."

	| classes |
	classes := OrderedCollection new.
	self subclasses do: [ :subclass |
			subclass subclasses isEmpty
				ifTrue: [ classes add: subclass ]
				ifFalse: [
						subclass = DSDoItRecord ifTrue: [ classes add: subclass ].
						classes addAll: subclass getLeafSubClasses ] ].

	^ classes
]
