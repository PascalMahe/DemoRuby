function afficherPopinMeteo(evtTarget){
	console.log(evtTarget);
	var bodyTag = document.getElementsByTagName("body")[0];
	var weatherPopinTagsArray = bodyTag.getElementsByClassName('popin bottom');
	console.log("afficherPopinMeteo - weatherPopinTagsArray.length : " + weatherPopinTagsArray.length);
	var weatherPopinIndexesArray = [1, 4, 7, 9, 11]; // indexes of div.popin-bottom tags that contain weather data
	// cf. Reference/popin-list.txt for, well, reference
	var randPopinIndexIndex = getRandomAbitrary(weatherPopinIndexesArray.length); // generating random index
	var randPopinIndex = weatherPopinIndexesArray[randPopinIndexIndex];
	var randPopin = weatherPopinTagsArray[randPopinIndex]; // getting the random popin
	var popinText = randPopin.textContent;
	popinText = popinText.trim();
	console.log("afficherPopinMeteo - getting popin n°" + randPopinIndex + ": " + randPopin.textContent.trim());
	randPopin.style.display = "block";
	
	randPopin.style.top = evtTarget.getBoundingClientRect().bottom + "px";
	randPopin.style.left = evtTarget.getBoundingClientRect().left + "px";
	
	
}

function getRandomAbitrary(max){
	return Math.floor(Math.random() * max);
}