-- Create VIEW with structures
DROP VIEW IF EXISTS "View_Structures_All";
CREATE VIEW "View_Structures_All" AS 
SELECT pb.name AS 'Player/Clan', COUNT(bi.instance_id) AS 'Pieces', SUBSTR("ABCDEFGHIJKLMNOPQRSTUVWXYZ",(CASE WHEN (x<0) THEN CAST(ROUND(((339849-ABS(ap.x))/(815610/26))) AS INT) ELSE CAST(ROUND((339849+ap.x)/(815610/26)) AS INT) END),1) || (CASE WHEN (ap.y<0) THEN CAST(ROUND((450438-ABS(ap.y))/(807297/26)) AS INT) ELSE CAST(ROUND((450438+ap.y)/(807297/26)) AS INT) END) AS 'Field', 'TeleportPlayer ' || ap.x || ' ' || ap.y || ' ' || ap.z AS 'Location'
FROM building_instances bi 
INNER JOIN buildings b 
ON b.object_id = bi.object_id 
INNER JOIN actor_position ap 
ON ap.id = bi.object_id 
INNER JOIN ( SELECT guildid, name FROM guilds UNION SELECT id, char_name FROM characters ) pb 
ON b.owner_id = pb.guildid 
GROUP BY bi.object_id
ORDER BY pb.name ASC, COUNT(bi.instance_id) DESC;

-- Create VIEW with abandoned structures (all clanmember >=7 days offline)
DROP VIEW IF EXISTS "View_Structures_Abandoned";
CREATE VIEW "View_Structures_Abandoned" AS 
SELECT pb.name AS 'Player/Clan', COUNT(bi.instance_id) AS 'Pieces', SUBSTR("ABCDEFGHIJKLMNOPQRSTUVWXYZ",(CASE WHEN (ap.x<0) THEN CAST(ROUND(((339849-ABS(ap.x))/(815610/26))) AS INT) ELSE CAST(ROUND((339849+ap.x)/(815610/26)) AS INT) END),1) || (CASE WHEN (ap.y<0) THEN CAST(ROUND((450438-ABS(ap.y))/(807297/26)) AS INT) ELSE CAST(ROUND((450438+ap.y)/(807297/26)) AS INT) END) AS 'Field', 'TeleportPlayer ' || ap.x || ' ' || ap.y || ' ' || ap.z AS 'Location' 
FROM buildings b 
INNER JOIN building_instances bi 
ON bi.object_id = b.object_id 
INNER JOIN actor_position ap 
ON ap.id = bi.object_id 
INNER JOIN ( SELECT guildid, name FROM guilds UNION SELECT id, char_name FROM characters ) pb 
ON b.owner_id = pb.guildid 
WHERE b.owner_id 
IN ( SELECT guildid FROM guilds WHERE guildid NOT IN (SELECT DISTINCT guild FROM characters WHERE lastTimeOnline > strftime('%s', 'now', '-7 days') AND guild IS NOT NULL) UNION SELECT id FROM characters WHERE lastTimeOnline < strftime('%s', 'now', '-7 days') AND guild IS NULL ) 
GROUP BY b.object_id
ORDER BY pb.name ASC;

-- Create VIEW with no owner structures
DROP VIEW IF EXISTS "View_Structures_No_Owner";
CREATE VIEW "View_Structures_No_Owner" AS 
SELECT b.owner_id AS 'OldOwnerID', SUBSTR("ABCDEFGHIJKLMNOPQRSTUVWXYZ",(CASE WHEN (ap.x<0) THEN CAST(ROUND(((339849-ABS(ap.x))/(815610/26))) AS INT) ELSE CAST(ROUND((339849+ap.x)/(815610/26)) AS INT) END),1) || (CASE WHEN (ap.y<0) THEN CAST(ROUND((450438-ABS(ap.y))/(807297/26)) AS INT) ELSE CAST(ROUND((450438+ap.y)/(807297/26)) AS INT) END) AS 'Field', 'TeleportPlayer ' || ap.x || ' ' || ap.y || ' ' || ap.z AS 'Location' 
FROM actor_position ap 
INNER JOIN buildings b 
ON b.object_id = ap.id 
WHERE b.object_id IN (SELECT DISTINCT object_id FROM buildings WHERE owner_id NOT IN (SELECT id FROM characters) AND owner_id NOT IN (SELECT guildid FROM guilds));

-- Create VIEW with characters
DROP VIEW IF EXISTS "View_Characters";
CREATE VIEW "View_Characters" AS 
SELECT c.char_name AS 'Player', c.playerId AS 'SteamID', c.level AS 'Level', g.name AS 'Clan', strftime("%Y-%m-%d", datetime(c.lastTimeOnline, "unixepoch")) AS 'Last Login'
FROM characters c 
LEFT OUTER JOIN guilds g 
ON g.guildId = c.guild 
LEFT OUTER JOIN account a 
ON a.user = c.playerId 
WHERE lastTimeOnline != "NULL"
ORDER BY c.char_name ASC;

-- Create VIEW with inactive characters (>=7 days offline)
DROP VIEW IF EXISTS "View_Characters_Inactive";
CREATE VIEW "View_Characters_Inactive" AS 
SELECT c.char_name AS 'Player', c.playerId AS 'SteamID', c.level AS 'Level', g.name AS 'Clan', strftime("%Y-%m-%d", datetime(c.lastTimeOnline, "unixepoch")) AS 'Last Login'
FROM characters c 
LEFT OUTER JOIN guilds g 
ON g.guildId = c.guild 
LEFT OUTER JOIN account a 
ON a.user = c.playerId 
WHERE c.lastTimeOnline < strftime('%s', 'now', '-7 days') 
ORDER BY c.char_name ASC;

-- Create VIEW with wheels
DROP VIEW IF EXISTS "View_Wheel_Count";
CREATE VIEW "View_Wheel_Count" AS 
SELECT pb.name AS 'Player/Clan', COUNT(b.owner_id) AS 'Wheels' 
FROM actor_position ap 
INNER JOIN buildings b 
ON b.object_id = ap.id 
INNER JOIN ( SELECT guildid, name FROM guilds UNION SELECT id, char_name FROM characters ) pb 
ON b.owner_id = pb.guildid 
WHERE ap.class LIKE '%Wheel%' 
GROUP BY b.owner_id 
ORDER BY COUNT(b.owner_id) DESC;

-- Create VIEW with wheel locations
DROP VIEW IF EXISTS "View_Wheel_Locations";
CREATE VIEW "View_Wheel_Locations" AS 
SELECT pb.name AS 'Player/Clan', SUBSTR("ABCDEFGHIJKLMNOPQRSTUVWXYZ",(CASE WHEN (ap.x<0) THEN CAST(ROUND(((339849-ABS(ap.x))/(815610/26))) AS INT) ELSE CAST(ROUND((339849+ap.x)/(815610/26)) AS INT) END),1) || (CASE WHEN (ap.y<0) THEN CAST(ROUND((450438-ABS(ap.y))/(807297/26)) AS INT) ELSE CAST(ROUND((450438+ap.y)/(807297/26)) AS INT) END) AS 'Field', 'TeleportPlayer ' || ap.x || ' ' || ap.y || ' ' || ap.z AS 'Location'
FROM actor_position ap 
INNER JOIN buildings b 
ON b.object_id = ap.id 
INNER JOIN ( SELECT guildid, name FROM guilds UNION SELECT id, char_name FROM characters ) pb 
ON b.owner_id = pb.guildid 
WHERE ap.class LIKE '%Wheel%' 
ORDER BY pb.name ASC;

-- Create VIEW with vaults
DROP VIEW IF EXISTS "View_Vault_Count";
CREATE VIEW "View_Vault_Count" AS 
SELECT pb.name AS 'Player/Clan', COUNT(b.owner_id) AS 'Vaults' 
FROM actor_position ap 
INNER JOIN buildings b 
ON b.object_id = ap.id 
INNER JOIN ( SELECT guildid, name FROM guilds UNION SELECT id, char_name FROM characters ) pb 
ON b.owner_id = pb.guildid 
WHERE ap.class LIKE '%Vault%' 
GROUP BY b.owner_id 
ORDER BY COUNT(b.owner_id) DESC;

-- Create VIEW with vault locations
DROP VIEW IF EXISTS "View_Vault_Locations";
CREATE VIEW "View_Vault_Locations" AS 
SELECT pb.name AS 'Player/Clan', SUBSTR("ABCDEFGHIJKLMNOPQRSTUVWXYZ",(CASE WHEN (ap.x<0) THEN CAST(ROUND(((339849-ABS(ap.x))/(815610/26))) AS INT) ELSE CAST(ROUND((339849+ap.x)/(815610/26)) AS INT) END),1) || (CASE WHEN (ap.y<0) THEN CAST(ROUND((450438-ABS(ap.y))/(807297/26)) AS INT) ELSE CAST(ROUND((450438+ap.y)/(807297/26)) AS INT) END) AS 'Field', 'TeleportPlayer ' || ap.x || ' ' || ap.y || ' ' || ap.z AS 'Location'
FROM actor_position ap 
INNER JOIN buildings b 
ON b.object_id = ap.id 
INNER JOIN ( SELECT guildid, name FROM guilds UNION SELECT id, char_name FROM characters ) pb 
ON b.owner_id = pb.guildid 
WHERE ap.class LIKE '%Vault%' 
ORDER BY pb.name ASC;