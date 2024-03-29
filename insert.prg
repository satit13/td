
Procedure trf_bcstkissue
	Select bcstkissue
	result=SQLEXEC(dbconn,"SET IDENTITY_INSERT "+Alias()+" OFF")
	Go Top
	Do While !Eof()
		Wait Window Alltrim(Str(Recno())) Nowa
		Do Insertdata
		Skip
	Enddo

Endproc
*********************************
Procedure trf_bcstkissuesub
	* run fix itemname data for ' in name of transaction Replace with ''

	Select bcstkissuesub
	result=SQLEXEC(dbconn,"SET IDENTITY_INSERT "+Alias()+" OFF ")
	Go Top
	lcdocno = ALLTRIM(bcstkissuesub.docno)
	Do While !Eof()
		Wait Window Alltrim(Str(Recno())) Nowa
		Do Insertdata
		Skip
	ENDDO

*** Calculate stock amount ***
 
	 lccommand = "insert into processstock (itemcode,processflag,flowstatus,processtype,processcase) "
	 lccommand = lccommand + " select distinct itemcode , 1,0,0,0 from bcstkissuesub where docno ='"+lcdocno+"'"
	 result = SQLEXEC(dbconn,lccommand)
	 IF result <0 	
	 	DO ErrHand
	 ELSE 
	 	calitem = 1 
	 	lnLoopCount = 0
	 	DO WHILE  calitem >0 AND lnLoopcount <=10
	 		lccommand = "select COUNT(itemcode) as itemcount from processstock where itemcode in (select itemcode from bcstkissuesub where docno = ' "+lcdocno+"')"
	 		*MESSAGEBOX(lccommand)
	 		=SQLEXEC(dbconn,lccommand,'countprocessstock')
	 		SELECT countprocessstock
	 		calitem = countprocessstock.itemcount
	 		WAIT WINDOW 'Check Calculate item Loop : '+ALLTRIM(STR(lnLoopcount))  TIMEOUT 0.5
	 		lnLoopCount = lnLoopCount+1 
	 	ENDDO 	
	 	DO printbc WITH lcdocno 
	 ENDIF 

Endproc
***************************************************
Procedure Insertdata
	Wait Window Alias()+'.'+Alltrim(Str(Recno())) Nowa
	nfield=Fcount()
	lccommand="set dateformat dmy insert "+Alltrim(Alias())+" ("
	lFiled =""
	For initEnv = 1 To nfield
		IF UPPER(ALLTRIM(Fields(initEnv))) != 'ROWORDER'
			lFiled=lFiled+Iif(Len(Alltrim(lFiled))=0,'',',')+Fields(initEnv)
		ENDIF
	Endfor
	lccommand=lccommand+lFiled+" )"
	lccommand = lccommand+" values ("
	lFiled=''
	NextChar=''
	For initEnv = 1 To nfield
		Cflage=0
		Tflage=0
		NFlage=0
		MFlage=0
		IF UPPER(ALLTRIM(Fields(initEnv))) != 'ROWORDER'
			Do Case
			Case Type(Fields(initEnv)) = 'N'Or Type(Fields(initEnv)) = 'Y'   && Numeric or money
				lcx="Nextchar=ALLTRIM(STR("+Fields(initEnv)+",15,2))"
				Cflage=0
				Tflage=0
				NFlage=1
			Case Type(Fields(initEnv)) = 'C' Or Type(Fields(initEnv)) = 'M'    && Char or Memo field
				
				lcx="Nextchar=ALLTRIM("+Fields(initEnv)+")"
				Cflage=1
				Tflage=0
				NFlage=0
			Case Type(Fields(initEnv)) = 'T'      && Datetime field
				lcx="Nextchar=DTOC(TTOD("+Fields(initEnv)+"))"
				Cflage=0
				Tflage=1
				NFlage=0
			Case Type(Fields(initEnv)) = 'D'      && Datetime field
				lcx="Nextchar=DTOC("+Fields(initEnv)+")"
				Cflage=0
				Tflage=1
				NFlage=0
		Endcase
			&lcx
			&& ��ͧ field ����� char ������ѡ�� '  ����� field ����� insert date Error �͡仡�͹
			IF !ISNULL(nextchar)  
				
					IF ("'"$nextchar)
						xnextchar=''
						FOR i = 1 TO LEN(ALLTRIM(nextchar))
							IF SUBSTR(nextchar,i,1)="'"
								xnextchar=xnextchar+' ' 
							ELSE 
								xnextchar=xnextchar+SUBSTR(nextchar,i,1)
							ENDIF 
						ENDFOR 
						*MESSAGEBOX( 'old : '+nextchar+CHR(13)+'New : '+xnextchar)

						nextchar=xnextchar
					ENDIF 
		
			ENDIF 
			
			Do Case
			Case Cflage=1
				If Isnull(NextChar)
					NextChar=''
				Endif
				lFiled=lFiled+"'"+NextChar+"'"
			Case NFlage=1
				If Isnull(NextChar)
					NextChar='0'
				Endif
				lFiled=lFiled+NextChar
			Case Tflage=1
				If Isnull(NextChar)
					NextChar='01/01/1900'
				Endif
				lFiled=lFiled+"'"+NextChar+"'"
			Endcase
			If initEnv < nfield
				lFiled=lFiled+","
			ENDIF
		ENDIF 
	Endfor
	lccommand=lccommand+lFiled+" )"
	*MESSAGEBOX(lccommand)
	*cancel
	result=SQLEXEC(dbconn,lccommand)
	IF result < 0 
		DO errhand
	ENDIF 

	Return .T.
Endproc
********************************
Procedure errhand
= Aerror(aErrorArray)  && Data from most recent error
MESSAGEBOX(aErrorArray(2))
MESSAGEBOX(lccommand)
Return aErrorArray(2)
Endproc

*********************************

PROCEDURE  printbc
PARAMETERS lcdocno 



	 lccommand = "select a.DocNo,a.DocDate,a.ItemCode,a.WHCode,a.ShelfCode,a.Qty,a.UnitCode,a.SUMOFCOST,a.Personcode,"
	 lccommand = lccommand + "b.Name1 as itemname,c.Name as personname,e.MyDescription,d.Name as projectname ,f.name as unitname,A.PROJECTCODE "
	 lccommand = lccommand + "from BCStkIssuesub a left join bcitem b on a.ItemCode=b.Code "
	 lccommand = lccommand + "left join BCSale c on a.Personcode=c.code "
	 lccommand = lccommand + "left join BCProject d on a.ProjectCode=d.Code "
	 lccommand = lccommand + "left join BCStkIssue e on a.DocNo = e.DocNo " 
	 lccommand = lccommand + "left join bcitemunit f on a.unitcode=f.code "
	 lccommand = lccommand + "where a.docno = '"+lcdocno+"'"
	 
	 SET TALK OFF 
	 SET CONSOLE OFF 
	 result = SQLEXEC(dbconn,lccommand,"bcstkissuesub_BC")
	 IF result <0 
	 	 DO errhand
	 ELSE 
	 	SELECT bcstkissuesub_bc
	 	IF MESSAGEBOX('Print out to printer ? ',36,'Output ')=6
	 		REPORT FORM bcform TO PRINTER PROMPT  
		ELSE 
			REPORT FORM bcform PREVIEW 
		ENDIF 
	 	
	 	
	 ENDIF 

ENDPROC 


*****************

Procedure trf_bcapinvoice
	Select bcapinvoice
	result=SQLEXEC(dbconn,"SET IDENTITY_INSERT "+Alias()+" OFF")
	Go Top
	Do While !Eof()
		Wait Window Alltrim(Str(Recno())) Nowa
		Do Insertdata
		Skip
	Enddo

ENDPROC

*****************

Procedure trf_bcpaymoney
	Select bcpaymoney
	result=SQLEXEC(dbconn,"SET IDENTITY_INSERT "+Alias()+" OFF")
	Go Top
	Do While !Eof()
		Wait Window Alltrim(Str(Recno())) Nowa
		Do Insertdata
		Skip
	Enddo

Endproc
*********************************
Procedure trf_bcapinvoicesub
	* run fix itemname data for ' in name of transaction Replace with ''

	Select bcapinvoicesub
	result=SQLEXEC(dbconn,"SET IDENTITY_INSERT "+Alias()+" OFF ")
	Go Top
	lcdocno = ALLTRIM(bcapinvoicesub.docno)
	Do While !Eof()
		Wait Window Alltrim(Str(Recno())) Nowa
		Do Insertdata
		Skip
	ENDDO

*** Calculate stock amount ***
 
	 lccommand = "insert into processstock (itemcode,processflag,flowstatus,processtype,processcase) "
	 lccommand = lccommand + " select distinct itemcode , 1,0,0,0 from bcapinvoicesub where docno ='"+lcdocno+"'"
	 result = SQLEXEC(dbconn,lccommand)
	 IF result <0 	
	 	DO ErrHand
	 ELSE 
	 	calitem = 1 
	 	lnLoopCount = 0
	 	DO WHILE  calitem >0 AND lnLoopcount <=10
	 		lccommand = "select COUNT(itemcode) as itemcount from processstock where itemcode in (select itemcode from bcapinvoicesub where docno = ' "+lcdocno+"')"
	 		*MESSAGEBOX(lccommand)
	 		=SQLEXEC(dbconn,lccommand,'countprocessstock')
	 		SELECT countprocessstock
	 		calitem = countprocessstock.itemcount
	 		WAIT WINDOW 'Check Calculate item Loop : '+ALLTRIM(STR(lnLoopcount))  TIMEOUT 0.5
	 		lnLoopCount = lnLoopCount+1 
	 	ENDDO 	
	 *	DO printbc_rv WITH lcdocno 
	 ENDIF 

Endproc
***************************************************


PROCEDURE  printbc_rv
PARAMETERS lcdocno 

	*MESSAGEBOX(lcdocno,64,'�Ţ����͡�������')

	 lccommand = "select a.DocNo,a.DocDate,a.ItemCode,a.WHCode,a.ShelfCode,a.Qty,a.UnitCode,a.SUMOFCOST,a.creatorcode,"
	 lccommand = lccommand + "b.Name1 as itemname,c.Name as personname,e.MyDescription,d.Name as projectname ,f.name as unitname,A.PROJECTCODE ,"
	 lccommand = lccommand + " g.name1 as apname , e.apcode, case e.billtype when 0 then '�����Թʴ' when 1 then '�����Թ����' end as billtype, "
	 lccommand = lccommand + " case e.taxtype when 0 then '�¡�͡' when 1 then '����' when 2 then '�ѵ���ٹ��' end as taxtypedesc,e.taxtype,e.taxrate,e.beforetaxamount,e.taxamount,e.netdebtamount as totalamount ,e.taxno, "
	 lccommand = lccommand + " e.creatorcode,e.createdatetime ,g.address,g.telephone,g.idcardno,g.taxno as ap_taxno,e.sumcashamount,e.sumbankamount,e.pettycashamount ,excepttaxamount "
	 lccommand = lccommand + "from bcapinvoicesub a left join bcitem b on a.ItemCode=b.Code "
	 lccommand = lccommand + "left join BCSale c on a.creatorcode=c.code "
	 lccommand = lccommand + "left join BCProject d on a.ProjectCode=d.Code "
	 lccommand = lccommand + "left join bcapinvoice e on a.DocNo = e.DocNo " 
	 lccommand = lccommand + "left join bcitemunit f on a.unitcode=f.code "
	 lccommand = lccommand + "left join bcap g on a.apcode=g.code "
	 lccommand = lccommand + "where a.docno = '"+lcdocno+"'"
	 
	* MESSAGEBOX(lccommand)
	 SET TALK OFF 
	 SET CONSOLE OFF 
	 result = SQLEXEC(dbconn,lccommand,"bcapinvoicesub_BC")
	 IF result <0 
	 	 DO errhand
	 ELSE 
	 	SELECT bcapinvoicesub_BC
	 	IF MESSAGEBOX('Print out to printer ? ',36,'Output ')=6
	 		REPORT FORM bcform_rv TO PRINTER PROMPT  
		ELSE 
			REPORT FORM bcform_rv PREVIEW 
		ENDIF 
	 ENDIF 

ENDPROC 
***********************
Procedure trf_bcinputtax
	Select bcinputtax
	result=SQLEXEC(dbconn,"SET IDENTITY_INSERT "+Alias()+" OFF")
	Go Top
	Do While !Eof()
		Wait Window Alltrim(Str(Recno())) Nowa
		Do Insertdata
		Skip
	Enddo
Endproc
*********************************
