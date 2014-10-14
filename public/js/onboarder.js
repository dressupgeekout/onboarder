var nfyles = 0;
var nfylesInput = document.getElementById("nfyles-input");
var attachArea = document.getElementById("attach-area-list");
var addAnotherButton = document.getElementById("add-another-button");

function addAnotherAttachField() {
  var newListElement = document.createElement("li");
  var newField = document.createElement("input");
  newField.type = "file"
  newField.id = "fyle" + nfyles;
  newListElement.appendChild(newField);
  attachArea.appendChild(newListElement);

  nfyles++;
  nfylesInput.value = nfyles;
}

addAnotherButton.onclick = addAnotherAttachField;
