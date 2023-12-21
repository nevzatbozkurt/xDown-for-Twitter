var open = XMLHttpRequest.prototype.open;
XMLHttpRequest.prototype.open = function() {
    this.addEventListener("load", function() {
        var message = {
            "status": this.status,
            "responseURL": this.responseURL,
            "responseText": this.responseText, // İstek sonucunda alınan metin tabanlı veri
            "responseXML": this.responseXML // İstek sonucunda alınan XML veri
        };
        webkit.messageHandlers.handler.postMessage(message);
    });
    open.apply(this, arguments);
};
