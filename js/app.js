angular.module("bMale",['ui.router']);

angular.module("bMale")
.config( function($stateProvider, $urlRouterProvider) {
	
	$urlRouterProvider.otherwise("/mailbox");

	$stateProvider
		.state("signin", {
			url:"/signin",
			templateUrl:"templates/signin.html",
			controller:"signinCtrl"
		})
		.state("mailbox", {
			url:"/mailbox",
			templateUrl:"templates/mailbox.html",
			controller:"mailboxCtrl"
		})
		.state("mailbox.compose", {
			url:"/compose",
			templateUrl:"templates/mailbox.compose.html",
			controller:"composeCtrl"
		})
		.state("mailbox.inbox", {
			url:"/inbox",
			templateUrl:"templates/mailbox.inbox.html"
		})	
		.state("mailbox.sent", {
			url:"/sent",
			templateUrl:"templates/mailbox.sent.html"
		})
		.state("mailbox.drafts", {
			url:"/drafts",
			templateUrl:"templates/mailbox.drafts.html"
		});				
});
