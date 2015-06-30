function afficherPopinMeteo(evtTarget){
	console.log(evtTarget);
	var reunionDivTag = evtTarget.parentNode.parentNode;
	var reunionId = reunionDivTag.getAttribute("data-reunionid");
	var reunionIndex = reunionId - 1;
	var bodyTag = document.getElementsByTagName("body")[0];
	var weatherPopinTagsArray = bodyTag.getElementsByClassName('popin bottom');
	console.log("afficherPopinMeteo - weatherPopinTagsArray.length : " + weatherPopinTagsArray.length);
	var weatherPopinIndexesArray = [1, 4, 7, 9, 11]; // indexes of div.popin-bottom tags that contain weather data
	// cf. Reference/popin-list.txt for, well, reference

	var popinIndex = weatherPopinIndexesArray[reunionIndex];
	var popin = weatherPopinTagsArray[popinIndex]; // getting the random popin
	var popinText = popin.textContent;
	popinText = popinText.trim();
	console.log("afficherPopinMeteo - getting popin n°" + popinIndex + ": " + popinText);
	popin.style.display = "block";
	
	popin.style.top = evtTarget.getBoundingClientRect().bottom + "px";
	popin.style.left = evtTarget.getBoundingClientRect().left + "px";
	
	
}
