
REM Importiert die Officeeinstellung aus der Registry, ohne Rückfrage
REM - Historie Standardeinstellungen Onenote
ECHO.
ECHO ###################################
Echo Office-Einstellungen werden importiert...
REG Import "H:\PRG\OfficeSet.Reg" >> H:\PRG\WIN\ProfilMig-%date%.Log





:Ol-Back
REM --------------------------------------------------------------
REM Outlook-Konto, Einstellungen, Signaturen sichern
REM Prüfe, ob Outlook schon gesichert wurde
If Exist "H:\Mail\OL-Back\OL-Profil.reg" Goto Ende
	RoboCopy "%LocalAppData%\Microsoft\Outlook" "H:\Mail\OL-Back\Outlook" /E /XF "*.OST" "*.tmp"

