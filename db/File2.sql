-- MySQL dump 10.13  Distrib 8.0.34, for Win64 (x86_64)
--
-- Host: localhost    Database: projectpizza
-- ------------------------------------------------------
-- Server version	8.0.32

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `idCustomer` int NOT NULL AUTO_INCREMENT,
  `clast_name` varchar(45) NOT NULL,
  `cfirst_name` varchar(45) NOT NULL,
  PRIMARY KEY (`idCustomer`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES (1,'Nicusor','Dan'),(2,'Ragnar','Lothbrok'),(3,'Django','Unchained'),(4,'Leonardo','Dicaprio'),(5,'Dead','Pool'),(6,'Carlos','Prates'),(7,'Alex','Bodi'),(8,'Marcus','Piso'),(9,'Ana','Costache'),(10,'Hunter','Morgan');
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employee`
--

DROP TABLE IF EXISTS `employee`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employee` (
  `idEmployee` int NOT NULL AUTO_INCREMENT,
  `last_name` varchar(45) NOT NULL,
  `first_name` varchar(45) NOT NULL,
  `salary` int NOT NULL,
  `start_date` datetime NOT NULL,
  PRIMARY KEY (`idEmployee`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employee`
--

LOCK TABLES `employee` WRITE;
/*!40000 ALTER TABLE `employee` DISABLE KEYS */;
INSERT INTO `employee` VALUES (1,'John','Smith',1000,'2025-09-04 00:00:00'),(2,'George','Becali',1000,'2025-09-04 00:00:00'),(3,'Bryan','Battle',1250,'2025-09-04 00:00:00');
/*!40000 ALTER TABLE `employee` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ingredients`
--

DROP TABLE IF EXISTS `ingredients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ingredients` (
  `idIngredients` int NOT NULL AUTO_INCREMENT,
  `name_ing` varchar(20) NOT NULL,
  `alergen` tinyint NOT NULL DEFAULT '0',
  `vegetarian` tinyint(1) NOT NULL DEFAULT '0',
  `vegan` tinyint NOT NULL DEFAULT '0',
  `unit_cost` decimal(3,2) NOT NULL,
  PRIMARY KEY (`idIngredients`),
  UNIQUE KEY `idIngredients_UNIQUE` (`idIngredients`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ingredients`
--

LOCK TABLES `ingredients` WRITE;
/*!40000 ALTER TABLE `ingredients` DISABLE KEYS */;
/*!40000 ALTER TABLE `ingredients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pizza`
--

DROP TABLE IF EXISTS `pizza`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pizza` (
  `idPizza` int NOT NULL AUTO_INCREMENT,
  `pizza_name` varchar(45) NOT NULL,
  PRIMARY KEY (`idPizza`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pizza`
--

LOCK TABLES `pizza` WRITE;
/*!40000 ALTER TABLE `pizza` DISABLE KEYS */;
/*!40000 ALTER TABLE `pizza` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pizzaing_link`
--

DROP TABLE IF EXISTS `pizzaing_link`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pizzaing_link` (
  `idPizza` int NOT NULL,
  `idIngredients` int NOT NULL,
  `quantity` decimal(3,2) NOT NULL,
  PRIMARY KEY (`idPizza`,`idIngredients`),
  KEY `idIngredients` (`idIngredients`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pizzaing_link`
--

LOCK TABLES `pizzaing_link` WRITE;
/*!40000 ALTER TABLE `pizzaing_link` DISABLE KEYS */;
/*!40000 ALTER TABLE `pizzaing_link` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pricing_policy`
--

DROP TABLE IF EXISTS `pricing_policy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pricing_policy` (
  `idPrice` int NOT NULL AUTO_INCREMENT,
  `margin` decimal(5,2) NOT NULL,
  `vat` decimal(5,2) NOT NULL,
  `from` date NOT NULL,
  `to` date DEFAULT NULL,
  PRIMARY KEY (`idPrice`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pricing_policy`
--

LOCK TABLES `pricing_policy` WRITE;
/*!40000 ALTER TABLE `pricing_policy` DISABLE KEYS */;
INSERT INTO `pricing_policy` VALUES (1,40.00,9.00,'2025-09-04',NULL);
/*!40000 ALTER TABLE `pricing_policy` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-09-04 19:42:21
