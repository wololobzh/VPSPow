<?php

namespace App\Controllers;

use App\Services\UserService;

class UserController
{
    private UserService $userService;

    public function __construct(UserService $userService)
    {
        $this->userService = $userService;
    }

    public function createUser(string $nom, string $prenom, string $email, string $motDePasse): void
    {
        if ($this->userService->createUser($nom, $prenom, $email, $motDePasse)) {
            echo "User created successfully.";
        } else {
            echo "Failed to create user.";
        }
    }

    public function getUser(int $id): void
    {
        $user = $this->userService->getUserById($id);

        if ($user) {
            echo json_encode([
                'id' => $user->getId(),
                'nom' => $user->getNom(),
                'prenom' => $user->getPrenom(),
                'email' => $user->getEmail()
            ]);
        } else {
            echo "User not found.";
        }
    }

    public function updateUser(int $id, string $nom, string $prenom, string $email, string $motDePasse): void
    {
        if ($this->userService->updateUser($id, $nom, $prenom, $email, $motDePasse)) {
            echo "User updated successfully.";
        } else {
            echo "Failed to update user.";
        }
    }

    public function deleteUser(int $id): void
    {
        if ($this->userService->deleteUser($id)) {
            echo "User deleted successfully.";
        } else {
            echo "Failed to delete user.";
        }
    }

    public function listUsers(): void
    {
        $users = $this->userService->getAllUsers();
        echo json_encode(array_map(function ($user) {
            return [
                'id' => $user->getId(),
                'nom' => $user->getNom(),
                'prenom' => $user->getPrenom(),
                'email' => $user->getEmail()
            ];
        }, $users));
    }
}
