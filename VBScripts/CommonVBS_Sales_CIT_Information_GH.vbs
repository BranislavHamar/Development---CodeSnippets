'**********************************************************'
' Common Sales plugin - CIT Information
' Developed by Branislav Hamar  
'
' Version 1.5
'**********************************************************'
  
'********************************************'
' SETTINGS - Do changes as you wish! 
'********************************************'

Dim objArgs, ReportingCountry
Set objArgs = WScript.Arguments

Dim ActionThreshold  'default target for Sales to do actions
ActionThreshold = 90

Dim ReportingServerHostName 'default reporting server name
ReportingServerHostName = "yyyyy" 

Dim ReportingServerPort
ReportingServerPort = "3306" 'default reporting server port
    
Dim CommonSalesURL  'Common Sales webportal URL
CommonSalesURL = "http://xxxxx" 

'********************************************'
' CODE - Do not change anything!
'********************************************'

On Error Resume Next
        
If WScript.Arguments.Count > 0 Then

    For Each strArg in objArgs
      If InStr(UCase(strArg),"-C:") > 0 Then
        ReportingCountry = LCase(Right(strArg, Len(strArg) - 3))
      ElseIf InStr(UCase(strArg),"-T:") > 0 Then
        ActionThreshold = CInt(Right(strArg, Len(strArg) - 3))    
      ElseIf InStr(UCase(strArg),"-S:") > 0 Then
        ReportingServerHostName = Right(strArg, Len(strArg) - 3)
      ElseIf InStr(UCase(strArg),"-P:") > 0 Then
        ReportingServerPort = Right(strArg, Len(strArg) - 3)
      End If      
    Next
    
End If

If ReportingCountry = "" Then
    ReportingCountry = LCase(InputBox("Enter Reporting Country Code"))
End If 

Dim ReportingServerConnection 'ADODB connection string for mySQL
ReportingServerConnection = "Driver={MySQL ODBC 5.1 Driver}; Server=" + ReportingServerHostName + "; Port=" + ReportingServerPort + "; Database=sales" + ReportingCountry + "; UID=citinfo" + ReportingCountry + "; password=cit" + ReportingCountry + "; Option=3;" 


        'A. Setting Variables
        Dim objInstances, objIE, IE, objIECompanyNo, objIEPlace, cnn, rst, show, fso 
        Dim CITInformation, What(7), col, table
        Dim ImgGood, ImgBad, ImgAlert, ImgDetail
        Const adStateOpen = 1
        
        ImgGood   = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAACTklEQVR4XoXTX0hTURwH8O859zrdmDqbvtiCoJQYOBTNpx4WRBRWTHxpIrWg5xDqaVCIINSbr/ZSe2lvbfriSzCkiNAhbur6hyi6mZWRuTk3t3NO/pADU0E/cO/T+d7zu+f3O1BKHXouLfR5PIt3Ix0L/WtdCwOqI+lX7rm+tQuzdyKu+A3P0fWMXlp7qj9iMO5bLW7gr8hCQIAY4LDDCqeqQ0mWo6vdk706Qx/Ak/RozVR29vtmecu1sreOkzhFLazCkj67c6bl07VwgQPAu+3psA6f5o+RRY7tupZqNsKUZV2pgcsSano2/wWnCThvY3kvg/1q0bhjh5Symxfk3gj980m8tZ1YbpuAgsLUzxmgKJGzFFBiYoRbWbWbDkw7b2lGu60V2ui5x4i1jmE08wahxbcgqOYomgKspNyMWhUvfIZGixM73zCUHsOri0PwObyI/o6h9+MjwGECdgOafdOEKaSARjtTufTca+xBg1mHrXIWgZkgYOU6rEEoCV6WIkN9Jvedt6BRmAwmX+CfyAENVajEFCD2szwn8ykaEjK0/hKvf0xAW8mvI7Q2flA6xyGsAAhTpniVNII0YYR2epAeRmDxKbZKWQzOPwdMBtgMHMWzArIkgvxrZzRO40kTRsCBUGES3vmHGP8VA+rN4+FtCQEZlT3JOKdMS7HZT+PpKNmgJdQS0GShwzsWVnmRVsu7fn0XoDV9uBqBVD4aEuqzYkofGP0zlX2w883E4ctUqf79lTYINayE6lJl6aJWCYi0YDIumXomr8/No8J/Hds7FYH9b/kAAAAASUVORK5CYII="
        ImgBad    = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAC00lEQVR4XmWTTWhUVxiGn3PuZGZaZ+ZOErtyumlMTCKalDohFIsW1KIFMQUXgSJddOOiu9KFC4uCXWTVLnRV2hSKUheZCBXSRlLT0lqoCxtNbE0LEsd205j5N7lzz/m89xrsDH7wnnM48Lyc7+M9SkRorYUjA7tVPH4G7ewR7eSsNVhvoxjopngbH+evP1hoBdoM7owNFwLw2Pq/KzTLaxhjAEA7OFtSKLcLfH969PrKWJvBysSHyepv88vNtf9y9eJ9jIABZFNqUw6gs92QSBYbW3O9h6Z+XY8BVG5cu+RXy7laAPsCpLJ41RK2pbt4OoOpVYiVVlHpbC75z9+XgDG9eDyfD59d34T7PvmCVydn8be4bAiRJJVh+LPLbP9ogqaABOZNK8fm8t15bTfWz4U9GwFSLqmBYTL9Q4x+OROAbqSR81Oke3fyYs8gjWQaX0A3aojfPBdTyRcGo4EBXrXML+++ycjkNTr7d7P382/BGNyeHTy6+ztzH4zD4yoJB7Tv0YwlBmPWyjZjDAJYAa9SZv7EAd6YnKGrfxfi+6wu3eK7k8ehXiXjgAjR4lu7TVtrABD4f1cKRUsJaKVI6LYrxBq09f2HaOcZEM9k2f/VbNTCoz9us/rnHbp27OTghcvEU5kWY4U15qG2jdpSFJIQdrPs/XqO7MBQAC8w897bzL5/lLV7i3QGQ3z904t0pDNoBb5SxKxZ0uJ0nAoT5gBSKVG9e4u1YGCzJ95C6hU6GhV+PvkOpeVFSn8tUatU0MC6KIy1pxARbux7ufDTSLf80Id834tcHXbl4itIoYdI04GuDqXlm+BuKjz3abmyXRVCVgN4ud7xMJ5BwuhQEK+XcTXEFSRUtOM0qnQ6kHA0npVi0ZPx5z7Tj6MvFcKEPQ2JByIIACrsOXq2snb66LJt/0ytNf+au8sXzvpW9gRmObEGjCkqa246Yk8fvmdvtwJPAB2kcdm0kbhCAAAAAElFTkSuQmCC"
        ImgAlert  = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAACD0lEQVR4Xn1TTWsTURQ9700aU4xNYWpAOllYrWKlWjVZuBH0D9iV0LWIm2ykWXWhKHRZcNeN+yzTraCIiLRiIn7QihRR27QFbfxo0ziTzLvHGCWTSaAHDpz79ebey1xFEiEsnzoDFb1LWOkmHdKAxiuDXhHi3YmcW3+LTpAMuHy2wJXz5OshsmSRRfynRVNK0Hs1QreUKnTW/OugnIth9+kq/G0H9c/YDw3Y8KW/vOs7o8mLi65ueXce5buLL9+aQPrmhRabuu3vQwUWqk5cf8wDgMb7TAbKmuz+8gmnFugRG0hm23ZU/wTJyeqindEQdxb1NXTjZOp3oI/GgcbXUDyqq1BszGrq/jGYH+jGEdsLdDIGmJ1QPKI9+KLGNMlh0OzfwUgcML9CcaUIERnWDBcHc6dqgW6NsI5uUAQRir8BWMNA+KF4v0HxwSowdAMt1MIjkAqA2dAw1RVRcXRjsxLFXD6Bufln2Pz0vGcHdV/DUv6KFvTN+MpGN3Lzx5B/nET+oUHuvgDWQChecxV8IzM6OvGhSDYWGgg/slU5EOhtBQxebdt7rgXALNhXpKhbDhmd+vt71mWwnTR9bR2HDkZanL5+HLAS7WLXk/LWN071HNPe0uFCdXGI9RcxyktFLp8m17Lklywbb8b5/UmkSdVzTOHZlhLjIrgnwrQROhSBUn5ZQYpamdsDl+QdOvAHx4wysn+exR8AAAAASUVORK5CYII="
        ImgDetail = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAMUSURBVHjaYvz//z/DyVPHP//69Y/hPwMIQEh84O27D9xCAlyM9nZOjAABxHj46OHvqspKHIICvKjagQYzMjKAMZAJxmAAFGBiZGJ48Ogpw/t3r/8DBCBiDm4ABGEAin7a6lU5GeP+wykLQCjFeHKA9ywied43amv8drIugorRh5Ek0OnU7t+AiHKdB/dTeAUQC8jOP3//MQARA8wJ7GwsDD/+cDAcvfKD4f7zLwz8vEwM5hocDEriLAxfvv9k+Pv3LwM7OyvDv3//vwIEEBPQoQz/gJpABvwDYkYmRobf/zkZpmz8xLD9zDcGPl4WhnvP/zL0rfvEcOkRIwMHOwvDH6AGkB6QXoAAYmKAav7zF4iBNAsLC8O2s78Yjt7+w5DuI8gQYcfOUBTCz8ACtHHh/u8Mv4BeAgGwi4F6AQKICexqqO3//oJCionhxO3fDDw8bAyyIv8Zvn79zsDF8ptBRYqN4cqT/wzvPoMCkRGsHgQAAogJZhrYFWCD/jHoKbIz7Lnwm+H0PQYGbl4uhnffWBkWHfrJwMXBzCDI/Z/hx6//cAMAAojlHzDEf/z8y/Dl2x8GFqBxQnzMDB8//2X4+PIXg3fDWwZHbaDNj/4wMDEzMkyI52L49u0Hw6evf4Gu/8sA0gsQQCyM4LgF+h2oQEyYm2Hunt8MxVPeMCT68DPoKrAxnL75kyHCloMh1IadQUX0F8P7L3+B0csE9AZYGwNAAIFDhBWoWYCXg2HBnh8MBX0vGJIDhBgmZfABQ+MnQ5wDBwMwVoGu/MXw+esfBlaglaBExcwMtpoBIIBYQCkLZPu//4wML9//YkgLFmDoSxcEOvUrw9fv/4ByDAzfoCmRlZUJlkiBroAkU4AAArsAFPd/gTYUBfCAU+CP78Do+g1JjfCQRgIQFzCBvQAQQCwggzjYmIGhCvQb4x9gVEIUcbAz4cxMIOfzcrMyiAjz8wAEEAvQiSzfvgGTKz8vMD38B2cmRgK5ERgKDO/efQCmka8MAAHECMo4x44f+fz3HyMDsYCTg50NmF7YzEzNGAECDADwzyZVd2BUcQAAAABJRU5ErkJggg=="
                
        'B. Setting Functions
        Function CheckIE(CommonSalesURL)
           
        
                            Set objInstances = CreateObject("Shell.Application").windows
                                  
                            If objInstances.Count > 0 Then '/// make sure we have instances open.
                                  For Each objIE In objInstances
                                      If InStr(objIE.LocationURL,CommonSalesURL) > 0 then
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

        'C. Run Job                                              
        Do While 1=1 

        On Error Resume Next
                      
            '1. CHECK IF INTERNET EXPLORER EXISTS
             Do While IsEmpty(CheckIE(CommonSalesURL)) 
                Wscript.sleep 10
             Loop                                             
             Set IE = CheckIE(CommonSalesURL)
                             
            '2. CHECK IF CUSTOMER NUMBER EXISTS    
             Do While IsEmpty(IE.Document.getElementById("token.customerId"))   
               Wscript.sleep 10
             Loop 
             Set objIECompanyNo = IE.Document.getElementById("token.customerId")
                
            '3. CHECK IF PROPER CONTAINER EXISTS                        
             Do While IsEmpty(IE.Document.getElementById("7_H9NM9B1A00DB50IB7PI63Q3007")) 
               Wscript.sleep 10
             Loop 
             Set objIEPlace = IE.Document.getElementById("7_H9NM9B1A00DB50IB7PI63Q3007")

            '4. WAIT UNTIL INTERNET EXPLORER FINISH
             Do Until (IE.ReadyState=4 And Not IE.Busy)        
              Wscript.sleep 10
             Loop
                           
             If Instr(objIEPlace.InnerHTML,"citinformation") = 0  Then 

                                                                                        objIEPlace.getElementsByTagName("table")(0).style.height = "1px" 'fix to shrink height of above table
                                                                                        
                                                                                        CITInformation = "<table style='margin-left:3px;margin-right:5px;' border='0' width='100%' cellpadding='1' cellspacing='0'><tr>" + _
                                                                               			                     "<td class='wpsProcessPortletTitle' width='100%' nowrap align='left' valign='middle' style='padding-left: 2px;'>CIT Information</td></tr><tr>" + _
                                                                                                         "<td class='wpsProcessPortletBorder' width='100%' nowrap align='left' valign='middle' style='padding-left: 10px;'>" + _
                                                                                                            "<table class='tnt-table tnt-table-alt' name='citinformation' width='100%' cellspacing='0'>" + _                
                                                                                            							  "<tr class='tnt-table-headings'>" + _
                                                                                              								"<th class='tnt-table' align='left' width='11%'>Registered</th>" + _
                                                                                              								"<th class='tnt-table' align='left' width='11%'>Used</th>"  + _
                                                                                              								"<th class='tnt-table' align='left' width='11%'>NON CIT Cons</th>"  + _
                                                                                              								"<th class='tnt-table' align='left' width='11%'>CIT Cons</th>"  + _
                                                                                              								"<th class='tnt-table' align='left' width='11%'>CIT Cons Penetration</th>"  + _
                                                                                              								"<th class='tnt-table' align='left' width='11%'>Actions Needed?</th>"  + _
                                                                                              								"<th class='tnt-table' align='left' width='25%'>Comment</th>"  + _
                                                                                                							"<th class='tnt-table' align='left' width='9%'>Details</th>"  + _
                                                                                                              "<th class='tnt-table-rowactions'>&nbsp;</th>"  + _
                                                                                                            "</tr>"  + _
                                                                                                            "<tr class='tnt-table-odd'>"  + _
                                                                                              								"<td class='tnt-table tnt-row-align' id='CITrow0'><i>Loading item 0...</i></td>"  + _
                                                                                              								"<td class='tnt-table tnt-row-align' id='CITrow1'><i>Loading item 1...</i></td>"  + _									
                                                                                              								"<td class='tnt-table tnt-row-align' id='CITrow2'><i>Loading item 2...</i></td>"  + _
                                                                                              								"<td class='tnt-table tnt-row-align' id='CITrow3'><i>Loading item 3...</i></td>"  + _
                                                                                              								"<td class='tnt-table tnt-row-align' id='CITrow4'><i>Loading item 4...</i></td>"  + _
                                                                                              								"<td class='tnt-table tnt-row-align' id='CITrow5'><i>Loading item 5...</i></td>"  + _
                                                                                              								"<td class='tnt-table tnt-row-align' id='CITrow6'><i>Loading item 6...</i></td>"  + _
                                                                                              								"<td class='tnt-table tnt-row-align' id='CITrow7'><i>Loading item 7...</i></td>"  + _
                                                                                               								"<td class='tnt-table-rowactions tnt-row-align'>&nbsp;</td>"  + _
                                                                                                            "</tr></table>" + _
                                                                                                        "</td>" + _
                                                                                                        "</tr></table>"
                                                                
              
                                                                                        objIEPlace.InnerHTML =  objIEPlace.InnerHTML + CITInformation
                                                                                        
                                                                                                   'OPEN CONNECTION 
                                                                                                    Set cnn = CreateObject("ADODB.Connection")
                                                                                                        cnn.Open ReportingServerConnection 

                                                                                                    If cnn.State <> adStateOpen Then

                                                                                                                What(0) = "&nbsp;- "
                                                                                                                What(1) = "&nbsp;- "
                                                                                                                What(2) = "&nbsp;- "
                                                                                                                What(3) = "&nbsp;- "
                                                                                                                What(4) = "&nbsp;- "
                                                                                                                What(5) = "&nbsp;- "
                                                                                                                What(6) = "&nbsp;- "
                                                                                                                What(7) = "&nbsp;- "

                                                                                                    Else


                                                                                                                'FIND PROPER RECORD               0               1           2             3           
                                                                                                                Set rst = cnn.Execute("Select REGISTERED, NON_CIT_CONS, CIT_CONS, ACCOUNT From penetrbyacc Where CUSTOMERNUMBER = " + objIECompanyNo.Value )
            
            
                                                                                                                      If rst.EOF = True Then
                                                                                                                      
                                                                                                                            What(0) = "&nbsp;<img height='16px' src='" + ImgBad + "'> "
                                                                                                                            What(1) = "&nbsp;<img height='16px' src='" + ImgBad + "'> "
                                                                                                                            What(2) = "&nbsp;0 "
                                                                                                                            What(3) = "&nbsp;0 "
                                                                                                                            What(4) = "&nbsp;0 "
                                                                                                                            What(5) = "&nbsp;<img height='16px' src='" + ImgAlert + "'>"
                                                                                                                            What(6) = "&nbsp;Missing CIT Cons :-( "
                                                                                                                            What(7) = "&nbsp;- "                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
            
                                                                                                                      Else
                                                                                                                      
                                                                                                                            col = Split(rst.GetString, vbTab)
                                                                                                                            
                                                                                                                            'Column 1 - Registered
                                                                                                                            If col(0) = "Y" Then
                                                                                                                              What(0)  = "&nbsp;<img height='16px' src='" + ImgGood + "'> "
                                                                                                                              'What(0)  = "&nbsp;<img height='16px' src='file://" + ScriptPath + "images/Good.png'> " 
                                                                                                                            Else 
                                                                                                                              What(0)  = "&nbsp;<img height='16px' src='" + ImgBad + "'> "
                                                                                                                            End If
                
                                                                                                                            'Column 2 - Used                                                                                                               
                                                                                                                            If CInt(col(2)) > 0 Then
                                                                                                                                  What(1) = " &nbsp;<img height='16px' src='" + ImgGood + "'> "
                                                                                                                            Else
                                                                                                                                  What(1) = " &nbsp;<img height='16px' src='" + ImgBad + "'> "
                                                                                                                            End If
                                                                                                                               
                                                                                                                            'Column 3 - NON CIT Cons
                                                                                                                            What(2) = CInt(col(1))
                                                                                                                            
                                                                                                                            'Column 4 - CIT Cons
                                                                                                                            What(3) = CInt(col(2))
                
                                                                                                                            'Column 5 - CIT Cons Penetration
                                                                                                                            What(4) = What(3) / (What(2) +  What(3)) * 100
                                                                                                                            What(4) = round(What(4),2)
                                                                                                                            
                                                                                                                                  If What(4) < ActionThreshold Then
                                                                                                                                     What(5) = " &nbsp;<img height='16px' src='" + ImgAlert + "'>"
                                                                                                                                     What(6) = " Low CIT Penetration (<" + CStr(ActionThreshold) + "%) :-(" 
                                                                                                                                    If What(4) = 0 Then
                                                                                                                                     What(5) = " &nbsp;<img height='16px' src='" + ImgAlert + "'>"
                                                                                                                                     What(6) = " Missing CIT Cons :-(" 
                                                                                                                                    End If
                                                                                                                                  Else 
                                                                                                                                     What(5) = " &nbsp;<img height='16px' src='" + ImgGood + "'> " 
                                                                                                                                     What(6) = " Excellent (>" + CStr(ActionThreshold) + "%) ;-) "
                                                                                                                                  End If
                                                                                            
                                                                                                                                  What(7) = " &nbsp;<a target='_blank' title='More info' href='http://xxxxx" + ReportingCountry + "/imoneCIT.php?ID=" + col(3) + "&showall=y'><img border='0px' height='16px' src='" + ImgDetail + "'></a>" 
                                                                                                                             
                                                                                                                             What(4) = CStr(What(4)) + Cstr("%")
                                                                                                                             
                                                                                                                            Erase col 
            
                                                                                                                      End If
                                                                                                                 
                                                                                                                rst.Close
                                                                                                                cnn.Close
                                                                                                           
                                                                                                                Set cnn = Nothing
                                                                                                                Set rst = Nothing

                                                                                                         End If
                                                                                                         
                                                                
                                                                                      objIEPlace.InnerHTML = replace(objIEPlace.InnerHTML,"Loading item 0...", What(0) )
                                                                                      objIEPlace.InnerHTML = replace(objIEPlace.InnerHTML,"Loading item 1...", What(1) )
                                                                                      objIEPlace.InnerHTML = replace(objIEPlace.InnerHTML,"Loading item 2...", What(2) )
                                                                                      objIEPlace.InnerHTML = replace(objIEPlace.InnerHTML,"Loading item 3...", What(3) )
                                                                                      objIEPlace.InnerHTML = replace(objIEPlace.InnerHTML,"Loading item 4...", What(4) )
                                                                                      objIEPlace.InnerHTML = replace(objIEPlace.InnerHTML,"Loading item 5...", What(5) )                                                                                        
                                                                                      objIEPlace.InnerHTML = replace(objIEPlace.InnerHTML,"Loading item 6...", What(6) )
                                                                                      objIEPlace.InnerHTML = replace(objIEPlace.InnerHTML,"Loading item 7...", What(7) )
                                                                                      Erase What
                                                                                      CITInformation = ""

              End If

              Set objIECompanyNo = Nothing
              Set objIEPlace = Nothing             
              Set IE = Nothing               

        On Error GoTo 0 
                     
        WScript.sleep 10
        Loop

On Error GoTo 0    
---------------------------
OK   
---------------------------
