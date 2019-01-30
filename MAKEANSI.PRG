***********************************************************
* MakeANSI.PRG - create file of ANSI escape codes from a
*                saved screen .MEM file
*
* A .MEM file stores a screen image as a 4000 character string.
*
* The odd-numbered bytes (1,3,5,7...) are the screen characters,
* from the top left corner, left to right, down the screen.
*
* The even byte (2,4,6,8...) following it is the color
* code for that screen character using the following scheme:
*
* mColorAttr has Bits  8--7--6--5--4--3--2--1
* Bit 8      - Blink Attribute 1 = Yes, 0 = No
* Bits 7,6,5 - Color of background, 0 to 7 (see table below)
* Bit 4      - Intensity Attribute 1 = Yes, 0 = No
* Bits 3,2,1 - Color of foreground, 0 to 7 (see table below)
*
****************** Popup Startup Screen *******************
if file("MAKEANSI.MEM") 
   restore from makeansi.mem additive
   restore screen from mScreen
   release mScreen
else
   clear
endif

*************************  SETUP  *************************
set talk off
private mOldColor, mCharacter, mESCape, mPrompt, Read_File
private Read_Handle, Read_Size, Read_Point, Read_String
private Write_File, Write_Handle
mOldColor = 0
mESCape = chr(27)
* These are the ANSI Escape color codes *
dimension mANSIf(8)   && ANSI (f)oreground color
          mANSIf(1) = '30'
          mANSIf(2) = '34'
          mANSIf(3) = '32'
          mANSIf(4) = '36'
          mANSIf(5) = '31'
          mANSIf(6) = '35'
          mANSIf(7) = '33'
          mANSIf(8) = '37'
dimension mANSIb(8)   && ANSI (b)ackground color
          mANSIb(1) = '40'
          mANSIb(2) = '44'
          mANSIb(3) = '42'
          mANSIb(4) = '46'
          mANSIb(5) = '41'
          mANSIb(6) = '45'
          mANSIb(7) = '43'
          mANSIb(8) = '47'
dimension mBits(8)  && Array holds bit values of color byte
          mBits = 0
*********************  SPECIFY I/O  ***********************
wait window "Click to start"

mPrompt = 'Where is the saved screen .MEM file?'
Read_File = GetFile("MEM",mPrompt)
if empty(Read_File)
   return
endif

mPrompt = 'Select output ANSI text file'
Write_File = PutFile(mPrompt,'Output.TXT','TXT')
if empty(Write_File)
   return
endif

*************************  READ  **************************
Read_Handle = FOPEN(Read_file,0)
if Read_Handle<=0
   WAIT WINDOW "Error opening file. Aborting" NoWait
   return
endif

* Move to EOF to determine file size
Read_Size = FSEEK(Read_Handle, 0, 2)
IF Read_Size <= 4032 && Is File too small?
   mPrompt = 'This file does not contain a screen image.'
   WAIT WINDOW mPrompt NOWAIT
    = FCLOSE(Read_Handle) && Close the file
    return
endif

* Move to BOF + 32 and store contents to string
Read_Point = FSEEK(Read_Handle,32, 0)
Read_String = FREAD(Read_Handle, Read_Size-33)
if not FCLOSE(Read_Handle) && Close the file
   do ErrorChk
   return
endif

************************  WRITE ***************************
Write_Handle = FCREATE(Write_File)
if ErrorChk()
   return
endif

* Home the cursor and clear the screen
if FWRITE(Write_Handle,mESCape+"[2J") = 0
   do ErrorChk
   return
endif

clear
for x=1 to len(Read_string)-2 step 2
   mCharacter = substr(Read_String,x,1)
   mColorAttr = asc(substr(Read_String,x+1,1))
   if mColorAttr # mOldColor  && recalculate only if
      mOldColor = mColorAttr  && the color has changed
      =BitSplit(mColorAttr,@mBits)
      mBlink = iif(mBits(8)=1,"5;","")
      mBackColor = mAnsib(4*mBits(7)+2*mBits(6)+mBits(5)+1)
      mIntense = iif(mBits(4)=1,"1;","")
      mForeColor = mAnsif(4*mBits(3)+2*mBits(2)+mBits(1)+1)
      ANSIString = mESCape+"["+"0;"+mIntense+mBlink+;
                   mForeColor+";"+mBackColor+"m"
      * send the ANSI color string
      if FWRITE(Write_Handle,ANSIString) = 0
         do ErrorChk
         return
      endif  
   endif
   ?? mCharacter  && display on screen to entertain
   if FWRITE(Write_Handle,mCharacter) = 0
      do ErrorChk
      return
   endif
next

* Home the cursor and reset the color
if FWRITE(Write_Handle,mESCape+"[0;0H"+mESCape+"[0m") = 0
   do ErrorChk
   return
endif
if not FCLOSE(Write_Handle)
   do ErrorChk
   return
endif

return

Procedure BitSplit
parameters mParam, mBitArray   && the character to take apart
external array mBitArray      && Avoids a BUILD APP error
private mNum                  && Temporary scratch number 
private mExp                  && Exponent, Array Pointer

mNum = mParam
for mExp = 7 to 0 step -1
   if mNum >=2^mExp
      mBitArray(mExp+1) = 1
      mNum = mNum - 2^mExp
   else
      mBitArray(mExp+1) = 0
   endif
next
return

Function ErrorChk
if FERROR() # 0
   close all
   DEFINE WINDOW alert FROM 7,17 TO 12,60 DOUBLE COLOR SCHEME 7
   DO CASE
      CASE FERROR() = 2
         reason = 'File not found'
      CASE FERROR() = 4
         reason = 'Too many files open (out of handles)'
      CASE FERROR() = 5
         reason = 'Access denied'
      CASE FERROR() = 6
         reason = 'Invalid file handle'
      CASE FERROR() = 8
         reason = 'Out of memory'
      CASE FERROR() = 25
         reason = 'Seek error - BOF encountered'
      CASE FERROR() = 29
         reason = 'Disk full'
      CASE FERROR() = 31
         reason = 'General failure'
      OTHERWISE
         reason = 'Unrecognized error code '+Ltrim(Str(FERROR()))
   ENDCASE

   ACTIVATE WINDOW alert
   @ 1,7 SAY 'Unable to open file'
   @ 2,7 SAY 'Reason: ' + reason
   @ 3,7 SAY 'Press a key to exit'
   set cursor off
   wait ""
   DEACTIVATE WINDOW alert
   CANCEL
endif
return FERROR() # 0  && can use as function() and procedure
