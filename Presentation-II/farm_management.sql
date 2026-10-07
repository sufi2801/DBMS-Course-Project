-- MySQL dump 10.13  Distrib 9.7.1, for macos26.4 (arm64)
--
-- Host: localhost    Database: farm_management
-- ------------------------------------------------------
-- Server version	9.7.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ 'f3b62aae-8653-11f1-b96b-d5c14826e407:1-87';

--
-- Table structure for table `Application`
--

DROP TABLE IF EXISTS `Application`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Application` (
  `application_id` int NOT NULL AUTO_INCREMENT,
  `plan_id` int NOT NULL,
  `input_id` int NOT NULL,
  `application_date` date NOT NULL,
  `quantity_used` decimal(10,2) NOT NULL,
  `cost` decimal(10,2) NOT NULL,
  PRIMARY KEY (`application_id`),
  KEY `plan_id` (`plan_id`),
  KEY `input_id` (`input_id`),
  CONSTRAINT `application_ibfk_1` FOREIGN KEY (`plan_id`) REFERENCES `CropPlan` (`plan_id`) ON DELETE CASCADE,
  CONSTRAINT `application_ibfk_2` FOREIGN KEY (`input_id`) REFERENCES `Input` (`input_id`),
  CONSTRAINT `application_chk_1` CHECK ((`quantity_used` > 0)),
  CONSTRAINT `application_chk_2` CHECK ((`cost` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Application`
--

LOCK TABLES `Application` WRITE;
/*!40000 ALTER TABLE `Application` DISABLE KEYS */;
INSERT INTO `Application` VALUES (1,1,4,'2026-06-10',24.00,4320.00),(2,1,1,'2026-06-25',100.00,2500.00),(3,1,3,'2026-07-15',5.00,2250.00),(4,2,2,'2026-06-20',150.00,4800.00),(5,3,1,'2025-11-20',80.00,2000.00);
/*!40000 ALTER TABLE `Application` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_application_dates` BEFORE INSERT ON `application` FOR EACH ROW BEGIN
    DECLARE p_start DATE; DECLARE p_end DATE;
    SELECT start_date, end_date INTO p_start, p_end FROM CropPlan WHERE plan_id = NEW.plan_id;
    IF NEW.application_date < p_start OR NEW.application_date > p_end THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Application date must fall within the Crop Plan duration';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `Buyer`
--

DROP TABLE IF EXISTS `Buyer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Buyer` (
  `buyer_id` int NOT NULL AUTO_INCREMENT,
  `buyer_name` varchar(100) NOT NULL,
  `contact_number` varchar(15) DEFAULT NULL,
  `location` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`buyer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Buyer`
--

LOCK TABLES `Buyer` WRITE;
/*!40000 ALTER TABLE `Buyer` DISABLE KEYS */;
INSERT INTO `Buyer` VALUES (1,'Telangana Grain Traders','9876543210','Hyderabad'),(2,'Cotton Corp of India','9123456780','Warangal'),(3,'Local Oil Mill','9988776655','Nizamabad');
/*!40000 ALTER TABLE `Buyer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Crop`
--

DROP TABLE IF EXISTS `Crop`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Crop` (
  `crop_id` int NOT NULL AUTO_INCREMENT,
  `crop_name` varchar(50) NOT NULL,
  `category` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`crop_id`),
  UNIQUE KEY `crop_name` (`crop_name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Crop`
--

LOCK TABLES `Crop` WRITE;
/*!40000 ALTER TABLE `Crop` DISABLE KEYS */;
INSERT INTO `Crop` VALUES (1,'Maize','Cereal'),(2,'Cotton','Fibre'),(3,'Groundnut','Oilseed');
/*!40000 ALTER TABLE `Crop` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `CropPlan`
--

DROP TABLE IF EXISTS `CropPlan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `CropPlan` (
  `plan_id` int NOT NULL AUTO_INCREMENT,
  `season_id` int NOT NULL,
  `variety_id` int NOT NULL,
  `planned_area_acres` decimal(8,2) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `expected_yield_kg` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`plan_id`),
  KEY `season_id` (`season_id`),
  KEY `variety_id` (`variety_id`),
  CONSTRAINT `cropplan_ibfk_1` FOREIGN KEY (`season_id`) REFERENCES `Season` (`season_id`) ON DELETE CASCADE,
  CONSTRAINT `cropplan_ibfk_2` FOREIGN KEY (`variety_id`) REFERENCES `Variety` (`variety_id`),
  CONSTRAINT `cropplan_chk_1` CHECK ((`planned_area_acres` > 0)),
  CONSTRAINT `cropplan_chk_2` CHECK ((`expected_yield_kg` >= 0)),
  CONSTRAINT `cropplan_chk_3` CHECK ((`end_date` > `start_date`))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `CropPlan`
--

LOCK TABLES `CropPlan` WRITE;
/*!40000 ALTER TABLE `CropPlan` DISABLE KEYS */;
INSERT INTO `CropPlan` VALUES (1,1,1,12.00,'2026-06-10','2026-09-30',6000.00),(2,2,2,15.50,'2026-06-15','2026-10-25',4500.00),(3,3,3,10.00,'2025-11-10','2026-03-01',3000.00);
/*!40000 ALTER TABLE `CropPlan` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_cropplan_dates` BEFORE INSERT ON `cropplan` FOR EACH ROW BEGIN
    DECLARE s_start DATE; DECLARE s_end DATE;
    SELECT start_date, end_date INTO s_start, s_end FROM Season WHERE season_id = NEW.season_id;
    IF NEW.start_date < s_start OR NEW.end_date > s_end THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'CropPlan dates must fall within the Season dates';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Temporary view structure for view `cropprofitability`
--

DROP TABLE IF EXISTS `cropprofitability`;
/*!50001 DROP VIEW IF EXISTS `cropprofitability`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `cropprofitability` AS SELECT 
 1 AS `plan_id`,
 1 AS `crop_name`,
 1 AS `variety_name`,
 1 AS `total_input_cost`,
 1 AS `total_labour_cost`,
 1 AS `total_sale_revenue`,
 1 AS `net_profit`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `Farm`
--

DROP TABLE IF EXISTS `Farm`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Farm` (
  `farm_id` int NOT NULL AUTO_INCREMENT,
  `farm_name` varchar(100) NOT NULL,
  `owner_name` varchar(100) NOT NULL,
  `location` varchar(150) NOT NULL,
  `total_area_acres` decimal(8,2) NOT NULL,
  PRIMARY KEY (`farm_id`),
  CONSTRAINT `farm_chk_1` CHECK ((`total_area_acres` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Farm`
--

LOCK TABLES `Farm` WRITE;
/*!40000 ALTER TABLE `Farm` DISABLE KEYS */;
INSERT INTO `Farm` VALUES (1,'Green Valley Farm','Ravi Kumar','Nizamabad, Telangana',45.00),(2,'Sunrise Agro','Lakshmi Devi','Warangal, Telangana',30.50);
/*!40000 ALTER TABLE `Farm` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Field`
--

DROP TABLE IF EXISTS `Field`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Field` (
  `field_id` int NOT NULL AUTO_INCREMENT,
  `farm_id` int NOT NULL,
  `field_name` varchar(100) NOT NULL,
  `area_acres` decimal(8,2) NOT NULL,
  `soil_type` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`field_id`),
  KEY `farm_id` (`farm_id`),
  CONSTRAINT `field_ibfk_1` FOREIGN KEY (`farm_id`) REFERENCES `Farm` (`farm_id`) ON DELETE CASCADE,
  CONSTRAINT `field_chk_1` CHECK ((`area_acres` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Field`
--

LOCK TABLES `Field` WRITE;
/*!40000 ALTER TABLE `Field` DISABLE KEYS */;
INSERT INTO `Field` VALUES (1,1,'North Block',12.00,'Black Cotton'),(2,1,'South Block',15.50,'Red Loamy'),(3,2,'Riverside Plot',10.00,'Alluvial');
/*!40000 ALTER TABLE `Field` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Harvest`
--

DROP TABLE IF EXISTS `Harvest`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Harvest` (
  `harvest_id` int NOT NULL AUTO_INCREMENT,
  `plan_id` int NOT NULL,
  `harvest_date` date NOT NULL,
  `quantity_kg` decimal(10,2) NOT NULL,
  `quality_grade` varchar(10) DEFAULT NULL,
  `storage_location` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`harvest_id`),
  KEY `plan_id` (`plan_id`),
  CONSTRAINT `harvest_ibfk_1` FOREIGN KEY (`plan_id`) REFERENCES `CropPlan` (`plan_id`) ON DELETE CASCADE,
  CONSTRAINT `harvest_chk_1` CHECK ((`quantity_kg` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Harvest`
--

LOCK TABLES `Harvest` WRITE;
/*!40000 ALTER TABLE `Harvest` DISABLE KEYS */;
INSERT INTO `Harvest` VALUES (1,1,'2026-09-28',6200.00,'A','Warehouse 1'),(2,2,'2026-10-22',4300.00,'B','Warehouse 2'),(3,3,'2026-02-28',2850.00,'A','Warehouse 1');
/*!40000 ALTER TABLE `Harvest` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Input`
--

DROP TABLE IF EXISTS `Input`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Input` (
  `input_id` int NOT NULL AUTO_INCREMENT,
  `input_name` varchar(100) NOT NULL,
  `input_type` varchar(50) NOT NULL,
  `unit` varchar(20) NOT NULL,
  `unit_cost` decimal(10,2) NOT NULL,
  PRIMARY KEY (`input_id`),
  CONSTRAINT `input_chk_1` CHECK ((`unit_cost` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Input`
--

LOCK TABLES `Input` WRITE;
/*!40000 ALTER TABLE `Input` DISABLE KEYS */;
INSERT INTO `Input` VALUES (1,'Urea','Fertilizer','kg',25.00),(2,'DAP','Fertilizer','kg',32.00),(3,'Imidacloprid','Pesticide','litre',450.00),(4,'Maize Seed','Seed','kg',180.00);
/*!40000 ALTER TABLE `Input` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `IrrigationEvent`
--

DROP TABLE IF EXISTS `IrrigationEvent`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `IrrigationEvent` (
  `irrigation_id` int NOT NULL AUTO_INCREMENT,
  `plan_id` int NOT NULL,
  `irrigation_date` date NOT NULL,
  `duration_hours` decimal(4,1) NOT NULL,
  `water_volume_litres` decimal(10,2) DEFAULT NULL,
  `method` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`irrigation_id`),
  KEY `plan_id` (`plan_id`),
  CONSTRAINT `irrigationevent_ibfk_1` FOREIGN KEY (`plan_id`) REFERENCES `CropPlan` (`plan_id`) ON DELETE CASCADE,
  CONSTRAINT `irrigationevent_chk_1` CHECK ((`duration_hours` > 0)),
  CONSTRAINT `irrigationevent_chk_2` CHECK ((`water_volume_litres` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `IrrigationEvent`
--

LOCK TABLES `IrrigationEvent` WRITE;
/*!40000 ALTER TABLE `IrrigationEvent` DISABLE KEYS */;
INSERT INTO `IrrigationEvent` VALUES (1,1,'2026-06-12',3.0,15000.00,'Sprinkler'),(2,1,'2026-07-10',2.5,12000.00,'Sprinkler'),(3,2,'2026-06-18',4.0,20000.00,'Drip'),(4,3,'2025-11-25',3.5,16000.00,'Flood');
/*!40000 ALTER TABLE `IrrigationEvent` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `LabourActivity`
--

DROP TABLE IF EXISTS `LabourActivity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `LabourActivity` (
  `labour_id` int NOT NULL AUTO_INCREMENT,
  `plan_id` int NOT NULL,
  `activity_date` date NOT NULL,
  `task_description` varchar(100) NOT NULL,
  `worker_count` int NOT NULL,
  `hours_worked` decimal(5,1) NOT NULL,
  `wage_per_hour` decimal(8,2) NOT NULL,
  PRIMARY KEY (`labour_id`),
  KEY `plan_id` (`plan_id`),
  CONSTRAINT `labouractivity_ibfk_1` FOREIGN KEY (`plan_id`) REFERENCES `CropPlan` (`plan_id`) ON DELETE CASCADE,
  CONSTRAINT `labouractivity_chk_1` CHECK ((`worker_count` > 0)),
  CONSTRAINT `labouractivity_chk_2` CHECK ((`hours_worked` > 0)),
  CONSTRAINT `labouractivity_chk_3` CHECK ((`wage_per_hour` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `LabourActivity`
--

LOCK TABLES `LabourActivity` WRITE;
/*!40000 ALTER TABLE `LabourActivity` DISABLE KEYS */;
INSERT INTO `LabourActivity` VALUES (1,1,'2026-06-10','Sowing',5,6.0,60.00),(2,1,'2026-08-20','Weeding',4,5.0,55.00),(3,2,'2026-06-15','Sowing',6,7.0,65.00),(4,3,'2025-11-10','Sowing',4,6.0,55.00);
/*!40000 ALTER TABLE `LabourActivity` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Sale`
--

DROP TABLE IF EXISTS `Sale`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Sale` (
  `sale_id` int NOT NULL AUTO_INCREMENT,
  `harvest_id` int NOT NULL,
  `buyer_id` int NOT NULL,
  `sale_date` date NOT NULL,
  `quantity_sold_kg` decimal(10,2) NOT NULL,
  `price_per_kg` decimal(8,2) NOT NULL,
  `total_amount` decimal(12,2) GENERATED ALWAYS AS ((`quantity_sold_kg` * `price_per_kg`)) STORED,
  PRIMARY KEY (`sale_id`),
  KEY `harvest_id` (`harvest_id`),
  KEY `buyer_id` (`buyer_id`),
  CONSTRAINT `sale_ibfk_1` FOREIGN KEY (`harvest_id`) REFERENCES `Harvest` (`harvest_id`) ON DELETE CASCADE,
  CONSTRAINT `sale_ibfk_2` FOREIGN KEY (`buyer_id`) REFERENCES `Buyer` (`buyer_id`),
  CONSTRAINT `sale_chk_1` CHECK ((`quantity_sold_kg` > 0)),
  CONSTRAINT `sale_chk_2` CHECK ((`price_per_kg` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Sale`
--

LOCK TABLES `Sale` WRITE;
/*!40000 ALTER TABLE `Sale` DISABLE KEYS */;
INSERT INTO `Sale` (`sale_id`, `harvest_id`, `buyer_id`, `sale_date`, `quantity_sold_kg`, `price_per_kg`) VALUES (1,1,1,'2026-10-02',6000.00,18.50),(2,2,2,'2026-10-25',4300.00,65.00),(3,3,3,'2026-03-05',2800.00,55.00);
/*!40000 ALTER TABLE `Sale` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_sale_within_stock` BEFORE INSERT ON `sale` FOR EACH ROW BEGIN
    DECLARE harvested DECIMAL(10,2); DECLARE already_sold DECIMAL(10,2);
    SELECT quantity_kg INTO harvested FROM Harvest WHERE harvest_id = NEW.harvest_id;
    SELECT IFNULL(SUM(quantity_sold_kg),0) INTO already_sold FROM Sale WHERE harvest_id = NEW.harvest_id;
    IF (already_sold + NEW.quantity_sold_kg) > harvested THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sale quantity exceeds available harvested stock';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `Season`
--

DROP TABLE IF EXISTS `Season`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Season` (
  `season_id` int NOT NULL AUTO_INCREMENT,
  `field_id` int NOT NULL,
  `season_name` varchar(50) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  PRIMARY KEY (`season_id`),
  KEY `field_id` (`field_id`),
  CONSTRAINT `season_ibfk_1` FOREIGN KEY (`field_id`) REFERENCES `Field` (`field_id`) ON DELETE CASCADE,
  CONSTRAINT `season_chk_1` CHECK ((`end_date` > `start_date`))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Season`
--

LOCK TABLES `Season` WRITE;
/*!40000 ALTER TABLE `Season` DISABLE KEYS */;
INSERT INTO `Season` VALUES (1,1,'Kharif 2026','2026-06-01','2026-10-31'),(2,2,'Kharif 2026','2026-06-01','2026-10-31'),(3,3,'Rabi 2025-26','2025-11-01','2026-03-31');
/*!40000 ALTER TABLE `Season` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `SoilTest`
--

DROP TABLE IF EXISTS `SoilTest`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `SoilTest` (
  `soil_test_id` int NOT NULL AUTO_INCREMENT,
  `field_id` int NOT NULL,
  `test_date` date NOT NULL,
  `ph_level` decimal(3,1) DEFAULT NULL,
  `nitrogen_level` varchar(20) DEFAULT NULL,
  `phosphorus_level` varchar(20) DEFAULT NULL,
  `potassium_level` varchar(20) DEFAULT NULL,
  `recommendation` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`soil_test_id`),
  KEY `field_id` (`field_id`),
  CONSTRAINT `soiltest_ibfk_1` FOREIGN KEY (`field_id`) REFERENCES `Field` (`field_id`) ON DELETE CASCADE,
  CONSTRAINT `soiltest_chk_1` CHECK ((`ph_level` between 0 and 14))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `SoilTest`
--

LOCK TABLES `SoilTest` WRITE;
/*!40000 ALTER TABLE `SoilTest` DISABLE KEYS */;
INSERT INTO `SoilTest` VALUES (1,1,'2026-05-15',6.8,'Medium','Low','High','Apply phosphorus-rich fertilizer before sowing'),(2,2,'2026-05-16',7.2,'High','Medium','Medium','Standard NPK schedule sufficient'),(3,3,'2025-10-20',6.5,'Low','Low','Medium','Apply nitrogen booster at sowing');
/*!40000 ALTER TABLE `SoilTest` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Variety`
--

DROP TABLE IF EXISTS `Variety`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Variety` (
  `variety_id` int NOT NULL AUTO_INCREMENT,
  `crop_id` int NOT NULL,
  `variety_name` varchar(50) NOT NULL,
  `maturity_days` int NOT NULL,
  PRIMARY KEY (`variety_id`),
  UNIQUE KEY `crop_id` (`crop_id`,`variety_name`),
  CONSTRAINT `variety_ibfk_1` FOREIGN KEY (`crop_id`) REFERENCES `Crop` (`crop_id`) ON DELETE CASCADE,
  CONSTRAINT `variety_chk_1` CHECK ((`maturity_days` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Variety`
--

LOCK TABLES `Variety` WRITE;
/*!40000 ALTER TABLE `Variety` DISABLE KEYS */;
INSERT INTO `Variety` VALUES (1,1,'DHM-117',110),(2,2,'Bt Cotton RCH-2',160),(3,3,'TAG-24',100);
/*!40000 ALTER TABLE `Variety` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'farm_management'
--

--
-- Final view structure for view `cropprofitability`
--

/*!50001 DROP VIEW IF EXISTS `cropprofitability`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `cropprofitability` AS select `cp`.`plan_id` AS `plan_id`,`c`.`crop_name` AS `crop_name`,`v`.`variety_name` AS `variety_name`,coalesce(`input_cost`.`total`,0) AS `total_input_cost`,coalesce(`labour_cost`.`total`,0) AS `total_labour_cost`,coalesce(`sale_rev`.`total`,0) AS `total_sale_revenue`,((coalesce(`sale_rev`.`total`,0) - coalesce(`input_cost`.`total`,0)) - coalesce(`labour_cost`.`total`,0)) AS `net_profit` from (((((`cropplan` `cp` join `variety` `v` on((`cp`.`variety_id` = `v`.`variety_id`))) join `crop` `c` on((`v`.`crop_id` = `c`.`crop_id`))) left join (select `application`.`plan_id` AS `plan_id`,sum(`application`.`cost`) AS `total` from `application` group by `application`.`plan_id`) `input_cost` on((`input_cost`.`plan_id` = `cp`.`plan_id`))) left join (select `labouractivity`.`plan_id` AS `plan_id`,sum(((`labouractivity`.`worker_count` * `labouractivity`.`hours_worked`) * `labouractivity`.`wage_per_hour`)) AS `total` from `labouractivity` group by `labouractivity`.`plan_id`) `labour_cost` on((`labour_cost`.`plan_id` = `cp`.`plan_id`))) left join (select `h`.`plan_id` AS `plan_id`,sum((`sl`.`quantity_sold_kg` * `sl`.`price_per_kg`)) AS `total` from (`harvest` `h` join `sale` `sl` on((`sl`.`harvest_id` = `h`.`harvest_id`))) group by `h`.`plan_id`) `sale_rev` on((`sale_rev`.`plan_id` = `cp`.`plan_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-07 10:08:04
