<?php

require_once __DIR__ . '/Controllers/UserController.php';
require_once __DIR__ . '/Services/UserService.php';
require_once __DIR__ . '/Models/User.php';

use App\Controllers\UserController;
use App\Services\UserService;

// Database connection setup
$dsn = 'mysql:host=db;dbname=monsite;charset=utf8';
$username = 'monsiteuser';
$password = 'exempleUser123';

try {
    $pdo = new PDO($dsn, $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die("Database connection failed: " . $e->getMessage());
}

// Initialize UserService and UserController
$userService = new UserService($pdo);
$userController = new UserController($userService);

// Display the list of users
$userController->listUsers();
