`Exports all tables of the database into a .txt CSV file (tab-separated and line feed)
`Each table is saved in a separate file named after the table + .txt
C_LONGINT($tableCount;$tableNumber;$fieldCount;$i;$j;$Ref)
C_POINTER($fieldPtr)
ARRAY TEXT($fieldNames;0)
C_TEXT($filePath;$fileName;$line;$fieldValue)
C_TIME($fileRef)

` Get the destination folder
$folderPath:=Select folder("Choose a folder to save the files:")

If (OK=1)
	` Get the number of tables
	$tableCount:=Count tables
	TRACE
	` Loop through all tables
	$Ref:=Open window(50;50;500;250;5;"Operation in Progress")
	
	For ($tableNumber;1;$tableCount)
		` Select the current table
		$fileName:=Table name($tableNumber)+".txt"  ` File name: {table name}.txt
		$filePath:=$folderPath+$fileName
		$tablePtr:=Table($tableNumber)
		` Create the file
		If (Test path name($filePath)=Is a document )
			DELETE DOCUMENT($filePath)
		End if 
		$fileRef:=Create document($filePath)
		
		If (OK=1)
			` Get the fields of the table
			$fieldCount:=Count fields(Table($tableNumber))
			ARRAY TEXT($fieldNames;$fieldCount)
			
			For ($i;1;$fieldCount)
				$fieldNames{$i}:=Field name($tableNumber;$i)
			End for 
			
			` Write headers to the file
			$line:=""
			For ($i;1;$fieldCount)
				$line:=$line+$fieldNames{$i}
				If ($i<$fieldCount)
					$line:=$line+Char(Tab )  ` Add a tab between columns
				End if 
			End for 
			$line:=$line+Char(Line feed )  ` Add a line feed
			
			SEND PACKET($fileRef;$line)
			
			` Loop through records of the table
			ALL RECORDS($tablePtr->)
			FIRST RECORD($tablePtr->)
			
			While (Not(End selection($tablePtr->)))
				GOTO XY(0;0)
				MESSAGE("Exporting table "+Table name($tableNumber)+" : "+String(Selected record number($tablePtr->))+"/"+String(Records in selection($tablePtr->)))  ` Do Something with the record
				$line:=""
				For ($j;1;$fieldCount)
					$fieldPtr:=Field(Table($tablePtr);$j)
					
					` Determine field value based on its type
					Case of 
						: (Type($fieldPtr->)=Is Alpha Field )  ` Text field
							$fieldValue:=$fieldPtr->
						: (Type($fieldPtr->)=Is String Var )  ` Text field
							$fieldValue:=$fieldPtr->
						: (Type($fieldPtr->)=Is Text )  ` Text field
							$fieldValue:=$fieldPtr->
						: (Type($fieldPtr->)=Is Integer )  ` Numeric field
							$fieldValue:=String($fieldPtr->)
						: (Type($fieldPtr->)=Is LongInt )  ` Numeric field
							$fieldValue:=String($fieldPtr->)
						: (Type($fieldPtr->)=Is Real )  ` Numeric field
							$fieldValue:=String($fieldPtr->)
						: (Type($fieldPtr->)=Is Date )  ` Date field
							$fieldValue:=String($fieldPtr->)
						: (Type($fieldPtr->)=Is Time )  ` Time field
							$fieldValue:=String($fieldPtr->)
						: (Type($fieldPtr->)=Is Boolean )  ` Boolean field
							If ($fieldPtr->)
								$fieldValue:="1"
							Else 
								$fieldValue:="0"
							End if 
						Else   ` Other unsupported types
							$fieldValue:=""
					End case 
					
					$fieldValue:=Replace string($fieldValue;Char(13);"{linefeed}")
					$fieldValue:=Replace string($fieldValue;Char(Line feed );"{linefeed}")
					
					` Add value to line, separated by tabs
					$line:=$line+$fieldValue
					If ($j<$fieldCount)
						$line:=$line+Char(Tab )
					End if 
				End for 
				
				` Add line feed at the end of the record
				$line:=$line+Char(Line feed )
				SEND PACKET($fileRef;$line)
				
				` Move to next record
				NEXT RECORD($tablePtr->)
			End while 
			
			` Close the file
			CLOSE DOCUMENT($fileRef)
			ERASE WINDOW($Ref)
			`ALERT("Exported table: "+Table name($tableNumber))
		Else 
			ALERT("Unable to create file for table: "+Table name($tableNumber))
		End if 
	End for 
	CLOSE WINDOW
	
	ALERT("Export completed for all tables.")
Else 
	ALERT("Export canceled.")
End if 
