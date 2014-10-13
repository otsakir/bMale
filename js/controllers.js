angular.module("bMale").controller("NewMessageCtrl", function ChatBoxCtrl($scope) {
	$scope.message = {};
	
	$scope.sendButtonClicked = function (message) {
		console.log("Sending message");
	}
});

