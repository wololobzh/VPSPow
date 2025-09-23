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

// Fetch users
$users = $userService->getAllUsers();

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Liste des utilisateurs</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div class="container">
        <h1>Liste des utilisateurs</h1>
        <table class="table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Nom</th>
                    <th>Prénom</th>
                    <th>Email</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($users as $user): ?>
                    <tr>
                        <td><?= htmlspecialchars($user->getId()) ?></td>
                        <td><?= htmlspecialchars($user->getNom()) ?></td>
                        <td><?= htmlspecialchars($user->getPrenom()) ?></td>
                        <td><?= htmlspecialchars($user->getEmail()) ?></td>
                        <td>
                            <a href="edit_user.php?id=<?= htmlspecialchars($user->getId()) ?>" class="btn btn-edit">Modifier</a>
                            <a href="delete_user.php?id=<?= htmlspecialchars($user->getId()) ?>" class="btn btn-delete" onclick="return confirm('Êtes-vous sûr de vouloir supprimer cet utilisateur ?');">Supprimer</a>
                        </td>
                    </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</body>
</html>
