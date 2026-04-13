Extension { #name : 'DSToolInfo' }

{ #category : '*DebuggingSpy-Anonymizer' }
DSToolInfo >> anonymize [
	"Self applies the anonymous filter and returns the anonymous record."

	^ self class anonymousFilter applyOn: self
]

{ #category : '*DebuggingSpy-Anonymizer' }
DSToolInfo class >> anonymousFilter [
	"Returns the data filter that anonymizes the ToolInfo."

	^ DSRecordDataFilter new
		  with: #toolIdentityHash;
		  with: #windowIdentityHash;
		  transform: #toolClass with: [ :toolClass |
				  (SystemBuildInfo current systemPackages includes: toolClass package)
					  ifTrue: [ toolClass ]
					  ifFalse: [ toolClass identityHash ] ];
		  yourself
]
