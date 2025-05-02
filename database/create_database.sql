DROP DATABASE IF EXISTS `memory_lane`;
CREATE DATABASE `memory_lane`;
USE `memory_lane`;

CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL
);

CREATE TABLE Photos (
    photo_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    photo_url VARCHAR(255) NOT NULL,
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    landmark VARCHAR(255),
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);
CREATE INDEX idx_latlong ON Photos (latitude, longitude);

CREATE TABLE Comments (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    photo_id INT NOT NULL,
    user_id INT NOT NULL,
    comment TEXT NOT NULL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (photo_id) REFERENCES Photos(photo_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);
CREATE INDEX idx_comments_photo_id ON Comments(photo_id);
CREATE INDEX idx_comments_user_id ON Comments(user_id);

CREATE TABLE Tags (
    photo_id INT NOT NULL,
    tagged_user INT NOT NULL,
    PRIMARY KEY (photo_id, tagged_user),
    FOREIGN KEY (photo_id) REFERENCES Photos(photo_id) ON DELETE CASCADE,
    FOREIGN KEY (tagged_user) REFERENCES Users(user_id) ON DELETE CASCADE
);
CREATE INDEX idx_tags_photo_id ON Tags(photo_id);


INSERT INTO Users(username, email, password_hash)
VALUES ('admin', 'admin@gmail.com', '1234');
