#Requires AutoHotkey v1.1

exploringObjectIdentity() {
    OutputDebug, % "`nexploringObjectIdentity()`n"

    DID := 6
    saved := new pivotInfo(DID, 500)
    saved2 := new pivotInfo(DID, 500)
    testObject := getCurrentPivotInfo(saved, {}, DID) ; as didPivotNow == saved.did, we should get the saved obj
    if (saved == testObject) {
        OutputDebug, % "successful: retrieval of the object with the same address`n"
    }

    if (saved != saved2 and testObject != saved2) {
        OutputDebug, % "successful: two class instances created with the new keyword are seen as different.`n"
    }
    OutputDebug, % "Test finished.`n`n"
    return
}