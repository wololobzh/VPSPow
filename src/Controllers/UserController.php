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

    public function createUser(string $nom, string $prenom, string $email, string $motDePasse): bool
    {
        return $this->userService->createUser($nom, $prenom, $email, $motDePasse);
    }

    public function getUser(int $id): ?array
    {
        $user = $this->userService->getUserById($id);

        if ($user) {
            return [
                'id' => $user->getId(),
                'nom' => $user->getNom(),
                'prenom' => $user->getPrenom(),
                'email' => $user->getEmail()
            ];
        }

        return null;
    }

    public function updateUser(int $id, string $nom, string $prenom, string $email, string $motDePasse): bool
    {
        return $this->userService->updateUser($id, $nom, $prenom, $email, $motDePasse);
    }

    public function deleteUser(int $id): bool
    {
        return $this->userService->deleteUser($id);
    }

    public function listUsers(): array
    {
        $users = $this->userService->getAllUsers();
        return array_map(function ($user) {
            return [
                'id' => $user->getId(),
                'nom' => $user->getNom(),
                'prenom' => $user->getPrenom(),
                'email' => $user->getEmail()
            ];
        }, $users);
    }
}
