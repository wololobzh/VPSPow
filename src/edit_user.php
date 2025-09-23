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

// Handle edit user request
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $id = $_POST['id'];
    $nom = $_POST['nom'];
    $prenom = $_POST['prenom'];
    $email = $_POST['email'];

    $userController->updateUser($id, $nom, $prenom, $email, '');
    header('Location: index.php');
    exit;
}

// Fetch user data
$id = $_GET['id'] ?? null;
if ($id) {
    $user = $userService->getUserById($id);
    if (!$user) {
        die("User not found.");
    }
} else {
    die("Invalid user ID.");
}

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Modifier l'utilisateur</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div class="container">
        <h1>Modifier l'utilisateur</h1>
        <form method="POST" action="edit_user.php">
            <input type="hidden" name="id" value="<?= htmlspecialchars($user->getId()) ?>">
            <label for="nom">Nom :</label>
            <input type="text" id="nom" name="nom" value="<?= htmlspecialchars($user->getNom()) ?>" required>

            <label for="prenom">Prénom :</label>
            <input type="text" id="prenom" name="prenom" value="<?= htmlspecialchars($user->getPrenom()) ?>" required>

            <label for="email">Email :</label>
            <input type="email" id="email" name="email" value="<?= htmlspecialchars($user->getEmail()) ?>" required>

            <button type="submit">Enregistrer</button>
        </form>
    </div>
</body>
</html>
