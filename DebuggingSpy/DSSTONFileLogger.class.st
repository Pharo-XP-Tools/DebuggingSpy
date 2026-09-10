"
I log DSRecords as STON into files.
"
Class {
	#name : 'DSSTONFileLogger',
	#superclass : 'DSFileLogger',
	#instVars : [
		'loggingDirectory',
		'loggingFilename',
		'loggingFileReference',
		'savedConfiguration'
	],
	#category : 'DebuggingSpy-Loggers',
	#package : 'DebuggingSpy',
	#tag : 'Loggers'
}

{ #category : 'logging' }
DSSTONFileLogger class >> log: aDSEventRecord [

	self writeToFile: (STON toString: aDSEventRecord)
]

{ #category : 'logging' }
DSSTONFileLogger class >> writeToFile: aString [

	| str strSize firstWrite writingPosition |
	str := self stream.
	strSize := str writeStreamSize.
	firstWrite := strSize = 0.
	firstWrite ifTrue: [ str nextPut: $[ ].
	writingPosition := firstWrite
		                   ifTrue: [ str position ]
		                   ifFalse: [ strSize - 1 ].
	str position: writingPosition.
	firstWrite ifFalse: [
			str nextPut: $,.
			str crlf ].
	str nextPutAll: aString.
	str nextPut: $].
	str close
]
