USE `memory_lane`;
DELIMITER //
CREATE PROCEDURE AddUser(IN p_username VARCHAR(50), IN p_email VARCHAR(100), IN p_password_hash VARCHAR(255))
BEGIN
    INSERT INTO Users (username, email, password_hash)
    VALUES (p_username, p_email, p_password_hash);
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE UpdateUser(IN p_user_id INT, IN p_username VARCHAR(50), IN p_email VARCHAR(100), OUT p_status INT)
BEGIN
	IF EXISTS(SELECT 1 FROM Users WHERE user_id = p_user_id) THEN
		UPDATE Users SET username = p_username, email = p_email WHERE user_id = p_user_id;
        SET p_status = 200;
	ELSE
		SET p_status = 404;
	END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE RemoveUser(IN p_user_id INT, OUT p_status INT)
BEGIN
	IF EXISTS (SELECT 1 FROM Users WHERE user_id = p_user_id) THEN
		DELETE FROM Users WHERE user_id = p_user_id;
        SET p_status = 200;
	ELSE
		SET p_status = 404;
	END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE UploadPhoto(IN p_user_id INT, IN p_photo_url VARCHAR(255), IN p_latitude DECIMAL(9,6), IN p_longitude DECIMAL(9,6))
BEGIN
    INSERT INTO Photos (user_id, photo_url, latitude, longitude, timestamp) VALUES (p_user_id, p_photo_url, p_latitude, p_longitude, NOW());
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE DeletePhoto(IN p_photo_id INT, OUT p_status INT)
BEGIN
	IF EXISTS(SELECT 1 FROM Photos WHERE photo_id = p_photo_id) THEN
		DELETE FROM Photos WHERE photo_id = p_photo_id;
        SET p_status = 200;
	ELSE
		SET p_status = 404;
	END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE AddComment(IN p_photo_id INT, IN p_user_id INT, IN p_comment TEXT)
BEGIN
    INSERT INTO Comments (photo_id, user_id, comment, timestamp) VALUES (p_photo_id, p_user_id, p_comment, NOW());
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE RemoveComment(IN p_comment_id INT, OUT p_status INT)
BEGIN
	IF EXISTS(SELECT 1 FROM Comments WHERE comment_id = p_comment_id) THEN
		DELETE FROM Comments WHERE comment_id = p_comment_id;
        SET p_status = 200;
	ELSE
		SET p_status = 404;
	END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE AddTag(IN p_photo_id INT, IN p_tagged_user INT)
BEGIN
    INSERT INTO Tags (photo_id, tagged_user) VALUES (p_photo_id, p_tagged_user);
END //
DELIMITER ;
DELIMITER //
CREATE PROCEDURE RemoveTag(IN p_photo_id INT, IN p_tagged_user INT, OUT p_status INT)
BEGIN
	IF EXISTS(SELECT 1 FROM Tags WHERE photo_id = p_photo_id AND tagged_user = p_tagged_user) THEN
		DELETE FROM Tags WHERE photo_id = p_photo_id AND tagged_user = p_tagged_user;
        SET p_status = 200;
	ELSE
		SET p_status = 404;
	END IF;
END //
DELIMITER ;

-- Using haversine formula: https://en.wikipedia.org/wiki/Haversine_formula
-- Used to calculate distance from lat and long and filter based on distance
DELIMITER //
CREATE PROCEDURE GetNearbyPhotos(IN p_latitude DECIMAL(9, 6), IN p_longitude DECIMAL(9, 6), IN p_radius_km DECIMAL(9, 2))
BEGIN
	DECLARE haversine DECIMAL(9, 6)
	SELECT photo_id, user_id, photo_url, latitude, longitude, timestamp,
	2 * 6367 * ASIN(SQRT((1 - COS(RADIANS(p_latitude) - RADIANS(latitude)) + COS(p_latitude) * COS(latitude) * (1 - COS(RADIANS(p_longitude) - RADIANS(longitude)))) / 2))
	AS distance_km
	FROM Photos
	HAVING distance_km <= p_radius_km
	ORDER BY distance_km;
END //
DELIMITER ;