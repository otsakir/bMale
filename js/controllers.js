
angular.module("bMale").service("messageService", function ($http, $q) {
	var service = {};
	
	service.getInbox = function() {
		var deferred = $q.defer();
		$http({url:"bmale.lua/inbox", method:"GET"})
		.success(function (data) { 
			console.log("retrieved inbox");
			if (data.status == "ok")
				deferred.resolve(data.payload);
			else
				deferred.reject(data.message);
		})
		.error(function (data,status) {
			console.log("http error while getting inbox")
			deferred.reject();
		});
		return deferred.promise;
	}
	
	service.getSent = function() {
		var deferred = $q.defer();
		$http({url:"bmale.lua/sent", method:"GET"})
		.success(function (data) { 
			console.log("retrieved sent");
			if (data.status == "ok")
				deferred.resolve(data.payload);
			else
				deferred.reject(data.message);
		})
		.error(function (data,status) {
			console.log("http error while getting sent messages")
			deferred.reject();
		});
		return deferred.promise;
	}	
	
	service.getDrafts = function() {
		var deferred = $q.defer();
		$http({url:"bmale.lua/drafts", method:"GET"})
		.success(function (data) { 
			console.log("retrieved drafts");
			if (data.status == "ok")
				deferred.resolve(data.payload);
			else
				deferred.reject(data.message);
		})
		.error(function (data,status) {
			console.log("http error while getting drafts")
			deferred.reject();
		});
		return deferred.promise;
	}
	
	service.getMessage = function(id,revision) {
		var deferred = $q.defer();
		$http({url:"bmale.lua/drafts/"+id, method:"GET"})
		.success(function (data) { 
			console.log("retrieved message");
			if (data.status == "ok")
				deferred.resolve(data.payload);
			else
				deferred.reject(data.message);
		})
		.error(function (data,status) {
			console.log("http error while getting draft")
			deferred.reject();
		});
		return deferred.promise;
	}
	
	service.createDraft = function (message) {
		console.log("Sending message");
		var deferred = $q.defer();
		$http({url:"bmale.lua/drafts", method:"POST", data:message})
		.success(function (data) {
			if (data.status == 'ok') {
				console.log("draft saved")
				deferred.resolve(data.payload);
			} else {
				deferred.reject("application error");
				console.log("error sending message")
			}
		})
		.error(function () {
			console.log("error sending");
			deferred.reject("http error");
		});
		return deferred.promise;
	}
	
	service.sendDraft = function (message) {
		var deferred = $q.defer();
		console.log("IN messageService.sendDraft()");
		deferred.resolve();
		return deferred.promise;
	}
	
	
	service.updateDraft = function(message, id, revision) { 
		console.log("updating draft");
		var deferred = $q.defer();
		$http({url:"bmale.lua/drafts/"+id+"/"+revision+"/save", method:"PUT", data:message})
		.success(function (data) {
			if (data.status == 'ok')
				deferred.resolve(data.payload);
			else
				deferred.reject("application error");
		})
		.error(function () {
			deferred.reject("http error");
		});
		return deferred.promise;
	}
	
	service.removeDraft = function(id,revision) {
		var deferred = $q.defer();
		$http({url:"bmale.lua/drafts/"+id+"/"+revision, method:"DELETE"})
		.success(function (data) {
			if (data.status == 'ok')
				deferred.resolve();
			else
				deferred.reject("application error");
		})
		.error(function () {
			deferred.reject("http error");
		});
		return deferred.promise;		
	}
	
	service.sendMessage = function(id,revision) {
		var deferred = $q.defer();
		$http({url:"bmale.lua/messages/"+id+"/send", method:"PUT"})
		.success(function (data) {
			if (data.status == 'ok')
				deferred.resolve();
			else
				deferred.reject("application error");
		})
		.error(function () {
			deferred.reject("http error");
		});
		return deferred.promise;			
	}
	
	return service;
});

angular.module("bMale").controller("mailboxCtrl", function mailboxCtrl($scope,$state) {
	$scope.state = $state;
});

angular.module("bMale").controller("composeCtrl", function composeCtrl($scope,$http, messageService, $location) {
	$scope.draft = {title: '', body: '', typedDestinations: ''};	
	
	$scope.sendClicked = function (message) {
		messageService.createDraft(message)
		.then(function (response) {
			console.log(response);
			return messageService.sendDraft({});
		})
		.then(function (response){
			console.log("message sent successfully");
			$location.path("#/mailbox");
		});
	}
	
	$scope.saveClicked = function(message) {
		messageService.createDraft(message)
		.then(function (response) {
			$location.path("#/mailbox/inbox");
		});
	}
	
});

angular.module("bMale").controller("viewMessageCtrl", function viewMessageCtrl($scope, message) {
	$scope.message = message;
});



angular.module("bMale").controller("signinCtrl", function signinCtrl($scope,$http) {
	$scope.signinForm = {username:"", password:""};
	
	$scope.submitSigninForm = function (form) {
		$http({url:"bmale.lua/signin", method:"POST", data:form})
		.success(function (data) {
			if (data.status == "ok")
				console.log("authentication successfull");
			else
				console.log("authentication failed");
		})
		.error(function () {
				console.log("HTTP error");
		});
	}
});

angular.module("bMale").controller("draftsCtrl", function draftsCtrl($scope,$http, drafts ) {
	$scope.drafts = drafts;
});

angular.module("bMale").controller("editDraftCtrl", function editDraftCtrl($scope,$http, draft, $location, messageService) {
	$scope.draft = draft;
	
	$scope.saveClicked = function (message, id, revision) {
		messageService.updateDraft(message,id,revision)
		.then(function (response) {
			console.log(response);
			$location.path("#/mailbox/inbox");
		});
	}
	
	$scope.discardClicked = function (id,revision) {
		messageService.removeDraft(id,revision) 
		.then(function (response) {
			console.log("draft "+id+" removed");
			$location.path("#/mailbox/inbox");
		});
	}
	
	$scope.closeDraft = function() {
		$location.path("#/mailbox/inbox");
	}
	
	$scope.sendMessage = function(id, revision) {
		messageService.sendMessage(id,revision)
		.then(function (response) {
				console.log("message sent");
				$location.path("#/mailbox/inbox");
		});
	}
});

angular.module("bMale").controller("inboxCtrl", function inboxCtrl($scope,inboxMessages) {
	$scope.inboxMessages = inboxMessages;
});

angular.module("bMale").controller("sentCtrl", function inboxCtrl($scope,sentMessages) {
	$scope.sentMessages = sentMessages;
});

angular.module("bMale").controller("desktopCtrl", function desktopCtrl($scope,$http) {
	$scope.signOutClicked = function () {
		$http({url:"bmale.lua/signout", method:"GET"})
		.success(function (data) {
			console.log("signed out");
		})
		.error(function () {
			console.log("error signing out");
		});
	}
});

angular.module("bMale").controller("topLevelCtrl", function toplLevelCtrl($scope, $cookies) {
	console.log("in topLevelCtrl");
	$scope.cookies = $cookies;
});




