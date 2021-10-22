// JavaScript source code
// HTTP Request Power Automate - Pushes an HTTP request to URL endpoint. Passes student ID as schema parameter
// Was used to trigger from a D365 Ribbon Button. This would trigger a Power Automate flow, with a passed GUID
// Ethan Harriman 2020-11-04

DXC.SendQuote = function (primaryControl) {   
    var flowUrl = [Endpoint URL];
    var input = JSON.stringify({
        "som_studentID": primaryControl.data.entity.getId().replace("{", "").replace("}", "")
    });
    var req = new XMLHttpRequest();
    req.open("POST", flowUrl, true);
    req.setRequestHeader('Content-Type', 'application/json');
    req.send(input);
};
