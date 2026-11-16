"
I am a record indicates that a file was uploaded in Columbus.
"
Class {
	#name : 'SourceUploadedRecord',
	#superclass : 'DSAbstractColumbusRecord',
	#instVars : [
		'source_id',
		'filename'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
SourceUploadedRecord >> eventName [ 

	^ 'Source uploaded'
]
