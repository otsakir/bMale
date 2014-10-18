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

