angular.module("bMale",['ui.router','ngCookies']);

angular.module("bMale")
.config( function($stateProvider, $urlRouterProvider) {
	
	$urlRouterProvider.otherwise("/mailbox");

	$stateProvider
		.state("desktop", {
			url:"",
			templateUrl:"templates/desktop.html",
			controller:"desktopCtrl"
		})
		.state("signin", {
			url:"/signin",
			templateUrl:"templates/signin.html",
			controller:"signinCtrl"
		})
		.state("desktop.mailbox", {
			url:"/mailbox",
			templateUrl:"templates/mailbox.html",
			controller:"mailboxCtrl"
		})
		.state("desktop.mailbox.compose", {
			url:"/compose",
			templateUrl:"templates/mailbox.compose.html",
			controller:"composeCtrl"
		})
		.state("desktop.mailbox.inbox", {
			url:"/inbox",
			templateUrl:"templates/mailbox.inbox.html"
		})	
		.state("desktop.mailbox.sent", {
			url:"/sent",
			templateUrl:"templates/mailbox.sent.html"
		})
		.state("desktop.mailbox.drafts", {
			url:"/drafts",
			templateUrl:"templates/mailbox.drafts.html"
		});				
});
