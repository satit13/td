 CLOSE ALL
 CLEAR ALL
 SET DATE TO BRIT
 SET CENTURY ON
 SET NEAR ON
 SET EXCLUSIVE OFF
 SET SAFETY OFF
 SET CPDIALOG OFF
 SET DELETED ON
 SET MULTILOCKS ON
 ON ERROR 
 SET CONSOLE ON
 LCLASTSETTALK = SET('TALK')
 SET TALK OFF
 DO setdefault_dir
*  SET DEFAULT TO c:\work\cash_diary
 CSTARTPATH =FULLPATH(CURDIR())
* LCTXTFILE = 'CASH.INI'
 PUBLIC dbconn,DEFAULT_DIR ,DB,d1,d2,lcODBC,A
* lcODBC=CGET(LCTXTFILE,1)
 
*MESSAGEBOX(lcodbc)
*DB=CGET(LCTXTFILE,2)
* CD (CSTARTPATH)
*SET DEFAULT TO (CSTARTPATH)
*DEFAULT_DIR = CSTARTPATH
PUBLIC dbconn
STORE 0 TO dbconn
*A=sqlconnect(lcODBC)
DO FORM login TO flageLogin 
IF flageLogin  =1
	DO FORM berk NAME berk 
	READ EVENTS 
ELSE 
	MESSAGEBOX('Cannot connect to database ',16,'Error  connect data!')
ENDIF 
 SET SYSMENU TO DEFAULT

  set talk &lcLastSetTalk
  set path to &lcLastSetPath
*----------------------------------------------------------------*
PROCEDURE cGet
 PARAMETER CFILE , NNUM
 LOCAL _PATH
 _PATH = ''
 *CD (CSTARTPATH)
 IF FILE(CFILE)
    SETUPFILE = FOPEN(CFILE,0)
    IF SETUPFILE < 0
        MESSAGEBOX('!�������ö�Դ���  ' + FULLPATH(CURDIR()) + 'setup.txt file...',16,'Unable to Open file ' + CFILE)
    ELSE 
       STORE FSEEK(SETUPFILE,0,2) TO GNEND
       STORE FSEEK(SETUPFILE,0) TO GNTOP
       NCOUNT = 1
       DO WHILE NCOUNT <= NNUM
          A = FGETS(SETUPFILE)
          NCOUNT = NCOUNT + 1
       ENDDO 
       _PATH = SUBSTR(A,AT('=',A) + 1,LEN(ALLTRIM(A)) - AT('=',A))
    ENDIF 
    = FCLOSE(SETUPFILE)
    RETURN _PATH
 ELSE 
     MESSAGEBOX('����� ' +CFILE+ CHR(13) + CHR(13) +  ;
   'Program being Cancel...!',16,'Error File Does not Exist .....')
    CANCEL 
    RETURN .F.
 ENDIF 
ENDPROC
*------*

PROCEDURE setdefault_dir
	LOCAL lcsys16,lcprogram,lcpath,lcolddir
	lcsys16=SYS(16,1)
	lcolddir=(SYS(5)+CURDIR())
	lcprogram = SUBSTR(lcsys16,AT(":",lcsys16)-1)
	CD LEFT(lcprogram,RAT("\",lcprogram))
	 SET DEFAULT TO (LEFT(lcprogram,RAT("\",lcprogram)))
	 DEFAULT_DIR = LEFT(lcprogram,RAT("\",lcprogram))
	 
 
ENDPROC 


PROCEDURE errhand
   = AERROR(aErrorArray)  && Data from most recent error
   MESSAGEBOX(aErrorArray(n))
ENDPROC 