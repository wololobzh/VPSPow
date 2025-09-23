<?php

namespace App\Services;

use App\Models\User;
use PDO;

class UserService
{
    private PDO $db;

    public function __construct(PDO $db)
    {
        $this->db = $db;
    }

    public function createUser(string $nom, string $prenom, string $email, string $motDePasse): bool
    {
        $stmt = $this->db->prepare("INSERT INTO utilisateurs (nom, prenom, email, mot_de_passe) VALUES (:nom, :prenom, :email, :motDePasse)");
        return $stmt->execute(['nom' => $nom, 'prenom' => $prenom, 'email' => $email, 'motDePasse' => $motDePasse]);
    }

    public function getUserById(int $id): ?User
    {
        $stmt = $this->db->prepare("SELECT * FROM utilisateurs WHERE id = :id");
        $stmt->execute(['id' => $id]);
        $data = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($data) {
            return new User($data['id'], $data['nom'], $data['prenom'], $data['email'], $data['mot_de_passe']);
        }

        return null;
    }

    public function updateUser(int $id, string $nom, string $prenom, string $email, string $motDePasse): bool
    {
        $stmt = $this->db->prepare("UPDATE utilisateurs SET nom = :nom, prenom = :prenom, email = :email, mot_de_passe = :motDePasse WHERE id = :id");
        return $stmt->execute(['id' => $id, 'nom' => $nom, 'prenom' => $prenom, 'email' => $email, 'motDePasse' => $motDePasse]);
    }

    public function deleteUser(int $id): bool
    {
        $stmt = $this->db->prepare("DELETE FROM utilisateurs WHERE id = :id");
        return $stmt->execute(['id' => $id]);
    }

    public function getAllUsers(): array
    {
        $stmt = $this->db->query("SELECT * FROM utilisateurs");
        $users = [];

        while ($data = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $users[] = new User($data['id'], $data['nom'], $data['prenom'], $data['email'], $data['mot_de_passe']);
        }

        return $users;
    }
}
