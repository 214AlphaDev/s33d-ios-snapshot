deps:
	rm -rf ~/Library/Developer/Xcode/DerivedData/frontend-*
	xcodegen
	pod install
