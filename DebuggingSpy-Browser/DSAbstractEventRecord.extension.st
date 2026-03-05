Extension { #name : 'DSAbstractEventRecord' }

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
