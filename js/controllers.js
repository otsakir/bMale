angular.module("ChitChat").controller("ChatBoxCtrl", function ChatBoxCtrl($scope) {
	$scope.lines = ["testline"];

	function sendButtonClicked(message) {
		// do some actual sending here
		$scope.lines.push(message);
	}
	$scope.sendButtonClicked = sendButtonClicked;
});

