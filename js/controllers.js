angular.module("bMale").controller("composeCtrl", function composeCtrl($scope,$http) {
	$scope.message = {to:'', message:{subject:'', body:''}};
	
	$scope.sendButtonClicked = function (message) {
		console.log("Sending message");
		$http({url:"bmale.lua/send", method:"POST", data:message})
		.success(function (data) {
			if (data.status == 'ok') {
				console.log("created document " + data.payload.id);
			} else {
				console.log("error sending message")
			}
		})
		.error(function () {
			console.log("error sending");
		});
		
	}
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

