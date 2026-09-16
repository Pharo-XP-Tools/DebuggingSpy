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
DSSTONFileLogger class >> materialize: aFilename [

	^ STON fromString: aFilename asFileReference contents
]
