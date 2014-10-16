angular.module("bMale",['ngRoute']);

angular.module("bMale").config([ '$routeProvider',  function($routeProvider) {
	
	$routeProvider.when('/compose', {
		templateUrl : 'templates/compose.html',
		controller : 'composeCtrl'
	})
	
}]);
