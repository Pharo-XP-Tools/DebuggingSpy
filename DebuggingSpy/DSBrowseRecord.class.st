"
Record when a user is doing a ""Browse"" on a class, method, ...
"
Class {
	#name : 'DSBrowseRecord',
	#superclass : 'DSAbstractBrowserRecord',
	#instVars : [
		'packageBrowsed',
		'classBrowsed',
		'methodBrowsed'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSBrowseRecord >> eventName [
	^ 'Browse'
]
