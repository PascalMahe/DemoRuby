call gem install selenium-webdriver
:: Vérification : si échec de l'installation,
:: nouvelle tentative (après avoir mis en place le proxy)
if errorlevel 1 (
	:: Conf GIE-SV
	:: SET USER=mahep
	:: SET PASSWORD=juin2013
	:: SET SERVER=sl-proxy-cos
	:: SET PORT=80
	
	:: Conf MMA
	SET USER=sp35514
	SET PASSWORD=Motdepasseintranetmma1
	SET SERVER=proxy-internet.societe.mma.fr
	SET PORT=8080
	
	SET HTTP_PROXY=http://%USER%:%PASSWORD%@%SERVER%:%PORT%
	call gem install selenium-webdriver
)


