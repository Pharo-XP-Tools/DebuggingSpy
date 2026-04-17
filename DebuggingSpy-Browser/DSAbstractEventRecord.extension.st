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

{ #category : '*DebuggingSpy-Browser' }
DSAbstractEventRecord >> printAsFormattedTime [
	"Returns the specified date and time as a string of format hh:mm:ss.nnnnnnnnn"

	^ (String new: 18 streamContents: [ :aStream | dateTime asTime print24: true showSeconds: true on: aStream ]) asText allBold
]

{ #category : '*DebuggingSpy-Browser' }
DSAbstractEventRecord >> type [
	"Returns the record's type to be displayed in the windows presenter."

	^ self class name
]

{ #category : '*DebuggingSpy-Browser' }
DSAbstractEventRecord >> window [
	"Returns the record's window from the browser selected history."

	^ DSRecordBrowserPresenter uniqueInstance getWindowFromRecord: self
]

{ #category : '*DebuggingSpy-Browser' }
DSAbstractEventRecord >> windowColor [
	"Returns the record's window color."

	^ self window windowColor
]
