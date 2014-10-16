angular.module("bMale").controller("composeCtrl", function composeCtrl($scope,$http) {
	$scope.message = {};
	
	$scope.sendButtonClicked = function (message) {
		console.log("Sending message");
		$http({url:"bmale.lua/send", method:"POST", data:message})
		.success(function () {
			console.log('send ok');
		})
		.error(function () {
			console.log("error sending");
		});
		
	}
});

