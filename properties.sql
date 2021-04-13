SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


CREATE TABLE `properties` (
  `id` int(255) NOT NULL,
  `name` varchar(50) NOT NULL,
  `propertyOwner` varchar(255) NOT NULL,
  `interiorId` int(11) NOT NULL,
  `interiorType` int(11) NOT NULL,
  `location` varchar(255) NOT NULL,
  `forSale` tinyint(1) NOT NULL,
  `salePrice` int(255) NOT NULL,
  `fee` int(255) NOT NULL,
  `inventory` varchar(255) NOT NULL DEFAULT '[]',
  `capacity` int(255) NOT NULL DEFAULT 0,
  `locked` tinyint(1) NOT NULL,
  `previousInt` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

ALTER TABLE `properties`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `properties`
  MODIFY `id` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=151;
COMMIT;


CREATE TABLE `propertiesuserstatus` (
  `id` int(11) NOT NULL,
  `identifier` varchar(255) NOT NULL,
  `insideInterior` tinyint(1) NOT NULL,
  `interiorId` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

ALTER TABLE `propertiesuserstatus`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `propertiesuserstatus`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
COMMIT;
