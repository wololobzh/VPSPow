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

// Handle form submission for adding a user
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['add_user'])) {
    $nom = $_POST['nom'];
    $prenom = $_POST['prenom'];
    $email = $_POST['email'];
    $motDePasse = $_POST['mot_de_passe'];

    if ($userController->createUser($nom, $prenom, $email, $motDePasse)) {
        header('Location: index.php');
        exit;
    } else {
        $error = "Failed to add user.";
    }
}

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

        <h2>Ajouter un utilisateur</h2>
        <?php if (isset($error)): ?>
            <p style="color: red;"><?= htmlspecialchars($error) ?></p>
        <?php endif; ?>
        <form method="POST" action="index.php">
            <label for="nom">Nom :</label>
            <input type="text" id="nom" name="nom" required>

            <label for="prenom">Prénom :</label>
            <input type="text" id="prenom" name="prenom" required>

            <label for="email">Email :</label>
            <input type="email" id="email" name="email" required>

            <label for="mot_de_passe">Mot de passe :</label>
            <input type="password" id="mot_de_passe" name="mot_de_passe" required>

            <button type="submit" name="add_user">Ajouter</button>
        </form>
    </div>
</body>
</html>
