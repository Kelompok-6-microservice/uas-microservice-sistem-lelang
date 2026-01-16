<?php

/** @var \Laravel\Lumen\Routing\Router $router */

/*
|--------------------------------------------------------------------------
| Application Routes
|--------------------------------------------------------------------------
|
| Here is where you can register all of the routes for an application.
| It is a breeze. Simply tell Lumen the URIs it should respond to
| and give it the Closure to call when that URI is requested.
|
*/

$router->get('/', function () use ($router) {
    return $router->app->version();
});

$router->post('/register', 'AuthController@register');
$router->post('/login', 'AuthController@login');

// Endpoint CRUD User tambahan
$router->get('/users', 'AuthController@index');        // Lihat semua user
$router->get('/users/{id}', 'AuthController@show');   // Lihat satu profil
$router->put('/users/{id}', 'AuthController@update'); // Edit profil
$router->delete('/users/{id}', 'AuthController@destroy'); // Hapus akun