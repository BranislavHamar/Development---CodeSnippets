'**********************************************************'

' Common Frontline plugin - Cooperative Connote

' Developed by Branislav Hamar,   

'

' Version 1.3

'**********************************************************'



'********************************************'

' SETTINGS - Do changes as you wish! 

'********************************************'



Option Explicit



SetLocale("sk")



Dim URL : URL = "xxxxx"



Dim objInstances, objIE, IE, objIEPlace, objNet 

Dim CC_button, script, SenderAccount, CRN, CompanyName

Dim strComputer, objWMIService, colProcesses, objProcess

Dim objArgs, DomainURL, strArg, CollectionInstructions

Set objArgs = WScript.Arguments



If WScript.Arguments.Count > 0 Then



    For Each strArg in objArgs

      If InStr(UCase(strArg),"-D:") > 0 Then

        DomainURL = LCase(Right(strArg, Len(strArg) - 3))

      ElseIf InStr(UCase(strArg),"-C:") > 0 Then

        CollectionInstructions = Right(strArg, Len(strArg) - 3)

      End If      

    Next

    

End If



If DomainURL = "" Then

   DomainURL = LCase(InputBox("Please Enter Domain Name"))

End If



If CollectionInstructions = "" Then

   CollectionInstructions = "INTERNET CONNOTE"

End If



On Error Resume Next 



Function CheckIE(URL)

   



                    Set objInstances = CreateObject("Shell.Application").windows

                          

                    If objInstances.Count > 0 Then '/// make sure we have instances open.

                          For Each objIE In objInstances

                              If InStr(objIE.LocationURL,URL) > 0 then

                            	  Set CheckIE = objIE      

                                Do until CheckIE.readyState = 4 

                                  Wscript.sleep 100 

                                Loop

                              End if

                          Next

                    End If



                    objIE = ""

                    Set objInstances = Nothing

                    

End Function



                                                 

Do While 1=1 



            '1. CHECK IF INTERNET EXPLORER EXISTS

             Do While IsEmpty(CheckIE(URL)) 

                Wscript.sleep 100

                'msgbox "Waiting for IE 1"                

             Loop                                             



             Do While (CheckIE(URL) is Nothing) 

                Wscript.sleep 100

                'msgbox "Waiting for IE 2"

             Loop  

             

               Wscript.sleep 100

               Set IE = CheckIE(URL)

               'msgbox "IE available"

             



            '2. CHECK IF PLACE TO PUT EXISTS                        

             Do While (IE.Document.getElementById("ns_7_R69M9B1A003R50IL8G17OT2C60_BookingEditForm") is Nothing)

              Wscript.sleep 800

 

                'msgbox "Waiting for area to put content further"     

               

                 If IE.Document.getElementById("cacIdLegacyAccountNumber").Value <> "" Then

                    SenderAccount = IE.Document.getElementById("cacIdLegacyAccountNumber").Value         

                 Else

                    SenderAccount = "0"

                 End If



                 If IE.Document.getElementById("ns_7_R69M9B1A003R50IL8G17OT2C60_addressType").Value = "C" Then

                    If IE.Document.getElementById("addressAccountNumber").Value <> "" Then

                      SenderAccount = IE.Document.getElementById("addressAccountNumber").Value

                    Else 

                      SenderAccount = "0"

                    End If

                 End If





                If Not IsEmpty(IE.Document.getElementById("ns_7_R69M9B1A003R50IL8G17OT2C60_BookingEditForm")) Then Exit Do

                If Not (IE.Document.getElementById("ns_7_R69M9B1A003R50IL8G17OT2C60_BookingEditForm") is Nothing) Then Exit Do

                If Not Instr(IE.Document.getElementById("cooperativeconnote").InnerHTML,"CC_email") = 0 Then Exit Do



                  

             Loop





               Wscript.sleep 100

               Set objIEPlace = IE.Document.getElementById("ns_7_R69M9B1A003R50IL8G17OT2C60_BookingEditForm")

               'msgbox "Area to put content further available 1 - " + objIEPlace.InnerHTML   

  

            '3. LOAD OF HTML INFORMATION

                                                                                

                                                                                'On Error GoTo 0



                                                                                'WAIT UNTIL WHOLE PAGE LOADS                                                                 

                                                                                'Do Until IE.ReadyState=4

                                                                                'msgbox "Waiting for IE to finish"

                                                                                ' Wscript.sleep 10

                                                                                'Loop



                                                                                Set objNet = CreateObject("WScript.NetWork")

                                                                                                                                                                              

                                                                                'Javascript function to gather actual values from form fields                                                                                     

                                                                                script = "  " + _

                                                                                         " function CHECKOBJ(urlobj,obj) { " + _

                                                                                         "    if (typeof(document.getElementById(obj)) != 'undefined' && document.getElementById(obj) != null) " + _

                                                                                         "      {" + _

                                                                                         "        return '&' + urlobj + '=' + encodeURIComponent(document.getElementById(obj).value) ;" + _

                                                                                         "      };" + _

                                                                                         "    else {" + _

                                                                                         "        return '&' + urlobj + '=' ;" + _

                                                                                         "      };" + _

                                                                                         " } " + _                                                                                                                                                                                                                                                                           

                                                                                         "  " + _

                                                                                         "  " + _

                                                                                         " function LINK() { " + _

                                                                                         "  "  + _                                                                                         

                                                                                         "    var URL = 'http://" + DomainURL + "/includes/php/csfl/upload.php?'; " + _

                                                                                         "    URL = URL + 'UserName=' + encodeURI('" + objNet.UserName + "');" + _

                                                                                         "    URL = URL + CHECKOBJ('CC_CRN','CC_CRN'); " + _

                                                                                         "    URL = URL + CHECKOBJ('AccountNumber','accountNumber'); " + _

                                                                                         "    URL = URL + '&SenderAccount=' + encodeURI('" + SenderAccount + "');" + _

                                                                                         "    URL = URL + CHECKOBJ('CC_email','CC_email'); " + _

                                                                                         "    URL = URL + CHECKOBJ('PaymentTerms','paymentTerms'); " + _

                                                                                         "    URL = URL + CHECKOBJ('SenderName','DONOTSAVE_collectionCompanyName'); " + _

                                                                                         "    URL = URL + CHECKOBJ('SenderStreet1','DONOTSAVE_collectionAddressLine1'); " + _

                                                                                         "    URL = URL + CHECKOBJ('SenderTown','DONOTSAVE_collectionAddressLine2'); " + _

                                                                                         "    URL = URL + CHECKOBJ('SenderPostcode','DONOTSAVE_collectionAddressLine3'); " + _

                                                                                         "    URL = URL + CHECKOBJ('SenderCountry','DONOTSAVE_collectionCountry'); " + _

                                                                                         "    URL = URL + CHECKOBJ('SenderContact','collectionDetails.contactName'); " + _

                                                                                         "    URL = URL + CHECKOBJ('SenderPhone1','collectionDetails.telAreaCode'); " + _

                                                                                         "    URL = URL + CHECKOBJ('SenderPhone2','collectionDetails.telPhone'); " + _                                                                                                                                                                                                                                                                                                                                                                                                                                                           

                                                                                         "    URL = URL + CHECKOBJ('SenderExtension','collectionDetails.telExtn'); " + _

                                                                                         "    URL = URL + CHECKOBJ('ReceiverName','deliveryAddress1'); " + _

                                                                                         "    URL = URL + CHECKOBJ('ReceiverStreet1','deliveryAddress1'); " + _

                                                                                         "    URL = URL + CHECKOBJ('ReceiverTown','deliveryTown'); " + _

                                                                                         "    URL = URL + CHECKOBJ('ReceiverPostcode','deliveryPostcode'); " + _

                                                                                         "    URL = URL + CHECKOBJ('ReceiverCountry','deliveryCountryId'); " + _

                                                                                         "    URL = URL + CHECKOBJ('ShipmentType','goodsType'); " + _

                                                                                         "    URL = URL + CHECKOBJ('ShipmentDescription','goodsDesc'); " + _

                                                                                         "    URL = URL + CHECKOBJ('Items_0','itemGroups[0].numberOfItems'); " + _

                                                                                         "    URL = URL + CHECKOBJ('Length_0','itemGroups[0].itemLength'); " + _

                                                                                         "    URL = URL + CHECKOBJ('Width_0','itemGroups[0].itemWidth'); " + _

                                                                                         "    URL = URL + CHECKOBJ('Height_0','itemGroups[0].itemHeight'); " + _

                                                                                         "    URL = URL + CHECKOBJ('Items_1','itemGroups[1].numberOfItems'); " + _

                                                                                         "    URL = URL + CHECKOBJ('Length_1','itemGroups[1].itemLength'); " + _

                                                                                         "    URL = URL + CHECKOBJ('Width_1','itemGroups[1].itemWidth'); " + _

                                                                                         "    URL = URL + CHECKOBJ('Height_1','itemGroups[1].itemHeight'); " + _

                                                                                         "    URL = URL + CHECKOBJ('Items_2','itemGroups[2].numberOfItems'); " + _

                                                                                         "    URL = URL + CHECKOBJ('Length_2','itemGroups[2].itemLength'); " + _

                                                                                         "    URL = URL + CHECKOBJ('Width_2','itemGroups[2].itemWidth'); " + _

                                                                                         "    URL = URL + CHECKOBJ('Height_2','itemGroups[2].itemHeight'); " + _

                                                                                         "    URL = URL + CHECKOBJ('Items_3','itemGroups[3].numberOfItems'); " + _

                                                                                         "    URL = URL + CHECKOBJ('Length_3','itemGroups[3].itemLength'); " + _

                                                                                         "    URL = URL + CHECKOBJ('Width_3','itemGroups[3].itemWidth'); " + _

                                                                                         "    URL = URL + CHECKOBJ('Height_3','itemGroups[3].itemHeight'); " + _

                                                                                         "    URL = URL + CHECKOBJ('Items_4','itemGroups[4].numberOfItems'); " + _

                                                                                         "    URL = URL + CHECKOBJ('Length_4','itemGroups[4].itemLength'); " + _

                                                                                         "    URL = URL + CHECKOBJ('Width_4','itemGroups[4].itemWidth'); " + _

                                                                                         "    URL = URL + CHECKOBJ('Height_4','itemGroups[4].itemHeight'); " + _

                                                                                         "    URL = URL + CHECKOBJ('TotalItems','numberOfItems'); " + _ 

                                                                                         "    URL = URL + CHECKOBJ('TotalWeight','totalWeightValue'); " + _

                                                                                         "    URL = URL + CHECKOBJ('TotalSubWeight','totalWeightSubValue'); " + _

                                                                                         "    URL = URL + CHECKOBJ('TotalLength','totalLength'); " + _

                                                                                         "    URL = URL + CHECKOBJ('TotalWidth','totalWidth'); " + _

                                                                                         "    URL = URL + CHECKOBJ('TotalHeight','totalHeight'); " + _

                                                                                         "    URL = URL + CHECKOBJ('DGIndicator','dangerousGoodsIndicator'); " + _

                                                                                         "    URL = URL + CHECKOBJ('DGOption','dangerousGoodsOption'); " + _

                                                                                         "          Service = new Object();" + _

                                                                                         "          Service = document.getElementsByName('lineOfBusiness');" + _

                                                                                         "          var ServiceLength = Service.length;" + _

                                                                                         "                    URL = URL + '&Service=' + Service[ServiceLength-1].value; " + _

                                                                                         "          Options = new Object();" + _

                                                                                         "          Options = document.getElementsByName('selectedOptions');" + _

                                                                                         "          var OptionsLength = Options.length;" + _

                                                                                         "            var y=0; " + _

                                                                                         "            for (var i = 0; i < OptionsLength; i++) { " + _

                                                                                         "                if (Options[i].checked == true ) { " + _

                                                                                         "                    URL = URL + '&ServiceOption_' + y + '=' + Options[i].value; " + _

                                                                                         "                      if  (Options[i].value == 'IN' ) {        " + _

                                                                                         "                        URL = URL + CHECKOBJ('InsuranceValue','insuranceValue'); " + _

                                                                                         "                        URL = URL + CHECKOBJ('InsuranceCurrency','insuranceCurrency'); " + _

                                                                                         "                      }" + _

                                                                                         "                      if  (Options[i].value == 'CS' ) {        " + _

                                                                                         "                        URL = URL + CHECKOBJ('CashCollectionValue','cashCollectionValue'); " + _

                                                                                         "                        URL = URL + CHECKOBJ('CashCollectionCurrency','cashCollectionCurrency'); " + _

                                                                                         "                      }" + _

                                                                                         "            y++;" + _

                                                                                         "                  }" + _

                                                                                         "             }          " + _

                                                                                         "          ExpectedDeliveryDate = new Object();" + _

                                                                                         "          ExpectedDeliveryDate = document.getElementsByName('expectedDeliveryDate');" + _

                                                                                         "          var ExpectedDeliveryDateLength = ExpectedDeliveryDate.length;" + _

                                                                                         "                    URL = URL + '&ExpectedDeliveryDate=' + ExpectedDeliveryDate[ExpectedDeliveryDateLength-1].value; " + _

                                                                                         "    URL = URL + CHECKOBJ('CollectionDate','collectionDetails.collectionDate'); " + _

                                                                                         "    URL = URL + CHECKOBJ('CollectionTimeFrom','collectionDetails.goodsAvailableFromTime'); " + _

                                                                                         "    URL = URL + CHECKOBJ('CollectionTimeTo','collectionDetails.goodsAvailableToTime'); " + _

                                                                                         "    URL = URL + CHECKOBJ('UnavailableFrom','collectionDetails.goodsUnavailabilityFromTime'); " + _

                                                                                         "    URL = URL + CHECKOBJ('UnavailableTo','collectionDetails.goodsUnavailabilityToTime'); " + _

                                                                                         "    URL = URL + CHECKOBJ('CollectionInstructions','collectionDetails.driverInstructions'); " + _                                                                                         

                                                                                         "    " + _                                                                                                                                                                                                                                                                                                                                                                    

                                                                                         "  window.open(URL,'_blank'); " + _

                                                                                         "  "  + _

                                                                                         "  DrvInstr = new Object();" + _

                                                                                         "  DrvInstr = document.getElementById('collectionDetails.driverInstructions');"  + _

                                                                                         "  var CollInstr;"  + _                                                                                         

                                                                                         "  CollInstr = DrvInstr.value;"  + _                                                                                         

                                                                                         "  var CollCCMsg;"  + _                                                                                         

                                                                                         "  CollCCMsg = '" + CollectionInstructions + ",';"  + _                                                                                         

                                                                                         "  "  + _                                                                                          

                                                                                         "  if (CollInstr.search(CollCCMsg) < 0) "  + _

                                                                                         "      {" + _

                                                                                         "        DrvInstr.value = CollCCMsg + CollInstr; "  + _

                                                                                         "      };" + _ 

                                                                                         " }"                                                                                           

                                                                                                                                                                         

                                                                                IE.Document.parentWindow.execScript(script)                                                                                

                                                                              

                                                                                

                                                                                CC_button = "<hr width='99%'>" + _

                                                                                "<table border=0 id='cooperativeconnote' cellpadding=0 cellspacing=0 style='margin-left:4px'>" + _

                                                                                "<tr ><td><label for='CC_email'>Email</label></td><td><label for='CRN'>&nbsp;&nbsp;CRN</label></td><td>&nbsp;</td><td>&nbsp;</td><tr/>" + _

                                                                                "<tr ><td><input type='text' name='CC_email'  size='30'></td><td>&nbsp;&nbsp;<input type='text' id='CC_CRN' name='CC_CRN' size='7'></td><td>&nbsp;&nbsp;<a style='padding-top:3px;width:200px;text-decoration:none;text-align:center;' id='CC_button' class='tnt-button' href='#' onclick='LINK()'>&nbsp; Create Cooperative Connote&nbsp;</a></td><td>&nbsp;&nbsp;<a target='_blank' style='padding-top:3px;width:200px;text-decoration:none;text-align:center;' id='CC_button2' class='tnt-button' href='http://" + DomainURL + "/includes/php/csfl/list.php'>&nbsp; All Cooperative Connotes&nbsp;</a></td><tr/>" + _

                                                                                "</table>"

                                                                                

                                                                                objIEPlace.InnerHTML =  objIEPlace.InnerHTML + CC_button

                                                                                

                                                                                IE.Document.parentWindow.execScript("document.getElementById('CC_CRN').value = document.getElementById('obj.crn').value;") 

                                                                                

                                                                                'On Error Resume Next

                                                                                

                                                                                CC_button = ""



                                                                                'Set cursor focus on receivers town

                                                                                'IE.Document.getElementById("deliveryTown").Focus

                                                                               





             Do While NOT (IE.Document.getElementById("ns_7_R69M9B1A003R50IL8G17OT2C60_BookingEditForm") is Nothing) 

              Wscript.sleep 2000



                'msgbox "Waiting for area to put content further 5 " 

                              

                If IsEmpty(IE.Document.getElementById("ns_7_R69M9B1A003R50IL8G17OT2C60_BookingEditForm")) Then Exit Do

                If (IE.Document.getElementById("ns_7_R69M9B1A003R50IL8G17OT2C60_BookingEditForm") is Nothing) Then Exit Do

                If Instr(IE.Document.getElementById("cooperativeconnote").InnerHTML,"CC_email") = 0 Then Exit Do

                

                'msgbox "Waiting for area to put content further 6 "     

             Loop



             Set objIEPlace = Nothing             

             Set IE = Nothing               



Wscript.sleep 1000



Loop

