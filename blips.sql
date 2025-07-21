CREATE TABLE IF NOT EXISTS `blips` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `sprite` int(11) NOT NULL,
  `color` int(11) NOT NULL,
  `scale` float NOT NULL DEFAULT '1.0',
  `x` float NOT NULL,
  `y` float NOT NULL,
  `z` float NOT NULL,
  `shortRange` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;