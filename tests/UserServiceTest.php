<?php

use PHPUnit\Framework\TestCase;
use App\Services\UserService;
use App\Models\User;

class UserServiceTest extends TestCase
{
    private $pdo;
    private $userService;

    protected function setUp(): void
    {
        $this->pdo = new PDO('sqlite::memory:');
        $this->pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

        $this->pdo->exec("CREATE TABLE utilisateurs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nom TEXT NOT NULL,
            prenom TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            mot_de_passe TEXT NOT NULL
        )");

        $this->userService = new UserService($this->pdo);
    }

    /**
     * @covers \App\Services\UserService::createUser
     */
    public function testCreateUser(): void
    {
        $result = $this->userService->createUser('John', 'Doe', 'john.doe@example.com', 'password123');
        $this->assertTrue($result);

        $stmt = $this->pdo->query("SELECT * FROM utilisateurs WHERE email = 'john.doe@example.com'");
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        $this->assertNotEmpty($user);
        $this->assertEquals('John', $user['nom']);
        $this->assertEquals('Doe', $user['prenom']);
        $this->assertEquals('john.doe@example.com', $user['email']);
    }

    /**
     * @covers \App\Services\UserService::getUserById
     */
    public function testGetUserById(): void
    {
        $this->pdo->exec("INSERT INTO utilisateurs (nom, prenom, email, mot_de_passe) VALUES ('Jane', 'Doe', 'jane.doe@example.com', 'password123')");
        $id = $this->pdo->lastInsertId();

        $user = $this->userService->getUserById((int) $id);

        $this->assertInstanceOf(User::class, $user);
        $this->assertEquals('Jane', $user->getNom());
        $this->assertEquals('Doe', $user->getPrenom());
        $this->assertEquals('jane.doe@example.com', $user->getEmail());
    }

    /**
     * @covers \App\Services\UserService::updateUser
     */
    public function testUpdateUser(): void
    {
        $this->pdo->exec("INSERT INTO utilisateurs (nom, prenom, email, mot_de_passe) VALUES ('Alice', 'Smith', 'alice.smith@example.com', 'password123')");
        $id = $this->pdo->lastInsertId();

        $result = $this->userService->updateUser((int) $id, 'Alice', 'Johnson', 'alice.johnson@example.com', 'password123');
        $this->assertTrue($result);

        $stmt = $this->pdo->query("SELECT * FROM utilisateurs WHERE id = $id");
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        $this->assertEquals('Alice', $user['nom']);
        $this->assertEquals('Johnson', $user['prenom']);
        $this->assertEquals('alice.johnson@example.com', $user['email']);
    }

    /**
     * @covers \App\Services\UserService::deleteUser
     */
    public function testDeleteUser(): void
    {
        $this->pdo->exec("INSERT INTO utilisateurs (nom, prenom, email, mot_de_passe) VALUES ('Bob', 'Brown', 'bob.brown@example.com', 'password123')");
        $id = $this->pdo->lastInsertId();

        $result = $this->userService->deleteUser((int) $id);
        $this->assertTrue($result);

        $stmt = $this->pdo->query("SELECT * FROM utilisateurs WHERE id = $id");
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        $this->assertEmpty($user);
    }

    /**
     * @covers \App\Services\UserService::getAllUsers
     */
    public function testGetAllUsers(): void
    {
        $this->pdo->exec("INSERT INTO utilisateurs (nom, prenom, email, mot_de_passe) VALUES
            ('Charlie', 'White', 'charlie.white@example.com', 'password123'),
            ('Diana', 'Green', 'diana.green@example.com', 'password123')");

        $users = $this->userService->getAllUsers();

        $this->assertCount(2, $users);
        $this->assertEquals('Charlie', $users[0]->getNom());
        $this->assertEquals('Diana', $users[1]->getNom());
    }
}
