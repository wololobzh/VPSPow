CREATE TABLE utilisateurs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(50) NOT NULL,
    prenom VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    mot_de_passe VARCHAR(255) NOT NULL
);

INSERT INTO utilisateurs (nom, prenom, email, mot_de_passe) VALUES
('Dupont', 'Alice', 'alice.dupont@example.com', 'motdepasse1'),
('Martin', 'Bob', 'bob.martin@example.com', 'motdepasse2'),
('Petit', 'Claire', 'claire.petit@example.com', 'motdepasse3'),
('Leroy', 'David', 'david.leroy@example.com', 'motdepasse4'),
('Blanc', 'Emma', 'emma.blanc@example.com', 'motdepasse5');